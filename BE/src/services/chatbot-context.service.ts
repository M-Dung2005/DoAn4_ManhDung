import type { RowDataPacket } from 'mysql2';
import { pool } from '../config/database.js';
import { chatSearchTerms, type ChatInput } from '../utils/chatbot.js';
import { customerVouchers } from './voucher.service.js';

export async function loadChatbotContext(accountId: number, input: ChatInput) {
  // Every private query binds the authenticated account; client account IDs are never accepted.
  const [categories] = await pool.query<RowDataPacket[]>('SELECT ma_danh_muc,ten_danh_muc FROM danh_muc WHERE trang_thai=1 ORDER BY ma_danh_muc LIMIT 60');
  const terms = chatSearchTerms(input);
  const relevance = terms.map(() => 'COALESCE((p.ten_san_pham LIKE ? OR d.ten_danh_muc LIKE ? OR t.ten_thuong_hieu LIKE ?),0)').join(' + ') || '0 + 0';
  const [products] = await pool.query<RowDataPacket[]>(`SELECT p.ma_san_pham,p.ma_san_pham_code,p.ten_san_pham,LEFT(p.mo_ta,400) mo_ta,
    p.gia_ban,p.so_luong,p.bao_hanh,p.trang_thai,p.hinh_anh,d.ten_danh_muc,t.ten_thuong_hieu
    FROM san_pham p JOIN danh_muc d ON d.ma_danh_muc=p.ma_danh_muc
    LEFT JOIN thuong_hieu t ON t.ma_thuong_hieu=p.ma_thuong_hieu
    WHERE d.trang_thai=1 AND p.trang_thai IN ('DangBan','HetHang')
    ORDER BY (p.ma_san_pham=?) DESC,(${relevance}) DESC,p.ma_san_pham DESC LIMIT 60`, [input.productId || 0, ...terms.flatMap(term => Array(3).fill(`%${term}%`))]);
  const ids = products.map(product => Number(product.ma_san_pham));
  const [variants] = ids.length ? await pool.query<RowDataPacket[]>('SELECT ma_san_pham,ma_bien_the,ten_bien_the,gia_ban,so_luong,trang_thai FROM san_pham_bien_the WHERE ma_san_pham IN (?) AND trang_thai IN (\'DangBan\',\'HetHang\') ORDER BY ma_san_pham,ma_bien_the LIMIT 240', [ids]) : [[]];
  const [specifications] = ids.length ? await pool.query<RowDataPacket[]>(`SELECT s.ma_san_pham,t.ten_thong_so,s.gia_tri,s.gia_tri_so,s.gia_tri_bool,t.don_vi
    FROM thong_so_san_pham s JOIN thong_so t ON t.ma_thong_so=s.ma_thong_so
    WHERE s.ma_san_pham IN (?) AND t.trang_thai=1 LIMIT 480`, [ids]) : [[]];
  const conversation = [...input.history.filter(item => item.role === 'user').slice(-2).map(item => item.content), input.message].join(' ').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').toLowerCase();
  const ordersRequested = /\bdon\b|\border\b|giao\s+hang|van\s+chuyen|mua\s+lai|da\s+dat/.test(conversation);
  const cartRequested = /gio\s+hang|cart/.test(conversation);
  const vouchersRequested = /voucher|ma\s+giam|giam\s+gia|khuyen\s+mai/.test(conversation);
  const [orders] = ordersRequested ? await pool.query<RowDataPacket[]>('SELECT ma_don_hang,trang_thai,tong_tien,ngay_dat,phuong_thuc_thanh_toan FROM don_hang WHERE ma_tai_khoan=? ORDER BY ma_don_hang DESC LIMIT 5', [accountId]) : [[]];
  const [cart] = cartRequested ? await pool.query<RowDataPacket[]>(`SELECT p.ten_san_pham,v.ten_bien_the,c.so_luong,COALESCE(v.gia_ban,p.gia_ban) gia_ban
    FROM gio_hang g JOIN chi_tiet_gio_hang c ON c.ma_gio_hang=g.ma_gio_hang JOIN san_pham p ON p.ma_san_pham=c.ma_san_pham
    LEFT JOIN san_pham_bien_the v ON v.ma_bien_the=c.ma_bien_the
    WHERE g.ma_tai_khoan=? LIMIT 20`, [accountId]) : [[]];
  const vouchers = vouchersRequested ? (await customerVouchers(accountId)).slice(0, 20).map(voucher => ({ ma_code: voucher.ma_code, giam_tien: voucher.giam_tien, loai: voucher.loai, giam_toi_da: voucher.giam_toi_da, don_toi_thieu: voucher.don_toi_thieu, ket_thuc: voucher.ket_thuc, co_the_dung: voucher.co_the_dung, ly_do: voucher.ly_do, la_cong_khai: voucher.la_cong_khai })) : null;
  const shippingFee = Math.max(0, Number(process.env.SHIPPING_FEE || 0));
  const freeShippingFrom = Math.max(0, Number(process.env.FREE_SHIPPING_FROM || 0));
  return {
    products,
    data: {
      store: 'SmartShop', currency: 'VND', categories,
      catalogLimitedTo: 60,
      productInQuestion: input.productId || null,
      products: products.map(({ hinh_anh: _image, ...product }) => ({ ...product,
        variants: variants.filter(variant => variant.ma_san_pham === product.ma_san_pham),
        attributes: specifications.filter(spec => spec.ma_san_pham === product.ma_san_pham),
      })),
      orders: ordersRequested ? orders : null,
      cart: cartRequested ? cart : null,
      cartLimitedTo: 20,
      vouchers,
      policies: {
        payment: 'Thanh toán khi nhận hàng (COD).',
        shippingFee, freeShippingFrom,
        cancellation: 'Khách hàng có thể hủy khi đơn còn Chờ xác nhận. Các trường hợp khác cần liên hệ nhân viên.',
        receipt: 'Khách hàng xác nhận đã nhận hàng khi đơn đang giao; sau đó có thể đánh giá sản phẩm.',
        vouchers: 'Voucher hiển thị trong Voucher của tôi. Mã riêng cần được cấp/nhận trước; hạn dùng, giá trị đơn tối thiểu và lượt sử dụng được kiểm tra ở thanh toán.',
        rewards: 'Khách có thể điểm danh, xem các mốc thưởng, đổi Xu, quay may mắn và giới thiệu bạn bè trong mục Điểm danh & Quà tặng.',
        returns: 'Chưa có chính sách đổi trả hoặc thời gian giao hàng được xác nhận. Chuyển khách sang liên hệ nhân viên khi được hỏi.',
      },
    },
  };
}
