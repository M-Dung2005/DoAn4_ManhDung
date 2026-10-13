import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { useRouter, useSegments } from 'expo-router';
import { Pressable, StyleSheet, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { cardShadow, shop } from '@/constants/shop-theme';

export function ChatbotLauncher() {
  const router = useRouter();
  const segments = useSegments();
  const insets = useSafeAreaInsets();
  if (segments[0] !== '(tabs)' || segments.some(segment => segment === 'cart')) return null;
  return <Pressable accessibilityRole="button" accessibilityLabel="Mở trợ lý AI SmartShop" onPress={() => router.push('/chatbot' as any)} style={[styles.button, { bottom: 86 + Math.max(insets.bottom, 10) }]}>
    <MaterialIcons name="auto-awesome" size={21} color="#fff" /><Text style={styles.label}>Hỏi AI</Text>
  </Pressable>;
}

const styles = StyleSheet.create({
  button: { position: 'absolute', right: 20, zIndex: 10, minHeight: 48, borderRadius: 24, paddingHorizontal: 18, flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: shop.primary, ...cardShadow, shadowOpacity: 0.18, elevation: 6 },
  label: { fontSize: 13, fontWeight: '800', color: '#fff' },
});
