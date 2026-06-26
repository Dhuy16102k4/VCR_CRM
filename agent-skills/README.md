# VCR-CRM Agentic Vibe Code Architecture

## 1. Mục đích và Công dụng (Purpose & Usage)
Cấu trúc "Vibe Code" này được thiết kế để nâng cấp AI từ một "trợ lý chat" thụ động thành một **Đội ngũ kỹ sư phần mềm chủ động (Agentic Workflow)** chuyên biệt cho nền tảng Salesforce.

Thay vì dựa vào khả năng phán đoán của AI, cấu trúc này ép AI phải làm việc theo một chuỗi dây chuyền công nghiệp: **Lấy Ngữ Cảnh -> Kích hoạt Command -> Tải Skill -> Thực Thi -> Kiểm Chứng bằng Tool -> Lưu Trữ Bộ Nhớ.**

---

## 2. Giải Phẫu Cấu Trúc (Architecture Roles)
Mỗi thành phần trong kiến trúc này đóng một vai trò riêng biệt, kết hợp lại thành một vòng lặp tự trị hoàn chỉnh:

*   **`agent-skills/commands/*.json` (Trigger / Instruction):** Đóng vai trò là công tắc kích hoạt và **Chỉ thị ban đầu**. Thay vì viết prompt dài dòng, lệnh Slash (VD: `/apex`) sẽ "ép" AI phải vào đúng form Agentic, không được phép chat lan man.
*   **`agent-skills/skills/*/SKILL.md` (Standard Operating Procedures - SOPs):** Đây là **Quy trình chuẩn**. Khi được lệnh (command) gọi, AI sẽ tải file này ra đọc. File này quy định các bước 1-2-3-4 bắt buộc phải làm, quy tắc "Anti-Rationalization" (Chống AI lấp liếm/lười biếng), và điều kiện vượt qua Cổng kiểm duyệt (Verification Gate).
*   **`MEMORY.md` (Persistent Context / Long-term Memory):** Đóng vai trò là **Bộ nhớ dài hạn** và **Bảng quản lý Sprint**. AI bắt buộc phải đọc file này ở đầu mọi phiên để biết bối cảnh tổng thể, và ghi kết quả vào cuối phiên để không bị mất trí nhớ khi chuyển chat.
*   **`.clinerules` (System Context):** Là **Hiến pháp** nền tảng của hệ thống, cài đặt sâu vào bộ nhớ hệ thống (System Prompt) để AI luôn biết mình là ai và đang làm việc trên loại dự án nào.
*   **`agent-skills/hooks/` (Automated Actions):** Các kịch bản chạy tự động (Ví dụ: Chạy script cập nhật `MEMORY.md` vào cuối phiên làm việc).
*   **`agent-skills/plugin.json`**: File manifest khai báo cho Antigravity biết thư mục nào chứa lệnh và skill.

---

## 3. Cấu Trúc Thư Mục (Directory Structure)
Cấu trúc cây thư mục phản ánh chính xác kiến trúc hoạt động của dự án:

```text
agent-skills/
├── commands/        # Chứa các file JSON kích hoạt lệnh Slash (/apex, /build, /test)
├── skills/          # Các quy trình thực thi chính (SOPs - Apex Dev, E2E Test, v.v.)
├── agents/          # Định nghĩa vai trò (Persona) như Senior Architect, QA
├── references/      # Các bảng Checklist dùng chung (Security, Limits)
├── hooks/           # Kịch bản tự chạy tự động (VD: Cập nhật MEMORY.md vào cuối phiên)
├── plugin.json      # File khai báo plugin cho Antigravity/RooCode
└── README.md        # File tài liệu này
```

## 4. Hệ Thống Các Lệnh (Slash Commands) và Kỹ Năng (Skills)
Mọi thao tác với hệ thống giờ đây được điều hướng thông qua thư mục `commands/`. Mỗi lệnh sẽ định hướng AI tải một file `SKILL.md` cụ thể để thực thi.

| Lệnh (Command) | Kỹ Năng Kích Hoạt (Skill) | Mô tả & Cách hoạt động |
|----------------|---------------------------|------------------------|
| **`/apex`** | `salesforce-apex-dev` | **Lệnh Combo Siêu Tốc:** Yêu cầu AI viết code (Apex/Flow) và bắt buộc phải dùng MCP Tool để Test và Deploy trong cùng 1 phiên. Phù hợp làm các task nhanh. |
| **`/audit`** | `salesforce-metadata-auditor` | **Lệnh Kiểm toán:** Dùng để rà soát bảo mật (FLS), Profile, Permission Sets. Ép AI dùng SOQL/Metadata API soi dữ liệu Org thực tế thay vì đoán mò. |
| **`/spec`** | `vcr-crm-docs-generator` | **Phân tích yêu cầu:** Đọc `MEMORY.md`, phân tích Data Model, Limits trước khi code. Đóng vai trò Kiến trúc sư (Architect). |
| **`/plan`** | `vcr-crm-docs-generator` | **Lên kế hoạch:** Chia nhỏ công việc thành các bước (Task Breakdown), liệt kê các file cần tạo/sửa và cập nhật `MEMORY.md`. |
| **`/build`** | `salesforce-apex-dev`<br>*(Hoặc `python-excel-automation`)* | **Thực thi Code:** Cắm cúi viết code, tạo file XML hoặc script Python theo đúng kế hoạch. AI sẽ không tự ý Test để tiết kiệm thời gian, chỉ code! |
| **`/test`** | `salesforce-e2e-tester` | **Xác thực (Verification):** Chạy Unit Test/E2E Test thông qua Terminal hoặc MCP Tools. Phân tích Log lỗi, tự động sửa nếu cần thiết. |
| **`/review`** | `salesforce-metadata-auditor` | **Kiểm duyệt (Code Review):** Rà soát lại chất lượng code, tìm "Code smell", kiểm tra giới hạn Bulkification và FLS. |
| **`/ship`** | `salesforce-org-manager` | **Triển khai (Deploy):** Đẩy code lên Org bằng lệnh SF CLI, tick DONE task trong `MEMORY.md` và đóng tính năng. |

---

## 5. Quy Trình Vận Hành Của AI Khi Người Dùng Gõ Lệnh (Execution & Token Economics)

Vấn đề lớn nhất của các setup Vibe Code đời cũ (dồn toàn bộ vào file `.cursorrules`) là tốn hàng chục nghìn Token Input một cách lãng phí cho mỗi lần gửi tin nhắn. Cấu trúc mới này áp dụng quy tắc **"Lazy Loading" (Tải Lười)** theo RAG.

**Mô phỏng những gì xảy ra khi bạn gõ `/build Làm tính năng ABC`:**

1. **Khởi động (Nạp Context Nhẹ):** 
   - AI đọc `.clinerules` và lệnh `build.json`.
   - Lệnh `build.json` ép AI đi đọc file `MEMORY.md`.
   - *Token tiêu hao: Rất ít (~2.000 tokens) vì nó không cần đọc luật về Test hay Audit ở bước này.*
2. **Nạp Skill Đặc Thù (Lazy Load Skill):**
   - Lệnh `/build` báo cho AI biết nó phải làm Developer. AI mở thư mục `skills/salesforce-apex-dev/` và chỉ đọc file `SKILL.md` của thư mục đó.
   - *Token tiêu hao: AI tiết kiệm được ~80% Token vì không phải đọc phần luật của `metadata-auditor` hay `python-automation`.*
3. **Thực Thi Code Bằng Tool (Action):**
   - AI dùng tool `write_to_file` để tự tạo/sửa code cục bộ.
4. **Trả Lời Người Dùng:**
   - AI báo cáo kết quả: *"Tôi đã tạo xong file, mời bạn gọi lệnh /test để kiểm chứng"*.

**Tổng kết về mặt Tiêu Hao Token (Token Economics):**
Bằng cách chia nhỏ các file lệnh và skill, AI có một "Context Window" rất sạch sẽ và thông thoáng. Việc này không những giảm từ 30% - 50% phí API cho mỗi prompt, mà còn giúp AI tập trung tuyệt đối vào nhiệm vụ hiện tại, chấm dứt hoàn toàn hiện tượng AI bị "ảo giác" (Hallucination) hoặc quên mất quy tắc Bulkification của Salesforce!
