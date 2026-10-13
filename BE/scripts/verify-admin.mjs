// Exercise the running admin source against a disposable copy of the current database.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve, dirname, basename } from 'node:path';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import { chromium } from '../../FE/admin/node_modules/@playwright/test/index.mjs';

dotenv.config();
const database = `smartshop_admin_test_${Date.now()}_${process.pid}`;
const config = { host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '' };
const connection = await mysql.createConnection(config);
const temporary = await mkdtemp(join(tmpdir(), 'smartshop-admin-'));
const defaults = join(temporary, 'client.cnf');
const quote = value => '"' + String(value).replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r') + '"';
const bin = process.env.MYSQL_BIN || 'C:/Program Files/MySQL/MySQL Server 8.0/bin';
const client = (name, args, input) => {
  const executable = process.platform === 'win32' ? join(bin, `${name}.exe`) : name;
  const result = spawnSync(executable, [`--defaults-extra-file=${defaults}`, ...args], { input, encoding: 'utf8', windowsHide: true, maxBuffer: 64 * 1024 * 1024 });
  if (result.error || result.status !== 0) throw new Error(`${name} failed; check local MySQL client configuration.`);
  return result.stdout;
};
let server, browser, created = false;
let admin, customer;
let serverErrors = '';
const failures = [];
const base = 'http://127.0.0.1:3014/api';
const frontend = process.env.ADMIN_TEST_URL || 'http://localhost:5173';
async function request(path, session = admin, method = 'GET', body, expected = 200) {
  const response = await fetch(base + path, { method, headers: { 'Content-Type': 'application/json', ...(session ? { Authorization: `Bearer ${session.token}` } : {}) }, ...(body ? { body: JSON.stringify(body) } : {}) });
  const json = await response.json();
  assert.equal(response.status, expected, `${method} ${path}: ${JSON.stringify(json)}`);
  return json;
}
async function check(name, action) {
  try { await action(); console.log('PASS:', name); }
  catch (error) { failures.push(`${name}: ${error.message}`); console.log('FAIL:', name, error.message); }
}
try {
  await writeFile(defaults, `[client]\nhost=${quote(config.host)}\nport=${config.port}\nuser=${quote(config.user)}\npassword=${quote(config.password)}\ndefault-character-set=utf8mb4\n`, { mode: 0o600 });
  const source = process.env.DB_NAME || 'smartshop';
  const dump = client('mysqldump', ['--single-transaction', '--routines', '--triggers', '--no-tablespaces', '--set-gtid-purged=OFF', '--column-statistics=0', source]);
  assert.ok(dump.includes('Dump completed'), 'Database copy did not complete');
  await connection.query(`CREATE DATABASE \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
  created = true;
  client('mysql', [`--database=${database}`], dump);
  server = spawn(process.execPath, ['dist/app.js'], { cwd: resolve('.'), env: { ...process.env, DB_NAME: database, PORT: '3014', GEMINI_API_KEY: '', LOG_TO_FILE: 'false', NODE_ENV: 'test' }, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
  server.stdout.on('data', () => {});
  server.stderr.on('data', chunk => { serverErrors += chunk.toString(); });
  for (let attempt = 0; attempt < 40; attempt++) {
    if (server.exitCode !== null) throw new Error('Disposable BE could not start. Ensure port 3014 is free.');
    try { await request('/health', null); break; } catch { await new Promise(r => setTimeout(r, 250)); }
  }
  admin = (await request('/auth/login', null, 'POST', { ten_dang_nhap: 'admin', mat_khau: '123456' })).data;
  customer = (await request('/auth/login', null, 'POST', { ten_dang_nhap: 'khachhang', mat_khau: '123456' })).data;
  browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
  page.setDefaultTimeout(12000);
  page.on('pageerror', e => failures.push(`Browser: ${e.message}`));
  await page.route('**/api/**', async route => {
    const original = new URL(route.request().url());
    if (!original.pathname.startsWith('/api/')) return route.continue();
    await route.fulfill({ response: await route.fetch({ url: `http://127.0.0.1:3014${original.pathname}${original.search}` }) });
  });
  await page.addInitScript(data => { localStorage.setItem('admin_token', data.token); localStorage.setItem('admin_refresh_token', data.refresh_token); }, admin);
  await check('All admin pages load with the actual database schema', async () => {
    for (const route of ['dashboard', 'products', 'categories', 'brands', 'category-specifications', 'orders', 'reviews', 'contacts', 'customers', 'employees', 'inventory', 'vouchers', 'reports', 'account']) {
      await page.goto(`${frontend}/${route}`);
      await page.locator('.page h1, .page h2, .page h3, .page h4').first().waitFor();
      await page.waitForTimeout(400);
      assert.equal(await page.locator('.load-error').count(), 0, route);
    }
  });
  await check('Category and brand create, edit, detail, search, delete in browser', async () => {
    for (const [route, label] of [['categories', 'Tên danh mục'], ['brands', 'Tên thương hiệu']]) {
      await page.goto(`${frontend}/${route}`);
      await page.getByRole('button', { name: 'Thêm mới', exact: true }).click();
      await page.getByLabel(label, { exact: true }).fill('ADMIN_VERIFY_TEMP');
      await page.getByRole('button', { name: 'Lưu', exact: true }).click();
      const row = page.getByRole('row').filter({ hasText: 'ADMIN_VERIFY_TEMP' });
      await row.getByRole('button', { name: 'Sửa', exact: true }).click();
      await page.getByLabel(label, { exact: true }).fill('ADMIN_VERIFY_TEMP_EDIT');
      await page.getByRole('button', { name: 'Lưu', exact: true }).click();
      await page.getByLabel('Tìm kiếm', { exact: true }).fill('ADMIN_VERIFY_TEMP_EDIT');
      await row.getByRole('button', { name: 'Xem chi tiết', exact: true }).click();
      await page.locator('.ant-drawer-close').click();
      await row.getByRole('button', { name: 'Xóa', exact: true }).click();
      await page.getByRole('dialog').getByRole('button', { name: 'Xóa', exact: true }).click();
      await row.waitFor({ state: 'detached' });
    }
  });
  let productId, variantId;
  await check('Product create, update, images, specifications, variants and search', async () => {
    await page.goto(`${frontend}/products`);
    await page.getByText('Bảng', { exact: true }).click();
    await page.getByRole('button', { name: 'Thêm sản phẩm', exact: true }).click();
    await page.getByLabel('Mã sản phẩm', { exact: true }).fill('ADMIN-VERIFY-TEMP');
    await page.getByLabel('Tên sản phẩm', { exact: true }).fill('ADMIN_VERIFY_TEMP');
    await page.getByLabel('Danh mục', { exact: true }).click();
    await page.getByTitle('Thời trang', { exact: true }).last().click();
    await page.getByLabel('Thương hiệu', { exact: true }).click();
    await page.getByTitle('UrbanWear', { exact: true }).last().click();
    await page.getByLabel('Giá bán (VNĐ)', { exact: true }).fill('500000');
    await page.getByRole('button', { name: 'Lưu', exact: true }).click();
    const row = page.getByRole('row').filter({ hasText: 'ADMIN_VERIFY_TEMP' });
    await row.waitFor();
    await row.getByRole('button', { name: 'Sửa sản phẩm', exact: true }).click();
    await page.getByLabel('Giá bán (VNĐ)', { exact: true }).fill('510000');
    await page.getByRole('button', { name: 'Lưu', exact: true }).click();
    await page.getByRole('dialog').waitFor({ state: 'detached' });
    const products = (await request('/san-pham?search=ADMIN-VERIFY-TEMP')).data;
    assert.equal(products.length, 1);
    productId = products[0].ma_san_pham;
    const detail = (await request(`/san-pham/${productId}`)).data;
    assert.equal(Number(detail.gia_ban), 510000);
    await request(`/san-pham/${productId}`, admin, 'PUT', { ...detail, gia_ban: Number(detail.gia_ban), gia_nhap: 100000, so_luong: 0, variants: [{ ma_sku: 'ADMIN-VERIFY-TEMP-V1', ten_bien_the: 'Kiểm thử M', gia_ban: 510000, so_luong: 5, trang_thai: 'DangBan' }], thong_so: [], danh_sach_hinh_anh: [{ duong_dan: '/uploads/smartshop/SS-0001.jpg', la_anh_chinh: true }] });
    const updated = (await request(`/san-pham/${productId}`)).data;
    variantId = updated.variants[0].ma_bien_the;
    assert.equal(updated.variants.length, 1);
    assert.equal(updated.danh_sach_hinh_anh.length, 1);
    await request(`/san-pham/${productId}/hinh-anh`, admin, 'POST', { duong_dan: '/uploads/smartshop/SS-0002.jpg', mo_ta: 'ADMIN_VERIFY_IMAGE' });
    const images = (await request(`/san-pham/${productId}/hinh-anh`)).data;
    const addedImage = images.find(i => i.mo_ta === 'ADMIN_VERIFY_IMAGE');
    assert.ok(addedImage);
    await request(`/san-pham/${productId}/hinh-anh/${addedImage.ma_hinh_anh}/chinh`, admin, 'PUT');
    await request(`/san-pham/${productId}/hinh-anh/${addedImage.ma_hinh_anh}`, admin, 'DELETE');
    const existing = (await request('/san-pham/1')).data;
    await request('/san-pham/1', admin, 'PUT', { ...existing, gia_ban: Number(existing.gia_ban), gia_nhap: Number(existing.gia_nhap), thong_so: existing.thong_so_ky_thuat.map(s => ({ ma_thong_so: s.ma_thong_so, gia_tri: s.gia_tri })), variants: existing.variants.map(v => ({ ...v, gia_ban: Number(v.gia_ban) })) });
    assert.equal((await request('/san-pham/1')).data.variants[0].ma_bien_the, existing.variants[0].ma_bien_the);
  });
  await check('Technical specification groups, library and category assignments', async () => {
    const category = (await request('/danh-muc', admin, 'POST', { ten_danh_muc: 'ADMIN_VERIFY_SPEC', trang_thai: true })).data.ma_danh_muc;
    assert.ok(category, 'Category create must return its inserted ID');
    const group = (await request('/thong-so/nhom', admin, 'POST', { ten_nhom_thong_so: 'ADMIN_VERIFY_GROUP', thu_tu_hien_thi: 99 })).data.ma_nhom_thong_so;
    const spec = (await request('/thong-so', admin, 'POST', { ma_nhom_thong_so: group, ten_thong_so: 'ADMIN_VERIFY_SPEC', kieu_du_lieu: 'NUMBER', don_vi: 'cm' })).data.ma_thong_so;
    await request(`/thong-so/nhom/${group}`, admin, 'PUT', { ten_nhom_thong_so: 'ADMIN_VERIFY_GROUP_EDIT' });
    await request(`/thong-so/${spec}`, admin, 'PUT', { ten_thong_so: 'ADMIN_VERIFY_SPEC_EDIT' });
    await request(`/danh-muc/${category}/thong-so`, admin, 'POST', { ma_thong_so: spec, bat_buoc: false, thu_tu_hien_thi: 1 });
    await request(`/danh-muc/${category}/thong-so/${spec}`, admin, 'PUT', { bat_buoc: true });
    assert.equal((await request(`/danh-muc/${category}/thong-so`)).data[0].ma_thong_so, spec);
    await request(`/danh-muc/${category}/thong-so/${spec}`, admin, 'DELETE');
    await request(`/thong-so/${spec}`, admin, 'DELETE');
    await request(`/danh-muc/${category}`, admin, 'DELETE');
  });
  await check('Employee CRUD, linked account, permissions, account locking', async () => {
    await request('/nhan-vien', admin, 'POST', { ho_ten: 'ADMIN_VERIFY_EMPLOYEE', luong: 9000000, trang_thai: 'DangLam' });
    const employee = (await request('/nhan-vien')).data.find(e => e.ho_ten === 'ADMIN_VERIFY_EMPLOYEE');
    await request(`/nhan-vien/${employee.ma_nhan_vien}`, admin, 'PUT', { ho_ten: 'ADMIN_VERIFY_EMPLOYEE', chuc_vu: 'Kiểm thử', luong: 9500000 });
    const linked = (await request(`/nhan-vien/${employee.ma_nhan_vien}/account`, admin, 'POST', { ten_dang_nhap: 'admin_verify_employee', email: 'admin_verify_employee@example.com', mat_khau: '12345678' })).data;
    const account = (await request('/tai-khoan')).data.find(a => a.ten_dang_nhap === 'admin_verify_employee');
    assert.ok(linked);
    await request(`/permissions/${account.ma_tai_khoan}`, admin, 'PUT', { permissions: ['catalog', 'inventory'] });
    const staff = (await request('/auth/login', null, 'POST', { ten_dang_nhap: 'admin_verify_employee', mat_khau: '12345678' })).data;
    await request('/shop/inventory', staff);
    await request('/shop/reports', staff, 'GET', undefined, 403);
    await request(`/permissions/${account.ma_tai_khoan}`, admin, 'PUT', { permissions: [] });
    await request('/shop/inventory', staff, 'GET', undefined, 403);
    await request(`/tai-khoan/${account.ma_tai_khoan}`, admin, 'PUT', { trang_thai: 'Khoa' });
    await request('/auth/me', staff, 'GET', undefined, 401);
    await request(`/nhan-vien/${employee.ma_nhan_vien}`, admin, 'DELETE');
    await request(`/tai-khoan/${account.ma_tai_khoan}`, admin, 'DELETE');
  });
  await check('Inventory receipt and variant stock update', async () => {
    assert.ok(productId && variantId);
    await request('/shop/inventory', admin, 'POST', { ma_san_pham: productId, ma_bien_the: variantId, so_luong: 3, ghi_chu: 'ADMIN_VERIFY' });
    assert.equal((await request(`/san-pham/${productId}`)).data.variants[0].so_luong, 8);
    assert.ok((await request('/shop/inventory')).data.some(r => r.ma_san_pham === productId));
  });
  await check('Voucher creation, lookup, grant and enable/disable', async () => {
    await request('/shop/vouchers', admin, 'POST', { ma_code: 'ADMIN_VERIFY', giam_tien: 10000, don_toi_thieu: 0, so_luot: 10, bat_dau: '2026-01-01T00:00', ket_thuc: '2030-01-01T00:00' });
    const voucher = (await request('/shop/vouchers')).data.find(v => v.ma_code === 'ADMIN_VERIFY');
    await request(`/shop/vouchers/${voucher.ma_voucher}`, admin, 'PUT', { trang_thai: false });
    await request(`/shop/vouchers/${voucher.ma_voucher}`, admin, 'PUT', { trang_thai: true });
    assert.ok((await request('/shop/vouchers/lookup-user?q=khachhang')).data.length);
    await request('/shop/vouchers/grant', admin, 'POST', { ma_voucher: voucher.ma_voucher, tai_khoan: 'khachhang', so_ngay_hieu_luc: 30 });
    assert.ok((await request('/shop/my-vouchers', customer)).data);
  });
  let orderId;
  const selection = { source: 'buy_now', ma_san_pham: productId, ma_bien_the: variantId, so_luong: 1 };
  await check('Orders: detail, confirmation, dispatch, receipt, reviews, deletion', async () => {
    assert.ok(productId && variantId);
    const quote = (await request('/don-hang/checkout?' + new URLSearchParams(selection), customer)).data;
    orderId = (await request('/don-hang', customer, 'POST', { ...selection, snapshot: quote.snapshot, request_id: 'admin-verify-order-request', ho_ten_nguoi_nhan: 'ADMIN_VERIFY_BUYER', so_dien_thoai: '0912345678', dia_chi_giao_hang: '123 Đường kiểm thử, Hà Nội', phuong_thuc_thanh_toan: quote.phuong_thuc_thanh_toan })).data.ma_don_hang;
    assert.equal((await request(`/don-hang/${orderId}`)).data.items.length, 1);
    await request(`/don-hang/${orderId}/trang-thai`, admin, 'PUT', { trang_thai: 'DaXacNhan' });
    await request(`/don-hang/${orderId}/trang-thai`, admin, 'PUT', { trang_thai: 'DangGiao' });
    await request(`/don-hang/${orderId}/xac-nhan-nhan-hang`, customer, 'PUT');
    await request('/danh-gia', customer, 'POST', { ma_san_pham: productId, ma_don_hang: orderId, so_sao: 5, noi_dung: 'ADMIN_VERIFY_REVIEW' });
    const review = (await request(`/danh-gia?ma_san_pham=${productId}`)).data[0];
    await request(`/danh-gia/${review.ma_danh_gia}`, admin, 'DELETE');
    await request(`/don-hang/${orderId}`, admin, 'DELETE');
  });
  await check('Contacts: customer submission, admin reply, detail and deletion', async () => {
    await request('/lien-he', customer, 'POST', { ho_ten: 'Khách hàng', email: 'khachhang@smartshop.example', tieu_de: 'ADMIN_VERIFY_CONTACT', noi_dung: 'Yêu cầu hỗ trợ kiểm thử admin' });
    const contact = (await request('/lien-he')).data.find(c => c.tieu_de === 'ADMIN_VERIFY_CONTACT');
    await request(`/lien-he/${contact.ma_lien_he}`, admin, 'PUT', { trang_thai: 'DaPhanHoi', phan_hoi: 'Phản hồi kiểm thử từ admin' });
    assert.equal((await request(`/lien-he/${contact.ma_lien_he}`)).data.phan_hoi, 'Phản hồi kiểm thử từ admin');
    await request(`/lien-he/${contact.ma_lien_he}`, admin, 'DELETE');
  });
  await check('Dashboard, populated reports and Excel exports', async () => {
    await request('/dashboard');
    await request('/shop/reports');
    await page.goto(`${frontend}/orders`);
    const [orderDownload] = await Promise.all([page.waitForEvent('download'), page.getByRole('button', { name: 'Xuất Excel', exact: true }).click()]);
    assert.match(orderDownload.suggestedFilename(), /\.xlsx$/);
    await page.goto(`${frontend}/reports`);
    await page.getByRole('button', { name: 'Xuất Excel' }).first().click();
    const [reportsDownload] = await Promise.all([page.waitForEvent('download'), page.getByText('Xuất toàn bộ sổ cái', { exact: false }).click()]);
    assert.match(reportsDownload.suggestedFilename(), /\.xlsx$/);
  });
  await check('Own profile save, password change, refresh and logout', async () => {
    const profile = (await request('/auth/me')).data;
    await request('/auth/me', admin, 'PUT', { ho_ten: profile.ho_ten, email: profile.email, so_dien_thoai: profile.so_dien_thoai, dia_chi: profile.dia_chi });
    const rotated = (await request('/auth/refresh', null, 'POST', { refresh_token: admin.refresh_token })).data;
    admin = rotated;
    await request('/auth/password', admin, 'PUT', { mat_khau_cu: '123456', mat_khau_moi: '12345678' });
    admin = (await request('/auth/login', null, 'POST', { ten_dang_nhap: 'admin', mat_khau: '12345678' })).data;
    await request('/auth/logout', admin, 'POST', { refresh_token: admin.refresh_token });
    await request('/auth/refresh', null, 'POST', { refresh_token: admin.refresh_token }, 401);
  });
  if (failures.length) throw new Error(failures.join('\n'));
  console.log('All admin verification groups passed. Original database unchanged.');
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
} finally {
  await browser?.close();
  if (server && server.exitCode === null) { const ended = new Promise(r => server.once('exit', r)); server.kill(); await ended; }
  if (created) await connection.query(`DROP DATABASE \`${database}\``);
  await connection.end();
  if (resolve(dirname(temporary)) !== resolve(tmpdir()) || !basename(temporary).startsWith('smartshop-admin-')) throw new Error('Unexpected temporary cleanup path');
  await rm(temporary, { recursive: true, force: true });
}
