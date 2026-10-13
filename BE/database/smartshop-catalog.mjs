// Demo catalog for the SmartShop ecommerce project. Prices/specifications are sample data.
// Photographs illustrate product types, rather than certify a brand or exact model.
const photo = id => `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=700&q=85`;
export const catalog = [
  { name: 'Điện thoại & phụ kiện', description: 'Điện thoại, sạc và phụ kiện cho cuộc sống kết nối.', brand: 'SmartTech', specs: ['Dung lượng', 'Kết nối'], products: [
    ['Điện thoại Nova S 128GB', 6490000, '1511707171634-5f897ff02aa9', ['128 GB', '5G / Wi-Fi'], ['Đen / 128 GB', 'Bạc / 128 GB']],
    ['Điện thoại Nova Lite 64GB', 3290000, '1592750475338-74b7b21085ab', ['64 GB', '4G / Wi-Fi'], ['Đen / 64 GB', 'Xanh / 64 GB']],
    ['Sạc nhanh USB-C 30W', 290000, '1583863788434-e58a36330cf0', ['30 W', 'USB-C'], ['Trắng', 'Đen']],
    ['Ốp lưng bảo vệ Nova S', 149000, '1606041008023-472dfb5e530f', ['Nova S', 'Ốp lưng'], ['Trong suốt', 'Xanh navy']],
  ] },
  { name: 'Máy tính & văn phòng', description: 'Máy tính và phụ kiện cho học tập, làm việc.', brand: 'SmartTech', specs: ['Bộ nhớ RAM', 'Kết nối'], products: [
    ['Laptop AirBook 14 inch', 15990000, '1496181133206-80ce9b88a853', ['16 GB', 'Wi-Fi / Bluetooth'], ['Bạc', 'Xám']],
    ['Laptop WorkBook 15 inch', 12990000, '1517336714731-489689fd1ca8', ['8 GB', 'Wi-Fi / Bluetooth'], ['Bạc', 'Đen']],
    ['Bàn phím cơ Compact K68', 890000, '1587829741301-dc798b83add3', ['Không áp dụng', 'USB-C'], ['Trắng', 'Đen']],
    ['Chuột không dây Silent M2', 349000, '1527814050087-3793815479db', ['Không áp dụng', 'Bluetooth'], ['Đen', 'Trắng']],
  ] },
  { name: 'Âm thanh & công nghệ', description: 'Tai nghe, đồng hồ và thiết bị giải trí cá nhân.', brand: 'SoundSpace', specs: ['Kết nối', 'Thời lượng pin'], products: [
    ['Tai nghe không dây Studio Pro', 1290000, '1505740420928-5e560c06d30e', ['Bluetooth 5.3', '30 giờ'], ['Đen', 'Kem']],
    ['Tai nghe chụp tai Everyday', 690000, '1546435770-a3e426bf472b', ['Bluetooth 5.0', '20 giờ'], ['Đen', 'Trắng']],
    ['Loa bluetooth Mini Beat', 790000, '1608043152269-423dbba4e7e1', ['Bluetooth 5.0', '12 giờ'], ['Đen', 'Xanh']],
    ['Đồng hồ thông minh Fit Watch', 1590000, '1523275335684-37898b6baf30', ['Bluetooth 5.2', '7 ngày'], ['Dây đen', 'Dây trắng']],
  ] },
  { name: 'Thời trang', description: 'Trang phục hằng ngày, thoải mái và dễ phối.', brand: 'UrbanWear', specs: ['Chất liệu', 'Kích cỡ'], products: [
    ['Áo thun cotton Essential', 199000, '1521572163474-6864f9cf17ab', ['Cotton', 'M / L'], ['Trắng / M', 'Trắng / L']],
    ['Áo sơ mi linen Everyday', 399000, '1596755094514-f87e34085b2c', ['Linen', 'M / L'], ['Be / M', 'Be / L']],
    ['Áo khoác denim Urban', 599000, '1543076447-215ad9ba6923', ['Denim', 'M / L'], ['Xanh / M', 'Xanh / L']],
    ['Quần jeans Straight Fit', 449000, '1542272604-787c3835535d', ['Denim', '29 / 30'], ['Xanh / 29', 'Xanh / 30']],
  ] },
  { name: 'Giày dép & túi xách', description: 'Giày và túi đồng hành cùng phong cách của bạn.', brand: 'DailyMove', specs: ['Chất liệu', 'Kích cỡ'], products: [
    ['Giày sneaker Street One', 790000, '1542291026-7eec264c27ff', ['Vải mesh / cao su', '40 / 41'], ['Đỏ / 40', 'Đỏ / 41']],
    ['Giày thể thao Cloud Walk', 890000, '1549298916-b41d501d3772', ['Vải dệt / cao su', '38 / 39'], ['Trắng / 38', 'Trắng / 39']],
    ['Balo City Pack 20L', 490000, '1553062407-98eeb64c6a62', ['Polyester', '20 lít'], ['Đen', 'Xám']],
    ['Túi tote Canvas Daily', 159000, '1590874103328-eac38a683ce7', ['Canvas', '35 x 40 cm'], ['Kem', 'Đen']],
  ] },
  { name: 'Làm đẹp & chăm sóc', description: 'Chăm sóc da và cơ thể trong thói quen mỗi ngày.', brand: 'PureCare', specs: ['Dung tích', 'Loại da'], products: [
    ['Serum dưỡng ẩm Hydra 30ml', 329000, '1608248543803-ba4f8c70ae0b', ['30 ml', 'Mọi loại da'], ['30 ml', 'Bộ 2 chai 30 ml']],
    ['Kem dưỡng Daily Moisture 50ml', 259000, '1556229010-6c3f2c9ca5f8', ['50 ml', 'Da thường / da khô'], ['50 ml', 'Bộ 2 hũ 50 ml']],
    ['Sữa rửa mặt Gentle Clean 150ml', 179000, '1556228720-195a672e8a03', ['150 ml', 'Mọi loại da'], ['150 ml', 'Bộ 2 chai 150 ml']],
    ['Dầu gội Botanical Care 300ml', 189000, '1608571423902-eed4a5ad8108', ['300 ml', 'Chăm sóc tóc'], ['300 ml', 'Bộ 2 chai 300 ml']],
  ] },
  { name: 'Nhà cửa & đời sống', description: 'Đồ dùng và cảm hứng cho không gian sống.', brand: 'LivingLab', specs: ['Chất liệu', 'Kích thước'], products: [
    ['Đèn bàn Nordic Light', 459000, '1507473885765-e6ed057f782c', ['Kim loại / gỗ', '35 cm'], ['Trắng', 'Đen']],
    ['Ghế thư giãn Cozy Chair', 1890000, '1567538096630-e0c55bd6374c', ['Vải / gỗ', '65 x 70 x 80 cm'], ['Be', 'Xám']],
    ['Bình giữ nhiệt Travel 500ml', 299000, '1602143407151-7111542de6e8', ['Inox', '500 ml'], ['Đen', 'Trắng']],
    ['Chậu cây trang trí Mini Green', 129000, '1485955900006-10f4d324d411', ['Gốm', '15 cm'], ['Trắng', 'Đất nung']],
  ] },
  { name: 'Thể thao & ngoài trời', description: 'Dụng cụ luyện tập và phụ kiện cho ngày năng động.', brand: 'ActiveLife', specs: ['Chất liệu', 'Kích thước'], products: [
    ['Thảm yoga Balance 6mm', 349000, '1544367567-0f2fcb009e0b', ['TPE', '183 x 61 cm'], ['Tím', 'Xanh']],
    ['Bộ tạ tay Home Fit 2kg', 299000, '1517836357463-d25dfeac3438', ['Kim loại bọc cao su', '2 kg / chiếc'], ['Đen', 'Hồng']],
    ['Bóng rổ Training Size 7', 249000, '1546519638-68e109498ffc', ['Cao su', 'Size 7'], ['Cam', 'Đen']],
    ['Bình nước thể thao Active 750ml', 159000, '1602143407151-7111542de6e8', ['Nhựa không BPA', '750 ml'], ['Xanh', 'Đen']],
  ] },
  { name: 'Sách & văn phòng phẩm', description: 'Sách, sổ và đồ dùng cho học tập, sáng tạo.', brand: 'PaperStory', specs: ['Chất liệu', 'Khổ giấy'], products: [
    ['Sổ tay Planner Daily A5', 89000, '1455390582262-044cdead277a', ['Giấy 100 gsm', 'A5'], ['Bìa xanh', 'Bìa kem']],
    ['Sách Kỹ năng học tập hiệu quả', 119000, '1544947950-fa07a98d237f', ['Bìa mềm', '14 x 20.5 cm'], ['Bìa xanh', 'Bìa trắng']],
    ['Bộ bút màu Creative 24 màu', 99000, '1513542789411-b6a5d4f31634', ['Gỗ', '24 màu'], ['Hộp giấy', 'Hộp kim loại']],
    ['Sổ ghi chép Minimal A6', 49000, '1531346878377-a5be20888e57', ['Giấy 80 gsm', 'A6'], ['Bìa đen', 'Bìa nâu']],
  ] },
].map((category, categoryIndex) => ({ ...category, products: category.products.map(([name, price, image, values, variants], index) => ({
  code: `SS-${String(categoryIndex + 1).padStart(2, '0')}${String(index + 1).padStart(2, '0')}`,
  name, price, image: photo(image), specs: Object.fromEntries(category.specs.map((key, i) => [key, values[i]])),
  variants: variants.map((name, i) => ({ name, stock: 20, price: category.name === 'Làm đẹp & chăm sóc' && i === 1 ? price * 2 : price })),
})) }));
