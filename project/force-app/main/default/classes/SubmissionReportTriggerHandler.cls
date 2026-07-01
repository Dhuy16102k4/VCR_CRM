/**
 * @description Handler for Submission_Report__c trigger. Enforces One Trigger Per Object pattern.
 * Performs bulkified operations such as rolling up active BCC counts to Opportunity,
 * and enforces data integrity rules for the BCC Multi-Level Approval Process.
 *
 * Related Spec: docs/07_automation/05_bcc_approval_process_spec.md
 */
public class SubmissionReportTriggerHandler {

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 1: ROLLUP — Active BCC Count to Opportunity
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Calculates the number of Active Submission Reports and updates the parent Opportunity.
     * "Active" is defined as Status__c != 'Rejected'.
     * Called from: after insert, after update, after delete, after undelete.
     *
     * @param newList List of new/updated Submission Reports (null on delete)
     * @param oldMap  Map of old Submission Reports before update (null on insert)
     */
    public static void rollupActiveBccToOpportunity(
        List<Submission_Report__c> newList,
        Map<Id, Submission_Report__c> oldMap
    ) {
        Set<Id> oppIds = new Set<Id>();

        // 1. Gather all affected Opportunity Ids
        if (newList != null) {
            for (Submission_Report__c bcc : newList) {
                if (bcc.Opportunity__c != null) {
                    if (oldMap == null) {
                        // Insert
                        oppIds.add(bcc.Opportunity__c);
                    } else {
                        // Update — only recalculate if Opportunity or Status changed
                        Submission_Report__c oldBcc = oldMap.get(bcc.Id);
                        if (bcc.Opportunity__c != oldBcc.Opportunity__c || bcc.Status__c != oldBcc.Status__c) {
                            oppIds.add(bcc.Opportunity__c);
                            if (oldBcc.Opportunity__c != null && bcc.Opportunity__c != oldBcc.Opportunity__c) {
                                oppIds.add(oldBcc.Opportunity__c); // Recalculate old opp if reparented
                            }
                        }
                    }
                } else if (oldMap != null && oldMap.get(bcc.Id).Opportunity__c != null) {
                    // Reparented to null
                    oppIds.add(oldMap.get(bcc.Id).Opportunity__c);
                }
            }
        }

        if (oldMap != null && newList == null) {
            // Delete
            for (Submission_Report__c bcc : oldMap.values()) {
                if (bcc.Opportunity__c != null) {
                    oppIds.add(bcc.Opportunity__c);
                }
            }
        }

        // 2. Perform ONE bulk SOQL query to aggregate values
        if (!oppIds.isEmpty()) {
            Map<Id, Integer> oppBccCountMap = new Map<Id, Integer>();

            for (Id oppId : oppIds) {
                oppBccCountMap.put(oppId, 0); // Initialize with 0
            }

            for (AggregateResult ar : [
                SELECT Opportunity__c, COUNT(Id) totalBcc
                FROM Submission_Report__c
                WHERE Opportunity__c IN :oppIds
                AND Status__c != 'Rejected'
                GROUP BY Opportunity__c
            ]) {
                oppBccCountMap.put((Id) ar.get('Opportunity__c'), (Integer) ar.get('totalBcc'));
            }

            // 3. Perform ONE bulk DML update
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Id oppId : oppBccCountMap.keySet()) {
                oppsToUpdate.add(new Opportunity(
                    Id = oppId,
                    Active_BCC_Count__c = oppBccCountMap.get(oppId)
                ));
            }

            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 2: ENTRY VALIDATION — Enforce Approval Entry Criteria
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Validates that a BCC record meets the entry criteria before creation
     * or before its Status changes away from Draft.
     *
     * BUSINESS RULE (mirrors Approval Process Entry Criteria in spec §3):
     *   - Opportunity__c must NOT be null
     *   - Account__c must NOT be null
     *
     * This is the Apex safety-net addressing Risks R1 & R2 from the BCC Approval Spec.
     * It prevents data integrity issues BEFORE the Approval Process even runs.
     *
     * Called from: before insert, before update.
     *
     * @param newList List of new/updated Submission Reports (Trigger.new)
     * @param oldMap  Map of old records before update (null on insert)
     */
    public static void validateEntryBeforeSubmission(
        List<Submission_Report__c> newList,
        Map<Id, Submission_Report__c> oldMap
    ) {
        for (Submission_Report__c bcc : newList) {
            Boolean isInsert = (oldMap == null);
            Boolean statusChangedFromDraft = !isInsert
                && oldMap.get(bcc.Id).Status__c == 'Draft'
                && bcc.Status__c != 'Draft';

            // Only validate on new BCC creation OR when Status changes away from Draft
            if (!isInsert && !statusChangedFromDraft) {
                continue;
            }

            if (bcc.Opportunity__c == null) {
                bcc.addError(
                    'BCC phải được gắn với một Opportunity trước khi trình duyệt. Vui lòng chọn Opportunity.'
                );
            }
            if (bcc.Account__c == null) {
                bcc.addError(
                    'BCC phải được gắn với một Khách Thuê (Account) trước khi trình duyệt. Vui lòng chọn Account.'
                );
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 3: LOCK GUARD — Prevent Edit While In Review / Approved
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Prevents non-admin users from editing protected fields on a BCC
     * while it is in 'In Review' or 'Approved' status.
     *
     * BUSINESS RULE (spec §4 — Record Lock):
     *   The Standard Approval Process Record Lock handles UI-level blocking.
     *   This Apex guard is the programmatic safety-net for API/integration access.
     *
     * Protected fields: Opportunity__c, Account__c, Total_Submission_Report_Amount__c, Status__c
     * Bypass: System Administrators are fully exempt.
     *
     * Called from: before update.
     *
     * @param newList List of updated Submission Reports (Trigger.new)
     * @param oldMap  Map of old records before update (Trigger.oldMap)
     */
    public static void preventEditWhileInReview(
        List<Submission_Report__c> newList,
        Map<Id, Submission_Report__c> oldMap
    ) {
        // System Admins bypass this restriction entirely
        if (isCurrentUserAdmin()) {
            return;
        }

        Set<String> lockedStatuses = new Set<String>{ 'In Review', 'Approved' };

        for (Submission_Report__c bcc : newList) {
            Submission_Report__c oldBcc = oldMap.get(bcc.Id);

            // Only enforce if the record is currently in a locked state
            if (!lockedStatuses.contains(oldBcc.Status__c)) {
                continue;
            }

            if (bcc.Opportunity__c != oldBcc.Opportunity__c) {
                bcc.addError(
                    'Không thể thay đổi Opportunity khi BCC đang trong quy trình phê duyệt (In Review / Approved).'
                );
            }
            if (bcc.Account__c != oldBcc.Account__c) {
                bcc.addError(
                    'Không thể thay đổi Khách Thuê (Account) khi BCC đang trong quy trình phê duyệt.'
                );
            }
            if (bcc.Total_Submission_Report_Amount__c != oldBcc.Total_Submission_Report_Amount__c) {
                bcc.addError(
                    'Không thể thay đổi Tổng Giá Trị khi BCC đang trong quy trình phê duyệt.'
                );
            }
            // Block manual force-reset to Draft while locked (must use Recall in Approval Process)
            if (bcc.Status__c == 'Draft' && oldBcc.Status__c != 'Draft') {
                bcc.addError(
                    'Không thể tự ý đổi trạng thái BCC về Draft. Hãy sử dụng nút "Recall" trong Approval Process.'
                );
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPER
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Checks if the currently running user has the System Administrator profile.
     * @TestVisible allows unit tests to verify this branch.
     * @return Boolean true if current user is a System Admin
     */
    @TestVisible
    private static Boolean isCurrentUserAdmin() {
        return [
            SELECT Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].Profile.Name == 'System Administrator';
    }
}
