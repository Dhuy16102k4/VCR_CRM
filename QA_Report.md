# Báo cáo QA: Kiểm tra chéo Tài liệu Dự án và Database/URD gốc

Dưới đây là kết quả kiểm tra các tài liệu phân tách trong `project/docs/` so với file gốc `VCR-CRM_Database_1.0.xlsx` và URD trong thư mục `docs/`. Nhìn chung, các tài liệu trong `project/docs` **chưa hoàn toàn chính xác và còn thiếu sót rất nhiều thông tin quan trọng** so với tài liệu gốc.

---

## 1. Danh sách Object cần tạo/cập nhật
- **Về cơ bản:** Các tài liệu phân tách đã liệt kê được các Object chính (Account, Contact, Brand, Business Entity, Product RO...).
- **Điểm thiếu sót:** Một số object phụ trợ quan trọng có trong Database nhưng chưa thấy file `.md` tương ứng trong thư mục master data, ví dụ như: `Advertising Target`, `Sales T+3 & Achievement Target`, `Approval Process` definitions, v.v.

---

## 2. Danh sách Field (Label, API Name, Datatype, Required)
Rất nhiều field trong `project/docs` bị sai tên API, sai kiểu dữ liệu hoặc bị thiếu so với DB.

### 2.1. Khách Thuê (Account) - `01_account.md`
- **Thiếu rất nhiều field:** `Revenue__c`, `Vincom_Usual_Rental_Area__c`, `Total_Area_Renting_At_Vincom__c`, `Number_Of_RO_In_Shop_House__c`, `Number_Of_RO_In_Vincom__c`, các trường Địa chỉ (Country_1__c, Province_1__c, ...), `Account_Short_Name__c`, `Contact_Role__c`.
- **Sai API Name:**
  - `Enterprise_Code__c` ➔ Thực tế DB là `Enterprise_Code_Certificate__c`
  - `ID_Number__c` ➔ Thực tế DB là `ID_Number_Passport__c`
  - `RO_Worldwide__c` ➔ Thực tế DB là `Number_Of_RO_Worldwide__c`
  - `RO_Vietnam__c` ➔ Thực tế DB là `Number_Of_RO_In_Vietnam__c`
- **Thiếu công thức (Formula):** Các trường Ngân hàng như `Bank_Name__c`, `Bank_Country__c`, `Bank_Code__c` trong DB là Formula nhưng trong tài liệu không đề cập rõ ràng định dạng Formula.

### 2.2. Người Liên Hệ (Contact) - `02_contact.md`
- **Sai API Name / Nhầm Field:** MD ghi `Is_Primary__c` nhưng DB là `Primary_Contact__c`.
- **Thiếu Field:** MD liệt kê 2 Custom Fields, nhưng DB yêu cầu các trường địa chỉ (Country_1__c, Province_1__c, District_1__c, Ward_1__c, v.v.) và trường `Contact_Role__c`.

### 2.3. Thương Hiệu (Brand) - `03_brand.md`
- **Dư Field / Field không tồn tại trong DB:** `Brand_Code__c`, `Brand_Type__c`, `Active__c`, `Logo_URL__c`. (Các field này không có trong sheet KD | Thương Hiệu của DB 1.0).
- **Sai API Name:** 
  - `Investment_Cost_Per_M2__c` ➔ Thực tế DB là `Investment_Cost_m2__c`
  - `Is_A_Chain__c` ➔ Thực tế DB là `Is_a_Chain__c`

### 2.4. Business Entity & Product RO
- **Sai sót tương tự:** Rất nhiều trường Formula (Occupation__c, Unit_Price_VND_m2_Month__c, ...) và các trường tính diện tích không được map chính xác API Name 100% so với Database.

---

## 3. Relationship giữa các Object
- **Account - Brand Relationship:** DB có định nghĩa Custom Object `AccountBrandRelationship` (Junction Object). Trong thư mục docs có file `07_account_brand_relationship.md` nhưng các trường thiếu sự đồng bộ (DB yêu cầu `Type__c`, `Account__c`, `Brand_Name__c`...).
- **Product RO & Business Entity:** Các quan hệ Master-Detail/Lookup đa phần đúng về mặt kiến trúc, nhưng cần map chuẩn xác tên field Lookup (VD: DB ghi `Business_Entity__c`, cần đảm bảo API chính xác).

---

## 4. Validation Rule (Tên, Điều kiện, Lỗi)
Có sự sai lệch lớn giữa tài liệu phân tách và file Excel gốc.

### Account:
- **Tài liệu dự án:** Liệt kê `Require_TaxCode_When_Closed`, `Require_EnterpriseCode_When_Deposit`, `Require_ID_When_Deposit`.
- **Database Excel:** Hoàn toàn không ghi nhận 3 rule này trong sheet `Validation (final)`. Thay vào đó, DB yêu cầu:
  1. Bắt buộc nhập Trading Partner.
  2. Bắt buộc chọn Thương Hiệu trên Khách Thuê (tùy bộ phận).
  3. Nhập đúng định dạng Điện Thoại (bắt đầu từ '0', không bắt đầu '00', 10 hoặc 11 số).
  4. Phân Loại = Pháp Nhân Vincom thì bắt buộc Trạng Thái = Đang Hoạt Động.

### Brand:
- **Tài liệu dự án:** Rule `Require_Contact_Info` (Contact hoặc (Mobile + Email)).
- **Database Excel:** Bắt buộc nhập thông tin Người Liên Hệ hoặc **(Tên Người Liên Hệ và Di Động)** ➔ Tài liệu dự án đang nhầm sang Email.

### Contact:
- **Tài liệu dự án:** `Require_Phone_Or_Email`, `Require_Account`.
- **Database Excel:** Yêu cầu Ngày Sinh nhỏ hơn ngày hiện tại; Bắt buộc nhập ĐTDĐ, ĐTDĐ 1 hoặc Email; Đúng định dạng số ĐTDĐ.

---

## 5. Duplicate Rule (Matching, Action, Alert Message)

### Account:
- **Tài liệu dự án:** Trùng tên Account, trùng Số Điện Thoại.
- **Database Excel:**
  - Trùng chính xác **MST** (Cảnh báo và Block).
  - Trùng chính xác **Điện Thoại** (Cảnh báo và Allow). 
  - *Không hề có rule trùng tên Account trong DB Duplicate sheet.*

### Contact:
- **Tài liệu dự án:** Trùng Email chính xác, Trùng SĐT chính xác.
- **Database Excel:**
  - Rule 1: Trùng chính xác Họ và Di Động HOẶC Họ và Di Động 1 HOẶC Họ và Email (Block).
  - Rule 2: Trùng chính xác Di Động HOẶC Di Động 1 HOẶC Email HOẶC trùng fuzzy Họ (Allow).

---

## KẾT LUẬN & ĐỀ XUẤT
Tài liệu tách nhỏ `@project/docs` đang bị **"Out-of-sync"** (Lệch pha) nghiêm trọng so với Database Document `VCR-CRM_Database_1.0.xlsx`. 
**Đề xuất hành động:**
1. Cần chạy một lượt rà soát lại toàn bộ API Name trong thư mục `project/docs/` để đồng nhất với các cột API Name trong file Database Excel.
2. Cập nhật lại toàn bộ Validation Rule và Duplicate Rule theo đúng định nghĩa ở sheet `KD | Validation (final)` và `KD | Duplication`.
3. Bổ sung các field bị thiếu sót (đặc biệt là các trường Formula, Roll-up và các trường tính toán hệ thống).
