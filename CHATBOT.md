# Trợ lý AI SmartShop — Google Gemini

Chatbot được mở bằng nút **Hỏi AI** ở trang chủ, danh sách sản phẩm hoặc tài khoản. Khách cũng có thể bấm **Hỏi AI về sản phẩm này** ở trang chi tiết để gửi kèm mã sản phẩm.

## Cấu hình

Tạo API key trong [Google AI Studio](https://aistudio.google.com/apikey), rồi điền vào `BE/.env`. Google hướng dẫn sử dụng key ở [tài liệu Gemini API](https://ai.google.dev/gemini-api/docs/api-key).

```dotenv
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-3.1-flash-lite
GEMINI_TIMEOUT_MS=45000
```

Lưu file và khởi động lại BE (`npm run dev`). Nếu cổng 3000 đã có phiên BE đang chạy, dừng phiên đó bằng Ctrl+C rồi chạy lại. Không đặt key trong `FE/Mobile/.env` hoặc biến `EXPO_PUBLIC_*`. `.env` của BE đã được loại khỏi Git.

Mặc định dùng `gemini-3.1-flash-lite`, đã có trong danh sách model trả về cho API key của dự án. Có thể đổi `GEMINI_MODEL` thành model Gemini có quyền truy cập và hỗ trợ JSON schema. Danh sách model nằm trong [tài liệu Google](https://ai.google.dev/gemini-api/docs/models). Backend dùng REST [generateContent](https://ai.google.dev/api/generate-content) và [structured outputs](https://ai.google.dev/gemini-api/docs/generate-content/structured-output), không cần cài thêm SDK.

## Chức năng

- Tư vấn từ tên, danh mục, thương hiệu, giá, tồn kho, thuộc tính và biến thể trong database hiện tại.
- Gợi ý tối đa 3 sản phẩm, có thẻ mở trang chi tiết; ID ngoài dữ liệu không được tạo liên kết.
- Đọc tối đa 5 đơn gần nhất, 20 dòng giỏ hàng hoặc 20 voucher của khách khi câu hỏi liên quan.
- Giải thích cách đặt hàng COD, dùng voucher, hủy đơn đang chờ xác nhận, xác nhận nhận hàng và các mục thưởng.
- Ghi nhớ tối đa 8 tin nhắn trước đó trong yêu cầu, cho phép xóa cuộc trò chuyện và thử lại khi lỗi.
- Đưa khách sang màn hình liên hệ nhân viên khi cần xử lý đổi trả, khiếu nại hoặc yêu cầu chưa có chính sách xác nhận.

Chatbot chỉ đọc dữ liệu và chỉ dẫn khách thao tác; không tự tạo/hủy đơn, thanh toán, cấp voucher hay sửa tài khoản. Truy vấn thông tin cá nhân luôn dùng tài khoản từ JWT; không chấp nhận mã tài khoản do client gửi. Không gửi mật khẩu, API key, email, điện thoại hoặc địa chỉ giao hàng từ database sang Gemini. Câu hỏi và phần lịch sử khách nhập sẽ được gửi cho Gemini cùng dữ liệu mua sắm liên quan để trả lời; không lưu lịch sử chat vào database.

Mỗi tài khoản được gửi tối đa 12 yêu cầu/phút, chỉ có một yêu cầu AI đang xử lý. Backend giới hạn độ dài tin nhắn, lịch sử, dữ liệu tra cứu và thời gian chờ. Khi chưa có key, thiếu quota hoặc Gemini lỗi, ứng dụng thông báo tình trạng và cho phép liên hệ nhân viên; không giả lập câu trả lời AI trong ứng dụng thật.

## API

Các endpoint cần Bearer token của khách hàng hoặc quản trị viên:

- `GET /api/chatbot/status`: trạng thái đã cấu hình key; không xác nhận key còn quota hoặc hợp lệ.
- `POST /api/chatbot/messages`: nhận `{ message, history?, productId? }`, trả `{ message, products, actions, handoff }` trong `data`.

## Kiểm tra

```powershell
# Trong BE: kiểm thử không gọi Gemini và không tiêu thụ quota.
npm test

# Trong FE/Mobile
npm run typecheck
npx expo export --platform web
```

Kiểm thử BE dùng phản hồi Gemini mô phỏng để kiểm tra giới hạn đầu vào, quyền sở hữu, bảo vệ key, định dạng JSON, lỗi/timeout/quota, chống gửi trùng và giới hạn theo tài khoản.

Kiểm tra kết nối Gemini thật sau khi cấu hình key: chạy `npm run build` rồi `node scripts/verify-gemini.mjs` trong BE. Lệnh thực hiện một yêu cầu AI thật và sử dụng quota của tài khoản Gemini.

Kiểm tra UI với dữ liệu database thật, phản hồi Gemini mô phỏng: chạy `node scripts/chatbot-preview-server.mjs` trong BE (cổng 3012); mở Expo web ở cổng 8083; chạy `node scripts/test-chatbot.mjs` trong FE/admin. Dừng server kiểm thử sau khi xong. File này không được app thật import. Ảnh `docs/previews/chatbot-preview-simulated.png` là ảnh kiểm thử với phản hồi mô phỏng.
