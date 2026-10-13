import { spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, basename, join, resolve } from 'node:path';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';
import { expandedCatalog as catalog, extraSpecificationNames } from '../database/smartshop-expanded-catalog.mjs';
import { baseAccountNames } from '../database/smartshop-account-names.mjs';
import { specificationsForVariant } from '../database/smartshop-variant-specifications.mjs';
import { ensureSmartShopRewards } from './seed-smartshop-rewards.mjs';

dotenv.config();
const source = process.env.DB_NAME || 'dien_gia_dung';
const target = 'smartshop';
const apply = process.argv.includes('--apply');
const reset = process.argv.includes('--reset');
const fromSchema = process.argv.includes('--from-schema');
const seedOnly = process.argv.includes('--seed-only');
const products = catalog.flatMap(category => category.products);
const quote = value => '"' + String(value).replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r') + '"';
const sqlQuote = value => '`' + value.replaceAll('`', '``') + '`';

if (!apply) {
  console.log(`SmartShop: ${catalog.length} categories, ${products.length} products, ${products.reduce((n, p) => n + p.variants.length, 0)} variants.`);
  console.log(`Source schema: ${source}. New database: ${target}. Old records are excluded from the new database.`);
  console.log('Apply: npm run setup:smartshop -- --apply. Existing target requires --reset and is backed up first.');
  process.exit(0);
}

const config = { host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306), user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '', connectTimeout: 10000 };
const connection = await mysql.createConnection(config);
const temporary = await mkdtemp(join(tmpdir(), 'smartshop-mysql-'));
const defaultsFile = join(temporary, 'client.cnf');
const bin = process.env.MYSQL_BIN || 'C:/Program Files/MySQL/MySQL Server 8.0/bin';
const executable = name => process.platform === 'win32' ? join(bin, name + '.exe') : name;
const stamp = new Date().toISOString().replaceAll(/[:.]/g, '-');
const backupDirectory = resolve('database/backups');

function runClient(name, args, input) {
  const result = spawnSync(executable(name), [`--defaults-extra-file=${defaultsFile}`, ...args], { input, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, windowsHide: true });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${name} failed: ${result.stderr?.trim() || result.status}`);
  return result.stdout;
}

async function backup(database) {
  const filename = join(backupDirectory, `${database}-${stamp}.sql`);
  const content = runClient('mysqldump', ['--single-transaction', '--routines', '--triggers', '--events', '--no-tablespaces', '--set-gtid-purged=OFF', '--column-statistics=0', database]);
  if (!content.includes('Dump completed')) throw new Error('Backup did not complete; refusing to reset data.');
  await writeFile(filename, content, 'utf8');
  console.log('Backup saved:', filename);
}

try {
  await mkdir(backupDirectory, { recursive: true });
  await writeFile(defaultsFile, `[client]\nhost=${quote(config.host)}\nport=${config.port}\nuser=${quote(config.user)}\npassword=${quote(config.password)}\ndefault-character-set=utf8mb4\n`, { mode: 0o600 });
  const [databases] = await connection.execute('SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?', [target]);
  if (seedOnly && source !== target) throw new Error('--seed-only requires DB_NAME=smartshop.');
  if (databases.length && !reset && !seedOnly) throw new Error('smartshop already exists. Use --apply --reset to replace it after an automatic backup.');
  if (!seedOnly) {
  if (!fromSchema) await backup(source);
  if (databases.length && (fromSchema || source !== target)) await backup(target);
  // Dump structure, routines, triggers, and events before resetting a target that is also the source.
  const schema = fromSchema ? await readFile('database/smartshop-schema.sql', 'utf8') : runClient('mysqldump', ['--no-data', '--routines', '--triggers', '--events', '--no-tablespaces', '--set-gtid-purged=OFF', '--column-statistics=0', source]);
  const [qualifiedRoutines] = fromSchema ? [[]] : await connection.execute('SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=? AND (LOCATE(?, ROUTINE_DEFINITION)>0 OR LOCATE(?, ROUTINE_DEFINITION)>0)', [source, `${source}.`, `\`${source}\`.`]);
  if (qualifiedRoutines.length && source !== target) throw new Error('Source routines contain qualified database names. Adapt those routines before copying the schema.');
  if (databases.length) await connection.query(`DROP DATABASE ${sqlQuote(target)}`);
  await connection.query(`CREATE DATABASE ${sqlQuote(target)} CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
  runClient('mysql', [`--database=${target}`], schema);
  await connection.query(`USE ${sqlQuote(target)}`);
  const [tables] = await connection.query('SHOW TABLES');
  for (const row of tables) await connection.query(`ALTER TABLE ${sqlQuote(Object.values(row)[0])} AUTO_INCREMENT=1`);
  const portableSchema = schema.replace(/DEFINER=`[^`]+`@`[^`]+`/g, '');
  if (!fromSchema) await writeFile('database/smartshop-schema.sql', '-- SmartShop schema only: no historical data. Import into an empty smartshop database.\n' + portableSchema);
  } else {
    await connection.query(`USE ${sqlQuote(target)}`);
    const [counts] = await connection.query('SELECT (SELECT COUNT(*) FROM tai_khoan)+(SELECT COUNT(*) FROM san_pham)+(SELECT COUNT(*) FROM danh_muc) AS total');
    if (counts[0].total !== 0) throw new Error('Database already contains catalog/accounts. Refusing to seed over existing records.');
  }
  await connection.beginTransaction();
  const password = await bcrypt.hash('123456', 12);
  const accounts = [['admin', 'Quản trị SmartShop', 'Admin', 'SSADMIN'], ['nhanvien', baseAccountNames.nhanvien, 'NhanVien', 'SSSTAFF'], ['khachhang', baseAccountNames.khachhang, 'KhachHang', 'SSMEMBER']];
  for (const [username, name, role, referral] of accounts) {
    const [result] = await connection.execute('INSERT INTO tai_khoan (ten_dang_nhap,mat_khau,ho_ten,email,vai_tro,trang_thai,diem_thuong,ma_gioi_thieu) VALUES (?,?,?,?,?,\'HoatDong\',500,?)', [username, password, name, `${username}@smartshop.example`, role, referral]);
    if (role === 'NhanVien') {
      await connection.execute("INSERT INTO nhan_vien (ma_tai_khoan,ho_ten,chuc_vu,ngay_vao_lam,luong,trang_thai) VALUES (?,?,'Nhân viên bán hàng',CURRENT_DATE(),9000000,'DangLam')", [result.insertId, name]);
      await connection.execute('INSERT INTO staff_permissions (ma_tai_khoan,permissions) VALUES (?,?)', [result.insertId, JSON.stringify(['orders','catalog','inventory','reports','reviews','vouchers','contacts'])]);
    }
  }
  const [group] = await connection.execute("INSERT INTO nhom_thong_so (ten_nhom_thong_so,thu_tu_hien_thi,trang_thai) VALUES ('Thuộc tính sản phẩm',1,1)");
  const [extraGroup] = await connection.execute("INSERT INTO nhom_thong_so (ten_nhom_thong_so,thu_tu_hien_thi,trang_thai) VALUES ('Thông tin sản phẩm',2,1)");
  const specs = new Map();
  for (const name of new Set(catalog.flatMap(category => category.specs))) {
    const [result] = await connection.execute("INSERT INTO thong_so (ma_nhom_thong_so,ten_thong_so,kieu_du_lieu,cho_phep_loc,thu_tu_hien_thi,trang_thai) VALUES (?,?,'TEXT',1,?,1)", [extraSpecificationNames.includes(name) ? extraGroup.insertId : group.insertId, name, specs.size + 1]);
    specs.set(name, result.insertId);
  }
  const brands = new Map();
  for (const category of catalog) {
    if (!brands.has(category.brand)) {
      const [brand] = await connection.execute('INSERT INTO thuong_hieu (ten_thuong_hieu,quoc_gia,mo_ta) VALUES (?,\'Việt Nam\',?)', [category.brand, `Thương hiệu mẫu ${category.brand} trong dự án SmartShop.`]);
      brands.set(category.brand, brand.insertId);
    }
    const [categoryRow] = await connection.execute('INSERT INTO danh_muc (ten_danh_muc,mo_ta,trang_thai) VALUES (?,?,1)', [category.name, category.description]);
    for (const [index, name] of category.specs.entries()) await connection.execute('INSERT INTO danh_muc_thong_so (ma_danh_muc,ma_thong_so,bat_buoc,thu_tu_hien_thi) VALUES (?,?,0,?)', [categoryRow.insertId, specs.get(name), index + 1]);
    for (const product of category.products) {
      const stock = product.variants.reduce((n, variant) => n + variant.stock, 0);
      const image = product.localImagePath || `/uploads/smartshop/${product.code}.jpg`;
      const description = `${product.name} — lựa chọn dành cho bạn tại SmartShop. ${category.description}\nDữ liệu và hình ảnh minh họa phục vụ đồ án thương mại điện tử.`;
      const [row] = await connection.execute("INSERT INTO san_pham (ma_danh_muc,ma_thuong_hieu,ma_san_pham_code,ten_san_pham,mo_ta,gia_nhap,gia_ban,so_luong,bao_hanh,hinh_anh,trang_thai) VALUES (?,?,?,?,?,?,?,?,?,?,'DangBan')", [categoryRow.insertId, brands.get(category.brand), product.code, product.name, description, Math.round(product.price * 0.65), product.price, stock, category.brand === 'SmartTech' || category.brand === 'SoundSpace' ? 12 : 0, image]);
      await connection.execute('INSERT INTO hinh_anh_san_pham (ma_san_pham,duong_dan,mo_ta,la_anh_chinh,thu_tu_hien_thi) VALUES (?,?,?,1,1)', [row.insertId, image, product.name]);
      for (const [name, value] of Object.entries(product.specs)) await connection.execute('INSERT INTO thong_so_san_pham (ma_san_pham,ma_thong_so,gia_tri) VALUES (?,?,?)', [row.insertId, specs.get(name), value]);
      for (const [index, variant] of product.variants.entries()) {
        const variantSpecs = Object.entries(product.specs).map(([name, value]) => ({ ma_thong_so: specs.get(name), ten_thong_so: name, ten_nhom: extraSpecificationNames.includes(name) ? 'Thông tin sản phẩm' : 'Thuộc tính sản phẩm', kieu_du_lieu: 'TEXT', gia_tri: value }));
        await connection.execute("INSERT INTO san_pham_bien_the (ma_san_pham,ma_sku,ten_bien_the,gia_ban,so_luong,trang_thai,thong_so_json) VALUES (?,?,?,?,?,'DangBan',?)", [row.insertId, `${product.code}-${index + 1}`, variant.name, variant.price, variant.stock, JSON.stringify(specificationsForVariant(variantSpecs, variant.name))]);
      }
    }
  }
  await connection.execute("INSERT INTO voucher (ma_code,giam_tien,loai,giam_toi_da,don_toi_thieu,so_luot,moi_khach,la_cong_khai,bat_dau,ket_thuc,mo_ta,trang_thai) VALUES ('SMART50',50000,'SoTien',NULL,500000,100,1,1,NOW(),DATE_ADD(NOW(),INTERVAL 90 DAY),'Giảm 50.000đ cho đơn từ 500.000đ',1),('SMART10',10,'PhanTram',100000,300000,100,1,1,NOW(),DATE_ADD(NOW(),INTERVAL 90 DAY),'Giảm 10%, tối đa 100.000đ cho đơn từ 300.000đ',1)");
  await ensureSmartShopRewards(connection);
  await connection.commit();
  const [check] = await connection.query('SELECT (SELECT COUNT(*) FROM danh_muc) categories,(SELECT COUNT(*) FROM san_pham) products,(SELECT COUNT(*) FROM san_pham_bien_the) variants,(SELECT COUNT(*) FROM don_hang) orders');
  if (check[0].categories !== catalog.length || check[0].products !== products.length || check[0].orders !== 0) throw new Error('New database counts do not match the fresh SmartShop catalog.');
  const env = await readFile('.env', 'utf8');
  await writeFile('.env', /^\s*DB_NAME\s*=/m.test(env) ? env.replace(/^\s*DB_NAME\s*=.*$/m, 'DB_NAME=smartshop') : env + '\nDB_NAME=smartshop\n');
  console.log('SmartShop ready:', JSON.stringify(check[0]));
  console.log('BE/.env now uses DB_NAME=smartshop. Source database remains as a recovery copy.');
} catch (error) {
  await connection.rollback().catch(() => {});
  console.error('SmartShop setup failed:', error.message);
  process.exitCode = 1;
} finally {
  await connection.end();
  if (resolve(dirname(temporary)) !== resolve(tmpdir()) || !basename(temporary).startsWith('smartshop-mysql-')) throw new Error('Unexpected temporary path; refusing cleanup.');
  await rm(temporary, { recursive: true, force: true });
}
