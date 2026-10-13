import { useState } from 'react';
import { Alert, Button, Form, Input } from 'antd';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { startPage } from '../auth/permissions';
import { errorMessage } from '../utils/errors';
import Brand from '../components/Brand';
import { AppstoreOutlined, ShoppingCartOutlined, BarChartOutlined } from '@ant-design/icons';
export default function LoginPage() {
  const { user, login } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  if (user) return <Navigate to={startPage(user)} replace />;
  return <div className="login-page"><section className="login-story"><Brand light /><div className="login-story-copy"><span className="login-kicker">SMARTSHOP WORKSPACE</span><h1>Một cửa hàng.<br />Vạn kết nối.</h1><p>Không gian vận hành hệ thống thương mại điện tử. Từ sản phẩm đến đơn hàng, mọi thứ trong tầm tay.</p><div className="login-feature-grid"><div><AppstoreOutlined /><strong>Danh mục đa ngành</strong><span>Sản phẩm, thuộc tính và biến thể</span></div><div><ShoppingCartOutlined /><strong>Vận hành liền mạch</strong><span>Đơn hàng, khách hàng và kho</span></div><div><BarChartOutlined /><strong>Hiểu hoạt động kinh doanh</strong><span>Doanh thu và báo cáo bán hàng</span></div></div></div><small>SmartShop · Hệ thống thương mại điện tử</small></section><div className="login-box"><span className="eyebrow">CHÀO MỪNG TRỞ LẠI</span><h2>Đăng nhập quản trị</h2><p className="login-description">Đăng nhập để bắt đầu quản lý SmartShop.</p>
    {error && <Alert type="error" showIcon message={error} />}
    <Form layout="vertical" onFinish={async (values: { username: string; password: string }) => {
      if (loading) return; setLoading(true); setError('');
      try { await login(values.username, values.password); } catch (e) { setError(errorMessage(e)); } finally { setLoading(false); }
    }}>
      <Form.Item name="username" label="Tên đăng nhập" rules={[{ required: true, whitespace: true, message: 'Nhập tên đăng nhập' }]}><Input autoComplete="username" /></Form.Item>
      <Form.Item name="password" label="Mật khẩu" rules={[{ required: true, message: 'Nhập mật khẩu' }]}><Input.Password autoComplete="current-password" /></Form.Item>
      <Button type="primary" htmlType="submit" loading={loading} block>Đăng nhập</Button>
    </Form><p className="login-footer">SmartShop · Không gian dành cho quản trị viên và nhân viên</p></div></div>;
}
