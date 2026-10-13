import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import { productPhotos } from '../database/smartshop-product-photos.mjs';

dotenv.config();
assert.ok(process.env.DB_NAME, 'Configure DB_NAME first');
const photos = Object.values(productPhotos);
assert.equal(photos.length, 96);
const hashes = new Set();
for (const photo of photos) {
  const bytes = await readFile(photo.path.slice(1));
  assert.ok(bytes[0] === 255 && bytes[1] === 216, photo.code);
  const hash = createHash('sha256').update(bytes).digest('hex');
  assert.equal(hash, photo.sha256, `Image changed: ${photo.code}`);
  assert.ok(!hashes.has(hash), `Duplicate photo: ${photo.code}`);
  hashes.add(hash);
}
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  await connection.beginTransaction();
  const [before] = await connection.query('SELECT * FROM san_pham WHERE ma_san_pham_code IN (?) FOR UPDATE', [photos.map(p => p.code)]);
  assert.equal(before.length, photos.length);
  const [gallery] = await connection.query('SELECT * FROM hinh_anh_san_pham WHERE ma_san_pham IN (?)', [before.map(p => p.ma_san_pham)]);
  await mkdir('database/backups', { recursive: true });
  await writeFile(`database/backups/product-photos-${Date.now()}.json`, JSON.stringify({ products: before.map(p => ({ ma_san_pham: p.ma_san_pham, hinh_anh: p.hinh_anh })), gallery }, null, 2));
  for (const product of before) {
    const photo = productPhotos[product.ma_san_pham_code];
    await connection.execute('UPDATE san_pham SET hinh_anh=? WHERE ma_san_pham=?', [photo.path, product.ma_san_pham]);
    const images = gallery.filter(i => i.ma_san_pham === product.ma_san_pham);
    const primary = images.filter(i => i.la_anh_chinh);
    assert.ok(primary.length <= 1, `Multiple primary images on ${photo.code}`);
    const image = primary[0] || images[0];
    if (image) await connection.execute('UPDATE hinh_anh_san_pham SET duong_dan=?,la_anh_chinh=1 WHERE ma_hinh_anh=?', [photo.path, image.ma_hinh_anh]);
    else await connection.execute('INSERT INTO hinh_anh_san_pham (ma_san_pham,duong_dan,la_anh_chinh,thu_tu_hien_thi) VALUES (?,?,1,1)', [product.ma_san_pham, photo.path]);
  }
  const [after] = await connection.query('SELECT * FROM san_pham WHERE ma_san_pham_code IN (?)', [photos.map(p => p.code)]);
  for (const original of before) {
    const updated = after.find(p => p.ma_san_pham === original.ma_san_pham);
    assert.deepEqual(updated, { ...original, hinh_anh: productPhotos[original.ma_san_pham_code].path }, 'Only the product photo may change');
  }
  await connection.commit();
  console.log('Applied 96 distinct real product photos; product IDs, prices, stock and variants preserved.');
} catch (error) {
  await connection.rollback();
  console.error('Photo changes were not committed:', error.message);
  process.exitCode = 1;
} finally { await connection.end(); }
