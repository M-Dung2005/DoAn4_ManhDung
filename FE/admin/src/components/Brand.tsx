import { ShoppingOutlined } from '@ant-design/icons';

export default function Brand({ light = false }: { light?: boolean }) {
  return <div className={`smartshop-brand${light ? ' smartshop-brand-light' : ''}`}>
    <span className="smartshop-logo"><ShoppingOutlined /></span>
    <div><strong>Smart<span>Shop</span></strong><small>THƯƠNG MẠI ĐIỆN TỬ</small></div>
  </div>;
}
