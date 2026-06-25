# VCR-CRM Agentic Vibe Code Architecture

## 1. Mục đích và Công dụng (Purpose & Usage)
Cấu trúc "Vibe Code" này được thiết kế để nâng cấp AI từ một "trợ lý chat" thụ động thành một **Đội ngũ kỹ sư phần mềm chủ động (Agentic Workflow)** chuyên biệt cho nền tảng Salesforce.

Thay vì dựa vào khả năng phán đoán của AI, cấu trúc này ép AI phải làm việc theo một chuỗi dây chuyền công nghiệp: **Lấy Ngữ Cảnh -> Xác định Quy Trình (Skill) -> Thực Thi -> Kiểm Chứng bằng Tool -> Lưu Trữ Bộ Nhớ.**

### 🛠️ Cách Vận Hành (Workflow)
1. **Khởi động (Context Loading):** Khi bạn giao task, điều đầu tiên AI BẮT BUỘC phải làm là đọc file `MEMORY.md` ở thư mục gốc để nắm trạng thái hiện tại (Đã làm gì, có bug nào, bước tiếp theo là gì).
2. **Điều phối (Skill Dispatching):** Dựa vào Meta-Skill hoặc `.clinerules`, AI xác định nghiệp vụ cần làm (VD: Viết Apex, Audit Metadata, Cấu hình Flow) và tự động kéo đúng file `SKILL.md` tương ứng trong thư mục `skills/` ra để đọc.
3. **Thực thi (Execution):** AI không được tự do code theo ý thích. Nó phải làm theo đúng từng bước (Step-by-step Process) được định nghĩa trong `SKILL.md` (Ví dụ: Luôn phải Bulkify code Apex, không đặt SOQL trong vòng lặp).
4. **Kiểm duyệt (Verification Gates):** AI không được quyền kết thúc task nếu chưa chạy các công cụ MCP (như `@salesforce/mcp` để deploy hoặc run test) và lấy output log làm bằng chứng.
5. **Đóng phiên (Post-session Hook):** Khi mọi việc hoàn tất, AI sẽ chạy file `hooks/post-session-memory-update.md` để tự động tổng hợp những gì vừa làm và ghi đè vào `MEMORY.md`.

---

## 2. Tối Ưu Hiệu Năng & Mức Tiêu Hao Token
Cấu trúc này giải quyết được vấn đề lớn nhất của các setup "vibe" đời cũ (như nhồi nhét tất cả vào 1 file `.cursorrules` khổng lồ).

### 📉 Về Token & Chi phí (Tiết kiệm cực lớn)
*   **Vibe cũ (Monolithic Rules):** Bất kể bạn yêu cầu AI làm gì (dù chỉ đổi màu text), AI cũng phải đọc lại toàn bộ bộ luật (Apex, UI, Flow, Security, Git). Điều này làm mất hàng chục ngàn Token Input vô ích cho mỗi lần enter.
*   **Vibe mới (Lazy Loading):** Phân mảnh theo nguyên lý RAG. AI chỉ nạp đúng những gì nó cần. Khi code Apex, nó chỉ đọc `skills/salesforce-apex-dev/SKILL.md`. Việc tải ngữ cảnh nhẹ đi **70-80%**, tiết kiệm chi phí API và giúp model sinh text nhanh hơn.

### 🚀 Về Hiệu năng & Chất lượng Code
*   **Tránh ảo giác (No Hallucination):** Việc áp dụng *Verification Gates* và *Anti-Rationalization* khóa chặt thói quen "code đại, lười test, biện minh" của AI.
*   **Không suy thoái trí nhớ (Zero Context Degradation):** Khi phiên chat quá dài, AI thường quên luật. Với cấu trúc này, Quy trình được chuẩn hóa ở file tĩnh, còn Bộ nhớ động nằm ở `MEMORY.md`. AI chỉ cần đọc lại 2 file này là reset lại trạng thái minh mẫn 100%.

---

## 3. Cấu trúc Thư mục

```text
agent-skills/
├── skills/          # Các quy trình thực thi chính (Apex Dev, E2E Test, v.v.)
├── agents/          # Định nghĩa vai trò (Persona) như Senior Architect, QA
├── references/      # Các bảng Checklist dùng chung (Security, Limits)
├── hooks/           # Kịch bản tự chạy (như update MEMORY.md khi kết thúc)
└── README.md        # File này
```
