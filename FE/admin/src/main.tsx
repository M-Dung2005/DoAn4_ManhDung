import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import './styles.css';
import './smartshop.css';
import { App as AntApp, ConfigProvider } from 'antd';
import viVN from 'antd/locale/vi_VN';

function AdminApp() {
  const [reducedMotion, setReducedMotion] = React.useState(() => window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  React.useEffect(() => {
    const preference = window.matchMedia('(prefers-reduced-motion: reduce)');
    const update = () => setReducedMotion(preference.matches);
    update();
    preference.addEventListener('change', update);
    return () => preference.removeEventListener('change', update);
  }, []);
  return <ConfigProvider locale={viVN} theme={{ token: { colorPrimary: '#4f46e5', borderRadius: 10, motion: !reducedMotion } }}><AntApp><App /></AntApp></ConfigProvider>;
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <AdminApp />
    </BrowserRouter>
  </React.StrictMode>,
);
