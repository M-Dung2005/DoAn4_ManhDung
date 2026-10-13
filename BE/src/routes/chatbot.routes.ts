import { Router } from 'express';
import { authenticate, type AuthRequest } from '../middleware/auth.middleware.js';
import { authorize } from '../middleware/role.middleware.js';
import { chatbotConfigured, chatWithGemini } from '../services/chatbot.service.js';
import { ChatbotError, validateChatInput } from '../utils/chatbot.js';
import { sendSuccess } from '../utils/response.js';

const router = Router();
const active = new Set<number>();
const limits = new Map<number, { count: number; until: number }>();
router.use(authenticate, authorize('KhachHang','Admin'));
router.get('/status', (_req, res) => sendSuccess(res, 'Trạng thái trợ lý', { enabled: chatbotConfigured(), provider: 'Google Gemini' }));
router.post('/messages', async (req: AuthRequest, res) => {
  const accountId = req.user!.ma_tai_khoan;
  let acquired = false;
  const abort = new AbortController();
  const disconnected = () => { if (!res.writableEnded) abort.abort(); };
  try {
    const input = validateChatInput(req.body);
    if (active.has(accountId)) throw new ChatbotError(409, 'Trợ lý đang trả lời. Bạn đợi một chút nhé.', 'CHATBOT_PENDING');
    const now = Date.now();
    for (const [id, bucket] of limits) if (bucket.until <= now) limits.delete(id);
    const bucket = limits.get(accountId) || { count: 0, until: now + 60000 };
    if (bucket.count >= 12) { res.setHeader('Retry-After', Math.ceil((bucket.until - now) / 1000)); throw new ChatbotError(429, 'Bạn gửi nhiều câu hỏi liên tiếp. Hãy thử lại sau một phút.', 'CHATBOT_RATE_LIMIT'); }
    bucket.count++; limits.set(accountId, bucket);
    active.add(accountId); acquired = true;
    res.on('close', disconnected);
    const reply = await chatWithGemini(accountId, input, abort.signal);
    if (!res.destroyed) sendSuccess(res, 'Trợ lý đã trả lời', reply);
  } catch (error) {
    if (res.destroyed) return;
    const expected = error instanceof ChatbotError;
    if (!expected) console.warn('Chatbot could not load the store context.');
    res.status(expected ? error.status : 503).json({ success: false, code: expected ? error.code : 'CHATBOT_UNAVAILABLE', message: expected ? error.message : 'Chưa tải được thông tin cửa hàng. Bạn hãy thử lại hoặc gửi liên hệ.' });
  } finally {
    res.off('close', disconnected);
    if (acquired) active.delete(accountId);
  }
});
export default router;
