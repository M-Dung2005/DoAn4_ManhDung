import { NavLink } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { canAccess } from '../auth/permissions';
import { AppstoreOutlined, BarChartOutlined, DashboardOutlined, GiftOutlined, InboxOutlined, MessageOutlined, OrderedListOutlined, ShopOutlined, StarOutlined, TagsOutlined, TeamOutlined, UserOutlined, SettingOutlined, ProfileOutlined } from '@ant-design/icons';
import Brand from './Brand';
export const navigation = [
  ['/dashboard', 'Tổng quan'], ['/products', 'Sản phẩm'], ['/categories', 'Danh mục'], ['/category-specifications', 'Danh mục thông số'], ['/brands', 'Thương hiệu'],
  ['/orders', 'Đơn hàng'], ['/customers', 'Khách hàng / Tài khoản'], ['/employees', 'Nhân viên'], ['/reviews', 'Đánh giá'], ['/contacts', 'Liên hệ'],
  ['/inventory','Nhập kho'], ['/vouchers','Mã giảm giá'], ['/account','Tài khoản của tôi'],
  ['/reports','Báo cáo'],
];
export default function Sidebar({ onNavigate }: { onNavigate?: () => void }) {
  const { user } = useAuth();
  const icons = [DashboardOutlined, ShopOutlined, AppstoreOutlined, SettingOutlined, TagsOutlined, OrderedListOutlined, TeamOutlined, UserOutlined, StarOutlined, MessageOutlined, InboxOutlined, GiftOutlined, ProfileOutlined, BarChartOutlined];
  return <aside className="sidebar"><Brand light /><div className="sidebar-caption">KHÔNG GIAN QUẢN TRỊ</div><nav className="sidebar-nav" aria-label="Menu quản trị">{navigation.map(([path, label], index) => ({ path, label, Icon: icons[index] })).filter(({ path }) => canAccess(user, path)).map(({ path, label, Icon }) => <NavLink key={path} to={path} onClick={onNavigate}><Icon aria-hidden="true" className="nav-icon" /><span>{label}</span></NavLink>)}</nav><div className="sidebar-footer"><span className="sidebar-status" /> SmartShop Workspace<small>Quản lý cửa hàng, kết nối khách hàng.</small></div></aside>;
}
