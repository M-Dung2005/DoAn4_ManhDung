-- SmartShop schema only: no historical data. Import into an empty smartshop database.
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: dien_gia_dung
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_sessions`
--

DROP TABLE IF EXISTS `auth_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_sessions` (
  `token_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `token_version` int NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`token_hash`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `auth_sessions_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bien_dong_kho`
--

DROP TABLE IF EXISTS `bien_dong_kho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bien_dong_kho` (
  `ma_bien_dong` bigint NOT NULL AUTO_INCREMENT,
  `ma_san_pham` int NOT NULL,
  `ma_bien_the` int DEFAULT NULL,
  `ma_sku` varchar(80) DEFAULT NULL,
  `ten_san_pham` varchar(200) NOT NULL,
  `so_luong` int NOT NULL,
  `ton_truoc` int NOT NULL,
  `ton_sau` int NOT NULL,
  `loai` varchar(30) NOT NULL,
  `ma_phieu` int DEFAULT NULL,
  `ma_don_hang` int DEFAULT NULL,
  `ma_tai_khoan` int DEFAULT NULL,
  `don_gia_nhap` decimal(15,2) DEFAULT NULL,
  `ghi_chu` varchar(1000) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_bien_dong`),
  KEY `idx_stock_product` (`ma_san_pham`,`ma_bien_the`,`ngay_tao`),
  KEY `idx_stock_order` (`ma_don_hang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bien_the_san_pham`
--

DROP TABLE IF EXISTS `bien_the_san_pham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bien_the_san_pham` (
  `ma_san_pham` int NOT NULL,
  `nhom_bien_the` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ten_thuoc_tinh` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gia_tri` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thu_tu` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_san_pham`),
  UNIQUE KEY `uq_variant_label` (`nhom_bien_the`,`gia_tri`),
  CONSTRAINT `fk_variant_product` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `checkout_requests`
--

DROP TABLE IF EXISTS `checkout_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `checkout_requests` (
  `ma_tai_khoan` int NOT NULL,
  `request_id` varchar(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `response_json` json NOT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_tai_khoan`,`request_id`),
  CONSTRAINT `checkout_requests_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chi_tiet_don_hang`
--

DROP TABLE IF EXISTS `chi_tiet_don_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chi_tiet_don_hang` (
  `ma_don_hang` int NOT NULL,
  `ma_san_pham` int NOT NULL,
  `ten_san_pham` varchar(200) NOT NULL,
  `so_luong` int NOT NULL,
  `don_gia` decimal(15,2) NOT NULL,
  `thanh_tien` decimal(15,2) GENERATED ALWAYS AS ((`so_luong` * `don_gia`)) STORED,
  `ma_bien_the` int DEFAULT NULL,
  `ten_bien_the` varchar(100) DEFAULT NULL,
  `variant_key` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_don_hang`,`ma_san_pham`,`variant_key`),
  KEY `idx_parent` (`ma_don_hang`),
  KEY `idx_product` (`ma_san_pham`),
  CONSTRAINT `chi_tiet_don_hang_ibfk_1` FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang` (`ma_don_hang`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chi_tiet_don_hang_ibfk_2` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `chi_tiet_don_hang_variant_insert` BEFORE INSERT ON `chi_tiet_don_hang` FOR EACH ROW SET NEW.variant_key = COALESCE(NEW.ma_bien_the, 0) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `chi_tiet_don_hang_variant_update` BEFORE UPDATE ON `chi_tiet_don_hang` FOR EACH ROW SET NEW.variant_key = COALESCE(NEW.ma_bien_the, 0) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `chi_tiet_gio_hang`
--

DROP TABLE IF EXISTS `chi_tiet_gio_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chi_tiet_gio_hang` (
  `ma_gio_hang` int NOT NULL,
  `ma_san_pham` int NOT NULL,
  `so_luong` int NOT NULL DEFAULT '1',
  `ma_bien_the` int DEFAULT NULL,
  `variant_key` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_gio_hang`,`ma_san_pham`,`variant_key`),
  KEY `idx_parent` (`ma_gio_hang`),
  KEY `idx_product` (`ma_san_pham`),
  CONSTRAINT `chi_tiet_gio_hang_ibfk_1` FOREIGN KEY (`ma_gio_hang`) REFERENCES `gio_hang` (`ma_gio_hang`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chi_tiet_gio_hang_ibfk_2` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `chi_tiet_gio_hang_variant_insert` BEFORE INSERT ON `chi_tiet_gio_hang` FOR EACH ROW SET NEW.variant_key = COALESCE(NEW.ma_bien_the, 0) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `chi_tiet_gio_hang_variant_update` BEFORE UPDATE ON `chi_tiet_gio_hang` FOR EACH ROW SET NEW.variant_key = COALESCE(NEW.ma_bien_the, 0) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `danh_gia`
--

DROP TABLE IF EXISTS `danh_gia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `danh_gia` (
  `ma_danh_gia` int NOT NULL AUTO_INCREMENT,
  `ma_san_pham` int NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `so_sao` int NOT NULL,
  `noi_dung` text,
  `ngay_danh_gia` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_danh_gia`),
  KEY `ma_san_pham` (`ma_san_pham`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `danh_gia_ibfk_1` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `danh_gia_ibfk_2` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `danh_gia_chk_1` CHECK ((`so_sao` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `danh_muc`
--

DROP TABLE IF EXISTS `danh_muc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `danh_muc` (
  `ma_danh_muc` int NOT NULL AUTO_INCREMENT,
  `ten_danh_muc` varchar(100) NOT NULL,
  `mo_ta` text,
  `trang_thai` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ma_danh_muc`),
  UNIQUE KEY `ten_danh_muc` (`ten_danh_muc`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `danh_muc_thong_so`
--

DROP TABLE IF EXISTS `danh_muc_thong_so`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `danh_muc_thong_so` (
  `ma_danh_muc` int NOT NULL,
  `ma_thong_so` int NOT NULL,
  `bat_buoc` tinyint(1) DEFAULT '0',
  `thu_tu_hien_thi` int DEFAULT '0',
  PRIMARY KEY (`ma_danh_muc`,`ma_thong_so`),
  KEY `ma_thong_so` (`ma_thong_so`),
  CONSTRAINT `danh_muc_thong_so_ibfk_1` FOREIGN KEY (`ma_danh_muc`) REFERENCES `danh_muc` (`ma_danh_muc`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `danh_muc_thong_so_ibfk_2` FOREIGN KEY (`ma_thong_so`) REFERENCES `thong_so` (`ma_thong_so`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dia_chi_giao_hang`
--

DROP TABLE IF EXISTS `dia_chi_giao_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dia_chi_giao_hang` (
  `ma_dia_chi` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `so_dien_thoai` varchar(15) NOT NULL,
  `dia_chi` varchar(255) NOT NULL,
  `mac_dinh` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_dia_chi`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `dia_chi_giao_hang_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `don_hang`
--

DROP TABLE IF EXISTS `don_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `don_hang` (
  `ma_don_hang` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ho_ten_nguoi_nhan` varchar(100) NOT NULL,
  `so_dien_thoai` varchar(15) NOT NULL,
  `dia_chi_giao_hang` varchar(255) NOT NULL,
  `tong_tien` decimal(15,2) DEFAULT '0.00',
  `phuong_thuc_thanh_toan` enum('TienMat','ChuyenKhoan','ThanhToanKhiNhanHang') DEFAULT 'ThanhToanKhiNhanHang',
  `trang_thai` enum('ChoXacNhan','DaXacNhan','DangGiao','DaGiao','DaHuy') DEFAULT 'ChoXacNhan',
  `ghi_chu` text,
  `ngay_dat` datetime DEFAULT CURRENT_TIMESTAMP,
  `ma_voucher` int DEFAULT NULL,
  `ma_code` varchar(40) DEFAULT NULL,
  `giam_gia` decimal(15,2) NOT NULL DEFAULT '0.00',
  `phi_giao_hang` decimal(15,2) NOT NULL DEFAULT '0.00',
  `ma_nhan_vien` int DEFAULT NULL,
  PRIMARY KEY (`ma_don_hang`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  KEY `fk_don_hang_nhan_vien` (`ma_nhan_vien`),
  CONSTRAINT `don_hang_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_don_hang_nhan_vien` FOREIGN KEY (`ma_nhan_vien`) REFERENCES `nhan_vien` (`ma_nhan_vien`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `order_created_notification` AFTER INSERT ON `don_hang` FOR EACH ROW INSERT INTO thong_bao (ma_tai_khoan,tieu_de,noi_dung,ma_don_hang) VALUES (NEW.ma_tai_khoan,'Đơn hàng mới',CONCAT('Đơn #',NEW.ma_don_hang,' đã được ghi nhận.'),NEW.ma_don_hang) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `order_status_notification` AFTER UPDATE ON `don_hang` FOR EACH ROW BEGIN IF OLD.trang_thai <> NEW.trang_thai THEN INSERT INTO thong_bao (ma_tai_khoan,tieu_de,noi_dung,ma_don_hang) VALUES (NEW.ma_tai_khoan,'Order update',CONCAT('Đơn #',NEW.ma_don_hang,': ', CASE NEW.trang_thai WHEN 'DaXacNhan' THEN 'Đã xác nhận' WHEN 'DangGiao' THEN 'Đang giao' WHEN 'DaGiao' THEN 'Đã giao' WHEN 'DaHuy' THEN 'Đã hủy' ELSE 'Chờ xác nhận' END),NEW.ma_don_hang); END IF; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `email_verification`
--

DROP TABLE IF EXISTS `email_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_verification` (
  `token_hash` char(64) NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `email` varchar(100) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_hash`),
  KEY `idx_email_verification_owner` (`ma_tai_khoan`),
  CONSTRAINT `email_verification_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gio_hang`
--

DROP TABLE IF EXISTS `gio_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gio_hang` (
  `ma_gio_hang` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_gio_hang`),
  UNIQUE KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `gio_hang_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hinh_anh_san_pham`
--

DROP TABLE IF EXISTS `hinh_anh_san_pham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hinh_anh_san_pham` (
  `ma_hinh_anh` int NOT NULL AUTO_INCREMENT,
  `ma_san_pham` int NOT NULL,
  `duong_dan` varchar(500) NOT NULL,
  `mo_ta` varchar(255) DEFAULT NULL,
  `la_anh_chinh` tinyint(1) DEFAULT '0',
  `thu_tu_hien_thi` int DEFAULT '0',
  PRIMARY KEY (`ma_hinh_anh`),
  KEY `idx_hinh_anh_san_pham` (`ma_san_pham`,`thu_tu_hien_thi`),
  CONSTRAINT `hinh_anh_san_pham_ibfk_1` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_diem_danh`
--

DROP TABLE IF EXISTS `lich_su_diem_danh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_diem_danh` (
  `ma_diem_danh` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ngay_diem_danh` date NOT NULL,
  `diem_cong` int NOT NULL DEFAULT '100',
  `chuoi_ngay` int NOT NULL DEFAULT '1',
  `qua_tang` varchar(255) DEFAULT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_diem_danh`),
  UNIQUE KEY `uq_user_checkin` (`ma_tai_khoan`,`ngay_diem_danh`),
  CONSTRAINT `lich_su_diem_danh_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_don_hang`
--

DROP TABLE IF EXISTS `lich_su_don_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_don_hang` (
  `ma_lich_su` bigint NOT NULL AUTO_INCREMENT,
  `ma_don_hang` int NOT NULL,
  `ma_tai_khoan` int DEFAULT NULL,
  `trang_thai_truoc` varchar(30) DEFAULT NULL,
  `trang_thai` varchar(30) NOT NULL,
  `ghi_chu` varchar(1000) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_lich_su`),
  KEY `idx_order_history` (`ma_don_hang`,`ma_lich_su`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_gioi_thieu`
--

DROP TABLE IF EXISTS `lich_su_gioi_thieu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_gioi_thieu` (
  `ma_gioi_thieu_ls` int NOT NULL AUTO_INCREMENT,
  `ma_nguoi_moi` int NOT NULL,
  `ma_nguoi_duoc_moi` int NOT NULL,
  `diem_thuong` int NOT NULL DEFAULT '500',
  `ma_voucher` int DEFAULT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_gioi_thieu_ls`),
  UNIQUE KEY `ma_nguoi_duoc_moi` (`ma_nguoi_duoc_moi`),
  KEY `ma_nguoi_moi` (`ma_nguoi_moi`),
  CONSTRAINT `lich_su_gioi_thieu_ibfk_1` FOREIGN KEY (`ma_nguoi_moi`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE,
  CONSTRAINT `lich_su_gioi_thieu_ibfk_2` FOREIGN KEY (`ma_nguoi_duoc_moi`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_hau_mai`
--

DROP TABLE IF EXISTS `lich_su_hau_mai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_hau_mai` (
  `ma_lich_su` int NOT NULL AUTO_INCREMENT,
  `ma_yeu_cau` int NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `trang_thai` varchar(30) NOT NULL,
  `ghi_chu` varchar(2000) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_lich_su`),
  KEY `fk_support_history` (`ma_yeu_cau`),
  CONSTRAINT `fk_support_history` FOREIGN KEY (`ma_yeu_cau`) REFERENCES `yeu_cau_hau_mai` (`ma_yeu_cau`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_moc_diem_danh`
--

DROP TABLE IF EXISTS `lich_su_moc_diem_danh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_moc_diem_danh` (
  `ma_moc_ls` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `moc_ngay` int NOT NULL,
  `phan_thuong` varchar(255) NOT NULL,
  `ma_voucher` int DEFAULT NULL,
  `ngay_nhan` datetime DEFAULT CURRENT_TIMESTAMP,
  `chuoi_tai_thoi_diem` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_moc_ls`),
  KEY `idx_user_moc` (`ma_tai_khoan`,`moc_ngay`),
  CONSTRAINT `lich_su_moc_diem_danh_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lien_he`
--

DROP TABLE IF EXISTS `lien_he`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lien_he` (
  `ma_lien_he` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int DEFAULT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `so_dien_thoai` varchar(15) DEFAULT NULL,
  `tieu_de` varchar(200) DEFAULT NULL,
  `noi_dung` text NOT NULL,
  `phan_hoi` text,
  `ngay_phan_hoi` datetime DEFAULT NULL,
  `trang_thai` enum('ChoPhanHoi','DaPhanHoi') DEFAULT 'ChoPhanHoi',
  `ngay_gui` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_lien_he`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `lien_he_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `contact_reply_notification` AFTER UPDATE ON `lien_he` FOR EACH ROW BEGIN IF NEW.phan_hoi IS NOT NULL AND NOT (OLD.phan_hoi <=> NEW.phan_hoi) AND NEW.ma_tai_khoan IS NOT NULL THEN INSERT INTO thong_bao (ma_tai_khoan,tieu_de,noi_dung) VALUES (NEW.ma_tai_khoan,'Contact reply',CONCAT('Cửa hàng đã phản hồi liên hệ: ',NEW.tieu_de)); END IF; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `nhan_vien`
--

DROP TABLE IF EXISTS `nhan_vien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhan_vien` (
  `ma_nhan_vien` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int DEFAULT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `chuc_vu` varchar(100) DEFAULT NULL,
  `so_dien_thoai` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `ngay_vao_lam` date DEFAULT NULL,
  `luong` decimal(15,2) DEFAULT '0.00',
  `trang_thai` enum('DangLam','NghiLam') DEFAULT 'DangLam',
  PRIMARY KEY (`ma_nhan_vien`),
  UNIQUE KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `nhan_vien_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nhap_kho`
--

DROP TABLE IF EXISTS `nhap_kho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhap_kho` (
  `ma_nhap` int NOT NULL AUTO_INCREMENT,
  `ma_san_pham` int NOT NULL,
  `ma_bien_the` int DEFAULT NULL,
  `ma_tai_khoan` int NOT NULL,
  `so_luong` int NOT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL,
  `ngay_nhap` datetime DEFAULT CURRENT_TIMESTAMP,
  `gia_nhap` decimal(15,2) DEFAULT NULL,
  `nha_cung_cap` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`ma_nhap`),
  KEY `ma_san_pham` (`ma_san_pham`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `nhap_kho_ibfk_1` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE RESTRICT,
  CONSTRAINT `nhap_kho_ibfk_2` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nhat_ky_thao_tac`
--

DROP TABLE IF EXISTS `nhat_ky_thao_tac`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhat_ky_thao_tac` (
  `ma_nhat_ky` bigint NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int DEFAULT NULL,
  `vai_tro` varchar(20) DEFAULT NULL,
  `phuong_thuc` varchar(10) NOT NULL,
  `duong_dan` varchar(255) NOT NULL,
  `ma_doi_tuong` varchar(100) DEFAULT NULL,
  `http_status` int NOT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_nhat_ky`),
  KEY `idx_audit_time` (`ngay_tao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nhom_thong_so`
--

DROP TABLE IF EXISTS `nhom_thong_so`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhom_thong_so` (
  `ma_nhom_thong_so` int NOT NULL AUTO_INCREMENT,
  `ten_nhom_thong_so` varchar(100) NOT NULL,
  `thu_tu_hien_thi` int DEFAULT '0',
  `trang_thai` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ma_nhom_thong_so`),
  UNIQUE KEY `ten_nhom_thong_so` (`ten_nhom_thong_so`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_reset`
--

DROP TABLE IF EXISTS `password_reset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset` (
  `token_hash` char(64) NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`token_hash`),
  KEY `idx_password_reset_account` (`ma_tai_khoan`,`expires_at`),
  CONSTRAINT `password_reset_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phieu_kho`
--

DROP TABLE IF EXISTS `phieu_kho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phieu_kho` (
  `ma_phieu` int NOT NULL AUTO_INCREMENT,
  `request_id` varchar(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `loai` enum('NhapKho','DieuChinh') NOT NULL,
  `nha_cung_cap` varchar(200) DEFAULT NULL,
  `ghi_chu` varchar(1000) NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_phieu`),
  UNIQUE KEY `request_id` (`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `san_pham`
--

DROP TABLE IF EXISTS `san_pham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `san_pham` (
  `ma_san_pham` int NOT NULL AUTO_INCREMENT,
  `ma_danh_muc` int NOT NULL,
  `ma_thuong_hieu` int NOT NULL,
  `ma_san_pham_code` varchar(50) NOT NULL,
  `ten_san_pham` varchar(200) NOT NULL,
  `mo_ta` text,
  `gia_nhap` decimal(15,2) DEFAULT '0.00',
  `gia_ban` decimal(15,2) NOT NULL,
  `so_luong` int DEFAULT '0',
  `bao_hanh` int DEFAULT '12',
  `hinh_anh` varchar(255) DEFAULT NULL,
  `trang_thai` enum('DangBan','HetHang','NgungBan') DEFAULT 'DangBan',
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_san_pham`),
  UNIQUE KEY `ma_san_pham_code` (`ma_san_pham_code`),
  KEY `ma_danh_muc` (`ma_danh_muc`),
  KEY `ma_thuong_hieu` (`ma_thuong_hieu`),
  CONSTRAINT `san_pham_ibfk_1` FOREIGN KEY (`ma_danh_muc`) REFERENCES `danh_muc` (`ma_danh_muc`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `san_pham_ibfk_2` FOREIGN KEY (`ma_thuong_hieu`) REFERENCES `thuong_hieu` (`ma_thuong_hieu`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `san_pham_bien_the`
--

DROP TABLE IF EXISTS `san_pham_bien_the`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `san_pham_bien_the` (
  `ma_bien_the` int NOT NULL AUTO_INCREMENT,
  `ma_san_pham` int NOT NULL,
  `ma_sku` varchar(80) NOT NULL,
  `ten_bien_the` varchar(100) NOT NULL,
  `gia_ban` decimal(15,2) NOT NULL,
  `so_luong` int NOT NULL DEFAULT '0',
  `trang_thai` enum('DangBan','HetHang','NgungBan') DEFAULT 'DangBan',
  `thong_so_json` json DEFAULT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_bien_the`),
  UNIQUE KEY `ma_sku` (`ma_sku`),
  UNIQUE KEY `uq_san_pham_bien_the_ten` (`ma_san_pham`,`ten_bien_the`),
  CONSTRAINT `fk_bien_the_san_pham` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=818 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `san_pham_yeu_thich`
--

DROP TABLE IF EXISTS `san_pham_yeu_thich`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `san_pham_yeu_thich` (
  `ma_tai_khoan` int NOT NULL,
  `ma_san_pham` int NOT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_tai_khoan`,`ma_san_pham`),
  KEY `ma_san_pham` (`ma_san_pham`),
  CONSTRAINT `san_pham_yeu_thich_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE,
  CONSTRAINT `san_pham_yeu_thich_ibfk_2` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_permissions`
--

DROP TABLE IF EXISTS `staff_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_permissions` (
  `ma_tai_khoan` int NOT NULL,
  `permissions` json NOT NULL,
  PRIMARY KEY (`ma_tai_khoan`),
  CONSTRAINT `staff_permissions_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tai_khoan`
--

DROP TABLE IF EXISTS `tai_khoan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tai_khoan` (
  `ma_tai_khoan` int NOT NULL AUTO_INCREMENT,
  `ten_dang_nhap` varchar(50) NOT NULL,
  `mat_khau` varchar(255) NOT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `so_dien_thoai` varchar(15) DEFAULT NULL,
  `dia_chi` varchar(255) DEFAULT NULL,
  `vai_tro` enum('Admin','NhanVien','KhachHang') DEFAULT 'KhachHang',
  `trang_thai` enum('HoatDong','Khoa') DEFAULT 'HoatDong',
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  `token_version` int NOT NULL DEFAULT '0',
  `diem_thuong` int NOT NULL DEFAULT '500',
  `ma_gioi_thieu` varchar(30) DEFAULT NULL,
  `ma_nguoi_gioi_thieu` int DEFAULT NULL,
  PRIMARY KEY (`ma_tai_khoan`),
  UNIQUE KEY `ten_dang_nhap` (`ten_dang_nhap`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `ma_gioi_thieu` (`ma_gioi_thieu`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tai_khoan_dia_chi`
--

DROP TABLE IF EXISTS `tai_khoan_dia_chi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tai_khoan_dia_chi` (
  `ma_dia_chi` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ten_dia_chi` varchar(100) NOT NULL DEFAULT 'Địa chỉ giao hàng',
  `ho_ten_nguoi_nhan` varchar(100) NOT NULL,
  `so_dien_thoai` varchar(15) NOT NULL,
  `dia_chi_giao_hang` varchar(255) NOT NULL,
  `la_mac_dinh` tinyint(1) NOT NULL DEFAULT '0',
  `default_slot` tinyint GENERATED ALWAYS AS (if(`la_mac_dinh`,1,NULL)) STORED,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_dia_chi`),
  UNIQUE KEY `uniq_default_address` (`ma_tai_khoan`,`default_slot`),
  KEY `idx_addresses_account` (`ma_tai_khoan`,`ma_dia_chi`),
  CONSTRAINT `tai_khoan_dia_chi_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tai_khoan_voucher`
--

DROP TABLE IF EXISTS `tai_khoan_voucher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tai_khoan_voucher` (
  `ma_tk_voucher` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `ma_voucher` int NOT NULL,
  `so_luong` int NOT NULL DEFAULT '1',
  `da_dung` int NOT NULL DEFAULT '0',
  `ngay_nhan` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_het_han` datetime NOT NULL,
  `trang_thai` enum('ChuaDung','DaDung','HetHan') NOT NULL DEFAULT 'ChuaDung',
  `nguon_goc` varchar(50) NOT NULL DEFAULT 'HeThong',
  PRIMARY KEY (`ma_tk_voucher`),
  KEY `idx_tk_voucher_user` (`ma_tai_khoan`,`trang_thai`),
  KEY `ma_voucher` (`ma_voucher`),
  CONSTRAINT `tai_khoan_voucher_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE,
  CONSTRAINT `tai_khoan_voucher_ibfk_2` FOREIGN KEY (`ma_voucher`) REFERENCES `voucher` (`ma_voucher`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thong_bao`
--

DROP TABLE IF EXISTS `thong_bao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thong_bao` (
  `ma_thong_bao` int NOT NULL AUTO_INCREMENT,
  `ma_tai_khoan` int NOT NULL,
  `noi_dung` varchar(500) NOT NULL,
  `ma_don_hang` int DEFAULT NULL,
  `da_doc` tinyint(1) NOT NULL DEFAULT '0',
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  `tieu_de` varchar(150) NOT NULL DEFAULT 'Notification',
  PRIMARY KEY (`ma_thong_bao`),
  KEY `ma_tai_khoan` (`ma_tai_khoan`),
  CONSTRAINT `thong_bao_ibfk_1` FOREIGN KEY (`ma_tai_khoan`) REFERENCES `tai_khoan` (`ma_tai_khoan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thong_so`
--

DROP TABLE IF EXISTS `thong_so`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thong_so` (
  `ma_thong_so` int NOT NULL AUTO_INCREMENT,
  `ma_nhom_thong_so` int NOT NULL,
  `ten_thong_so` varchar(150) NOT NULL,
  `kieu_du_lieu` enum('TEXT','NUMBER','BOOLEAN','OPTION') DEFAULT 'TEXT',
  `don_vi` varchar(30) DEFAULT NULL,
  `cho_phep_loc` tinyint(1) DEFAULT '0',
  `thu_tu_hien_thi` int DEFAULT '0',
  `trang_thai` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ma_thong_so`),
  UNIQUE KEY `uq_thong_so_nhom_ten` (`ma_nhom_thong_so`,`ten_thong_so`),
  CONSTRAINT `thong_so_ibfk_1` FOREIGN KEY (`ma_nhom_thong_so`) REFERENCES `nhom_thong_so` (`ma_nhom_thong_so`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thong_so_san_pham`
--

DROP TABLE IF EXISTS `thong_so_san_pham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thong_so_san_pham` (
  `ma_san_pham` int NOT NULL,
  `ma_thong_so` int NOT NULL,
  `gia_tri` varchar(1000) DEFAULT NULL,
  `gia_tri_so` decimal(18,4) DEFAULT NULL,
  `gia_tri_bool` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`ma_san_pham`,`ma_thong_so`),
  KEY `idx_tsp_thong_so_text` (`ma_thong_so`,`gia_tri`(191)),
  KEY `idx_tsp_thong_so_number` (`ma_thong_so`,`gia_tri_so`),
  CONSTRAINT `thong_so_san_pham_ibfk_1` FOREIGN KEY (`ma_san_pham`) REFERENCES `san_pham` (`ma_san_pham`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `thong_so_san_pham_ibfk_2` FOREIGN KEY (`ma_thong_so`) REFERENCES `thong_so` (`ma_thong_so`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thuong_hieu`
--

DROP TABLE IF EXISTS `thuong_hieu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thuong_hieu` (
  `ma_thuong_hieu` int NOT NULL AUTO_INCREMENT,
  `ten_thuong_hieu` varchar(100) NOT NULL,
  `quoc_gia` varchar(100) DEFAULT NULL,
  `mo_ta` text,
  PRIMARY KEY (`ma_thuong_hieu`),
  UNIQUE KEY `ten_thuong_hieu` (`ten_thuong_hieu`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `voucher`
--

DROP TABLE IF EXISTS `voucher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `voucher` (
  `ma_voucher` int NOT NULL AUTO_INCREMENT,
  `ma_code` varchar(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `giam_tien` decimal(15,2) NOT NULL,
  `loai` enum('SoTien','PhanTram') NOT NULL DEFAULT 'SoTien',
  `giam_toi_da` decimal(15,2) DEFAULT NULL,
  `don_toi_thieu` decimal(15,2) NOT NULL DEFAULT '0.00',
  `so_luot` int NOT NULL,
  `moi_khach` int NOT NULL DEFAULT '1',
  `la_cong_khai` tinyint(1) NOT NULL DEFAULT '1',
  `da_dung` int NOT NULL DEFAULT '0',
  `bat_dau` datetime NOT NULL,
  `ket_thuc` datetime NOT NULL,
  `mo_ta` varchar(255) DEFAULT NULL,
  `trang_thai` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ma_voucher`),
  UNIQUE KEY `ma_code` (`ma_code`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `voucher_su_dung`
--

DROP TABLE IF EXISTS `voucher_su_dung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `voucher_su_dung` (
  `ma_don_hang` int NOT NULL,
  `ma_voucher` int NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tam_tinh` decimal(15,2) NOT NULL,
  `tien_giam` decimal(15,2) NOT NULL,
  `hoan_luot` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_don_hang`),
  KEY `ix_voucher_user` (`ma_voucher`,`ma_tai_khoan`,`hoan_luot`),
  CONSTRAINT `voucher_su_dung_ibfk_1` FOREIGN KEY (`ma_voucher`) REFERENCES `voucher` (`ma_voucher`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yeu_cau_hau_mai`
--

DROP TABLE IF EXISTS `yeu_cau_hau_mai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `yeu_cau_hau_mai` (
  `ma_yeu_cau` int NOT NULL AUTO_INCREMENT,
  `ma_don_hang` int NOT NULL,
  `ma_chi_tiet_don_hang` int NOT NULL,
  `ma_tai_khoan` int NOT NULL,
  `loai` enum('DoiTra','BaoHanh') NOT NULL,
  `so_luong` int NOT NULL,
  `ly_do` varchar(2000) NOT NULL,
  `serial` varchar(150) DEFAULT NULL,
  `trang_thai` enum('ChoDuyet','DaDuyet','DaNhanHang','DangXuLy','HoanTat','TuChoi','DaHuy') DEFAULT 'ChoDuyet',
  `phan_hoi` varchar(2000) DEFAULT NULL,
  `hoan_ton` tinyint(1) NOT NULL DEFAULT '0',
  `tien_hoan` decimal(15,2) NOT NULL DEFAULT '0.00',
  `ngay_hoan_tien` datetime DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_yeu_cau`),
  KEY `idx_support_owner` (`ma_tai_khoan`,`ma_yeu_cau`),
  KEY `idx_support_line` (`ma_chi_tiet_don_hang`),
  KEY `fk_support_order` (`ma_don_hang`),
  CONSTRAINT `fk_support_order` FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang` (`ma_don_hang`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'dien_gia_dung'
--

--
-- Dumping routines for database 'dien_gia_dung'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_check_duplicate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_auth_check_duplicate`(IN p_ten_dang_nhap VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, IN p_email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, IN p_exclude_id INT)
BEGIN SELECT ma_tai_khoan FROM tai_khoan WHERE (ten_dang_nhap=p_ten_dang_nhap OR email=p_email) AND ma_tai_khoan<>COALESCE(p_exclude_id,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_find_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_auth_find_by_id`(IN p_ma_tai_khoan INT)
BEGIN
          SELECT ma_tai_khoan, ten_dang_nhap, ho_ten, email, so_dien_thoai, dia_chi, vai_tro, trang_thai, ngay_tao,
                 diem_thuong, ma_gioi_thieu, ma_nguoi_gioi_thieu
          FROM tai_khoan WHERE ma_tai_khoan = p_ma_tai_khoan;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_find_by_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_auth_find_by_username`(IN p_ten_dang_nhap VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT ma_tai_khoan, ten_dang_nhap, mat_khau, ho_ten, email, so_dien_thoai, dia_chi, vai_tro, trang_thai
    FROM tai_khoan WHERE ten_dang_nhap = p_ten_dang_nhap;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_register` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_auth_register`(
    IN p_ten_dang_nhap VARCHAR(50), IN p_mat_khau VARCHAR(255), IN p_ho_ten VARCHAR(100),
    IN p_email VARCHAR(100), IN p_so_dien_thoai VARCHAR(15), IN p_dia_chi VARCHAR(255))
BEGIN
    INSERT INTO tai_khoan (ten_dang_nhap, mat_khau, ho_ten, email, so_dien_thoai, dia_chi, vai_tro, trang_thai)
    VALUES (p_ten_dang_nhap, p_mat_khau, p_ho_ten, p_email, p_so_dien_thoai, p_dia_chi, 'KhachHang', 'HoatDong');
    SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_update_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_auth_update_profile`(
    IN p_ma_tai_khoan INT, IN p_ho_ten VARCHAR(100), IN p_email VARCHAR(100),
    IN p_so_dien_thoai VARCHAR(15), IN p_dia_chi VARCHAR(255))
BEGIN
    UPDATE tai_khoan SET ho_ten = p_ho_ten, email = p_email, so_dien_thoai = p_so_dien_thoai, dia_chi = p_dia_chi
    WHERE ma_tai_khoan = p_ma_tai_khoan;
    SELECT ROW_COUNT() AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_create`(IN p_ma_san_pham INT, IN p_ma_tai_khoan INT, IN p_so_sao INT, IN p_noi_dung TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM san_pham WHERE ma_san_pham=p_ma_san_pham) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='San pham khong ton tai';
    END IF;
    INSERT INTO danh_gia (ma_san_pham,ma_tai_khoan,so_sao,noi_dung) VALUES (p_ma_san_pham,p_ma_tai_khoan,p_so_sao,p_noi_dung);
    SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_delete`(IN p_id INT)
BEGIN DELETE FROM danh_gia WHERE ma_danh_gia=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_get_by_id`(IN p_id INT)
BEGIN SELECT * FROM danh_gia WHERE ma_danh_gia=p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_list`(IN p_ma_san_pham INT, IN p_so_sao INT, IN p_limit INT, IN p_offset INT)
BEGIN
    SELECT COUNT(*) AS total FROM danh_gia WHERE (p_ma_san_pham IS NULL OR ma_san_pham=p_ma_san_pham) AND (p_so_sao IS NULL OR so_sao=p_so_sao);
    SELECT dg.*, tk.ho_ten, sp.ten_san_pham FROM danh_gia dg JOIN tai_khoan tk ON tk.ma_tai_khoan=dg.ma_tai_khoan JOIN san_pham sp ON sp.ma_san_pham=dg.ma_san_pham
    WHERE (p_ma_san_pham IS NULL OR dg.ma_san_pham=p_ma_san_pham) AND (p_so_sao IS NULL OR dg.so_sao=p_so_sao) ORDER BY dg.ma_danh_gia DESC LIMIT p_limit OFFSET p_offset;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_list_by_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_list_by_product`(IN p_ma_san_pham INT)
BEGIN SELECT dg.*,tk.ho_ten FROM danh_gia dg JOIN tai_khoan tk ON tk.ma_tai_khoan=dg.ma_tai_khoan WHERE dg.ma_san_pham=p_ma_san_pham ORDER BY dg.ma_danh_gia DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_gia_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_gia_update`(IN p_id INT, IN p_so_sao INT, IN p_noi_dung TEXT)
BEGIN UPDATE danh_gia SET so_sao=COALESCE(p_so_sao,so_sao), noi_dung=COALESCE(p_noi_dung,noi_dung) WHERE ma_danh_gia=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_muc_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_muc_create`(IN p_ten VARCHAR(100), IN p_mo_ta TEXT, IN p_trang_thai BOOLEAN)
BEGIN INSERT INTO danh_muc (ten_danh_muc, mo_ta, trang_thai) VALUES (p_ten, p_mo_ta, p_trang_thai); SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_muc_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_muc_delete`(IN p_id INT)
BEGIN DELETE FROM danh_muc WHERE ma_danh_muc = p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_muc_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_muc_get_by_id`(IN p_id INT)
BEGIN SELECT * FROM danh_muc WHERE ma_danh_muc = p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_muc_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_muc_list`()
BEGIN SELECT * FROM danh_muc ORDER BY ma_danh_muc DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_danh_muc_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_danh_muc_update`(IN p_id INT, IN p_ten VARCHAR(100), IN p_mo_ta TEXT, IN p_trang_thai BOOLEAN)
BEGIN UPDATE danh_muc SET ten_danh_muc = COALESCE(p_ten, ten_danh_muc), mo_ta = COALESCE(p_mo_ta, mo_ta), trang_thai = COALESCE(p_trang_thai, trang_thai) WHERE ma_danh_muc = p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_dashboard_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_dashboard_summary`()
BEGIN
        SELECT (SELECT COUNT(*) FROM san_pham) AS tong_san_pham, (SELECT COUNT(*) FROM tai_khoan WHERE vai_tro='KhachHang') AS tong_khach_hang,
            (SELECT COUNT(*) FROM nhan_vien) AS tong_nhan_vien, (SELECT COUNT(*) FROM don_hang) AS tong_don_hang,
            (SELECT COALESCE(SUM(tong_tien),0) FROM don_hang WHERE trang_thai='DaGiao') AS tong_doanh_thu,
            (SELECT COUNT(*) FROM don_hang WHERE trang_thai='DaXacNhan') AS so_don_da_xac_nhan, (SELECT COUNT(*) FROM don_hang WHERE trang_thai='ChoXacNhan') AS so_don_cho_xac_nhan,
            (SELECT COUNT(*) FROM don_hang WHERE trang_thai='DangGiao') AS so_don_dang_giao, (SELECT COUNT(*) FROM don_hang WHERE trang_thai='DaGiao') AS so_don_da_giao,
            (SELECT COUNT(*) FROM don_hang WHERE trang_thai='DaHuy') AS so_don_da_huy;
        SELECT DATE_FORMAT(ngay_dat,'%Y-%m') AS thang, SUM(tong_tien) AS doanh_thu FROM don_hang WHERE trang_thai='DaGiao' AND ngay_dat>=DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 11 MONTH),'%Y-%m-01') GROUP BY DATE_FORMAT(ngay_dat,'%Y-%m') ORDER BY thang;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_cancel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_cancel`(IN p_id INT, IN p_ma_tai_khoan INT)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    SELECT trang_thai INTO v_status FROM don_hang WHERE ma_don_hang=p_id AND ma_tai_khoan=p_ma_tai_khoan FOR UPDATE;
    IF v_status IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Khong tim thay don hang cua ban'; END IF;
    IF v_status<>'ChoXacNhan' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chi huy don dang cho xac nhan'; END IF;
    UPDATE san_pham p JOIN (SELECT ma_san_pham, SUM(so_luong) AS so_luong FROM chi_tiet_don_hang WHERE ma_don_hang=p_id AND ma_bien_the IS NULL GROUP BY ma_san_pham) c ON c.ma_san_pham=p.ma_san_pham SET p.so_luong=p.so_luong+c.so_luong;
        UPDATE san_pham_bien_the v JOIN (SELECT ma_bien_the, SUM(so_luong) AS so_luong FROM chi_tiet_don_hang WHERE ma_don_hang=p_id AND ma_bien_the IS NOT NULL GROUP BY ma_bien_the) c ON c.ma_bien_the=v.ma_bien_the SET v.so_luong=v.so_luong+c.so_luong;
    UPDATE don_hang SET trang_thai='DaHuy' WHERE ma_don_hang=p_id;
    COMMIT; SELECT p_id AS ma_don_hang, 'DaHuy' AS trang_thai;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_create`(
    IN p_ma_tai_khoan INT, IN p_ho_ten_nguoi_nhan VARCHAR(100), IN p_so_dien_thoai VARCHAR(15),
    IN p_dia_chi_giao_hang VARCHAR(255), IN p_phuong_thuc_thanh_toan VARCHAR(30), IN p_ghi_chu TEXT)
BEGIN
    DECLARE v_cart INT;
    DECLARE v_order INT;
    DECLARE v_total DECIMAL(15,2);
    DECLARE v_count INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    SELECT ma_gio_hang INTO v_cart FROM gio_hang WHERE ma_tai_khoan=p_ma_tai_khoan FOR UPDATE;
    SELECT COUNT(*) INTO v_count FROM chi_tiet_gio_hang WHERE ma_gio_hang=v_cart;
    IF v_cart IS NULL OR v_count=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Gio hang trong'; END IF;
    SELECT COUNT(*) INTO v_count FROM chi_tiet_gio_hang c JOIN san_pham p ON p.ma_san_pham=c.ma_san_pham WHERE c.ma_gio_hang=v_cart AND c.so_luong>p.so_luong;
    IF v_count>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='San pham khong du so luong'; END IF;
    SELECT COALESCE(SUM(c.so_luong*p.gia_ban),0) INTO v_total FROM chi_tiet_gio_hang c JOIN san_pham p ON p.ma_san_pham=c.ma_san_pham WHERE c.ma_gio_hang=v_cart;
    INSERT INTO don_hang (ma_tai_khoan,ho_ten_nguoi_nhan,so_dien_thoai,dia_chi_giao_hang,tong_tien,phuong_thuc_thanh_toan,trang_thai,ghi_chu)
    VALUES (p_ma_tai_khoan,p_ho_ten_nguoi_nhan,p_so_dien_thoai,p_dia_chi_giao_hang,v_total,COALESCE(p_phuong_thuc_thanh_toan,'ThanhToanKhiNhanHang'),'ChoXacNhan',p_ghi_chu);
    SET v_order=LAST_INSERT_ID();
    INSERT INTO chi_tiet_don_hang (ma_don_hang,ma_san_pham,ten_san_pham,so_luong,don_gia)
    SELECT v_order,p.ma_san_pham,p.ten_san_pham,c.so_luong,p.gia_ban FROM chi_tiet_gio_hang c JOIN san_pham p ON p.ma_san_pham=c.ma_san_pham WHERE c.ma_gio_hang=v_cart;
    UPDATE san_pham p JOIN chi_tiet_gio_hang c ON c.ma_san_pham=p.ma_san_pham SET p.so_luong=p.so_luong-c.so_luong WHERE c.ma_gio_hang=v_cart;
    DELETE FROM chi_tiet_gio_hang WHERE ma_gio_hang=v_cart;
    COMMIT;
    SELECT v_order AS ma_don_hang, v_total AS tong_tien;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_delete`(IN p_id INT)
BEGIN DELETE FROM don_hang WHERE ma_don_hang=p_id AND trang_thai IN ('DaGiao','DaHuy'); SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_get_by_id`(IN p_id INT)
BEGIN
    SELECT dh.*, tk.ten_dang_nhap, tk.ho_ten FROM don_hang dh JOIN tai_khoan tk ON tk.ma_tai_khoan=dh.ma_tai_khoan WHERE dh.ma_don_hang=p_id;
    SELECT * FROM chi_tiet_don_hang WHERE ma_don_hang=p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_list`(IN p_ma_tai_khoan INT, IN p_is_customer BOOLEAN)
BEGIN
    SELECT dh.*, tk.ten_dang_nhap, tk.ho_ten FROM don_hang dh JOIN tai_khoan tk ON tk.ma_tai_khoan=dh.ma_tai_khoan
    WHERE p_is_customer=FALSE OR dh.ma_tai_khoan=p_ma_tai_khoan ORDER BY dh.ma_don_hang DESC;
    SELECT ctdh.* FROM chi_tiet_don_hang ctdh JOIN don_hang dh ON dh.ma_don_hang=ctdh.ma_don_hang
    WHERE p_is_customer=FALSE OR dh.ma_tai_khoan=p_ma_tai_khoan ORDER BY ctdh.ma_don_hang;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_don_hang_update_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_don_hang_update_status`(IN p_id INT, IN p_trang_thai VARCHAR(20))
BEGIN
    DECLARE v_old VARCHAR(20);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    SELECT trang_thai INTO v_old FROM don_hang WHERE ma_don_hang=p_id FOR UPDATE;
    IF v_old IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Khong tim thay don hang'; END IF;
    IF NOT ((v_old='ChoXacNhan' AND p_trang_thai IN ('DaXacNhan','DaHuy')) OR (v_old='DaXacNhan' AND p_trang_thai IN ('DangGiao','DaHuy')) OR (v_old='DangGiao' AND p_trang_thai IN ('DaGiao','DaHuy'))) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chuyen trang thai khong hop le';
    END IF;
    IF p_trang_thai='DaHuy' THEN UPDATE san_pham p JOIN (SELECT ma_san_pham, SUM(so_luong) AS so_luong FROM chi_tiet_don_hang WHERE ma_don_hang=p_id AND ma_bien_the IS NULL GROUP BY ma_san_pham) c ON c.ma_san_pham=p.ma_san_pham SET p.so_luong=p.so_luong+c.so_luong;
        UPDATE san_pham_bien_the v JOIN (SELECT ma_bien_the, SUM(so_luong) AS so_luong FROM chi_tiet_don_hang WHERE ma_don_hang=p_id AND ma_bien_the IS NOT NULL GROUP BY ma_bien_the) c ON c.ma_bien_the=v.ma_bien_the SET v.so_luong=v.so_luong+c.so_luong; END IF;
    UPDATE don_hang SET trang_thai=p_trang_thai WHERE ma_don_hang=p_id;
    COMMIT; SELECT p_id AS ma_don_hang, p_trang_thai AS trang_thai;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gio_hang_add_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_gio_hang_add_item`(IN p_ma_tai_khoan INT, IN p_ma_san_pham INT, IN p_so_luong INT)
BEGIN
    DECLARE v_cart INT;
    INSERT INTO gio_hang (ma_tai_khoan) SELECT p_ma_tai_khoan FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM gio_hang WHERE ma_tai_khoan=p_ma_tai_khoan);
    SELECT ma_gio_hang INTO v_cart FROM gio_hang WHERE ma_tai_khoan=p_ma_tai_khoan;
    INSERT INTO chi_tiet_gio_hang (ma_gio_hang,ma_san_pham,so_luong) VALUES (v_cart,p_ma_san_pham,p_so_luong) ON DUPLICATE KEY UPDATE so_luong=so_luong+p_so_luong;
    SELECT v_cart AS ma_gio_hang, ROW_COUNT() AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gio_hang_clear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_gio_hang_clear`(IN p_ma_tai_khoan INT)
BEGIN DELETE c FROM chi_tiet_gio_hang c JOIN gio_hang g ON g.ma_gio_hang=c.ma_gio_hang WHERE g.ma_tai_khoan=p_ma_tai_khoan; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gio_hang_delete_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_gio_hang_delete_item`(IN p_ma_tai_khoan INT, IN p_ma_san_pham INT)
BEGIN DELETE c FROM chi_tiet_gio_hang c JOIN gio_hang g ON g.ma_gio_hang=c.ma_gio_hang WHERE g.ma_tai_khoan=p_ma_tai_khoan AND c.ma_san_pham=p_ma_san_pham; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gio_hang_get` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_gio_hang_get`(IN p_ma_tai_khoan INT)
BEGIN
    SELECT * FROM gio_hang WHERE ma_tai_khoan=p_ma_tai_khoan;
    SELECT cth.*, sp.ten_san_pham, sp.gia_ban, sp.hinh_anh FROM chi_tiet_gio_hang cth JOIN gio_hang gh ON gh.ma_gio_hang=cth.ma_gio_hang JOIN san_pham sp ON sp.ma_san_pham=cth.ma_san_pham WHERE gh.ma_tai_khoan=p_ma_tai_khoan;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gio_hang_update_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_gio_hang_update_item`(IN p_ma_tai_khoan INT, IN p_ma_san_pham INT, IN p_so_luong INT)
BEGIN UPDATE chi_tiet_gio_hang c JOIN gio_hang g ON g.ma_gio_hang=c.ma_gio_hang SET c.so_luong=p_so_luong WHERE g.ma_tai_khoan=p_ma_tai_khoan AND c.ma_san_pham=p_ma_san_pham; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lien_he_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_lien_he_create`(IN p_ma_tai_khoan INT, IN p_ho_ten VARCHAR(100), IN p_email VARCHAR(100), IN p_so_dien_thoai VARCHAR(15), IN p_tieu_de VARCHAR(200), IN p_noi_dung TEXT)
BEGIN INSERT INTO lien_he (ma_tai_khoan,ho_ten,email,so_dien_thoai,tieu_de,noi_dung,trang_thai) VALUES (p_ma_tai_khoan,p_ho_ten,p_email,p_so_dien_thoai,p_tieu_de,p_noi_dung,'ChuaXuLy'); SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lien_he_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_lien_he_delete`(IN p_id INT)
BEGIN DELETE FROM lien_he WHERE ma_lien_he=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lien_he_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_lien_he_get_by_id`(IN p_id INT)
BEGIN SELECT * FROM lien_he WHERE ma_lien_he=p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lien_he_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_lien_he_list`()
BEGIN SELECT * FROM lien_he ORDER BY ma_lien_he DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lien_he_update_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_lien_he_update_status`(IN p_id INT, IN p_trang_thai VARCHAR(20))
BEGIN UPDATE lien_he SET trang_thai=p_trang_thai WHERE ma_lien_he=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_create`(IN p_ma_tai_khoan INT, IN p_ho_ten VARCHAR(100), IN p_chuc_vu VARCHAR(100), IN p_so_dien_thoai VARCHAR(15), IN p_email VARCHAR(100), IN p_ngay_vao_lam DATE, IN p_luong DECIMAL(15,2), IN p_trang_thai VARCHAR(20))
BEGIN INSERT INTO nhan_vien (ma_tai_khoan,ho_ten,chuc_vu,so_dien_thoai,email,ngay_vao_lam,luong,trang_thai) VALUES (p_ma_tai_khoan,p_ho_ten,p_chuc_vu,p_so_dien_thoai,p_email,p_ngay_vao_lam,p_luong,p_trang_thai); SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_delete`(IN p_id INT)
BEGIN DELETE FROM nhan_vien WHERE ma_nhan_vien=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_get_by_id`(IN p_id INT)
BEGIN SELECT * FROM nhan_vien WHERE ma_nhan_vien=p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_list`()
BEGIN SELECT * FROM nhan_vien ORDER BY ma_nhan_vien DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_update`(IN p_id INT, IN p_has_account BOOLEAN, IN p_ma_tai_khoan INT, IN p_ho_ten VARCHAR(100), IN p_chuc_vu VARCHAR(100), IN p_so_dien_thoai VARCHAR(15), IN p_email VARCHAR(100), IN p_ngay_vao_lam DATE, IN p_luong DECIMAL(15,2), IN p_trang_thai VARCHAR(20))
BEGIN UPDATE nhan_vien SET ma_tai_khoan=CASE WHEN p_has_account THEN p_ma_tai_khoan ELSE ma_tai_khoan END, ho_ten=COALESCE(p_ho_ten,ho_ten), chuc_vu=COALESCE(p_chuc_vu,chuc_vu), so_dien_thoai=COALESCE(p_so_dien_thoai,so_dien_thoai), email=COALESCE(p_email,email), ngay_vao_lam=COALESCE(p_ngay_vao_lam,ngay_vao_lam), luong=COALESCE(p_luong,luong), trang_thai=COALESCE(p_trang_thai,trang_thai) WHERE ma_nhan_vien=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nhan_vien_validate_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_nhan_vien_validate_account`(IN p_ma_tai_khoan INT, IN p_ma_nhan_vien INT)
BEGIN
        SELECT ma_tai_khoan FROM tai_khoan WHERE ma_tai_khoan=p_ma_tai_khoan AND vai_tro IN ('Admin','NhanVien');
        SELECT ma_nhan_vien FROM nhan_vien WHERE ma_tai_khoan=p_ma_tai_khoan AND ma_nhan_vien<>COALESCE(p_ma_nhan_vien,0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_create`(
    IN p_ma_danh_muc INT, IN p_ma_thuong_hieu INT, IN p_code VARCHAR(50), IN p_ten VARCHAR(200), IN p_mo_ta TEXT,
    IN p_gia_nhap DECIMAL(15,2), IN p_gia_ban DECIMAL(15,2), IN p_so_luong INT, IN p_bao_hanh INT,
    IN p_hinh_anh VARCHAR(255), IN p_trang_thai VARCHAR(20), IN p_thong_so_json JSON)
BEGIN
    DECLARE v_ma_san_pham INT;
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    INSERT INTO san_pham
        (ma_danh_muc, ma_thuong_hieu, ma_san_pham_code, ten_san_pham, mo_ta,
         gia_nhap, gia_ban, so_luong, bao_hanh, hinh_anh, trang_thai)
    VALUES
        (p_ma_danh_muc, p_ma_thuong_hieu, p_code, p_ten, p_mo_ta,
         p_gia_nhap, p_gia_ban, p_so_luong, p_bao_hanh, p_hinh_anh, p_trang_thai);

    SET v_ma_san_pham = LAST_INSERT_ID();

    -- Kiem tra thong so gui len phai thuoc danh muc cua san pham.
    SELECT COUNT(*) INTO v_count
    FROM JSON_TABLE(
        COALESCE(p_thong_so_json, JSON_ARRAY()), '$[*]'
        COLUMNS (ma_thong_so INT PATH '$.ma_thong_so')
    ) jt
    LEFT JOIN danh_muc_thong_so dmt
        ON dmt.ma_danh_muc = p_ma_danh_muc AND dmt.ma_thong_so = jt.ma_thong_so
    WHERE dmt.ma_thong_so IS NULL;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Co thong so khong hop le voi danh muc san pham';
    END IF;

    INSERT INTO thong_so_san_pham (ma_san_pham, ma_thong_so, gia_tri, gia_tri_so, gia_tri_bool)
    SELECT
        v_ma_san_pham,
        jt.ma_thong_so,
        jt.gia_tri,
        jt.gia_tri_so,
        jt.gia_tri_bool
    FROM JSON_TABLE(
        COALESCE(p_thong_so_json, JSON_ARRAY()), '$[*]'
        COLUMNS (
            ma_thong_so INT PATH '$.ma_thong_so',
            gia_tri VARCHAR(1000) PATH '$.gia_tri' NULL ON EMPTY,
            gia_tri_so DECIMAL(18,4) PATH '$.gia_tri_so' NULL ON EMPTY,
            gia_tri_bool BOOLEAN PATH '$.gia_tri_bool' NULL ON EMPTY
        )
    ) jt;

    -- Tu dong tao anh chinh tu truong hinh_anh cu de giu tuong thich.
    IF p_hinh_anh IS NOT NULL AND p_hinh_anh <> '' THEN
        INSERT INTO hinh_anh_san_pham (ma_san_pham, duong_dan, la_anh_chinh, thu_tu_hien_thi)
        VALUES (v_ma_san_pham, p_hinh_anh, TRUE, 1);
    END IF;

    COMMIT;
    SELECT v_ma_san_pham AS insertId, 1 AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_delete`(IN p_id INT)
BEGIN
    DELETE FROM san_pham WHERE ma_san_pham = p_id;
    SELECT ROW_COUNT() AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_find_by_code` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_find_by_code`(IN p_code VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT ma_san_pham FROM san_pham WHERE ma_san_pham_code = p_code;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_get_by_id`(IN p_id INT)
BEGIN
    SELECT
        sp.*, dm.ten_danh_muc, th.ten_thuong_hieu,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'ma_thong_so', tsp.ma_thong_so,
                'ten_thong_so', ts.ten_thong_so,
                'don_vi', ts.don_vi,
                'kieu_du_lieu', ts.kieu_du_lieu,
                'gia_tri', tsp.gia_tri,
                'gia_tri_so', tsp.gia_tri_so,
                'gia_tri_bool', tsp.gia_tri_bool,
                'ten_nhom', nts.ten_nhom_thong_so,
                'thu_tu_nhom', nts.thu_tu_hien_thi,
                'thu_tu_thong_so', ts.thu_tu_hien_thi
            ))
            FROM thong_so_san_pham tsp
            JOIN thong_so ts ON ts.ma_thong_so = tsp.ma_thong_so
            JOIN nhom_thong_so nts ON nts.ma_nhom_thong_so = ts.ma_nhom_thong_so
            WHERE tsp.ma_san_pham = sp.ma_san_pham
        ), JSON_ARRAY()) AS thong_so_ky_thuat,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'ma_hinh_anh', hsp.ma_hinh_anh,
                'duong_dan', hsp.duong_dan,
                'mo_ta', hsp.mo_ta,
                'la_anh_chinh', hsp.la_anh_chinh,
                'thu_tu_hien_thi', hsp.thu_tu_hien_thi
            ))
            FROM hinh_anh_san_pham hsp
            WHERE hsp.ma_san_pham = sp.ma_san_pham
        ), JSON_ARRAY()) AS danh_sach_hinh_anh
    FROM san_pham sp
    LEFT JOIN danh_muc dm ON dm.ma_danh_muc = sp.ma_danh_muc
    LEFT JOIN thuong_hieu th ON th.ma_thuong_hieu = sp.ma_thuong_hieu
    WHERE sp.ma_san_pham = p_id;

    SELECT
        dmt.ma_danh_muc,
        ts.ma_thong_so,
        nts.ten_nhom_thong_so,
        ts.ten_thong_so,
        ts.kieu_du_lieu,
        ts.don_vi,
        ts.cho_phep_loc,
        dmt.bat_buoc,
        dmt.thu_tu_hien_thi
    FROM danh_muc_thong_so dmt
    JOIN thong_so ts ON ts.ma_thong_so = dmt.ma_thong_so
    JOIN nhom_thong_so nts ON nts.ma_nhom_thong_so = ts.ma_nhom_thong_so
    JOIN san_pham sp ON sp.ma_danh_muc = dmt.ma_danh_muc
    WHERE sp.ma_san_pham = p_id
    ORDER BY nts.thu_tu_hien_thi, dmt.thu_tu_hien_thi, ts.thu_tu_hien_thi;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_list`(
    IN p_search VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, IN p_ma_danh_muc INT, IN p_ma_thuong_hieu INT,
    IN p_min_price DECIMAL(15,2), IN p_max_price DECIMAL(15,2), IN p_limit INT, IN p_offset INT)
BEGIN
    SELECT COUNT(*) AS total
    FROM san_pham sp
    LEFT JOIN danh_muc dm ON dm.ma_danh_muc = sp.ma_danh_muc
    WHERE (p_search IS NULL OR p_search = ''
        OR sp.ten_san_pham LIKE CONCAT('%', p_search, '%')
        OR sp.ma_san_pham_code LIKE CONCAT('%', p_search, '%')
        OR dm.ten_danh_muc LIKE CONCAT('%', p_search, '%'))
      AND (p_ma_danh_muc IS NULL OR sp.ma_danh_muc = p_ma_danh_muc)
      AND (p_ma_thuong_hieu IS NULL OR sp.ma_thuong_hieu = p_ma_thuong_hieu)
      AND (p_min_price IS NULL OR sp.gia_ban >= p_min_price)
      AND (p_max_price IS NULL OR sp.gia_ban <= p_max_price);

    SELECT
        sp.*, dm.ten_danh_muc, th.ten_thuong_hieu,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'ma_thong_so', tsp.ma_thong_so,
                'ten_thong_so', ts.ten_thong_so,
                'don_vi', ts.don_vi,
                'kieu_du_lieu', ts.kieu_du_lieu,
                'gia_tri', tsp.gia_tri,
                'gia_tri_so', tsp.gia_tri_so,
                'gia_tri_bool', tsp.gia_tri_bool,
                'ten_nhom', nts.ten_nhom_thong_so,
                'thu_tu_nhom', nts.thu_tu_hien_thi,
                'thu_tu_thong_so', ts.thu_tu_hien_thi
            ))
            FROM thong_so_san_pham tsp
            JOIN thong_so ts ON ts.ma_thong_so = tsp.ma_thong_so
            JOIN nhom_thong_so nts ON nts.ma_nhom_thong_so = ts.ma_nhom_thong_so
            WHERE tsp.ma_san_pham = sp.ma_san_pham
        ), JSON_ARRAY()) AS thong_so_ky_thuat,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'ma_hinh_anh', hsp.ma_hinh_anh,
                'duong_dan', hsp.duong_dan,
                'mo_ta', hsp.mo_ta,
                'la_anh_chinh', hsp.la_anh_chinh,
                'thu_tu_hien_thi', hsp.thu_tu_hien_thi
            ))
            FROM hinh_anh_san_pham hsp
            WHERE hsp.ma_san_pham = sp.ma_san_pham
        ), JSON_ARRAY()) AS danh_sach_hinh_anh
    FROM san_pham sp
    LEFT JOIN danh_muc dm ON dm.ma_danh_muc = sp.ma_danh_muc
    LEFT JOIN thuong_hieu th ON th.ma_thuong_hieu = sp.ma_thuong_hieu
    WHERE (p_search IS NULL OR p_search = ''
        OR sp.ten_san_pham LIKE CONCAT('%', p_search, '%')
        OR sp.ma_san_pham_code LIKE CONCAT('%', p_search, '%')
        OR dm.ten_danh_muc LIKE CONCAT('%', p_search, '%'))
      AND (p_ma_danh_muc IS NULL OR sp.ma_danh_muc = p_ma_danh_muc)
      AND (p_ma_thuong_hieu IS NULL OR sp.ma_thuong_hieu = p_ma_thuong_hieu)
      AND (p_min_price IS NULL OR sp.gia_ban >= p_min_price)
      AND (p_max_price IS NULL OR sp.gia_ban <= p_max_price)
    ORDER BY sp.ma_san_pham DESC
    LIMIT p_limit OFFSET p_offset;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_san_pham_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_san_pham_update`(
    IN p_id INT, IN p_ma_danh_muc INT, IN p_ma_thuong_hieu INT, IN p_code VARCHAR(50), IN p_ten VARCHAR(200), IN p_mo_ta TEXT,
    IN p_gia_nhap DECIMAL(15,2), IN p_gia_ban DECIMAL(15,2), IN p_so_luong INT, IN p_bao_hanh INT,
    IN p_hinh_anh VARCHAR(255), IN p_trang_thai VARCHAR(20), IN p_thong_so_json JSON)
BEGIN
    DECLARE v_ma_danh_muc INT;
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    SELECT ma_danh_muc INTO v_ma_danh_muc FROM san_pham WHERE ma_san_pham = p_id FOR UPDATE;
    IF v_ma_danh_muc IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong tim thay san pham';
    END IF;
    IF p_ma_danh_muc IS NOT NULL AND p_ma_danh_muc <> v_ma_danh_muc THEN
        DELETE FROM thong_so_san_pham WHERE ma_san_pham = p_id;
    END IF;

    SET v_ma_danh_muc = COALESCE(p_ma_danh_muc, v_ma_danh_muc);

    SELECT COUNT(*) INTO v_count
    FROM JSON_TABLE(
        COALESCE(p_thong_so_json, JSON_ARRAY()), '$[*]'
        COLUMNS (ma_thong_so INT PATH '$.ma_thong_so')
    ) jt
    LEFT JOIN danh_muc_thong_so dmt
        ON dmt.ma_danh_muc = v_ma_danh_muc AND dmt.ma_thong_so = jt.ma_thong_so
    WHERE dmt.ma_thong_so IS NULL;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Co thong so khong hop le voi danh muc san pham';
    END IF;

    UPDATE san_pham
    SET ma_danh_muc = COALESCE(p_ma_danh_muc, ma_danh_muc),
        ma_thuong_hieu = COALESCE(p_ma_thuong_hieu, ma_thuong_hieu),
        ma_san_pham_code = COALESCE(p_code, ma_san_pham_code),
        ten_san_pham = COALESCE(p_ten, ten_san_pham),
        mo_ta = COALESCE(p_mo_ta, mo_ta),
        gia_nhap = COALESCE(p_gia_nhap, gia_nhap),
        gia_ban = COALESCE(p_gia_ban, gia_ban),
        so_luong = COALESCE(p_so_luong, so_luong),
        bao_hanh = COALESCE(p_bao_hanh, bao_hanh),
        hinh_anh = COALESCE(p_hinh_anh, hinh_anh),
        trang_thai = COALESCE(p_trang_thai, trang_thai)
    WHERE ma_san_pham = p_id;

    -- Neu gui p_thong_so_json thi thay toan bo thong so cu bang bo thong so moi.
    IF p_thong_so_json IS NOT NULL THEN
        DELETE FROM thong_so_san_pham WHERE ma_san_pham = p_id;
        INSERT INTO thong_so_san_pham (ma_san_pham, ma_thong_so, gia_tri, gia_tri_so, gia_tri_bool)
        SELECT
            p_id, jt.ma_thong_so, jt.gia_tri, jt.gia_tri_so, jt.gia_tri_bool
        FROM JSON_TABLE(
            p_thong_so_json, '$[*]'
            COLUMNS (
                ma_thong_so INT PATH '$.ma_thong_so',
                gia_tri VARCHAR(1000) PATH '$.gia_tri' NULL ON EMPTY,
                gia_tri_so DECIMAL(18,4) PATH '$.gia_tri_so' NULL ON EMPTY,
                gia_tri_bool BOOLEAN PATH '$.gia_tri_bool' NULL ON EMPTY
            )
        ) jt;
    END IF;

    IF p_hinh_anh IS NOT NULL AND p_hinh_anh <> '' THEN
        UPDATE hinh_anh_san_pham SET la_anh_chinh = FALSE WHERE ma_san_pham = p_id;
        INSERT INTO hinh_anh_san_pham (ma_san_pham, duong_dan, la_anh_chinh, thu_tu_hien_thi)
        VALUES (p_id, p_hinh_anh, TRUE, 1);
    END IF;

    COMMIT;
    SELECT p_id AS ma_san_pham, 1 AS affectedRows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tai_khoan_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_tai_khoan_delete`(IN p_id INT)
BEGIN DELETE FROM tai_khoan WHERE ma_tai_khoan=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tai_khoan_find_by_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_tai_khoan_find_by_email`(IN p_email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, IN p_exclude_id INT)
BEGIN SELECT ma_tai_khoan,email FROM tai_khoan WHERE email=p_email AND ma_tai_khoan<>COALESCE(p_exclude_id,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tai_khoan_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_tai_khoan_get_by_id`(IN p_id INT)
BEGIN SELECT ma_tai_khoan,ten_dang_nhap,ho_ten,email,so_dien_thoai,dia_chi,vai_tro,trang_thai,ngay_tao FROM tai_khoan WHERE ma_tai_khoan=p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tai_khoan_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_tai_khoan_list`()
BEGIN SELECT ma_tai_khoan,ten_dang_nhap,ho_ten,email,so_dien_thoai,dia_chi,vai_tro,trang_thai,ngay_tao FROM tai_khoan ORDER BY ma_tai_khoan DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tai_khoan_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_tai_khoan_update`(IN p_id INT, IN p_ho_ten VARCHAR(100), IN p_email VARCHAR(100), IN p_so_dien_thoai VARCHAR(15), IN p_dia_chi VARCHAR(255), IN p_vai_tro VARCHAR(20), IN p_trang_thai VARCHAR(20))
BEGIN UPDATE tai_khoan SET ho_ten=COALESCE(p_ho_ten,ho_ten), email=COALESCE(p_email,email), so_dien_thoai=COALESCE(p_so_dien_thoai,so_dien_thoai), dia_chi=COALESCE(p_dia_chi,dia_chi), vai_tro=COALESCE(p_vai_tro,vai_tro), trang_thai=COALESCE(p_trang_thai,trang_thai) WHERE ma_tai_khoan=p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thong_so_get_by_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thong_so_get_by_product`(IN p_ma_san_pham INT)
BEGIN
    SELECT
        tsp.ma_san_pham,
        ts.ma_thong_so,
        nts.ten_nhom_thong_so,
        ts.ten_thong_so,
        ts.kieu_du_lieu,
        ts.don_vi,
        tsp.gia_tri,
        tsp.gia_tri_so,
        tsp.gia_tri_bool
    FROM thong_so_san_pham tsp
    JOIN thong_so ts ON ts.ma_thong_so = tsp.ma_thong_so
    JOIN nhom_thong_so nts ON nts.ma_nhom_thong_so = ts.ma_nhom_thong_so
    WHERE tsp.ma_san_pham = p_ma_san_pham
    ORDER BY nts.thu_tu_hien_thi, ts.thu_tu_hien_thi;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thong_so_list_by_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thong_so_list_by_category`(IN p_ma_danh_muc INT)
BEGIN
    SELECT
        dmt.ma_danh_muc,
        ts.ma_thong_so,
        nts.ma_nhom_thong_so,
        nts.ten_nhom_thong_so,
        ts.ten_thong_so,
        ts.kieu_du_lieu,
        ts.don_vi,
        ts.cho_phep_loc,
        dmt.bat_buoc,
        dmt.thu_tu_hien_thi
    FROM danh_muc_thong_so dmt
    JOIN thong_so ts ON ts.ma_thong_so = dmt.ma_thong_so
    JOIN nhom_thong_so nts ON nts.ma_nhom_thong_so = ts.ma_nhom_thong_so
    WHERE dmt.ma_danh_muc = p_ma_danh_muc
      AND ts.trang_thai = TRUE
      AND nts.trang_thai = TRUE
    ORDER BY nts.thu_tu_hien_thi, dmt.thu_tu_hien_thi, ts.thu_tu_hien_thi;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thuong_hieu_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thuong_hieu_create`(IN p_ten VARCHAR(100), IN p_quoc_gia VARCHAR(100), IN p_mo_ta TEXT)
BEGIN INSERT INTO thuong_hieu (ten_thuong_hieu, quoc_gia, mo_ta) VALUES (p_ten, p_quoc_gia, p_mo_ta); SELECT LAST_INSERT_ID() AS insertId, ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thuong_hieu_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thuong_hieu_delete`(IN p_id INT)
BEGIN DELETE FROM thuong_hieu WHERE ma_thuong_hieu = p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thuong_hieu_get_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thuong_hieu_get_by_id`(IN p_id INT)
BEGIN SELECT * FROM thuong_hieu WHERE ma_thuong_hieu = p_id; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thuong_hieu_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thuong_hieu_list`()
BEGIN SELECT * FROM thuong_hieu ORDER BY ma_thuong_hieu DESC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_thuong_hieu_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_thuong_hieu_update`(IN p_id INT, IN p_ten VARCHAR(100), IN p_quoc_gia VARCHAR(100), IN p_mo_ta TEXT)
BEGIN UPDATE thuong_hieu SET ten_thuong_hieu = COALESCE(p_ten, ten_thuong_hieu), quoc_gia = COALESCE(p_quoc_gia, quoc_gia), mo_ta = COALESCE(p_mo_ta, mo_ta) WHERE ma_thuong_hieu = p_id; SELECT ROW_COUNT() AS affectedRows; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-13 21:59:11
