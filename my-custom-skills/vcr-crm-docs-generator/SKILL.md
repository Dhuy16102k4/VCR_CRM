---
name: vcr-crm-docs-generator
description: "Quy chuẩn tự động hóa việc tạo và review tài liệu kỹ thuật cho dự án VCR-CRM Salesforce."
category: documentation
risk: safe
---

# VCR-CRM Documentation Generator

## Mục đích (Purpose)
Kỹ năng này định nghĩa các tiêu chuẩn để AI tạo, chuẩn hóa và review tài liệu dự án (URD, BRD, Data Dictionary, Master List) cho hệ thống VCR-CRM, đảm bảo tính đồng nhất.

## Quy tắc cốt lõi (Core Rules)
1. **Ngôn ngữ**: 100% sử dụng tiếng Việt chuyên nghiệp, giữ nguyên các thuật ngữ chuyên ngành Salesforce (ví dụ: Object, Field, Validation Rule, Page Layout).
2. **Cấu trúc tài liệu Object**: Bất kỳ mô tả đối tượng (Object) nào cũng phải bao gồm:
   - Tên Object (Label & API Name)
   - Danh sách Fields (Label, API Name, Data Type, Bắt buộc/Không bắt buộc)
   - Các Logic ràng buộc (Validation Rules, Duplicate Rules).
3. **Trình bày (Formatting)**: Sử dụng bảng Markdown (Markdown Tables) để liệt kê các trường dữ liệu.

## Hướng dẫn thực thi cho AI (AI Instructions)
- Luôn tìm và đối chiếu với file `PICKLIST_MASTER_LIST.md` nếu đang xử lý các trường dạng Picklist.
- Không bao giờ tự bịa dữ liệu (hallucination). Nếu thiếu thông tin thiết kế, AI phải chủ động đánh dấu là `[TBD - Cần confirm từ BA/Mentor]`.
- Mọi tài liệu tạo ra phải có mục "Lịch sử cập nhật" (Revision History) ở đầu file.
