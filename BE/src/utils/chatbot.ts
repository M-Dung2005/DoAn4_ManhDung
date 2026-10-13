export class ChatbotError extends Error {
  constructor(public status: number, message: string, public code = 'CHATBOT_UNAVAILABLE') { super(message); }
}

export interface ChatMessage { role: 'user' | 'assistant'; content: string }
export interface ChatInput { message: string; history: ChatMessage[]; productId?: number }
export const chatbotActions = ['products', 'orders', 'cart', 'vouchers', 'contact'] as const;
export type ChatbotAction = typeof chatbotActions[number];

export function chatSearchTerms(input: ChatInput) {
  const ignored = new Set(['toi','ban','minh','muon','can','tim','giup','voi','san','pham','cho','cua','hang','mot','nhung','nao','khong','duoi','tren','trieu','nghin','ngan','dong','co','gia','goi','y','tu','van','xin','hay','nhat','nhu','the','dang','xem']);
  const normalize = (term: string) => term.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').toLowerCase();
  const text = [input.message, ...input.history.filter(message => message.role === 'user').slice(-1).map(message => message.content)].join(' ');
  return [...new Set(text.toLowerCase().split(/[^\p{L}\p{N}]+/u).filter(term => term.length >= 2 && term.length <= 40 && /\p{L}/u.test(term) && !ignored.has(normalize(term))))].slice(0, 8);
}

export function geminiContents(input: ChatInput) {
  const contents: { role: 'user' | 'model'; parts: { text: string }[] }[] = [];
  for (const item of [...input.history, { role: 'user' as const, content: input.message }]) {
    const role = item.role === 'assistant' ? 'model' : 'user';
    if (!contents.length && role === 'model') continue;
    const previous = contents.at(-1);
    if (previous?.role === role) previous.parts.push({ text: item.content });
    else contents.push({ role, parts: [{ text: item.content }] });
  }
  return contents;
}

export function validateChatInput(body: unknown): ChatInput {
  if (!body || typeof body !== 'object' || Array.isArray(body)) throw new ChatbotError(400, 'Yêu cầu trò chuyện không hợp lệ.', 'INVALID_CHAT');
  const input = body as Record<string, unknown>;
  if (typeof input.message !== 'string' || !input.message.trim() || input.message.trim().length > 1500) throw new ChatbotError(400, 'Nhập câu hỏi từ 1 đến 1.500 ký tự.', 'INVALID_CHAT');
  const history = input.history ?? [];
  if (!Array.isArray(history) || history.length > 8) throw new ChatbotError(400, 'Lịch sử trò chuyện quá dài. Hãy bắt đầu cuộc trò chuyện mới.', 'INVALID_CHAT');
  let total = input.message.length;
  const messages: ChatMessage[] = history.map(item => {
    if (!item || !['user', 'assistant'].includes(item.role) || typeof item.content !== 'string' || !item.content.trim() || item.content.length > 4000) throw new ChatbotError(400, 'Lịch sử trò chuyện không hợp lệ.', 'INVALID_CHAT');
    total += item.content.length;
    return { role: item.role, content: item.content.trim() };
  });
  if (total > 16000) throw new ChatbotError(400, 'Cuộc trò chuyện quá dài. Hãy bắt đầu cuộc trò chuyện mới.', 'INVALID_CHAT');
  if (input.productId !== undefined && (!Number.isSafeInteger(input.productId) || Number(input.productId) < 1)) throw new ChatbotError(400, 'Sản phẩm tư vấn không hợp lệ.', 'INVALID_CHAT');
  return { message: input.message.trim(), history: messages, ...(input.productId !== undefined ? { productId: Number(input.productId) } : {}) };
}

export function parseChatReply(text: string, allowedProducts: number[]) {
  let value: any;
  try { value = JSON.parse(text); } catch { throw new ChatbotError(503, 'Trợ lý chưa hoàn tất câu trả lời. Bạn hãy thử lại.', 'INVALID_AI_REPLY'); }
  if (!value || typeof value.message !== 'string' || !value.message.trim() || value.message.length > 6000 || !Array.isArray(value.productIds) || !Array.isArray(value.actions) || typeof value.handoff !== 'boolean') throw new ChatbotError(503, 'Trợ lý chưa hoàn tất câu trả lời. Bạn hãy thử lại.', 'INVALID_AI_REPLY');
  return {
    message: value.message.trim(),
    productIds: [...new Set<number>(value.productIds.filter((id: unknown) => Number.isSafeInteger(id) && allowedProducts.includes(Number(id))))].slice(0, 3),
    actions: [...new Set<ChatbotAction>(value.actions.filter((action: unknown) => chatbotActions.includes(action as ChatbotAction)))].slice(0, 4),
    handoff: value.handoff,
  };
}
