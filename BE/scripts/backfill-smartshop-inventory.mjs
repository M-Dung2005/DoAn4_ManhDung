// Record missing import history for stock that is already present. Never add stock again.
import assert from 'node:assert/strict';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';

dotenv.config();
if (!process.argv.includes('--apply')) {
  console.log('Record missing opening-stock receipts with existing stock + non-canceled order quantities - already recorded imports.');
  console.log('No product/variant stock is changed. Apply: npm run backfill:inventory -- --apply');
  process.exit(0);
}
assert.ok(process.env.DB_NAME, 'Configure DB_NAME first.');
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  await connection.beginTransaction();
  // Use the same product-then-variant lock order as catalog/checkout operations.
  const [products] = await connection.query('SELECT * FROM san_pham ORDER BY ma_san_pham FOR UPDATE');
  const [variants] = await connection.query('SELECT * FROM san_pham_bien_the ORDER BY ma_san_pham,ma_bien_the FOR UPDATE');
  const [receiptsBefore] = await connection.query('SELECT * FROM nhap_kho ORDER BY ma_nhap FOR UPDATE');
  const [employees] = await connection.query(`SELECT t.ma_tai_khoan,t.ten_dang_nhap,p.permissions
    FROM tai_khoan t JOIN nhan_vien n USING(ma_tai_khoan) JOIN staff_permissions p USING(ma_tai_khoan)
    WHERE t.vai_tro='NhanVien' AND t.trang_thai='HoatDong' AND n.trang_thai='DangLam'
    ORDER BY t.ten_dang_nhap`);
  const allowed = employees.filter(e => (typeof e.permissions === 'string' ? JSON.parse(e.permissions) : e.permissions).includes('inventory'));
  const numbered = allowed.filter(e => /^nhanvien\d{2}$/.test(e.ten_dang_nhap));
  const staff = numbered.length ? numbered : allowed;
  assert.ok(staff.length, 'No active employee with inventory permission.');
  const [brands] = await connection.query('SELECT ma_thuong_hieu,ten_thuong_hieu FROM thuong_hieu');
  const [sales] = await connection.query(`SELECT ct.ma_san_pham,ct.ma_bien_the,SUM(ct.so_luong) AS quantity
    FROM chi_tiet_don_hang ct JOIN don_hang dh USING(ma_don_hang)
    WHERE dh.trang_thai<>'DaHuy' GROUP BY ct.ma_san_pham,ct.ma_bien_the`);
  const sold = (productId, variantId) => Number(sales.find(s => s.ma_san_pham === productId && s.ma_bien_the === variantId)?.quantity || 0);
  let created = 0, imported = 0;
  const covered = new Set();
  for (const [index, product] of products.entries()) {
    const productVariants = variants.filter(v => v.ma_san_pham === product.ma_san_pham);
    const items = productVariants.length ? productVariants : [{ ma_bien_the: null, so_luong: product.so_luong, gia_ban: product.gia_ban, ngay_tao: product.ngay_tao }];
    const previous = receiptsBefore.filter(r => r.ma_san_pham === product.ma_san_pham);
    // A legacy product-level receipt for a variant product cannot be allocated safely.
    assert.ok(!productVariants.length || !previous.some(r => r.ma_bien_the == null), `Product ${product.ma_san_pham_code} has unallocated legacy imports; review them first.`);
    const brand = brands.find(b => b.ma_thuong_hieu === product.ma_thuong_hieu)?.ten_thuong_hieu || 'SmartShop';
    for (const item of items) {
      const logged = previous.filter(r => r.ma_bien_the === item.ma_bien_the).reduce((sum, r) => sum + Number(r.so_luong), 0);
      const quantity = Number(item.so_luong) + sold(product.ma_san_pham, item.ma_bien_the) - logged;
      assert.ok(Number.isSafeInteger(quantity) && quantity >= 0, `Import history exceeds stock and orders on ${product.ma_san_pham_code}/${item.ma_bien_the}`);
      if (!quantity) continue;
      const unitCost = Math.round(Number(product.gia_nhap || 0) * Number(item.gia_ban) / Number(product.gia_ban));
      assert.ok(Number.isFinite(unitCost) && unitCost >= 0);
      const note = `[TON-DAU-KY:${product.ma_san_pham_code}] Bổ sung lịch sử lô hàng đã nhập; tồn kho đã ghi nhận trước đó, không cộng thêm tồn. Bao gồm lượng đã xuất cho đơn chưa hủy.`;
      await connection.execute('INSERT INTO nhap_kho (ma_san_pham,ma_bien_the,ma_tai_khoan,so_luong,ghi_chu,ngay_nhap,gia_nhap,nha_cung_cap) VALUES (?,?,?,?,?,?,?,?)', [product.ma_san_pham, item.ma_bien_the, staff[index % staff.length].ma_tai_khoan, quantity, note, item.ngay_tao || product.ngay_tao || new Date(), unitCost, `Nhà cung cấp ${brand}`]);
      created++; imported += quantity; covered.add(product.ma_san_pham);
    }
  }
  const [productsAfter] = await connection.query('SELECT * FROM san_pham ORDER BY ma_san_pham');
  const [variantsAfter] = await connection.query('SELECT * FROM san_pham_bien_the ORDER BY ma_san_pham,ma_bien_the');
  assert.deepEqual(productsAfter, products, 'Product data/stock must not change');
  assert.deepEqual(variantsAfter, variants, 'Variant data/stock must not change');
  const [receiptsAfter] = await connection.query('SELECT * FROM nhap_kho ORDER BY ma_nhap');
  for (const original of receiptsBefore) assert.deepEqual(receiptsAfter.find(r => r.ma_nhap === original.ma_nhap), original, 'Existing receipts must remain unchanged');
  assert.equal(receiptsAfter.length, receiptsBefore.length + created);
  for (const product of products) {
    const productVariants = variants.filter(v => v.ma_san_pham === product.ma_san_pham);
    const items = productVariants.length ? productVariants : [{ ma_bien_the: null, so_luong: product.so_luong }];
    for (const item of items) {
      const logged = receiptsAfter.filter(r => r.ma_san_pham === product.ma_san_pham && r.ma_bien_the === item.ma_bien_the).reduce((sum, r) => sum + Number(r.so_luong), 0);
      assert.equal(logged - sold(product.ma_san_pham, item.ma_bien_the), Number(item.so_luong), 'Imports minus non-canceled orders must match current stock');
    }
  }
  await connection.commit();
  console.log({ receiptsCreated: created, productsCovered: covered.size, quantityRecorded: imported, currentVariantStock: variants.reduce((sum, v) => sum + Number(v.so_luong), 0), stockChanged: false });
} catch (error) {
  await connection.rollback();
  console.error('Inventory history was not committed:', error.message);
  process.exitCode = 1;
} finally { await connection.end(); }
