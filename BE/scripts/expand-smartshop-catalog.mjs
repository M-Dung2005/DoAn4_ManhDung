import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import { additionalCatalog, extraSpecificationNames, extraSpecifications } from '../database/smartshop-expanded-catalog.mjs';
import { specificationsForVariant } from '../database/smartshop-variant-specifications.mjs';
import { productPhotos } from '../database/smartshop-product-photos.mjs';

dotenv.config();
const additions = additionalCatalog.flatMap(c => c.products);
assert.equal(additions.length, 60);
assert.equal(extraSpecificationNames.length, 10);
if (!process.argv.includes('--apply')) {
  console.log('Add 60 products (7 each in the first 6 categories, 6 each in the last 3), two variants per new product, and 10 extra attributes on every product.');
  console.log('Apply: npm run expand:catalog -- --apply. Existing product values are preserved; repeated runs do not add duplicates.');
  process.exit(0);
}
if (!process.env.DB_NAME) throw new Error('Configure DB_NAME in BE/.env first.');
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  // Prepare local illustrative photos before committing any database changes.
  for (const product of additions) {
    const target = resolve(productPhotos[product.code].path.slice(1));
    const bytes = await readFile(target);
    assert.ok(bytes[0] === 255 && bytes[1] === 216, `Missing JPEG photo: ${product.code}`);
  }
  await connection.beginTransaction();
  const [categories] = await connection.query('SELECT ma_danh_muc,ten_danh_muc FROM danh_muc ORDER BY ma_danh_muc');
  const categoryIds = new Map();
  for (const category of additionalCatalog) {
    const row = categories.find(c => c.ten_danh_muc === category.name);
    assert.ok(row, `Category not found: ${category.name}`);
    categoryIds.set(category.name, row.ma_danh_muc);
  }
  const [groups] = await connection.execute('SELECT ma_nhom_thong_so,trang_thai FROM nhom_thong_so WHERE ten_nhom_thong_so=?', ['Thông tin sản phẩm']);
  let groupId = groups[0]?.ma_nhom_thong_so;
  if (!groupId) {
    const [result] = await connection.execute('INSERT INTO nhom_thong_so (ten_nhom_thong_so,thu_tu_hien_thi,trang_thai) VALUES (?,2,1)', ['Thông tin sản phẩm']);
    groupId = result.insertId;
  } else assert.ok(groups[0].trang_thai, 'Extra attribute group is inactive');
  const definitionIds = new Map();
  for (const [index, name] of extraSpecificationNames.entries()) {
    const [found] = await connection.execute('SELECT ma_thong_so,kieu_du_lieu,trang_thai FROM thong_so WHERE ten_thong_so=?', [name]);
    let definitionId = found[0]?.ma_thong_so;
    if (!definitionId) {
      const [result] = await connection.execute("INSERT INTO thong_so (ma_nhom_thong_so,ten_thong_so,kieu_du_lieu,cho_phep_loc,thu_tu_hien_thi,trang_thai) VALUES (?,?,'TEXT',?,?,1)", [groupId, name, index < 7 ? 1 : 0, index + 1]);
      definitionId = result.insertId;
    } else {
      assert.equal(found[0].kieu_du_lieu, 'TEXT', `Existing attribute has an incompatible type: ${name}`);
      assert.ok(found[0].trang_thai, `Existing attribute is inactive: ${name}`);
    }
    definitionIds.set(name, definitionId);
    for (const category of additionalCatalog) await connection.execute('INSERT INTO danh_muc_thong_so (ma_danh_muc,ma_thong_so,bat_buoc,thu_tu_hien_thi) VALUES (?,?,0,?) ON DUPLICATE KEY UPDATE ma_thong_so=VALUES(ma_thong_so)', [categoryIds.get(category.name), definitionId, index + 3]);
  }
  let created = 0, skipped = 0;
  for (const [categoryIndex, category] of additionalCatalog.entries()) {
    const [brands] = await connection.execute('SELECT ma_thuong_hieu FROM thuong_hieu WHERE ten_thuong_hieu=?', [category.brand]);
    assert.ok(brands.length, `Brand not found: ${category.brand}`);
    for (const product of category.products) {
      const [existing] = await connection.execute('SELECT ma_san_pham,ma_danh_muc FROM san_pham WHERE ma_san_pham_code=?', [product.code]);
      if (existing.length) {
        assert.equal(existing[0].ma_danh_muc, categoryIds.get(category.name), `Product code belongs to another category: ${product.code}`);
        skipped++;
        continue;
      }
      const image = productPhotos[product.code].path;
      const description = `${product.name} — lựa chọn trong ngành hàng ${category.name} tại SmartShop. ${category.description}\nDữ liệu giá, thuộc tính và hình ảnh minh họa phục vụ đồ án thương mại điện tử.`;
      const [result] = await connection.execute("INSERT INTO san_pham (ma_danh_muc,ma_thuong_hieu,ma_san_pham_code,ten_san_pham,mo_ta,gia_nhap,gia_ban,so_luong,bao_hanh,hinh_anh,trang_thai) VALUES (?,?,?,?,?,?,?,?,?,?,'DangBan')", [categoryIds.get(category.name), brands[0].ma_thuong_hieu, product.code, product.name, description, Math.round(product.price * 0.65), product.price, product.variants.reduce((n, v) => n + v.stock, 0), categoryIndex < 3 ? 12 : 0, image]);
      const productId = result.insertId;
      await connection.execute('INSERT INTO hinh_anh_san_pham (ma_san_pham,duong_dan,mo_ta,la_anh_chinh,thu_tu_hien_thi) VALUES (?,?,?,1,1)', [productId, image, product.name]);
      const specificationValues = { ...product.specs, ...extraSpecifications(product, categoryIndex) };
      const variantSpecifications = [];
      for (const [name, value] of Object.entries(specificationValues)) {
        const [definitions] = await connection.execute('SELECT ma_thong_so FROM thong_so WHERE ten_thong_so=? AND trang_thai=1', [name]);
        assert.ok(definitions.length, `Attribute not found: ${name}`);
        const specId = definitions[0].ma_thong_so;
        await connection.execute('INSERT INTO thong_so_san_pham (ma_san_pham,ma_thong_so,gia_tri) VALUES (?,?,?)', [productId, specId, value]);
        variantSpecifications.push({ ma_thong_so: specId, ten_thong_so: name, ten_nhom: extraSpecificationNames.includes(name) ? 'Thông tin sản phẩm' : 'Thuộc tính sản phẩm', kieu_du_lieu: 'TEXT', gia_tri: value });
      }
      for (const [index, variant] of product.variants.entries()) await connection.execute("INSERT INTO san_pham_bien_the (ma_san_pham,ma_sku,ten_bien_the,gia_ban,so_luong,trang_thai,thong_so_json) VALUES (?,?,?,?,?,'DangBan',?)", [productId, `${product.code}-${index + 1}`, variant.name, variant.price, variant.stock, JSON.stringify(specificationsForVariant(variantSpecifications, variant.name))]);
      created++;
    }
  }
  let enriched = 0;
  const [products] = await connection.query('SELECT ma_san_pham,ma_danh_muc,ten_san_pham FROM san_pham');
  for (const product of products) {
    const categoryIndex = additionalCatalog.findIndex(c => categoryIds.get(c.name) === product.ma_danh_muc);
    assert.ok(categoryIndex >= 0, `Unknown category on product ${product.ma_san_pham}`);
    const [variants] = await connection.execute('SELECT ma_bien_the,ten_bien_the,thong_so_json FROM san_pham_bien_the WHERE ma_san_pham=?', [product.ma_san_pham]);
    const [values] = await connection.execute('SELECT ts.ten_thong_so,tsp.gia_tri FROM thong_so_san_pham tsp JOIN thong_so ts USING(ma_thong_so) WHERE tsp.ma_san_pham=?', [product.ma_san_pham]);
    const extra = extraSpecifications({ name: product.ten_san_pham, specs: Object.fromEntries(values.map(v => [v.ten_thong_so, v.gia_tri])), variants }, categoryIndex);
    for (const [name, value] of Object.entries(extra)) await connection.execute('INSERT INTO thong_so_san_pham (ma_san_pham,ma_thong_so,gia_tri) VALUES (?,?,?) ON DUPLICATE KEY UPDATE ma_thong_so=VALUES(ma_thong_so)', [product.ma_san_pham, definitionIds.get(name), value]);
    // Append extra metadata while preserving existing variant-specific attributes.
    const [stored] = await connection.execute('SELECT ma_thong_so,gia_tri FROM thong_so_san_pham WHERE ma_san_pham=?', [product.ma_san_pham]);
    const storedValues = new Map(stored.map(s => [s.ma_thong_so, s.gia_tri]));
    for (const variant of variants) {
      const original = typeof variant.thong_so_json === 'string' ? JSON.parse(variant.thong_so_json) : variant.thong_so_json || [];
      assert.ok(Array.isArray(original), `Invalid variant attributes: ${variant.ma_bien_the}`);
      const ids = new Set(original.map(s => Number(s.ma_thong_so)));
      const merged = [...original];
      for (const name of extraSpecificationNames) {
        const specId = definitionIds.get(name);
        if (!ids.has(specId)) merged.push({ ma_thong_so: specId, ten_thong_so: name, ten_nhom: 'Thông tin sản phẩm', kieu_du_lieu: 'TEXT', gia_tri: storedValues.get(specId) });
      }
      if (merged.length !== original.length) {
        const added = specificationsForVariant(merged.slice(original.length), variant.ten_bien_the);
        await connection.execute('UPDATE san_pham_bien_the SET thong_so_json=? WHERE ma_bien_the=?', [JSON.stringify([...original, ...added]), variant.ma_bien_the]);
      }
    }
    enriched++;
  }
  const ids = [...definitionIds.values()];
  const [coverage] = await connection.query('SELECT ma_san_pham,COUNT(*) AS count FROM thong_so_san_pham WHERE ma_thong_so IN (?) AND gia_tri IS NOT NULL AND TRIM(gia_tri)<>? GROUP BY ma_san_pham', [ids, '']);
  assert.equal(coverage.length, products.length);
  assert.ok(coverage.every(row => row.count === 10));
  const [distribution] = await connection.query('SELECT d.ten_danh_muc,COUNT(p.ma_san_pham) AS products FROM danh_muc d LEFT JOIN san_pham p USING(ma_danh_muc) GROUP BY d.ma_danh_muc ORDER BY d.ma_danh_muc');
  await connection.commit();
  console.log({ productsCreated: created, productsSkipped: skipped, productsWithTenExtraAttributes: enriched });
  console.table(distribution);
} catch (error) {
  await connection.rollback();
  console.error('Catalog changes were not committed:', error.message);
  process.exitCode = 1;
} finally { await connection.end(); }
