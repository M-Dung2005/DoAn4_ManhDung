import assert from 'node:assert/strict';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import { expandedCatalog } from '../database/smartshop-expanded-catalog.mjs';
import { specificationsForVariant } from '../database/smartshop-variant-specifications.mjs';

dotenv.config();
if (!process.env.DB_NAME) throw new Error('Configure DB_NAME first.');
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  await connection.beginTransaction();
  const codes = expandedCatalog.flatMap(c => c.products).map(p => p.code);
  const [variants] = await connection.query('SELECT bt.* FROM san_pham_bien_the bt JOIN san_pham sp USING(ma_san_pham) WHERE sp.ma_san_pham_code IN (?) FOR UPDATE', [codes]);
  let changed = 0;
  for (const variant of variants) {
    const specs = typeof variant.thong_so_json === 'string' ? JSON.parse(variant.thong_so_json) : variant.thong_so_json;
    assert.ok(Array.isArray(specs), `Invalid variant metadata: ${variant.ma_bien_the}`);
    const fixed = specificationsForVariant(specs, variant.ten_bien_the);
    if (JSON.stringify(fixed) !== JSON.stringify(specs)) {
      await connection.execute('UPDATE san_pham_bien_the SET thong_so_json=? WHERE ma_bien_the=?', [JSON.stringify(fixed), variant.ma_bien_the]);
      changed++;
    }
  }
  const [after] = await connection.query('SELECT bt.* FROM san_pham_bien_the bt JOIN san_pham sp USING(ma_san_pham) WHERE sp.ma_san_pham_code IN (?)', [codes]);
  assert.equal(after.length, variants.length);
  for (const original of variants) {
    const updated = after.find(v => v.ma_bien_the === original.ma_bien_the);
    const { thong_so_json: oldSpecs, ...oldFields } = original;
    const { thong_so_json: newSpecs, ...newFields } = updated;
    assert.deepEqual(newFields, oldFields, 'Variant IDs, prices and stock must stay unchanged');
    const specs = typeof newSpecs === 'string' ? JSON.parse(newSpecs) : newSpecs;
    assert.deepEqual(specs, specificationsForVariant(specs, updated.ten_bien_the));
  }
  await connection.commit();
  console.log(`Repaired ${changed}/${variants.length} variants; IDs, SKU, prices and stock preserved.`);
} catch (error) {
  await connection.rollback();
  console.error('Repair was not committed:', error.message);
  process.exitCode = 1;
} finally { await connection.end(); }
