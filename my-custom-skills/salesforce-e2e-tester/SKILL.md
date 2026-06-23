---
name: salesforce-e2e-tester
description: "Quy chuẩn thiết kế kịch bản End-to-End (E2E) Testing và Mock Data cho dự án Salesforce VCR-CRM."
category: testing
risk: low
---

# Salesforce E2E Testing Guidelines

## Mục đích (Purpose)
Sinh ra các kịch bản kiểm thử thực tế (Test Cases) hoặc script tạo Mock Data để chứng minh Validation Rule, Dependent Picklist, và Record Type hoạt động trơn tru trên màn hình giao diện (UI) của Salesforce Org. Đây là bước bắt buộc để nghiệm thu (UAT).

## Quy tắc cốt lõi (Core Rules)
1. **Dữ liệu Mock Thực tế**: Tên, số điện thoại, định dạng email phải mang ngữ cảnh thực tế của doanh nghiệp (VD: "Vincom Retail", "Kinh Doanh Quảng Cáo", "0901234567"). Cấm sử dụng các dữ liệu rác như "Test 1", "ABC".
2. **Kịch bản Negative (Bắt Lỗi)**: Phải có ít nhất 2 kịch bản cố tình vi phạm Validation Rules (ví dụ: SĐT có chứa chữ cái, Bỏ trống Brand đối với Record Type quy định) để kiểm chứng hệ thống chặn lỗi chính xác.
3. **Quản lý Phụ thuộc (Dependencies)**: Khi test Object nhánh (như Business Entity), phải tạo đầy đủ data của Object cha (Account/Brand) trước tiên.

## Hướng dẫn cho AI
- Liệt kê các bước thực thi test theo cấu trúc chuẩn: `Pre-conditions` -> `Test Steps` -> `Expected Result`.
- Sinh SOQL Script hoặc Apex Anonymous Script để Dev có thể copy chạy và sinh data nhanh gọn.
