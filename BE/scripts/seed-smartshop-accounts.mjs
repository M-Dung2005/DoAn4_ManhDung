import assert from 'node:assert/strict';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';
import { employeeNames, customerNames } from '../database/smartshop-account-names.mjs';

dotenv.config();
const accounts = [
  ...employeeNames.map((name, i) => ({ username: `nhanvien${String(i + 1).padStart(2, '0')}`, name, role: 'NhanVien', referral: `SSNV${String(i + 1).padStart(2, '0')}` })),
  ...customerNames.map((name, i) => ({ username: `khachhang${String(i + 1).padStart(2, '0')}`, name, role: 'KhachHang', referral: `SSKH${String(i + 1).padStart(2, '0')}` })),
];
if (!process.argv.includes('--apply')) {
  console.log('Add nhanvien01–nhanvien10 with linked employee profiles and khachhang01–khachhang60. Default password: 123456.');
  console.log('Existing accounts and their passwords are preserved. Apply: npm run seed:accounts -- --apply');
  process.exit(0);
}
if (!process.env.DB_NAME) throw new Error('Configure DB_NAME in BE/.env before adding accounts.');
const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: process.env.DB_NAME });
try {
  const passwordHash = await bcrypt.hash('123456', 12);
  await connection.beginTransaction();
  // Match the existing demo employee's permissions; never grant the Admin role.
  const [templates] = await connection.execute("SELECT p.permissions FROM staff_permissions p JOIN tai_khoan t USING(ma_tai_khoan) WHERE t.ten_dang_nhap='nhanvien' AND t.vai_tro='NhanVien'");
  const permissions = templates[0]?.permissions ?? ['orders', 'catalog', 'inventory', 'reports', 'reviews', 'vouchers', 'contacts'];
  const permissionsJson = typeof permissions === 'string' ? permissions : JSON.stringify(permissions);
  const counts = { accountsCreated: 0, employeeProfilesCreated: 0, accountsSkipped: 0 };
  for (const account of accounts) {
    const [existing] = await connection.execute('SELECT ma_tai_khoan,vai_tro FROM tai_khoan WHERE ten_dang_nhap=? FOR UPDATE', [account.username]);
    let accountId = existing[0]?.ma_tai_khoan;
    if (existing.length) {
      assert.equal(existing[0].vai_tro, account.role, `${account.username} already exists with a different role; refusing to change it.`);
      counts.accountsSkipped++;
    } else {
      const [result] = await connection.execute("INSERT INTO tai_khoan (ten_dang_nhap,mat_khau,ho_ten,email,vai_tro,trang_thai,ma_gioi_thieu) VALUES (?,?,?,?,?,'HoatDong',?)", [account.username, passwordHash, account.name, `${account.username}@smartshop.example`, account.role, account.referral]);
      accountId = result.insertId;
      counts.accountsCreated++;
    }
    if (account.role === 'NhanVien') {
      const [profiles] = await connection.execute('SELECT ma_nhan_vien FROM nhan_vien WHERE ma_tai_khoan=?', [accountId]);
      if (!profiles.length) {
        await connection.execute("INSERT INTO nhan_vien (ma_tai_khoan,ho_ten,email,chuc_vu,ngay_vao_lam,luong,trang_thai) VALUES (?,?,?,'Nhân viên bán hàng',CURRENT_DATE(),0,'DangLam')", [accountId, account.name, `${account.username}@smartshop.example`]);
        counts.employeeProfilesCreated++;
      }
      await connection.execute('INSERT INTO staff_permissions (ma_tai_khoan,permissions) VALUES (?,?) ON DUPLICATE KEY UPDATE ma_tai_khoan=VALUES(ma_tai_khoan)', [accountId, permissionsJson]);
    }
  }
  const placeholders = accounts.map(() => '?').join(',');
  const [rows] = await connection.execute(`SELECT t.ten_dang_nhap,t.vai_tro,t.trang_thai,n.ma_nhan_vien FROM tai_khoan t LEFT JOIN nhan_vien n USING(ma_tai_khoan) WHERE t.ten_dang_nhap IN (${placeholders})`, accounts.map(a => a.username));
  assert.equal(rows.length, 70);
  assert.equal(rows.filter(r => r.vai_tro === 'NhanVien' && r.ma_nhan_vien).length, 10);
  assert.equal(rows.filter(r => r.vai_tro === 'KhachHang').length, 60);
  await connection.commit();
  console.log('Account seed complete:', counts);
  console.log('Verified: 10 linked employees and 60 customer accounts.');
} catch (error) {
  await connection.rollback();
  console.error('No accounts committed:', error.message);
  process.exitCode = 1;
} finally {
  await connection.end();
}
