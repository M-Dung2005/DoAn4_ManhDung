import assert from 'node:assert/strict';
import { chromium } from '@playwright/test';
import { mkdir } from 'node:fs/promises';
import { resolve } from 'node:path';

const live = process.env.CHATBOT_TEST_MODE === 'live';
const backend = process.env.CHATBOT_TEST_BACKEND || (live ? 'http://localhost:3000' : 'http://localhost:3012');
const directory = resolve('../../docs/previews');
await mkdir(directory, { recursive: true });
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 });
page.setDefaultTimeout(15000);
const errors = [];
page.on('pageerror', error => { errors.push(error.message); console.log('Chatbot UI error:', error.message); });
const requests = [];
await page.route('**/api/**', async route => {
  const original = new URL(route.request().url());
  if (original.pathname.endsWith('/chatbot/messages')) requests.push(route.request().postDataJSON());
  await route.fulfill({ response: await route.fetch({ url: `${backend}${original.pathname}${original.search}` }) });
});
const auth = await fetch(backend + '/api/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Client-Platform': 'mobile' }, body: JSON.stringify({ ten_dang_nhap: 'khachhang', mat_khau: '123456' }) }).then(response => response.json());
assert.equal(auth.success, true);
try {
  await page.addInitScript(session => { localStorage.setItem('token', session.token); localStorage.setItem('user', JSON.stringify(session.user)); localStorage.setItem('refresh_token', session.refresh_token); }, auth.data);
  await page.goto(process.env.CHATBOT_TEST_SHOP || 'http://localhost:8083/');
  await page.getByRole('button', { name: 'Mở trợ lý AI SmartShop' }).click();
  const input = page.getByRole('textbox', { name: 'Câu hỏi cho trợ lý AI' });
  await input.waitFor(); await page.waitForFunction(() => !document.querySelector('[aria-label="Câu hỏi cho trợ lý AI"]')?.hasAttribute('readonly'));
  await input.fill('Tôi cần áo thun dưới 500.000đ');
  await page.getByRole('button', { name: 'Gửi câu hỏi', exact: true }).click();
  await page.getByRole('button', { name: 'Xem Áo thun cotton Essential', exact: true }).waitFor();
  assert.equal(requests.length, 1); assert.equal(requests[0].history.length, 0);
  const composerBox = await input.boundingBox();
  assert.ok(composerBox && composerBox.y >= 0 && composerBox.y + composerBox.height <= 844, 'Chat input must stay in the viewport after a reply');
  await page.screenshot({ path: resolve(directory, live ? 'chatbot-real.png' : 'chatbot-preview-simulated.png'), fullPage: true });
  if (!live) {
  await input.fill('Kiểm tra lỗi và thử lại');
  await page.getByRole('button', { name: 'Gửi câu hỏi', exact: true }).click();
  await page.getByText('Trợ lý đang bận. Bạn hãy thử lại sau ít phút.', { exact: true }).waitFor();
  await page.getByText('Thử lại', { exact: true }).click();
  await page.waitForFunction(() => document.querySelectorAll('[aria-label="Xem Áo thun cotton Essential"]').length === 2);
  assert.equal(requests.length, 3); assert.deepEqual(requests[1], requests[2]);
  assert.equal(await page.getByText('Kiểm tra lỗi và thử lại', { exact: true }).count(), 1);
  await page.getByRole('button', { name: 'Bắt đầu cuộc trò chuyện mới' }).click();
  await page.getByText('Bạn cần tìm điều gì?', { exact: true }).waitFor();
  await page.getByText('Gợi ý sản phẩm dưới 500.000đ', { exact: true }).click();
  await page.getByRole('button', { name: 'Xem Áo thun cotton Essential', exact: true }).click();
  await page.getByRole('button', { name: 'Hỏi AI về sản phẩm này', exact: true }).click();
  await page.getByRole('button', { name: 'Tư vấn giúp tôi sản phẩm đang xem', exact: true }).click();
  await page.getByRole('button', { name: 'Xem Áo thun cotton Essential', exact: true }).last().waitFor();
  assert.equal(requests.at(-1).productId, 13);
  }
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth), false);
  assert.deepEqual(errors, []);
  console.log(live ? 'Chatbot browser check passed with a real Gemini answer and a verified product card.' : 'Chatbot browser check passed: launcher, messages, verified product links, error/retry without duplication, reset and product context. Gemini responses simulated.');
} finally {
  await fetch(backend + '/api/auth/logout', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refresh_token: auth.data.refresh_token }) }).catch(() => {});
  await browser.close();
}
