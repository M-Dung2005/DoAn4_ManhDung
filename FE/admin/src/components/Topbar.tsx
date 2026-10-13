import { Avatar, Button, Space } from 'antd';
import { LogoutOutlined, MenuOutlined } from '@ant-design/icons';
import { useAuth } from '../auth/AuthContext';
import { labels } from '../utils/format';
export default function Topbar({ title, toggle }: { title: string; toggle: () => void }) {
  const { user, logout } = useAuth();
  return <header className="topbar"><Space><Button className="menu-toggle" onClick={toggle} aria-label="Mở menu" icon={<MenuOutlined />} /><div><span className="topbar-subtitle">SMARTSHOP / QUẢN LÝ</span><strong>{title}</strong></div></Space><Space wrap size={14}><Avatar style={{ background: '#eef2ff', color: '#4f46e5', fontWeight: 700 }}>{user?.ho_ten?.charAt(0)}</Avatar><div className="topbar-user"><strong>{user?.ho_ten}</strong><span>{labels[user?.vai_tro || '']}</span></div><Button onClick={logout} icon={<LogoutOutlined />}>Đăng xuất</Button></Space></header>;
}
