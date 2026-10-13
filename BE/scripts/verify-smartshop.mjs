import assert from 'node:assert/strict';
import { expandedCatalog, extraSpecificationNames } from '../database/smartshop-expanded-catalog.mjs';
import { createHash } from 'node:crypto';

const base = process.env.SMARTSHOP_TEST_URL || 'http://localhost:3000/api';
async function request(path, token, body) {
  const response = await fetch(base + path, { method: body ? 'POST' : 'GET', headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) }, ...(body ? { body: JSON.stringify(body) } : {}) });
  const json = await response.json();
  assert.equal(response.status, 200, `${path}: ${response.status} ${json.message}`);
  assert.equal(json.success, true, `${path}: ${json.message}`);
  return json;
}
const sessions = [];
try {
  const admin = await request('/auth/login', null, { ten_dang_nhap: 'admin', mat_khau: '123456' });
  sessions.push(admin.data);
  const customer = await request('/auth/login', null, { ten_dang_nhap: 'khachhang', mat_khau: '123456' });
  sessions.push(customer.data);
  for (const path of ['/auth/me','dashboard','permissions','tai-khoan','nhan-vien','don-hang','danh-gia','lien-he','shop/inventory','shop/reports','shop/vouchers'].map(path => path.startsWith('/') ? path : '/' + path)) {
    await request(path, admin.data.token);
    console.log('OK:', path);
  }
  const categories = await request('/danh-muc?has_products=true');
  assert.equal(categories.data.length, expandedCatalog.length);
  const products = await request('/san-pham?limit=100');
  assert.equal(products.pagination.total, expandedCatalog.flatMap(c => c.products).length);
  for (const category of categories.data) {
    const filtered = await request(`/san-pham?ma_danh_muc=${category.ma_danh_muc}`);
    assert.equal(filtered.pagination.total, expandedCatalog.find(c => c.name === category.ten_danh_muc).products.length, category.ten_danh_muc);
    const definitions = await request(`/danh-muc/${category.ma_danh_muc}/thong-so`, admin.data.token);
    assert.ok(extraSpecificationNames.every(name => definitions.data.some(s => s.ten_thong_so === name)));
  }
  const search = await request('/san-pham?search=' + encodeURIComponent('Áo thun'));
  assert.equal(search.pagination.total, expandedCatalog.flatMap(c => c.products).filter(p => p.name.includes('Áo thun')).length);
  const sorted = await request('/san-pham?sort=price_asc&limit=100', customer.data.token);
  assert.ok(sorted.data.every((product, index, rows) => index === 0 || Number(rows[index - 1].gia_ban) <= Number(product.gia_ban)));
  const product = (await request('/san-pham/1')).data;
  assert.equal(product.variants.length, 2);
  assert.ok(product.thong_so_ky_thuat.length > 0);
  const origin = base.replace(/\/api\/?$/, '');
  const photoHashes = new Set();
  for (const item of products.data) {
    const response = await fetch(origin + item.hinh_anh);
    assert.equal(response.status, 200, item.ten_san_pham);
    assert.match(response.headers.get('content-type'), /image\/jpeg/);
    const hash = createHash('sha256').update(Buffer.from(await response.arrayBuffer())).digest('hex');
    assert.ok(!photoHashes.has(hash), `Duplicate product photo: ${item.ma_san_pham_code}`);
    photoHashes.add(hash);
    const detail = (await request(`/san-pham/${item.ma_san_pham}`)).data;
    assert.ok(extraSpecificationNames.every(name => detail.thong_so_ky_thuat.some(s => s.ten_thong_so === name && s.gia_tri?.trim())), item.ten_san_pham);
    assert.ok(detail.thong_so_ky_thuat.length >= 12, item.ten_san_pham);
  }
  for (const path of ['/gio-hang','/shop/addresses','/shop/notifications','/shop/my-vouchers','/shop/rewards/status']) await request(path, customer.data.token);
  await request(`/don-hang/checkout?source=buy_now&ma_san_pham=1&ma_bien_the=${product.variants[0].ma_bien_the}&so_luong=1`, customer.data.token);
  console.log('SmartShop verification passed: catalog, filters, sorting, images, roles, rewards, vouchers and checkout preview.');
} finally {
  for (const session of sessions) await fetch(base + '/auth/logout', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${session.token}` }, body: JSON.stringify({ refresh_token: session.refresh_token }) }).catch(() => {});
}
