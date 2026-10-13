// Test-only preview: real store database, simulated Gemini responses. Never imported by app.ts.
import dotenv from 'dotenv';
dotenv.config();
process.env.PORT = '3012';
process.env.GEMINI_API_KEY = 'preview-test-key';
const originalFetch = globalThis.fetch;
let failNext = true;
globalThis.fetch = async (url, options) => {
  if (!String(url).startsWith('https://generativelanguage.googleapis.com/')) return originalFetch(url, options);
  const body = JSON.parse(options.body);
  const contextText = body.systemInstruction.parts[1].text;
  const context = JSON.parse(contextText.slice(contextText.indexOf('\n') + 1));
  const latest = body.contents.at(-1).parts.at(-1).text;
  if (latest === 'Tôi cần áo thun dưới 500.000đ') failNext = true;
  if (latest.includes('Kiểm tra lỗi') && failNext) { failNext = false; return new Response('{}', { status: 429 }); }
  const product = context.products.find(product => product.ma_san_pham === context.productInQuestion) || context.products.find(product => product.ten_san_pham.includes('Áo thun'));
  const reply = { message: `Bạn có thể tham khảo ${product.ten_san_pham}. Chọn phiên bản ở trang sản phẩm trước khi mua.`, productIds: [product.ma_san_pham, 999999], actions: ['products','contact'], handoff: false };
  return new Response(JSON.stringify({ candidates: [{ finishReason: 'STOP', content: { parts: [{ text: JSON.stringify(reply) }] } }] }), { status: 200, headers: { 'Content-Type': 'application/json' } });
};
await import('../dist/app.js');
