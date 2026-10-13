# SmartShop — Xây dựng hệ thống thương mại điện tử

SmartShop gồm backend Express/TypeScript/MySQL, web quản trị React/Ant Design và ứng dụng mua sắm React Native/Expo. Thư mục dự án thực tế mang tên `SmartShop`, chứa `BE`, `FE` và Git. Mở thư mục `SmartShop` trong IDE và mở terminal mới tại đây để chạy ứng dụng.

## Giao diện và danh mục

Giao diện thống nhất với xanh indigo, nền sáng, logo túi mua sắm và màu sắc riêng cho nhóm hàng. Trang chủ có danh mục, sản phẩm, voucher, điểm danh, vòng quay và giới thiệu bạn bè. Danh sách sản phẩm hỗ trợ tìm kiếm, lọc danh mục/thương hiệu/khoảng giá, sắp xếp và phân trang. Admin hỗ trợ xem sản phẩm dạng lưới hoặc bảng, quản lý hình ảnh, thuộc tính và biến thể.

Database hoạt động là `smartshop`, có 9 danh mục, 96 sản phẩm, 192 biến thể và 8 thương hiệu mẫu:

| Danh mục | Ví dụ sản phẩm |
| --- | --- |
| Điện thoại & phụ kiện | Nova S, sạc USB-C, ốp lưng |
| Máy tính & văn phòng | Laptop, bàn phím, chuột |
| Âm thanh & công nghệ | Tai nghe, loa, đồng hồ |
| Thời trang | Áo thun, sơ mi, áo khoác, jeans |
| Giày dép & túi xách | Sneaker, balo, túi tote |
| Làm đẹp & chăm sóc | Serum, kem dưỡng, sữa rửa mặt, dầu gội |
| Nhà cửa & đời sống | Đèn, ghế, bình giữ nhiệt, chậu cây |
| Thể thao & ngoài trời | Thảm yoga, tạ, bóng rổ, bình nước |
| Sách & văn phòng phẩm | Sổ, sách, bút màu |

Dữ liệu giá, thuộc tính và thương hiệu phục vụ minh họa đồ án. Mỗi sản phẩm dùng một ảnh sản phẩm riêng lấy từ nguồn bán lẻ, minh họa đúng loại hàng; các tên mẫu SmartShop không xác nhận model/nhãn hiệu trong ảnh. Danh sách 96 ảnh và URL nguồn nằm trong `BE/database/smartshop-product-photos.mjs`; ảnh lưu tại `/uploads/smartshop/real-photos/`. Đã kiểm tra SHA-256 và độ tương đồng hình ảnh để loại ảnh trùng, đồng thời rà soát bảng ảnh theo từng danh mục. Ảnh được lưu ở BE nên giao diện không phụ thuộc trực tiếp vào máy chủ ảnh bên ngoài.

Bộ mở rộng ở `BE/database/smartshop-expanded-catalog.mjs` bổ sung 60 sản phẩm: 7 sản phẩm cho mỗi danh mục trong 6 danh mục đầu, 6 sản phẩm cho mỗi danh mục còn lại. Mỗi sản phẩm có 2 biến thể và 10 thuộc tính bổ sung trong nhóm Thông tin sản phẩm; các thuộc tính đặc thù cũ được giữ, tổng cộng 12 thuộc tính mỗi sản phẩm. Với database đã có bộ 36 sản phẩm ban đầu, tải ảnh bằng `npm run assets:smartshop` rồi chạy `npm run expand:catalog -- --apply` từ `BE` để bổ sung; lệnh giữ dữ liệu hiện có và không tạo trùng khi chạy lại. Cài đặt mới bằng `init:smartshop` sử dụng luôn bộ 96 sản phẩm.

## Chức năng được giữ

Trợ lý AI dùng Google Gemini đã được bổ sung cho khách hàng. Hướng dẫn cấu hình API key và phạm vi hỗ trợ ở [CHATBOT.md](CHATBOT.md).

- Xác thực, đăng ký, đăng xuất, khôi phục/đổi mật khẩu, refresh token và quản lý phiên.
- Phân quyền quản trị viên/nhân viên/khách hàng; cấp quyền theo nhóm chức năng.
- CRUD danh mục, thương hiệu, sản phẩm, nhiều hình ảnh, thuộc tính và biến thể.
- Giỏ hàng, mua ngay, báo giá, địa chỉ giao hàng, đặt hàng COD và áp dụng voucher.
- Xử lý đơn, hủy/hoàn kho, xác nhận nhận hàng, mua lại và đánh giá sau mua.
- Voucher công khai/cá nhân, nhận voucher, điểm danh, tích xu, mốc thưởng, vòng quay và giới thiệu bạn bè.
- Quản lý khách hàng, nhân viên, liên hệ/phản hồi, thông báo, nhập kho, dashboard, báo cáo và xuất Excel/in đơn.

Đơn hàng, giỏ hàng, đánh giá, liên hệ, thông báo và lịch sử thưởng cũ không được đưa vào database mới. Database nguồn `dien_gia_dung` đã được xóa sau khi kiểm tra bản sao lưu. Bản xuất đầy đủ nằm trong `BE/database/backups/`, được loại khỏi Git vì chứa dữ liệu tài khoản cũ.

## Tài khoản mới

| Tên đăng nhập | Vai trò | Phân hệ |
| --- | --- | --- |
| `admin` | Quản trị viên | Web quản trị / Mobile |
| `nhanvien` | Nhân viên có các quyền vận hành | Web quản trị |
| `khachhang` | Khách hàng | Mobile |

Mật khẩu mẫu của cả ba tài khoản: `123456`. Hai voucher mẫu: `SMART50` (giảm 50.000đ cho đơn từ 500.000đ), `SMART10` (giảm 10%, tối đa 100.000đ cho đơn từ 300.000đ). Voucher có hiệu lực 90 ngày kể từ lúc tạo dữ liệu.

Bộ tài khoản bổ sung gồm 10 nhân viên `nhanvien01`–`nhanvien10` (mỗi tài khoản liên kết một hồ sơ nhân viên) và 60 khách hàng `khachhang01`–`khachhang60`, mật khẩu mặc định `123456`. Nhân viên mới dùng các quyền nghiệp vụ của tài khoản mẫu `nhanvien`; quản trị viên có thể điều chỉnh trong trang Nhân viên. Chạy `npm run seed:accounts -- --apply` từ `BE` để thêm bộ này trên máy khác; lệnh giữ nguyên tài khoản, mật khẩu và quyền đã tồn tại, không tạo trùng hồ sơ nhân viên.

Họ tên sử dụng tên người Việt, ví dụ `nhanvien01` là Nguyễn Văn An, `nhanvien02` là Trần Thị Thu Hà, `khachhang01` là Nguyễn Minh Anh. Danh sách tên nằm trong `BE/database/smartshop-account-names.mjs`. Để cập nhật bộ tên này cho tài khoản đã tạo bằng phiên bản trước, chạy `node scripts/update-smartshop-account-names.mjs --apply` từ `BE`; lệnh đồng bộ họ tên tài khoản/hồ sơ nhân viên, giữ nguyên mật khẩu và các trường dữ liệu khác.

## Khởi chạy

Mở terminal ở thư mục dự án chứa `BE` và `FE`:

```powershell
cd BE
npm run dev
```

```powershell
cd FE/admin
npm run dev
```

```powershell
cd FE/Mobile
npx expo start --clear
```

BE dùng `DB_NAME=smartshop` trong `.env`. Nếu terminal BE/Expo đang chạy trước khi chuyển đổi, khởi động lại để tải cấu hình mới. Đăng xuất phiên cũ và dùng tài khoản mới. API mặc định: `http://localhost:3000/api`; web quản trị thường ở `http://localhost:5173`.

Bản web của ứng dụng mua sắm xuất theo chế độ SPA (`web.output=single`), phù hợp với dữ liệu và phiên đăng nhập tải từ API. Khi đưa lên hosting, cấu hình các đường dẫn ứng dụng về `index.html` để hỗ trợ tải lại trang chi tiết sản phẩm/đơn hàng.

## Cài đặt database trên máy khác

Cài dependencies BE bằng `npm install`, sao chép `.env.example` thành `.env` và điền thông tin MySQL. Chạy từ `BE`:

Công cụ tải/kiểm tra ảnh cần Python cùng Pillow và ImageHash: `python -m pip install Pillow ImageHash`. Có thể đặt `PYTHON_BIN=python3` nếu tên lệnh Python trên máy khác là `python3`; BE đang chạy không cần Python.

```powershell
npm run init:smartshop
npm run assets:smartshop
npm run dev
```

`init:smartshop` tạo database từ `database/smartshop-schema.sql` (bao gồm bảng, stored procedures, triggers và events), sau đó tạo bộ dữ liệu mới. Nó từ chối ghi đè database đã tồn tại. Trên Windows, MySQL CLI mặc định ở `C:/Program Files/MySQL/MySQL Server 8.0/bin`; có thể cấu hình `MYSQL_BIN` nếu cài ở nơi khác.

Nếu đã nhập schema thủ công vào database `smartshop` rỗng thì chạy `npm run seed`. Lệnh này từ chối thêm lại bộ dữ liệu vào database đã có danh mục hoặc tài khoản.

Muốn thay toàn bộ dữ liệu SmartShop một lần nữa:

```powershell
npm run setup:smartshop -- --apply --reset --from-schema
npm run assets:smartshop
```

Lệnh reset tự xuất bản sao lưu trước khi tạo lại database. Các migrations chung tiếp tục giữ logic thương mại điện tử; migration SmartShop bỏ qua dữ liệu mẫu tủ lạnh/quạt/Tivi cũ.

## Kiểm tra

```powershell
# BE
npm test
node scripts/verify-smartshop.mjs

# FE/admin
npm run build
npm run test:e2e

# FE/Mobile
npm run typecheck
npm test
npx expo export --platform web
```

`verify-smartshop.mjs` kiểm tra API thật với bộ dữ liệu mẫu: tài khoản, danh mục, sản phẩm, bộ lọc, ảnh, phân quyền, thưởng, voucher và báo giá mua ngay. Nó không tạo đơn hàng.

Đã bổ sung lịch sử nhập ban đầu cho 96 sản phẩm: 192 dòng theo biến thể, tổng 3.840 đơn vị, có nhân viên phụ trách, giá nhập và nhà cung cấp mẫu. Các dòng ghi rõ `[TON-DAU-KY:...]` để phân biệt lịch sử được bổ sung với thao tác nhập hàng mới. Lệnh `npm run backfill:inventory -- --apply` từ `BE` tính phần lịch sử còn thiếu bằng tồn hiện có cộng lượng trong đơn chưa hủy, trừ lượng nhập đã ghi nhận. Lệnh không tăng tồn kho, không sửa phiếu cũ và không tạo trùng khi chạy lại với lịch sử đầy đủ.

Để kiểm tra các thao tác quản trị với schema và dữ liệu hiện tại, khởi chạy `FE/admin` rồi chạy `npm run verify:admin` từ `BE`. Lệnh tạo database tạm, dùng BE riêng ở cổng 3014 và kiểm tra trang quản trị, CRUD, thuộc tính/ảnh/biến thể, phân quyền, nhập kho, voucher, đơn hàng, đánh giá, liên hệ, hồ sơ và xuất Excel. Database tạm được xóa khi kiểm tra kết thúc; database cửa hàng không bị sửa. Cần MySQL CLI, Chrome và dependencies của `FE/admin`; có thể đặt `ADMIN_TEST_URL` nếu admin không chạy ở `http://localhost:5173`.
