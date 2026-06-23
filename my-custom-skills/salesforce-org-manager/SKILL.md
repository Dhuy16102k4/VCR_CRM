---
name: salesforce-org-manager
description: "Quản trị vòng đời Salesforce Org, deployment tự động hóa qua MCP và quy tắc dọn dẹp metadata."
category: devops
risk: moderate
---

# Salesforce Org Management

## Mục đích (Purpose)
Quản lý vòng đời của môi trường Salesforce (Tạo mới Scratch Org, Deploy, kết nối Sandbox) thông qua giao thức MCP, đồng thời bảo vệ nguyên tắc Zero Orphaned Metadata của dự án VCR-CRM.

## Quy tắc cốt lõi (Core Rules)
1. **Source of Truth**: Luôn lấy thư mục mã nguồn (`force-app`) ở Local làm gốc. Tuyệt đối không thay đổi lặt vặt trên giao diện Org rồi quên kéo về (pull) Local.
2. **Quản lý rác Metadata (Clean Environment)**: Những Custom Fields bị xóa bỏ trong yêu cầu BA phải được xóa hoàn toàn khỏi thư mục local. Nếu đẩy lên một Org sạch (hoặc dùng thư mục destructiveChanges), hệ thống sẽ không có rác.
3. **Xử lý sự cố môi trường**: Khi Org hiện tại gặp lỗi nền tảng nghiêm trọng (Ví dụ: Lỗi ngôn ngữ Anh - Việt trộn lẫn, hết limits), ưu tiên sử dụng SFDX để tạo Org mới thay vì tốn thời gian cố sửa lỗi hệ thống (workaround) của Salesforce.

## Hướng dẫn cho AI
- Bắt buộc tận dụng các công cụ MCP (`mcp_Salesforce_DX_list_all_orgs`, `mcp_Salesforce_DX_deploy_metadata`, `mcp_Salesforce_DX_run_soql_query`) một cách chủ động để rà soát và thực thi lệnh cho User.
- Trước khi thực thi deploy, hãy nhắc nhở User kiểm tra xem thư mục `force-app` có metadata nào vô nghĩa không.
