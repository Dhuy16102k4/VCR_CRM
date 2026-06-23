---
name: salesforce-metadata-auditor
description: "Kiểm toán và review metadata XML của Salesforce trước khi thực hiện deploy."
category: devops
risk: moderate
---

# Salesforce Metadata Auditor

## Mục đích (Purpose)
Review các file XML cấu hình của Salesforce (như `.field-meta.xml`, `.object-meta.xml`, `package.xml`) nhằm đảm bảo không bị lỗi cú pháp, thiếu định nghĩa field hoặc sai format chuẩn của Salesforce trước khi push lên Org.

## Quy tắc cốt lõi (Core Rules)
1. **Chuẩn hóa XML**: Mọi file XML phải bắt buộc chứa header `<xml version="1.0" encoding="UTF-8"?>`.
2. **Quy ước đặt tên (Naming Convention)**:
   - Các API Name của custom objects và custom fields bắt buộc phải có hậu tố `__c`.
   - Relationships (Master-Detail, Lookup) nếu là custom phải có hậu tố `__r` hoặc `__c` tùy ngữ cảnh truy vấn.
3. **Quản lý Package.xml**: Mọi component thêm mới (vd: CustomField, Layout) đều phải được định nghĩa tường minh trong file `package.xml` để đảm bảo không bị sót khi deploy qua CLI/MCP.

## Hướng dẫn thực thi cho AI (AI Instructions)
- Khi AI được yêu cầu review một file XML metadata, hãy tập trung tìm kiếm các thẻ (tags) bị lỗi thời, thẻ trống không hợp lệ hoặc thiếu thẻ bắt buộc (như `<label>`, `<type>`, `<fullName>`).
- Kiểm tra chéo (Cross-check) với User Requirements: Đảm bảo độ dài (length), kiểu dữ liệu (type) khớp đúng với thiết kế trên file Excel.
- Nếu phát hiện lỗi, AI KHÔNG được viết lại toàn bộ file, mà chỉ in ra đoạn mã (snippet) bị lỗi và cung cấp block code sửa chữa tương ứng.
