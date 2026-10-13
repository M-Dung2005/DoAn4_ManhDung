import dotenv from 'dotenv';
import mysql from 'mysql2/promise';

export const rewardVouchers = [
  ['CHECKIN7D', 30000, 200000, 'Quà điểm danh 7 ngày'],
  ['CHECKIN14D', 50000, 300000, 'Quà điểm danh 14 ngày'],
  ['CHECKIN21D', 70000, 400000, 'Quà điểm danh 21 ngày'],
  ['CHECKIN30D', 100000, 500000, 'Quà điểm danh 30 ngày'],
  ['NEWBIE50K', 50000, 250000, 'Quà khách hàng nhập mã giới thiệu'],
  ['REFERRAL50K', 50000, 200000, 'Quà giới thiệu bạn bè'],
  ['REWARD20K', 20000, 100000, 'Voucher đổi Xu: giảm 20.000đ'],
  ['REWARD50K', 50000, 250000, 'Voucher đổi Xu: giảm 50.000đ'],
  ['REWARD100K', 100000, 500000, 'Voucher đổi Xu: giảm 100.000đ'],
  ['FREESHIP15K', 15000, 150000, 'Voucher đổi Xu: giảm 15.000đ'],
];

export async function ensureSmartShopRewards(connection) {
  for (const [code, discount, minimum, description] of rewardVouchers) {
    await connection.execute("INSERT INTO voucher (ma_code,giam_tien,loai,don_toi_thieu,so_luot,moi_khach,la_cong_khai,bat_dau,ket_thuc,mo_ta,trang_thai) VALUES (?,?,'SoTien',?,2000,1,0,NOW(),DATE_ADD(NOW(),INTERVAL 1 YEAR),?,1) ON DUPLICATE KEY UPDATE la_cong_khai=0,mo_ta=VALUES(mo_ta)", [code, discount, minimum, description]);
  }
}

if (process.argv[1]?.endsWith('seed-smartshop-rewards.mjs')) {
  dotenv.config();
  if (process.env.DB_NAME !== 'smartshop') throw new Error('Reward setup requires DB_NAME=smartshop.');
  const connection = await mysql.createConnection({ host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', database: 'smartshop' });
  try { await connection.beginTransaction(); await ensureSmartShopRewards(connection); await connection.commit(); console.log('SmartShop reward vouchers ready.'); }
  catch (error) { await connection.rollback(); throw error; }
  finally { await connection.end(); }
}
