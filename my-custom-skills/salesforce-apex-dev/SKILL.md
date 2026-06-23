---
name: salesforce-apex-dev
description: "Quy chuẩn lập trình và tối ưu hóa mã nguồn Apex (Classes, Triggers, Unit Tests) cho dự án Salesforce."
category: development
risk: low
---

# Salesforce Apex Development

## Mục đích (Purpose)
Đảm bảo mã nguồn Apex do AI sinh ra hoặc review trong dự án (như xử lý logic cho Account, Brand, Opportunity) đạt tiêu chuẩn của Salesforce: An toàn, tối ưu hiệu năng (Bulkified) và dễ bảo trì.

## Quy tắc cốt lõi (Core Rules)
1. **Bulkification (Xử lý hàng loạt)**:
   - KHÔNG BAO GIỜ đặt câu lệnh `SOQL` hoặc `DML` (insert, update, delete) bên trong vòng lặp `for`.
   - Luôn sử dụng Collections (List, Set, Map) để gom dữ liệu trước khi thực hiện thao tác DML.
2. **Quy chuẩn Trigger (Trigger Pattern)**:
   - Tuân thủ nguyên tắc "One Trigger Per Object" (Chỉ viết 1 file Trigger duy nhất cho mỗi đối tượng).
   - Mọi logic xử lý phải được đẩy (delegate) sang một class Handler riêng biệt (VD: `AccountTriggerHandler`).
3. **Quy chuẩn Kiểm thử (Unit Testing)**:
   - Code coverage phải luôn đạt mức tối thiểu **80%** (Salesforce yêu cầu 75%, nhưng dự án set target 80%).
   - Class test phải sử dụng `@isTest` và bao bọc các thao tác kiểm thử bằng `Test.startTest()` và `Test.stopTest()`.
   - Phải luôn có `System.assertEquals()` hoặc `System.assertNotEquals()` để xác thực kết quả.

## Hướng dẫn thực thi cho AI (AI Instructions)
- Khi AI được yêu cầu viết mã Apex, hãy chủ động phân tích giới hạn Governor Limits (e.g., số lượng SOQL query, Heap size) và giải thích ngắn gọn tại sao đoạn code này an toàn.
- Tự động thêm JavaDoc/Docstring ở đầu mỗi Class và Method để giải thích luồng nghiệp vụ.
- Nếu người dùng yêu cầu review một đoạn code vi phạm Bulkification, AI phải cảnh báo ngay lập tức và đề xuất cách refactor (viết lại) sử dụng `Map` hoặc `Set`.
