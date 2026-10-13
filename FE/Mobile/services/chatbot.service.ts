import api from './api';

export type ChatAction = 'products' | 'orders' | 'cart' | 'vouchers' | 'contact';
export interface ChatHistoryMessage { role: 'user' | 'assistant'; content: string }
export interface ChatProduct { ma_san_pham: number; ten_san_pham: string; gia_ban: number; hinh_anh?: string; ten_danh_muc?: string; so_luong: number }
export interface ChatReply { message: string; products: ChatProduct[]; actions: ChatAction[]; handoff: boolean }
export interface ChatPayload { message: string; history: ChatHistoryMessage[]; productId?: number }

export const chatbotService = {
  status: async () => (await api.get('/chatbot/status')).data.data as { enabled: boolean; provider: string },
  send: async (payload: ChatPayload, signal: AbortSignal) => (await api.post('/chatbot/messages', payload, { timeout: 70000, signal })).data.data as ChatReply,
};
