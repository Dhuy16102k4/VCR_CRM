# VCR-CRM Project - Context Memory
**Cập nhật lần cuối:** 24/06/2026

## 1. 🎯 CÔNG VIỆC ĐÃ HOÀN THÀNH GẦN NHẤT

### 📅 25/06/2026 — Vibe Code Architecture Refactoring (✅ COMPLETED)

**Nhiệm vụ:** Tái cấu trúc (Refactor) và quốc tế hóa (English) toàn bộ quy chuẩn lập trình Vibe Code của dự án dựa trên format Agent Skills của Addy Osmani.

**Tóm tắt thành tích:**
- ✅ **Core Structure:** Refactored all Vibe code structures (`.clinerules`, hooks, references, agents) and custom agent skills to English to optimize token usage.
- ✅ **Action Workflow Standardization:** Migrated all 6 custom skills in `agent-skills/skills/` to the standardized Addy Osmani Action Workflow format (Overview, When to Use, Process, Anti-Rationalizations, Verification).

---

### 📅 24/06/2026 — Phase 3 (Sprint 3.1 & 3.2): Screen Flow & Record-Triggered Flow (✅ COMPLETED)

**Nhiệm vụ:** Tối ưu hóa UI nhập liệu với Screen Flow và xây dựng tự động hóa (Automation) chuyển đổi trạng thái Closed Won.

**Tóm tắt thành tích:**
- ✅ **BCC Builder Screen Flow:** Xóa bỏ các trường nhập tay rườm rà (Reservation Deposit) trên flow và sử dụng công thức ánh xạ (mapping) trực tiếp từ Opportunity sang Submission Report. Xóa các custom field dư thừa trên org.
- ✅ **Closed Won Automation:** Khởi tạo thành công Record-Triggered Flow `Opp_ClosedWon_Automation`. Khi Opp sang `Closed Won`, luồng tự động sinh 1 bản ghi `Contract` (Inactive), 1 bản ghi `RO Handover` (RO Handover), gán quyền sở hữu tự động cho Khối Vận hành (Queue BQL) và cập nhật Lookup ID ngược lại Opp.
- ✅ **Bổ sung Missing Fields:** Đã code và deploy thêm `Opportunity.Contract__c` (Lookup), `Opportunity.OTL_Contract_Handover_Date__c` (Date), và `RO_Handover__c.RO__c` (Lookup) phục vụ Data Mapping cho Flow.
- ✅ **Kiến trúc Bulkify:** Khẳng định chuẩn kiến trúc "Clicks Not Code" cho Sprint 3.2 và chốt phương án viết Bulkified Apex Trigger cho các tác vụ Roll-up ở Sprint 3.3.

---

### 📅 23/06/2026 — Phase 2 Closure & Phase 3 Planning (✅ COMPLETED)

**Nhiệm vụ:** Fix lỗi UI/UX cuối cùng của Phase 2 và lập kế hoạch cho Phase 3 (Automation).

**Tóm tắt thành tích:**
- ✅ **Fix Tab Visibility Bug:** Đã sửa file XML của 2 Permission Sets (`Sales_Console_Full_Access`, `Operations_Console_Full_Access`) để thêm thẻ `<tabSettings>` giúp tab `Business_Entity__c` hiển thị trên Navigation Bar.
- ✅ **UX Consulting:** Hỗ trợ user giải quyết lỗi "tràn form, mất nút Save" trên giao diện tạo mới Opportunity. Chẩn đoán đây là lỗi Standard UI Layout khi có quá nhiều trường.
- ✅ **Phase 3 Planning:** Đã tạo file `docs/07_automation/03_phase_3_automation_plan.md` nhằm định hướng chuyển đổi nút "New" thành **Screen Flow (Wizard)** để trị dứt điểm lỗi UI.

---

### 📅 23/06/2026 — Phase 2 UI/UX Configuration & Security Deployment (✅ COMPLETED)

**Nhiệm vụ:** Thiết lập Lightning Console Apps, Record Pages, Path Assistants và Security Model (Permission Sets & Groups).

**Tóm tắt thành tích:**
- ✅ **Lightning Console Apps (2)**: Tạo và deploy `VCR_Sales_Console` và `VCR_Operations_Console` với đầy đủ Navigation Items và Utility Bar (Notes, History, Recent Items, Macros).
- ✅ **Lightning Record Pages (4)**: Tạo và deploy FlexiPages cho `Opportunity`, `Liquidation__c`, `RO_Handover__c`, `Case` với Path, Highlights Panel và Related List Quick Links.
- ✅ **Path Assistants (4)**: Tạo cấu hình Path cho 4 core objects trên. (Đã xử lý lỗi `__MISSING__` recordTypeName bằng cách set `__MASTER__`).
- ✅ **Permission Sets (6)**: Tạo và deploy 6 permission sets theo chiến lược: `Sales_Console_Full_Access`, `Operations_Console_Full_Access`, `Cross_App_ReadOnly`, `Manager_Full_Access`, `Approval_Authority`, `Report_PowerUser`.
- ✅ **Permission Set Groups (4)**: Tạo và deploy `Sales_Staff_Group`, `Operations_Staff_Group`, `Manager_Group`, `Executive_Group` để dễ dàng assign theo roles.

**Files created/updated:** ~20 metadata files (Apps, FlexiPages, PathAssistants, PermissionSets, PermissionSetGroups).

**Next Step:** Administrator tiến hành End-to-End Testing trên Org theo checklist.

---

### 📅 18/06/2026 — Missing Objects & Campaign Configuration (✅ COMPLETED)

**Nhiệm vụ:** Bổ sung 3 Custom Objects còn thiếu + Custom Fields cho Standard Objects (Case, Campaign)

**Tóm tắt thành tích:**
- ✅ **Action_Plan__c** (Custom Object mới): AutoNumber AP-{000000}, fields: `Object_Name__c`, `Action_Plan_Id__c`
- ✅ **Action_Plan_Detail__c** (Custom Object mới): AutoNumber APD-{000000}, fields: `Stage__c`, `Subject__c`, `Description__c`, `Estimate__c`, `PIC__c`, `Validate_Complete_Task__c`, `Action_Plan__c` (Lookup)
- ✅ **Debt__c** (Custom Object mới): AutoNumber DEBT-{000000}, fields: `RO__c`, `Building__c`, `Account__c`, `Total_Debt__c`, `New_Debt__c`, `Report_Date__c`
- ✅ **Case** (Standard Object): 7 Custom Fields mới: `Contract__c`, `Business_Entity__c`, `RO_Name__c`, `Type_Level_1__c`, `Proposed_Liquidation_Date__c`, `ContactMobile__c`, `Stopping_Old_RO_Notification_Date__c`
- ✅ **Campaign** (Standard Object): Cấu hình picklist via StandardValueSet: `CampaignStatus` (4 values), `CampaignType` (5 values)
- ✅ **Unit Tests**: Test classes cho 4 objects mới (Action_Plan, Debt, Case, Campaign) - **100% PASS RATE (20/20)**. Unblocked for UI configuration and automation phases.

**Kỹ thuật quan trọng phát hiện:**
- Lookup field `required=true` trên Custom Object → phải dùng `deleteConstraint=Restrict` thay thế
- Lookup to `Product2` KHÔNG hỗ trợ Restrict/Cascade → bắt buộc dùng `deleteConstraint=SetNull`
- Standard Picklist (Status, Type) trên Standard Object → KHÔNG dùng `<valueSet>` trong object XML mà phải dùng `StandardValueSet` riêng

---

### 📅 18/06/2026 — Priority Medium Tasks Complete (✅ COMPLETED)

**Nhiệm vụ:** Hoàn thành tất cả Priority Medium tasks: Page Layouts, Validation Rules, Duplicate Rules, Field History Tracking, Reports & Dashboards, và Approval Process.

**Tóm tắt thành tích:**
- ✅ **Page Layouts (4)**: RO_Handover__c, Liquidation__c, Rental_Plan__c, Legal_Record__c với Related Lists đầy đủ
- ✅ **Validation Rules (4)**: Business logic validation cho 4 objects
- ✅ **Duplicate Rules (3)**: Chặn duplicate records theo business rules
- ✅ **Field History Tracking (18+ fields)**: Audit trail cho critical fields
- ✅ **Reports (4)**: Target Achievement, Advertising vs Actual, Sales Activity, T+3 Achievement
- ✅ **Dashboard (1)**: Sales Performance Dashboard với 4 components
- ✅ **Approval Process (1)**: Liquidation 3-level approval (L1→L2→L3) với 6 field updates + automation flow

**Files created:** 44 metadata files
- 4 Page Layouts with related lists
- 4 Validation Rules
- 6 Duplicate/Matching Rules
- 18 Field metadata updates (trackHistory)
- 4 Reports
- 1 Dashboard
- 1 Approval Process
- 1 Workflow (6 field updates)
- 1 Flow (status automation)

---

### 📅 17/06/2026 — Docs Audit & Sync (✅ COMPLETED)

**Nhiệm vụ:** Kiểm toán đồng bộ 2 chiều giữa `project/docs/` và `scratch/` scripts. Cập nhật 7 Markdown files cho khớp với code (Script là chuẩn).

**Phát hiện chính (14 điểm lệch pha):**
- 🔴 **API Name conflict:** `Advertising_Target__c` (docs) ≠ `Sales_Advertising_Target__c` (script/Org) → Đã sửa docs.
- 🔴 **Bug logic D10:** `generate_contract_fields.py` L101 — `history_count < 0` KHÔNG BAO GIỜ đúng → tất cả Contract fields bị `trackHistory=false`. Đã ghi chú vào docs, **chưa fix script**.
- 🔴 **Field thiếu `__c`:** `OTL_Contract_Handover_Date` trong `VH_Bàn_Giao_Mặt_Bằng_` CSV thiếu suffix → bị script bỏ qua. Đã ghi chú, **chưa fix CSV**.
- 🔴 **Picklist placeholder:** `generate_missing_objects.py` dùng `Value 1/Value 2` cho mọi picklist — không đọc CSV. Cần nhập thủ công.
- 🟡 **Formula fields chưa deploy:** `Sales_Advertising_Target__c` thiếu Achievement%, Revenue Gap, Status formula.
- 🟠 **Stale status:** Nhiều task vẫn ghi `TODO` dù đã deploy.

**Docs đã cập nhật:**
| File | Thay đổi |
|------|---------|
| `docs/10_operations/01_ro_handover.md` | Deploy ✅, picklist đầy đủ, cảnh báo OTL field |
| `docs/10_operations/02_liquidation.md` | Deploy ✅, picklist đầy đủ, fields thiếu API Name |
| `docs/03_targets/03_rental_plan.md` | Deploy ✅, làm rõ Text(255) type |
| `docs/03_targets/02_advertising_target.md` | **Sửa API Name**, 7 fields thực từ XML, picklist thực |
| `docs/03_targets/01_sales_targets.md` | Task ✅ Done, 17 fields thực T3, cảnh báo TBD picklist |
| `docs/02_sales_process/02_submission_report.md` | Deploy ✅, sửa Account__c type, cảnh báo formula |
| `docs/02_sales_process/03_contract.md` | Deploy ✅, ghi chú bug D10 trackHistory |

---

### 📅 17/06/2026 — Documentation Suite (✅ COMPLETED)

Hoàn thành tài liệu nghiệp vụ cho 7 objects:
- **RO Handover, Liquidation** (10_operations/)
- **Rental Plan** (03_targets/)
- **Case, Campaign, Action Plan Detail, Debt** (10_operations/)

---

### 📅 16/06/2026 — Core Objects Deployment (✅ COMPLETED)
- **Object Contract:** ~100 Custom Fields, 3 Page Layouts, Permission Set.
- **Submission Report & Line:** 63+ Custom Fields, Master-Detail, PermSet.
- **Opportunity:** 143 custom fields, 4 Page Layouts, Related Lists, PermSet.
- **Product2:** 115 field XML files, Formula, Picklist, Lookup.
- **Apex Test Suite:** 26/26 Tests Passed.

---

### 📅 15/06/2026 — English UI & Data Fixes (✅ COMPLETED)
- 100% English UI, 337+ từ khóa dịch, xóa translation metadata.
- 4 Account Validation Rules, 85+ Business Entity fields, Brand picklists.
- Mock Data chuẩn, Opportunity Stage fix.

---

## 2. ⚙️ THAY ĐỔI KỸ THUẬT QUAN TRỌNG

### UI Language Strategy
- **Quyết định:** Salesforce UI = **100% English**
- **Implementation:** Xóa tất cả translation metadata, label = English

### XML Automation Pipeline
- **Python Script** tự động gen `.field-meta.xml` từ CSV Master Data
- Áp dụng: Business Entity (85), Brand, Contract (100+), Opportunity (143), Product2 (115)
- Giới hạn 40 ký tự label: auto-truncate + full text vào Description

### Known Script Bugs
| Bug | Script | Status | Fix |
|-----|--------|--------|-----|
| **D10** | `generate_contract_fields.py` | ✅ **FIXED 18/06** | `history_count < 0` → `< 20` (HISTORY_TRACKING_LIMIT constant) |
| **S2** | `generate_missing_objects.py` | ✅ **FIXED 18/06** | Parse `Picklist EN` col (index 7) từ CSV; fallback `TBD` + WARN nếu trống |
| **S5** | `generate_bcc.py` | ✅ **FIXED 18/06** | Duplicate `relationshipName=Submission_Reports` cho 2 Lookups |
| **D3** | CSV `VH_Bàn_Giao_Mặt_Bằng_` | ✅ **FIXED 18/06** | Thêm `__c` vào `OTL_Contract_Handover_Date` |
| **Hidden** | `generate_missing_objects.py` | ✅ **FIXED 18/06** | `row[10]` → `row[9]` cho API Name column index |
| **Deploy1** | Metadata `Contract` | ✅ **FIXED 18/06** | Disable all trackHistory=false (re-enable manually in Salesforce Setup) |
| **Deploy2** | Metadata `Liquidation__c` | ✅ **FIXED 18/06** | `Product__c` → referenceTo=`Product2` + deleteConstraint=SetNull |
| **Deploy3** | Metadata `RO_Handover__c` | ✅ **FIXED 18/06** | Fix `Opp.__c` → `Opportunity`, rename `Contracts` → `RO_Handover_Contracts` |
| **Deploy4** | Metadata `Rental_Plan__c` | ✅ **FIXED 18/06** | Dùng `sf project delete source` xóa `RO_Name__c` trên org rồi deploy lại thành công |
| **Deploy5** | Metadata `Submission_Report__c`| ✅ **FIXED 18/06** | Dùng `sf project delete source` xóa 2 Formula fields rồi deploy lại thành công |

---

## 3. 🚀 NEXT ACTIONS

### 🔴 Sprint 3.2: Tự động hóa nghiệp vụ (Tiếp tục)
- [ ] **Tạo Queue BQL:** Admin tự cấu hình các Queue trên Setup UI (ví dụ: `BQL_VCR_CRM`) để Flow tự động gán Owner khi bàn giao mặt bằng.
- [x] **Flow: `Liquidation_Sync_Contract`:** Tạo Record-Triggered Flow tự động đổi Status của Contract thành `Liquidated` khi Liquidation được Approved.
- [ ] **Flow: `Task_Reminder_Creation`:** Tạo Record-Triggered Flow gửi Task nhắc nhở Sales Rep khi Opportunity kẹt stage quá 14 ngày.

### 🟡 Sprint 3.3: Logic Phức Tạp (Apex Triggers & Bulkification)
- [x] **Rollup Summary Trigger (Contract -> Account):** Viết Bulkified Apex Trigger tính tổng doanh thu từ tất cả Contract đẩy về Account.
- [ ] **Rollup Summary Trigger (BCC -> Opportunity):** Viết Bulkified Apex Trigger đếm số lượng Submission Report (BCC) đang Active của 1 Opportunity.
- [ ] **BCC Approval Process:** Cấu hình quy trình phê duyệt BCC qua nhiều cấp (Sales Manager -> Director).

### 🟢 Priority Critical — Fix Script Bugs (Đã hoàn thành)
- [x] **[BUG D10 — FIXED]** `generate_contract_fields.py`: `history_count < 0` → `< 20` (HISTORY_TRACKING_LIMIT). Re-generate xong, 18 fields có trackHistory=true.
- [x] **[BUG D3 — FIXED]** CSV `VH_Bàn_Giao_Mặt_Bằng_(RO_Hand.csv`: `OTL_Contract_Handover_Date` → thêm `__c`. Re-generate xong: OTL field đã có XML.
- [x] **[BUG S2 — FIXED]** `generate_missing_objects.py`: Picklist placeholder → parse `Picklist EN` col (idx 7) + fallback TBD + WARN.
- [x] **[Hidden Bug — FIXED]** `generate_missing_objects.py`: `row[10]` → `row[9]` cho API Name column index.
- [x] **[BUG S5 — FIXED]** Fix `generate_bcc.py`: duplicate `relationshipName`. Cần rename Lookup(Account) rel name → `Submission_Report_Accounts`.
- [x] **[BUG Deploy1 — FIXED]** Contract: disable all trackHistory=false (143/146 components deployed OK).
- [x] **[BUG Deploy2 — FIXED]** Liquidation__c.Product__c → referenceTo=Product2 + deleteConstraint=SetNull.
- [x] **[BUG Deploy3 — FIXED]** RO_Handover__c: Opportunity__c referenceTo=`Opportunity`, Contract__c relName=`RO_Handover_Contracts`.
- [x] **[BUG Deploy4 — FIXED]** `Rental_Plan__c.RO_Name__c`: Đã dùng SF CLI xóa tự động trên org và redeploy XML mới.
- [x] **[BUG Deploy5 — FIXED]** `Submission_Report__c`: Đã dùng SF CLI xóa 2 Formula fields cũ trên org và redeploy XML mới.
- [x] **✅ DEPLOY COMPLETE** 100% components (146/146) đã deploy thành công!

### 🟡 Priority High — Manual Picklist Entry (Tiếng Anh 100%) - ✅ COMPLETED
*   **Legal_Record__c:**
    *   `Status__c`: `Not Submitted`, `Submitted`, `Approved`, `Rejected` (Đã check trong XML)
*   **Liquidation__c:**
    *   `Stage__c`: `Negotiation`, `Approval`, `Customer Response`, `Closed Liquidation` (Đã check trong XML)
    *   `Liquidation_Type__c`: `Early Liquidation`, `On-time Liquidation` (Đã update TBD -> giá trị thực)
    *   `Approval_Status__c`: `Request not submitted`, `Request submitted`, `Approved Level 1`, `Approved Level 2`, `Approved Level 3`, `Denied` (Đã check trong XML)
*   **RO_Handover__c:**
    *   `Stage__c`: `RO Handover`, `RO Design Approval`, `RO Construction Control`, `RO Acceptance`, `RO Completed` (Đã check trong XML)
    *   `Acceptance_Result__c`: `Qualified`, `Not Qualified` (Đã check trong XML)
*   **Sales_T_3_Achievement_Target__c:** `Target_Type__c`: `Revenue`, `Conversion`, `Advertising` (Đã cập nhật)
*   **Legal_Record_Rule__c:** `Document_Type__c`, `Record_Type_Required__c` (Đã cập nhật)

### 🟢 Priority High — Formula Fields (Manual in Setup) - ✅ COMPLETED 100%
- [x] `Submission_Report__c.Total_Submission_Report_Amount__c`: ✅ Fixed (công thức thực đã được cập nhật)
- [x] `Submission_Report__c.Business_Entity__c`: ✅ Changed to Lookup(Business_Entity__c) instead of Formula
- [x] `Sales_Advertising_Target__c`: ✅ Revenue Achievement %, Revenue Gap, Status (all formulas working)
- [x] `Liquidation__c.Decrease_In_Full_Rate__c`: ✅ Formula field created
- [x] `Liquidation__c.Contracts_Expired_Date__c`: ✅ Formula = Contract__r.EndDate

### 🟢 Priority High — Missing Fields (Manual) - ✅ COMPLETED 100%
- [x] `RO_Handover__c.OTL_Contract_Handover_Date__c`: ✅ Date field created
- [x] `Liquidation__c` - All missing fields created:
  - ✅ `Compensation_Amount__c` (Currency)
  - ✅ `Approval_Date__c`, `Accepted_Date__c` (Date)
  - ✅ `Decrease_In_Full_Rate__c` (Formula - Percent)
  - ✅ `RO_Return_Status__c` (Picklist: Qualified/Not Qualified)
  - ✅ `Liquidation_Date__c` (Date)
  - ✅ `Contracts_Expired_Date__c` (Formula from Contract.EndDate)
- [x] `Sales_Advertising_Target__c` - All actual fields created:
  - ✅ `Actual_Revenue__c` (Currency)
  - ✅ `Actual_Impressions__c`, `Clicks__c`, `Conversions__c` (Number)

### 🟢 Priority Medium
- [x] **Page Layouts:** ✅ Đã tạo cho `RO_Handover__c`, `Liquidation__c`, `Rental_Plan__c`, `Legal_Record__c` (18/06/2026)
  - ✅ Related Lists: Open Activities, Activity History, Files, Notes
  - ✅ Legal_Record__c layout: Legal Type fields sắp xếp UX-friendly
  - ✅ RO_Handover__c: Added Legal Record related list
- [x] **Validation Rules:** ✅ Đã triển khai (18/06/2026)
  - ✅ RO_Handover__c: `Require_Acceptance_Result`, `Valid_Actual_Date`
  - ✅ Liquidation__c: `Require_Liquidation_Type`
  - ✅ Rental_Plan__c: `Check_Deposit_Date`
- [x] **Duplicate Rules:** �� tri?n khai b?ng **Apex Triggers** (thay v� Matching Rule do gi?i h?n Lookup)
  - ✅ RO_Handover__c: `One_Handover_Per_Opp` (blocks duplicate for same Opportunity when not completed)
  - ✅ Liquidation__c: `Unique_Liquidation_Per_Contract` (1 liquidation per contract)
  - ✅ Rental_Plan__c: `Unique_RO_Plan` (prevents duplicate active plans for same RO)
- [x] **Field History Tracking:** ✅ Đã bật cho critical fields (18/06/2026)
  - ✅ RO_Handover__c: Stage, Opportunity, Contract, Actual Handover Date, Acceptance Result
  - ✅ Liquidation__c: Stage, Type, Product, Contract, Approval Status, Risk
  - ✅ Rental_Plan__c: RO Name, Negotiation/Closing/Deposit/Revenue Dates
  - ✅ Legal_Record__c: Stage, Status
- [x] **Reports & Dashboards:** ✅ Đã tạo (18/06/2026)
  - ✅ 4 Reports: Target Achievement Summary, Advertising Target vs Actual, Sales Activity Performance, T+3 Achievement
  - ✅ 1 Dashboard: Sales Performance Dashboard (4 components - charts + table)
- [x] **Approval Process:** ✅ Đã tạo Liquidation 3-level approval (18/06/2026)
  - ✅ Entry criteria: Stage = Approval, có Contract/Product/Approver L1
  - ✅ Step 1 (L1): Team Lead/BU Manager approval
  - ✅ Step 2 (L2): Sales/Operations Director approval
  - ✅ Step 3 (L3): VP/Deputy GD (only for high-risk: Cao, Chắc chắn thanh lý)
  - ✅ Field Updates: 6 workflow field updates for status management
  - ✅ Automation: Flow for intermediate status updates

---

## 4. 🛡️ CORE RULES

1. **Single Source of Truth:** Script (`scratch/`) là chuẩn → Docs (`docs/`) phải phản ánh đúng code
2. **Automation First:** Objects > 50 fields → BẮT BUỘC dùng Python script
3. **Salesforce Limits:** Field Label ≤ 40 ký tự → Auto-truncate, full text vào Description
4. **Clean Metadata:** Xóa XMLs sai ngay, dùng `destructiveChanges.xml` khi cần
5. **Docs Audit:** Sau mỗi sprint → kiểm toán Docs ↔ Scratch để tránh lệch pha

---

## 5. 📚 KEY DOCUMENTS

| Document | Purpose |
|----------|---------|
| `docs/00_project_overview.md` | Project overview |
| `docs/01_master_data/*.md` | Master data specs (Account, Contact, Brand...) |
| `docs/02_sales_process/*.md` | Sales objects (Opportunity, Contract, BCC...) |
| `docs/03_targets/*.md` | Target objects (Sales, Advertising, Rental Plan) |
| `docs/04_legal/*.md` | Legal objects (Legal Record, Rule) |
| `docs/10_operations/*.md` | Ops objects (RO Handover, Liquidation, Case...) |
| `scratch/*.py` | XML generation scripts |
| `scratch/*_temp.md` | CSV preview exports (nguồn sự thật khi audit) |
| `MEMORY.md` | This file |

---

## 6. 🔗 DEPLOYMENT INFO

**Org:** dhuy1610z.6169fc65f8a7@agentforce.com
**Latest Deploy:** 18/06/2026 — Missing Objects + Campaign Config
**Status:** ✅ All objects deployed

**Deployed Objects:**
| Object | Status | Notes |
|--------|--------|-------|
| `Account` | ✅ | Record Types, Validation Rules, Layouts, Fields |
| `Brand__c` | ✅ | Dependent picklists, Layouts, Fields |
| `Business_Entity__c` | ✅ | 85 fields, 3 Record Types |
| `Opportunity` | ✅ | 143 Fields, 4 Layouts, PermSet |
| `AccountContactRelationship` | ✅ | Contact_Roles__c, Layout, PermSet |
| `Contract` | ✅ | ~100 Fields, 3 Layouts, PermSet |
| `Submission_Report__c` | ✅ | 63+ Fields, Layout, PermSet |
| `Submission_Report_Line__c` | ✅ | Fields, Layout |
| `Product2` | ✅ | 115 Fields |
| `Bankey__c` | ✅ | |
| `Legal_Record__c` | ✅ | Fields, Picklist |
| `Legal_Record_Rule__c` | ✅ | Fields, Picklist |
| `Sales_Activity_Target__c` | ✅ | 7 Fields, Layout |
| `Sales_T_3_Achievement_Target__c` | ✅ | 17 Fields, Layout |
| `Sales_Advertising_Target__c` | ✅ | 7 Fields, Formula fields |
| `Rental_Plan__c` | ✅ | Fields, Picklist |
| `RO_Handover__c` | ✅ | Fields, Picklist, Layout, Trigger |
| `Liquidation__c` | ✅ | Fields, Picklist, Approval Process, Trigger |
| `Contract_Line_Item__c` | ✅ | Fields |
| `Action_Plan__c` | ✅ **NEW 18/06** | Custom Object: AP-{000000}, 2 custom fields |
| `Action_Plan_Detail__c` | ✅ **NEW 18/06** | Custom Object: APD-{000000}, 7 custom fields |
| `Debt__c` | ✅ **NEW 18/06** | Custom Object: DEBT-{000000}, 6 custom fields |
| `Case` (Standard) | ✅ **NEW 18/06** | 7 custom fields: Contract, Business Entity, RO, Type, v.v. |
| `Campaign` (Standard) | ✅ **NEW 18/06** | StandardValueSet: CampaignStatus (4) + CampaignType (5) |
| `VCR_CRM Application` | ✅ | |
