---
name: python-excel-automation
description: "Quy chuẩn viết code Python xử lý file Excel an toàn, sạch sẽ và hiệu suất cao."
category: development
risk: low
---

# Python Excel Automation

## Mục đích (Purpose)
Đảm bảo mã nguồn Python khi đọc/ghi file Excel trong dự án (như các file `read_excel.py`, `update_excel.py`) đạt hiệu suất cao, dễ bảo trì và không gây rò rỉ bộ nhớ (memory leak).

## Quy tắc cốt lõi (Core Rules)
1. **Lựa chọn thư viện**:
   - Sử dụng `pandas` khi cần phân tích, tổng hợp dữ liệu lớn.
   - Sử dụng `openpyxl` khi cần giữ nguyên định dạng, màu sắc (formatting) của file Excel.
2. **Xử lý ngoại lệ (Error Handling)**: Mọi thao tác I/O file đều phải nằm trong khối `try...except`, bắt cụ thể các lỗi như `FileNotFoundError` hoặc `PermissionError` (khi file đang bị mở bởi ứng dụng khác).
3. **Quản lý tài nguyên**: Phải dùng `with pd.ExcelWriter(...)` hoặc quản lý engine tự động đóng luồng dữ liệu (stream) sau khi ghi xong.

## Hướng dẫn thực thi cho AI (AI Instructions)
- Khi sinh ra mã nguồn (generate code) hoặc review code Python xử lý Excel, AI phải tự động thêm Type Hinting (e.g. `def process(file_path: str) -> bool:`) và Docstring giải thích hàm.
- Tự động bổ sung module `logging` thay vì dùng `print()` để theo dõi quá trình đọc/ghi số lượng dòng.
- Đề xuất tách nhỏ hàm nếu một hàm vượt quá 50 dòng code.
