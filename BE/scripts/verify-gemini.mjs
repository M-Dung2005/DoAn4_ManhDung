// One real Gemini request with the configured key. This consumes the provider's normal quota.
import { pool } from '../dist/config/database.js';
import { chatWithGemini, chatbotConfigured } from '../dist/services/chatbot.service.js';
import { validateChatInput } from '../dist/utils/chatbot.js';

try {
  if (!chatbotConfigured()) throw new Error('Điền GEMINI_API_KEY trong BE/.env trước khi kiểm tra.');
  const [accounts] = await pool.query("SELECT ma_tai_khoan FROM tai_khoan WHERE vai_tro='KhachHang' AND trang_thai='HoatDong' ORDER BY ma_tai_khoan LIMIT 1");
  if (!accounts.length) throw new Error('Cần một tài khoản khách hàng để kiểm tra.');
  const reply = await chatWithGemini(accounts[0].ma_tai_khoan, validateChatInput({ message: 'Tôi muốn mua áo thun dưới 500.000 đồng. Bạn gợi ý sản phẩm nào đang có tại SmartShop?' }));
  console.log('Gemini thật đã phản hồi thành công.');
  console.log(reply.message);
  console.log('Sản phẩm được server xác nhận:', reply.products.map(product => product.ten_san_pham).join(', ') || '(không có gợi ý sản phẩm)');
} catch (error) {
  console.error('Kiểm tra Gemini chưa thành công:', error.code || '', error.message);
  process.exitCode = 1;
} finally { await pool.end(); }
