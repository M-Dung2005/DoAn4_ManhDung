import assert from 'node:assert/strict';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import { employeeNames, customerNames, baseAccountNames } from '../database/smartshop-account-names.mjs';

dotenv.config();
const updates = [
  ...employeeNames.map((name, i) => ({ username: `nhanvien${String(i + 1).padStart(2, '0')}`, name, role: 'NhanVien' })),
  ...customerNames.map((name, i) => ({ username: `khachhang${String(i + 1).padStart(2, '0')}`, name, role: 'KhachHang' })),
  { username: 'nhanvien', name: baseAccountNames.nhanvien, role: 'NhanVien' },
  { username: 'khachhang', name: baseAccountNames.khachhang, role: 'KhachHang' },
];
if (!process.argv.includes('--apply')) {
  console.log('Update Vietnamese full names for numbered staff/customers and the two original demo accounts. Apply: node scripts/update-smartshop-account-names.mjs --apply');
  process.exit(0);
}
if (!process.env.DB_NAME) throw new Error('Configure DB_NAME in BE/.env first.');
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  await connection.beginTransaction();
  const [before] = await connection.query('SELECT * FROM tai_khoan WHERE ten_dang_nhap IN (?) FOR UPDATE', [updates.map(u => u.username)]);
  const [profilesBefore] = await connection.query('SELECT n.* FROM nhan_vien n JOIN tai_khoan t USING(ma_tai_khoan) WHERE t.ten_dang_nhap IN (?)', [updates.filter(u => u.role === 'NhanVien').map(u => u.username)]);
  assert.equal(before.filter(r => /^nhanvien\d{2}$/.test(r.ten_dang_nhap)).length, 10);
  assert.equal(before.filter(r => /^khachhang\d{2}$/.test(r.ten_dang_nhap)).length, 60);
  let staff = 0, customers = 0;
  for (const update of updates) {
    const account = before.find(r => r.ten_dang_nhap === update.username);
    if (!account) continue;
    assert.equal(account.vai_tro, update.role, `Unexpected role for ${update.username}`);
    await connection.execute('UPDATE tai_khoan SET ho_ten=? WHERE ma_tai_khoan=?', [update.name, account.ma_tai_khoan]);
    if (update.role === 'NhanVien') {
      await connection.execute('UPDATE nhan_vien SET ho_ten=? WHERE ma_tai_khoan=?', [update.name, account.ma_tai_khoan]);
      staff++;
    } else customers++;
  }
  const [after] = await connection.query('SELECT * FROM tai_khoan WHERE ten_dang_nhap IN (?)', [updates.map(u => u.username)]);
  for (const original of before) {
    const updated = after.find(r => r.ma_tai_khoan === original.ma_tai_khoan);
    const name = updates.find(u => u.username === original.ten_dang_nhap).name;
    assert.deepEqual(updated, { ...original, ho_ten: name }, 'Account fields other than full name must remain unchanged');
  }
  const [profilesAfter] = await connection.query('SELECT n.* FROM nhan_vien n JOIN tai_khoan t USING(ma_tai_khoan) WHERE t.ten_dang_nhap IN (?)', [updates.filter(u => u.role === 'NhanVien').map(u => u.username)]);
  assert.equal(profilesAfter.length, profilesBefore.length);
  for (const original of profilesBefore) {
    const updated = profilesAfter.find(r => r.ma_nhan_vien === original.ma_nhan_vien);
    const account = after.find(r => r.ma_tai_khoan === original.ma_tai_khoan);
    assert.deepEqual(updated, { ...original, ho_ten: account.ho_ten }, 'Employee fields other than full name must remain unchanged');
  }
  await connection.commit();
  console.log(`Updated names: ${staff} employees, ${customers} customers; linked profiles synchronized. Passwords and other account fields verified unchanged.`);
} catch (error) {
  await connection.rollback();
  console.error('Names were not committed:', error.message);
  process.exitCode = 1;
} finally { await connection.end(); }
