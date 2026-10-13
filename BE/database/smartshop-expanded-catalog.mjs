import { catalog as originalCatalog } from './smartshop-catalog.mjs';
import { productPhotos } from './smartshop-product-photos.mjs';

// Illustrative ecommerce data with a distinct real source photo for each product.
export const extraSpecificationNames = [
  'Xuất xứ', 'Dòng sản phẩm', 'Đối tượng sử dụng', 'Quy cách đóng gói',
  'Khối lượng đóng gói', 'Chất liệu hoặc thành phần', 'Màu sắc / phiên bản',
  'Hướng dẫn sử dụng', 'Hướng dẫn bảo quản', 'Tình trạng sản phẩm',
];

// name, price, original photo index, original category attributes, variant labels
const additions = [
  [
    ['Điện thoại Nova Max 256GB', 8990000, 0, ['256 GB', '5G / Wi-Fi'], ['Đen / 256 GB', 'Bạc / 256 GB']],
    ['Điện thoại Nova Mini 128GB', 4590000, 1, ['128 GB', '4G / Wi-Fi'], ['Xanh / 128 GB', 'Trắng / 128 GB']],
    ['Sạc nhanh GaN Dual 65W', 590000, 2, ['65 W', 'USB-C / USB-A'], ['Trắng', 'Đen']],
    ['Sạc nhanh Compact 20W', 199000, 2, ['20 W', 'USB-C'], ['Trắng', 'Đen']],
    ['Ốp lưng Silicone Nova Lite', 129000, 3, ['Nova Lite', 'Ốp lưng'], ['Xanh pastel', 'Hồng pastel']],
    ['Ốp lưng chống sốc Nova Max', 189000, 3, ['Nova Max', 'Ốp lưng'], ['Đen', 'Trong suốt']],
    ['Điện thoại Nova Pro 512GB', 11990000, 0, ['512 GB', '5G / Wi-Fi'], ['Đen / 512 GB', 'Bạc / 512 GB']],
  ],
  [
    ['Laptop StudyBook 14 inch', 10990000, 0, ['8 GB', 'Wi-Fi / Bluetooth'], ['Bạc', 'Xám']],
    ['Laptop ProBook 16 inch', 22990000, 1, ['32 GB', 'Wi-Fi / Bluetooth'], ['Đen', 'Bạc']],
    ['Bàn phím cơ FullSize K104', 1190000, 2, ['Không áp dụng', 'USB-C'], ['Đen', 'Trắng']],
    ['Bàn phím không dây Office K78', 649000, 2, ['Không áp dụng', 'Bluetooth / USB'], ['Trắng', 'Xám']],
    ['Chuột không dây Travel M3', 249000, 3, ['Không áp dụng', 'Bluetooth'], ['Đen', 'Xanh']],
    ['Chuột gaming Precision G5', 599000, 3, ['Không áp dụng', 'USB'], ['Đen', 'Trắng']],
    ['Laptop CreatorBook 15 inch', 19990000, 1, ['16 GB', 'Wi-Fi / Bluetooth'], ['Xám', 'Bạc']],
  ],
  [
    ['Tai nghe chống ồn Quiet Pro', 1890000, 0, ['Bluetooth 5.3', '40 giờ'], ['Đen', 'Be']],
    ['Tai nghe chụp tai Comfort Lite', 549000, 1, ['Bluetooth 5.2', '25 giờ'], ['Trắng', 'Xanh']],
    ['Loa bluetooth Outdoor Beat', 1190000, 2, ['Bluetooth 5.3', '16 giờ'], ['Đen', 'Đỏ']],
    ['Loa bluetooth Pocket Sound', 449000, 2, ['Bluetooth 5.2', '8 giờ'], ['Xanh', 'Hồng']],
    ['Đồng hồ thông minh Active Watch', 1990000, 3, ['Bluetooth 5.3', '10 ngày'], ['Dây đen', 'Dây xanh']],
    ['Đồng hồ thông minh Slim Watch', 1290000, 3, ['Bluetooth 5.2', '5 ngày'], ['Dây trắng', 'Dây hồng']],
    ['Tai nghe Studio Wireless Max', 2490000, 0, ['Bluetooth 5.3', '50 giờ'], ['Đen', 'Bạc']],
  ],
  [
    ['Áo thun cổ tròn Basic Soft', 179000, 0, ['Cotton 100%', 'M / L'], ['Đen / M', 'Đen / L']],
    ['Áo thun Oversize Street', 249000, 0, ['Cotton', 'L / XL'], ['Trắng / L', 'Trắng / XL']],
    ['Áo sơ mi Oxford Classic', 429000, 1, ['Cotton Oxford', 'M / L'], ['Xanh / M', 'Xanh / L']],
    ['Áo sơ mi linen Summer', 359000, 1, ['Linen pha cotton', 'S / M'], ['Be / S', 'Be / M']],
    ['Áo khoác denim Vintage', 649000, 2, ['Denim', 'M / L'], ['Xanh / M', 'Xanh / L']],
    ['Quần jeans Slim Everyday', 399000, 3, ['Denim co giãn', '30 / 31'], ['Đen / 30', 'Đen / 31']],
    ['Quần jeans Wide Leg Urban', 499000, 3, ['Denim', '29 / 30'], ['Xanh nhạt / 29', 'Xanh nhạt / 30']],
  ],
  [
    ['Giày sneaker Canvas Classic', 549000, 0, ['Canvas / cao su', '39 / 40'], ['Đen / 39', 'Đen / 40']],
    ['Giày thể thao Runner Air', 990000, 1, ['Vải mesh / EVA', '40 / 41'], ['Trắng / 40', 'Trắng / 41']],
    ['Giày sneaker Street Low', 699000, 0, ['Da tổng hợp / cao su', '38 / 39'], ['Đỏ / 38', 'Đỏ / 39']],
    ['Balo Laptop City 25L', 649000, 2, ['Polyester chống thấm nhẹ', '25 lít'], ['Đen', 'Xám']],
    ['Balo Travel Compact 15L', 399000, 2, ['Nylon', '15 lít'], ['Xanh', 'Đen']],
    ['Túi tote Canvas Large', 199000, 3, ['Canvas', '40 x 45 cm'], ['Kem', 'Đen']],
    ['Túi tote Daily Zip', 249000, 3, ['Canvas có khóa kéo', '35 x 38 cm'], ['Nâu', 'Kem']],
  ],
  [
    ['Serum cấp ẩm Aqua Boost 30ml', 299000, 0, ['30 ml', 'Mọi loại da'], ['30 ml', 'Bộ 2 chai 30 ml']],
    ['Serum dưỡng da Daily Glow 30ml', 359000, 0, ['30 ml', 'Da thường'], ['30 ml', 'Bộ 2 chai 30 ml']],
    ['Kem dưỡng Night Soft 50ml', 289000, 1, ['50 ml', 'Da thường / da khô'], ['50 ml', 'Bộ 2 hũ 50 ml']],
    ['Kem dưỡng Light Gel 50ml', 249000, 1, ['50 ml', 'Da hỗn hợp'], ['50 ml', 'Bộ 2 hũ 50 ml']],
    ['Sữa rửa mặt Foam Fresh 150ml', 159000, 2, ['150 ml', 'Mọi loại da'], ['150 ml', 'Bộ 2 chai 150 ml']],
    ['Dầu gội Herbal Fresh 300ml', 199000, 3, ['300 ml', 'Chăm sóc tóc'], ['300 ml', 'Bộ 2 chai 300 ml']],
    ['Dầu gội Smooth Daily 300ml', 229000, 3, ['300 ml', 'Chăm sóc tóc'], ['300 ml', 'Bộ 2 chai 300 ml']],
  ],
  [
    ['Đèn bàn Reading LED', 399000, 0, ['Kim loại / nhựa ABS', '40 cm'], ['Trắng', 'Đen']],
    ['Đèn bàn Minimal Wood', 549000, 0, ['Gỗ / kim loại', '38 cm'], ['Gỗ sáng', 'Gỗ nâu']],
    ['Ghế thư giãn Lounge Soft', 2290000, 1, ['Vải / gỗ', '70 x 75 x 85 cm'], ['Be', 'Xám']],
    ['Ghế đọc sách Cozy Mini', 1590000, 1, ['Vải / gỗ', '60 x 65 x 75 cm'], ['Xanh', 'Nâu']],
    ['Bình giữ nhiệt Daily 750ml', 359000, 2, ['Inox 304', '750 ml'], ['Đen', 'Bạc']],
    ['Chậu cây gốm Nordic 20cm', 189000, 3, ['Gốm', '20 cm'], ['Trắng', 'Đất nung']],
  ],
  [
    ['Thảm yoga Comfort 8mm', 429000, 0, ['TPE', '183 x 61 cm'], ['Tím', 'Xanh']],
    ['Thảm yoga Travel 4mm', 249000, 0, ['Cao su tổng hợp', '173 x 61 cm'], ['Hồng', 'Xám']],
    ['Bộ tạ tay Home Fit 3kg', 399000, 1, ['Kim loại bọc cao su', '3 kg / chiếc'], ['Đen', 'Xanh']],
    ['Bộ tạ tay Home Fit 5kg', 599000, 1, ['Kim loại bọc cao su', '5 kg / chiếc'], ['Đen', 'Đỏ']],
    ['Bóng rổ Street Size 6', 229000, 2, ['Cao su', 'Size 6'], ['Cam', 'Đen']],
    ['Bình nước Active Sport 1L', 199000, 3, ['Nhựa không BPA', '1 lít'], ['Xanh', 'Đen']],
  ],
  [
    ['Sổ tay Weekly Planner A5', 99000, 0, ['Giấy 100 gsm', 'A5'], ['Bìa xanh', 'Bìa nâu']],
    ['Sổ ghi chép Dot Grid A5', 79000, 3, ['Giấy 100 gsm', 'A5'], ['Bìa đen', 'Bìa kem']],
    ['Sách Quản lý thời gian thông minh', 129000, 1, ['Bìa mềm', '14 x 20.5 cm'], ['Bìa xanh', 'Bìa trắng']],
    ['Sách Tư duy sáng tạo mỗi ngày', 139000, 1, ['Bìa mềm', '14 x 20.5 cm'], ['Bìa vàng', 'Bìa xanh']],
    ['Bộ bút màu Artist 36 màu', 149000, 2, ['Gỗ', '36 màu'], ['Hộp giấy', 'Hộp kim loại']],
    ['Sổ ghi chép Pocket A6', 59000, 3, ['Giấy 80 gsm', 'A6'], ['Bìa nâu', 'Bìa xanh']],
  ],
];

const profiles = [
  ['Trung Quốc', 'Thiết bị và phụ kiện di động', 'Người dùng điện thoại', 'Hộp bảo vệ kèm hướng dẫn', '0,5 kg', 'Nhựa ABS / kim loại', 'Sử dụng theo hướng dẫn của thiết bị', 'Giữ khô ráo, tránh nguồn nhiệt và va đập'],
  ['Trung Quốc', 'Thiết bị học tập và văn phòng', 'Học sinh, sinh viên và nhân viên văn phòng', 'Hộp bảo vệ kèm phụ kiện', '1,8 kg', 'Nhựa ABS / hợp kim', 'Kết nối và sử dụng theo hướng dẫn đi kèm', 'Tránh ẩm, vệ sinh bằng khăn mềm'],
  ['Trung Quốc', 'Thiết bị âm thanh và thông minh', 'Người dùng thiết bị giải trí', 'Hộp sản phẩm kèm phụ kiện', '0,4 kg', 'Nhựa ABS / silicone', 'Ghép nối với thiết bị tương thích theo hướng dẫn', 'Giữ khô ráo, tránh nhiệt độ cao'],
  ['Việt Nam', 'Trang phục hằng ngày', 'Người trưởng thành', 'Túi bảo vệ sản phẩm', '0,4 kg', 'Vải', 'Chọn kích cỡ phù hợp với số đo', 'Giặt theo nhãn chăm sóc, phơi nơi thoáng mát'],
  ['Việt Nam', 'Phụ kiện thời trang', 'Người trưởng thành', 'Hộp hoặc túi bảo vệ sản phẩm', '0,8 kg', 'Vải / cao su', 'Chọn kích cỡ hoặc dung tích phù hợp nhu cầu', 'Vệ sinh nhẹ, tránh ngâm nước lâu'],
  ['Việt Nam', 'Chăm sóc cá nhân', 'Người trưởng thành', 'Hộp niêm phong theo dung tích', '0,3 kg', 'Theo bảng thành phần trên bao bì', 'Đọc hướng dẫn sử dụng trên bao bì', 'Đậy kín, bảo quản nơi khô mát, tránh ánh nắng'],
  ['Việt Nam', 'Đồ dùng gia đình', 'Gia đình và người dùng cá nhân', 'Hộp bảo vệ phù hợp kích thước', '1 kg', 'Theo mô tả chất liệu', 'Sử dụng đúng công năng và hướng dẫn đi kèm', 'Vệ sinh định kỳ, tránh va đập'],
  ['Việt Nam', 'Dụng cụ luyện tập', 'Người yêu thích vận động', 'Hộp hoặc túi bảo vệ sản phẩm', '1 kg', 'Theo mô tả chất liệu', 'Lựa chọn sản phẩm phù hợp nhu cầu luyện tập', 'Vệ sinh sau sử dụng, giữ nơi khô ráo'],
  ['Việt Nam', 'Học tập và sáng tạo', 'Học sinh, sinh viên và người làm văn phòng', 'Túi hoặc hộp bảo vệ', '0,3 kg', 'Giấy / gỗ', 'Sử dụng cho học tập, ghi chép và sáng tạo', 'Giữ khô ráo, tránh nước và nguồn nhiệt'],
];

export function extraSpecifications(product, categoryIndex) {
  const p = profiles[categoryIndex];
  const material = product.specs?.['Chất liệu'] || p[5];
  const versions = (product.variants || []).map(v => v.name || v.ten_bien_the).filter(Boolean).join(' / ') || 'Tiêu chuẩn';
  const weight = /Ghế/.test(product.name) ? '8 kg' : /tạ.*5kg/.test(product.name) ? '10,5 kg' : /tạ.*3kg/.test(product.name) ? '6,5 kg' : /tạ.*2kg/.test(product.name) ? '4,5 kg' : p[4];
  return Object.fromEntries(extraSpecificationNames.map((name, i) => [name, [p[0], p[1], p[2], p[3], weight, material, versions, p[6], p[7], 'Mới, chưa qua sử dụng'][i]]));
}

export const additionalCatalog = originalCatalog.map((category, categoryIndex) => ({ ...category, products: additions[categoryIndex].map(([name, price, photoIndex, values, labels], index) => ({
  code: `SS-${String(categoryIndex + 1).padStart(2, '0')}${String(index + 5).padStart(2, '0')}`,
  name, price, image: category.products[photoIndex].image, imageReference: category.products[photoIndex].code,
  specs: Object.fromEntries(category.specs.map((key, i) => [key, values[i]])),
  variants: labels.map((name, i) => ({ name, stock: 20, price: categoryIndex === 5 && i === 1 ? price * 2 : price })),
})) }));

export const expandedCatalog = originalCatalog.map((category, categoryIndex) => ({
  ...category, specs: [...category.specs, ...extraSpecificationNames],
  products: [...category.products, ...additionalCatalog[categoryIndex].products].map(product => ({
    ...product, image: productPhotos[product.code].url, localImagePath: productPhotos[product.code].path,
    specs: { ...product.specs, ...extraSpecifications(product, categoryIndex) },
  })),
}));
