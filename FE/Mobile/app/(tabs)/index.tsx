import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import { Link, useFocusEffect } from 'expo-router';
import { useCallback, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View, useWindowDimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { cartService } from '../../services/cart.service';
import { productService } from '../../services/product.service';
import { categoryService, type Category } from '../../services/category.service';
import type { Product } from '../../types';
import { EmptyState, LoadingState, ProductCard } from '@/components/shop-ui';
import { shop } from '@/constants/shop-theme';
import { getApiMessage } from '@/utils/format';
import { getCategoryIcon } from '@/constants/category-icons';

const categoryColors = ['#EAF5FF', '#FFF2E8', '#F2EEFF', '#eef2ff'];

export default function HomeScreen() {
  const { width } = useWindowDimensions();
  const wide = width >= 800;
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [categoryError, setCategoryError] = useState('');
  const [cartCount, setCartCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadHome = useCallback(async () => {
    setError('');
    const categoriesRequest = categoryService.getCategories().then(data => {
      setCategories(data); setCategoryError('');
    }).catch(err => {
      setCategories([]); setCategoryError(getApiMessage(err, 'Chưa tải được danh mục.'));
    });
    try {
      const response = await productService.getProducts({ limit: 8 });
      setProducts(response.data || []);
    } catch (error) {
      setError(getApiMessage(error, 'Không thể tải danh sách sản phẩm'));
    } finally {
      setLoading(false);
    }

    try {
      const cart = await cartService.getCart();
      const count = (cart.data?.items || []).reduce((sum: number, item: any) => sum + Number(item.so_luong || 0), 0);
      setCartCount(count);
    } catch {
      setCartCount(0);
    }
    await categoriesRequest;
  }, []);

  useFocusEffect(useCallback(() => {
    loadHome();
  }, [loadHome]));

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <View style={styles.brandRow}>
            <View style={styles.brandIcon}><MaterialIcons name="shopping-bag" size={25} color="#fff" /></View>
            <View>
            <Text style={styles.eyebrow}>SMARTSHOP</Text>
            <Text style={styles.heading}>Mua sắm theo cách của bạn.</Text>
            </View>
          </View>
          <Link href="/cart" asChild>
            <Pressable accessibilityLabel="Mở giỏ hàng" style={styles.iconButton}>
              <MaterialIcons name="shopping-bag" size={23} color="#17213d" />
              {cartCount > 0 ? <View style={styles.badge}><Text style={styles.badgeText}>{cartCount > 9 ? '9+' : cartCount}</Text></View> : null}
            </Pressable>
          </Link>
        </View>

        <Link href="/products" asChild><Pressable accessibilityLabel="Tìm kiếm sản phẩm" style={styles.searchBar}><MaterialIcons name="search" size={22} color={shop.muted} /><Text style={styles.searchText}>Tìm điều bạn thích tại SmartShop</Text><View style={styles.searchArrow}><MaterialIcons name="arrow-forward" size={18} color={shop.primary} /></View></Pressable></Link>
        <View style={styles.hero}>
          <View style={styles.heroCircle} />
          <View style={styles.heroCopy}>
            <Text style={styles.heroKicker}>KHÁM PHÁ THẾ GIỚI SMARTSHOP</Text>
            <Text style={styles.heroTitle}>{'Mua sắm dễ dàng.\nĐa dạng lựa chọn.'}</Text>
            <Text style={styles.heroText}>Từ công nghệ đến phong cách sống. Khám phá những lựa chọn dành riêng cho bạn.</Text>
            <Link href="/products" asChild>
              <Pressable style={styles.heroButton}>
                <Text style={styles.heroButtonText}>Khám phá ngay</Text>
                <MaterialIcons name="arrow-forward" size={18} color={shop.ink} />
              </Pressable>
            </Link>
          </View>
          <View pointerEvents="none" style={[styles.heroCollection, !wide && styles.heroCollectionCompact]}>
            <View style={[styles.collectionCard, styles.collectionTech]}><MaterialCommunityIcons name="headphones" size={52} color="#a5b4fc" /><Text style={styles.collectionLabel}>TECH</Text></View>
            <View style={[styles.collectionCard, styles.collectionFashion]}><MaterialCommunityIcons name="shoe-sneaker" size={52} color="#f9a8d4" /><Text style={styles.collectionLabel}>STYLE</Text></View>
            <View style={[styles.collectionCard, styles.collectionHome]}><MaterialCommunityIcons name="lamp" size={44} color="#fde68a" /><Text style={styles.collectionLabel}>LIVING</Text></View>
          </View>
        </View>
        <View style={styles.discoveryRow}>
          <View style={styles.discoveryItem}><MaterialIcons name="apps" size={18} color={shop.primary} /><Text style={styles.discoveryText}>Đa dạng ngành hàng</Text></View>
          <View style={styles.discoveryItem}><MaterialIcons name="manage-search" size={18} color={shop.primary} /><Text style={styles.discoveryText}>Tìm kiếm dễ dàng</Text></View>
          <View style={styles.discoveryItem}><MaterialIcons name="local-offer" size={18} color={shop.primary} /><Text style={styles.discoveryText}>Ưu đãi thành viên</Text></View>
        </View>

        <SectionHeader title="Mua sắm theo danh mục" action="Xem tất cả" href="/products" />
        {categoryError ? <Text style={styles.searchText}>{categoryError}</Text> : null}
        <View style={styles.categoryRow}>
          {categories.map((item, index) => ({ ...item, icon: getCategoryIcon(item.ten_danh_muc), color: categoryColors[index % categoryColors.length] })).map((category) => (
            <Link href={{ pathname: '/products', params: { categoryId: String(category.ma_danh_muc) } }} key={category.ma_danh_muc} asChild>
              <Pressable accessibilityLabel={`Khám phá ${category.ten_danh_muc}`} style={StyleSheet.flatten([styles.category, wide && styles.categoryWide])}>
                <View style={[styles.categoryIcon, { backgroundColor: category.color }]}><MaterialCommunityIcons name={category.icon} size={28} color="#17213d" /></View>
                <Text style={styles.categoryLabel}>{category.ten_danh_muc}</Text>
              </Pressable>
            </Link>
          ))}
        </View>

        <SectionHeader title="Sản phẩm nổi bật" action="Xem thêm" href="/products" />
        {loading ? <LoadingState message="Đang chọn sản phẩm cho bạn..." /> : error ? <EmptyState icon="wifi-off" title="Chưa tải được sản phẩm" message={error} action="Thử lại" onAction={loadHome} /> : !products.length ? <EmptyState icon="inventory-2" title="Sản phẩm đang được cập nhật" /> : (
          <View style={styles.productRow}>{products.map(product => <View key={product.ma_san_pham} style={[styles.productCell, wide && styles.productCellWide]}><ProductCard product={product} /></View>)}</View>
        )}
        {/* Gamification Action Strip */}
        <View style={styles.rewardStrip}>
          <Link href={'/rewards' as any} asChild>
            <Pressable style={styles.rewardActionBtn}>
              <View style={[styles.rewardIconWrap, { backgroundColor: '#eef2ff' }]}>
                <MaterialIcons name="event-available" size={24} color="#4f46e5" />
                <View style={styles.miniBadge}><Text style={styles.miniBadgeText}>+100X</Text></View>
              </View>
              <Text style={styles.rewardActionText}>Điểm danh</Text>
            </Pressable>
          </Link>

          <Link href={'/referral' as any} asChild>
            <Pressable style={styles.rewardActionBtn}>
              <View style={[styles.rewardIconWrap, { backgroundColor: '#FFF2E8' }]}>
                <MaterialIcons name="group-add" size={24} color="#D97706" />
                <View style={[styles.miniBadge, { backgroundColor: '#EA580C' }]}><Text style={styles.miniBadgeText}>50K</Text></View>
              </View>
              <Text style={styles.rewardActionText}>Mời bạn bè</Text>
            </Pressable>
          </Link>

          <Link href={'/rewards' as any} asChild>
            <Pressable style={styles.rewardActionBtn}>
              <View style={[styles.rewardIconWrap, { backgroundColor: '#F2EEFF' }]}>
                <MaterialIcons name="attractions" size={24} color="#7C3AED" />
                <View style={[styles.miniBadge, { backgroundColor: '#8B5CF6' }]}><Text style={styles.miniBadgeText}>Hot</Text></View>
              </View>
              <Text style={styles.rewardActionText}>Vòng quay</Text>
            </Pressable>
          </Link>

          <Link href="/vouchers" asChild>
            <Pressable style={styles.rewardActionBtn}>
              <View style={[styles.rewardIconWrap, { backgroundColor: '#EAF5FF' }]}>
                <MaterialIcons name="local-offer" size={24} color="#0284C7" />
              </View>
              <Text style={styles.rewardActionText}>Voucher</Text>
            </Pressable>
          </Link>
        </View>

        {/* Retention Banner */}
        <Link href={'/rewards' as any} asChild>
          <Pressable style={styles.retentionBanner}>
            <View style={styles.retentionIconWrap}>
              <MaterialIcons name="stars" size={30} color="#c4b5fd" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.retentionTitle}>Điểm danh nhận Xu & Quà khủng</Text>
              <Text style={styles.retentionSub}>Chuỗi ngày tích lũy nhận voucher tới 100K</Text>
            </View>
            <View style={styles.retentionCta}>
              <Text style={styles.retentionCtaText}>Nhận ngay</Text>
              <MaterialIcons name="chevron-right" size={18} color="#17213d" />
            </View>
          </Pressable>
        </Link>

        <Link href="/products" asChild><Pressable style={styles.bottomBanner}><View style={{ flex: 1 }}><Text style={styles.bottomTitle}>Tìm thêm điều bạn thích</Text><Text style={styles.bottomText}>Khám phá tất cả sản phẩm tại SmartShop</Text></View><MaterialIcons name="arrow-circle-right" size={30} color={shop.primary} /></Pressable></Link>
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionHeader({ title, action, href }: { title: string; action: string; href: '/products' }) {
  return (
    <View style={styles.sectionHeader}>
      <Text style={styles.sectionTitle}>{title}</Text>
      <Link href={href} style={styles.sectionAction}>{action}</Link>
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: shop.background },
  content: { paddingHorizontal: 20, paddingBottom: 28, width: '100%', maxWidth: 1100, alignSelf: 'center' },
  brandRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  brandIcon: { width: 42, height: 42, borderRadius: 13, alignItems: 'center', justifyContent: 'center', backgroundColor: shop.primary },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 12, paddingTop: 18, paddingBottom: 22 },
  eyebrow: { color: shop.ink, fontSize: 18, fontWeight: '900', letterSpacing: 1.4 },
  heading: { color: shop.muted, fontSize: 11, marginTop: 6 },
  iconButton: { width: 46, height: 46, borderRadius: 17, backgroundColor: '#fff', borderWidth: 1, borderColor: shop.border, alignItems: 'center', justifyContent: 'center' },
  badge: { position: 'absolute', right: -3, top: -3, minWidth: 20, height: 20, borderRadius: 15, backgroundColor: shop.primary, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, borderWidth: 2, borderColor: shop.background },
  badgeText: { color: '#fff', fontSize: 9, fontWeight: '800' },
  searchBar: { backgroundColor: '#fff', borderRadius: 18, borderWidth: 1, borderColor: shop.border, minHeight: 54, flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 15, marginBottom: 20 },
  searchText: { color: shop.muted, fontSize: 13, flex: 1 },
  searchArrow: { backgroundColor: shop.soft, width: 32, height: 32, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  hero: { backgroundColor: '#252358', minHeight: 255, borderRadius: 22, padding: 26, overflow: 'hidden' },
  heroCircle: { position: 'absolute', right: -90, bottom: -65, width: 260, height: 260, borderRadius: 130, backgroundColor: '#31306b' },
  heroCopy: { width: '82%', zIndex: 1 },
  heroKicker: { color: shop.accent, fontSize: 9, fontWeight: '800', letterSpacing: 1.4 },
  heroTitle: { color: '#fff', fontSize: 27, lineHeight: 35, fontWeight: '800', letterSpacing: -0.8, marginTop: 14 },
  heroText: { color: '#d9defb', fontSize: 12, lineHeight: 19, marginTop: 10, maxWidth: 220 },
  heroButton: { alignSelf: 'flex-start', flexDirection: 'row', gap: 10, alignItems: 'center', backgroundColor: shop.accent, paddingHorizontal: 16, minHeight: 43, borderRadius: 22, marginTop: 20 },
  heroButtonText: { color: shop.ink, fontSize: 12, fontWeight: '800' },
  heroIcon: { position: 'absolute', right: -18, bottom: 24, transform: [{ rotate: '-12deg' }], opacity: 0.35 },
  heroCollection: { position: 'absolute', right: 32, top: 30, width: 240, height: 230 },
  heroCollectionCompact: { right: -100, opacity: 0.18 },
  collectionCard: { position: 'absolute', width: 116, height: 124, borderRadius: 20, borderWidth: 1, borderColor: '#ffffff30', backgroundColor: '#ffffff12', alignItems: 'center', justifyContent: 'center', gap: 12 },
  collectionTech: { top: 0, left: 0, transform: [{ rotate: '-9deg' }] },
  collectionFashion: { top: 65, right: 0, transform: [{ rotate: '12deg' }] },
  collectionHome: { bottom: 0, left: 8, transform: [{ rotate: '-4deg' }] },
  collectionLabel: { fontSize: 9, color: '#e0e7ff', fontWeight: '800', letterSpacing: 2 },
  discoveryRow: { flexDirection: 'row', justifyContent: 'space-around', flexWrap: 'wrap', gap: 8, marginTop: 18, marginBottom: 4 },
  discoveryItem: { flexDirection: 'row', alignItems: 'center', gap: 5 },
  discoveryText: { color: shop.muted, fontSize: 10 },
  promise: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 7, marginTop: 16 },
  promiseText: { color: shop.muted, fontSize: 10, flexShrink: 1 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 28, marginBottom: 16 },
  sectionTitle: { color: shop.ink, fontSize: 19, fontWeight: '800', letterSpacing: -0.5 },
  sectionAction: { color: shop.primary, fontSize: 11, fontWeight: '700', paddingVertical: 8 },
  categoryRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, paddingBottom: 2 },
  category: { alignItems: 'center', width: '23%', flexGrow: 1, maxWidth: '24%', paddingVertical: 14, backgroundColor: '#fff', borderRadius: 16, borderWidth: 1, borderColor: shop.border },
  categoryWide: { width: '11%', maxWidth: '12%' },
  categoryIcon: { width: 48, height: 48, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  categoryLabel: { color: shop.ink, fontSize: 11, fontWeight: '600', textAlign: 'center', marginTop: 10 },
  productRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  productCell: { width: '48%', flexGrow: 1, maxWidth: '49%' },
  productCellWide: { width: '23%', maxWidth: '24%' },
  bottomBanner: { backgroundColor: shop.soft, padding: 20, borderRadius: 22, flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 24 },
  bottomTitle: { color: shop.ink, fontSize: 14, fontWeight: '700' },
  bottomText: { color: shop.muted, fontSize: 12, marginTop: 5 },
  rewardStrip: { flexDirection: 'row', justifyContent: 'space-between', backgroundColor: '#fff', borderRadius: 22, paddingVertical: 14, paddingHorizontal: 12, marginTop: 16, borderWidth: 1, borderColor: shop.border },
  rewardActionBtn: { alignItems: 'center', flex: 1 },
  rewardIconWrap: { width: 48, height: 48, borderRadius: 18, alignItems: 'center', justifyContent: 'center', position: 'relative' },
  miniBadge: { position: 'absolute', top: -4, right: -6, backgroundColor: '#4f46e5', borderRadius: 10, paddingHorizontal: 5, paddingVertical: 2 },
  miniBadgeText: { color: '#fff', fontSize: 8, fontWeight: '800' },
  rewardActionText: { color: shop.ink, fontSize: 11, fontWeight: '700', marginTop: 6 },
  retentionBanner: { backgroundColor: '#17213d', borderRadius: 22, padding: 16, flexDirection: 'row', alignItems: 'center', gap: 12, marginTop: 14 },
  retentionIconWrap: { width: 48, height: 48, borderRadius: 18, backgroundColor: '#31306b', alignItems: 'center', justifyContent: 'center' },
  retentionTitle: { color: '#fff', fontSize: 13, fontWeight: '800' },
  retentionSub: { color: '#c7d2fe', fontSize: 11, marginTop: 3 },
  retentionCta: { backgroundColor: '#c4b5fd', paddingHorizontal: 10, paddingVertical: 6, borderRadius: 12, flexDirection: 'row', alignItems: 'center', gap: 2 },
  retentionCtaText: { color: '#17213d', fontSize: 11, fontWeight: '800' },
});
