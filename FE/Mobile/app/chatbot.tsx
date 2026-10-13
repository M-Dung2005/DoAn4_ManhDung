import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { useFocusEffect, useLocalSearchParams, useRouter } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
import { ActivityIndicator, KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ProductImage } from '@/components/shop-ui';
import { cardShadow, shop } from '@/constants/shop-theme';
import { authService } from '@/services/auth.service';
import { chatbotService, type ChatAction, type ChatHistoryMessage, type ChatPayload, type ChatReply } from '@/services/chatbot.service';
import { formatCurrency, getApiMessage } from '@/utils/format';

interface Message extends ChatHistoryMessage { id: number; reply?: ChatReply }
const actions: Record<ChatAction, { title: string; path: string; icon: React.ComponentProps<typeof MaterialIcons>['name'] }> = {
  products: { title: 'Khám phá sản phẩm', path: '/products', icon: 'storefront' },
  orders: { title: 'Đơn hàng của tôi', path: '/orders', icon: 'receipt-long' },
  cart: { title: 'Mở giỏ hàng', path: '/cart', icon: 'shopping-cart' },
  vouchers: { title: 'Voucher của tôi', path: '/vouchers', icon: 'local-offer' },
  contact: { title: 'Liên hệ nhân viên', path: '/contact', icon: 'support-agent' },
};

export default function ChatbotScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{ productId?: string }>();
  const parsedId = Number(params.productId);
  const productId = Number.isSafeInteger(parsedId) && parsedId > 0 ? parsedId : undefined;
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [enabled, setEnabled] = useState(false);
  const [checking, setChecking] = useState(true);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const [retryPayload, setRetryPayload] = useState<ChatPayload | null>(null);
  const scroll = useRef<ScrollView>(null);
  const controller = useRef<AbortController | null>(null);
  const lock = useRef(false);
  const generation = useRef(0);
  const nextId = useRef(1);
  const owner = useRef<number | undefined>(undefined);
  const contextProduct = useRef(productId);
  const mounted = useRef(true);
  useEffect(() => { mounted.current = true; return () => { mounted.current = false; controller.current?.abort(); }; }, []);
  useEffect(() => {
    if (contextProduct.current === productId) return;
    contextProduct.current = productId;
    controller.current?.abort(); generation.current++; lock.current = false;
    setMessages([]); setInput(''); setError(''); setRetryPayload(null); setSending(false);
  }, [productId]);

  const loadStatus = useCallback(() => {
    let active = true;
    setChecking(true);
    void Promise.all([chatbotService.status(), authService.getMe()]).then(([status, account]) => {
      if (!active || !mounted.current) return;
      const accountId = Number(account.data.ma_tai_khoan);
      if (owner.current !== undefined && owner.current !== accountId) {
        controller.current?.abort(); generation.current++; lock.current = false;
        setMessages([]); setInput(''); setRetryPayload(null); setSending(false); setError('');
      }
      owner.current = accountId;
      setEnabled(status.enabled);
    }).catch(err => { if (active) { setEnabled(false); setError(getApiMessage(err, 'Chưa kết nối được trợ lý.')); } }).finally(() => { if (active) setChecking(false); });
    return () => { active = false; };
  }, []);
  useFocusEffect(loadStatus);

  const deliver = async (payload: ChatPayload, retry = false) => {
    if (lock.current || checking || !enabled || !owner.current) return;
    lock.current = true; setSending(true); setError(''); setRetryPayload(null);
    const request = ++generation.current;
    controller.current = new AbortController();
    if (!retry) { setMessages(current => [...current, { id: nextId.current++, role: 'user', content: payload.message }]); setInput(''); }
    try {
      const reply = await chatbotService.send(payload, controller.current.signal);
      if (mounted.current && generation.current === request) setMessages(current => [...current, { id: nextId.current++, role: 'assistant', content: reply.message, reply }]);
    } catch (err: any) {
      if (mounted.current && generation.current === request && err?.code !== 'ERR_CANCELED') { setError(getApiMessage(err, 'Trợ lý chưa phản hồi. Bạn hãy thử lại hoặc liên hệ nhân viên.')); setRetryPayload(payload); }
    } finally {
      if (generation.current === request) { lock.current = false; if (mounted.current) setSending(false); }
    }
  };
  const send = (question = input) => {
    const message = question.trim();
    if (!message || message.length > 1500) return;
    const history = messages.map(({ role, content }) => ({ role, content })).slice(-8);
    // Keep the request within the server's bounded conversation window.
    while (history.length && history.reduce((size, item) => size + item.content.length, message.length) > 16000) history.shift();
    void deliver({ message, history, ...(productId ? { productId } : {}) });
  };
  const reset = () => { if (!lock.current) { setMessages([]); setInput(''); setError(''); setRetryPayload(null); } };
  const suggestions = productId ? ['Tư vấn giúp tôi sản phẩm đang xem', 'Sản phẩm này có những phiên bản nào?', 'Hướng dẫn đặt mua sản phẩm này'] : ['Gợi ý sản phẩm dưới 500.000đ', 'Đơn hàng gần nhất của tôi thế nào?', 'Cách sử dụng voucher', 'Hướng dẫn mua hàng'];

  return <SafeAreaView style={styles.safe} edges={['bottom']}>
    <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : 'height'} keyboardVerticalOffset={90}>
      <View style={styles.container}>
        <View style={styles.header}><View style={styles.avatar}><MaterialIcons name="auto-awesome" size={23} color="#fff" /></View><View style={styles.headerCopy}><Text style={styles.title}>Trợ lý SmartShop</Text><Text style={styles.subtitle}>AI · Google Gemini{productId ? ' · Tư vấn sản phẩm' : ''}</Text></View><Pressable accessibilityRole="button" accessibilityLabel="Bắt đầu cuộc trò chuyện mới" disabled={sending} onPress={reset} style={styles.reset}><MaterialIcons name="refresh" size={22} color={shop.primary} /></Pressable></View>
        <ScrollView ref={scroll} style={styles.flex} contentContainerStyle={styles.conversation} keyboardShouldPersistTaps="handled" onContentSizeChange={() => scroll.current?.scrollToEnd({ animated: true })}>
          {!messages.length ? <View style={styles.welcome}><View style={styles.welcomeIcon}><MaterialIcons name="forum" size={38} color={shop.primary} /></View><Text style={styles.welcomeTitle}>Bạn cần tìm điều gì?</Text><Text style={styles.welcomeCopy}>Mình có thể giúp bạn chọn sản phẩm, xem thông tin mua sắm và hướng dẫn sử dụng SmartShop.</Text><View style={styles.suggestions}>{suggestions.map(question => <Pressable accessibilityRole="button" accessibilityLabel={question} key={question} disabled={!enabled || checking} onPress={() => send(question)} style={styles.suggestion}><Text style={styles.suggestionText}>{question}</Text><MaterialIcons name="north-east" size={16} color={shop.primary} /></Pressable>)}</View></View> : null}
          {!checking && messages.map(message => <View key={message.id} style={[styles.messageRow, message.role === 'user' && styles.userRow]}>
            {message.role === 'assistant' ? <View style={styles.miniAvatar}><MaterialIcons name="auto-awesome" size={15} color={shop.primary} /></View> : null}
            <View style={[styles.bubble, message.role === 'user' && styles.userBubble]}><Text selectable style={[styles.messageText, message.role === 'user' && styles.userText]}>{message.content}</Text>
              {message.reply?.products.map(product => <Pressable accessibilityRole="button" accessibilityLabel={`Xem ${product.ten_san_pham}`} key={product.ma_san_pham} onPress={() => router.push({ pathname: '/product/[id]', params: { id: String(product.ma_san_pham) } })} style={styles.product}><ProductImage uri={product.hinh_anh} style={styles.productImage} /><View style={styles.productCopy}><Text numberOfLines={2} style={styles.productName}>{product.ten_san_pham}</Text><Text style={styles.productPrice}>{formatCurrency(product.gia_ban)}</Text><Text style={styles.productStock}>{product.so_luong > 0 ? 'Xem phiên bản và tồn kho' : 'Hiện hết hàng'}</Text></View><MaterialIcons name="chevron-right" size={20} color={shop.primary} /></Pressable>)}
              {message.reply?.actions.length ? <View style={styles.replyActions}>{message.reply.actions.map(action => <Pressable accessibilityRole="button" key={action} style={styles.replyAction} onPress={() => router.push(actions[action].path as any)}><MaterialIcons name={actions[action].icon} size={15} color={shop.primary} /><Text style={styles.replyActionText}>{actions[action].title}</Text></Pressable>)}</View> : null}
            </View>
          </View>)}
          {sending ? <View style={styles.typing} accessibilityLiveRegion="polite"><ActivityIndicator color={shop.primary} size="small" /><Text style={styles.subtitle}>Đang tìm câu trả lời cho bạn...</Text></View> : null}
          {checking ? <ActivityIndicator color={shop.primary} style={{ marginVertical: 16 }} /> : !enabled ? <View style={styles.notice}><Text style={styles.noticeTitle}>Nhân viên luôn sẵn sàng hỗ trợ</Text><Text style={styles.noticeText}>Trợ lý AI hiện chưa sẵn sàng. Bạn vẫn có thể gửi câu hỏi cho cửa hàng.</Text><Pressable accessibilityRole="button" onPress={() => router.push('/contact')}><Text style={styles.link}>Gửi liên hệ cho nhân viên →</Text></Pressable><Pressable accessibilityRole="button" onPress={() => { setError(''); loadStatus(); }}><Text style={styles.link}>Kiểm tra lại kết nối</Text></Pressable></View> : null}
          {error ? <View style={styles.errorBox} accessibilityLiveRegion="polite"><Text style={styles.errorText}>{error}</Text><View style={styles.replyActions}>{retryPayload ? <Pressable accessibilityRole="button" disabled={sending} onPress={() => void deliver(retryPayload, true)}><Text style={styles.link}>Thử lại</Text></Pressable> : null}<Pressable accessibilityRole="button" onPress={() => router.push('/contact')}><Text style={styles.link}>Liên hệ nhân viên</Text></Pressable></View></View> : null}
        </ScrollView>
        <View style={styles.composerWrap}><View style={styles.composer}><TextInput accessibilityLabel="Câu hỏi cho trợ lý AI" value={input} onChangeText={setInput} placeholder="Hỏi SmartShop..." placeholderTextColor={shop.muted} maxLength={1500} multiline editable={enabled && !checking && !sending} style={styles.input} /><Pressable accessibilityRole="button" accessibilityLabel="Gửi câu hỏi" disabled={!input.trim() || !enabled || checking || sending} onPress={() => send()} style={[styles.send, (!input.trim() || !enabled || checking || sending) && styles.disabled]}><MaterialIcons name="arrow-upward" size={23} color="#fff" /></Pressable></View><Text style={styles.footnote}>Thông tin tư vấn từ AI. Giá và tồn kho được xác nhận ở thanh toán.</Text></View>
      </View>
    </KeyboardAvoidingView>
  </SafeAreaView>;
}

const styles = StyleSheet.create({
  safe: { flex: 1, minHeight: 0, backgroundColor: shop.background }, flex: { flex: 1, minHeight: 0 }, container: { flex: 1, minHeight: 0, width: '100%', maxWidth: 820, alignSelf: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 18, borderBottomWidth: 1, borderBottomColor: shop.border, backgroundColor: '#fff' }, headerCopy: { flex: 1 },
  avatar: { width: 42, height: 42, borderRadius: 14, backgroundColor: shop.primary, alignItems: 'center', justifyContent: 'center' }, title: { fontSize: 17, color: shop.ink, fontWeight: '800' }, subtitle: { fontSize: 11, color: shop.muted, marginTop: 5 }, reset: { padding: 10 },
  conversation: { padding: 18, paddingBottom: 28, gap: 16 }, welcome: { alignItems: 'center', paddingVertical: 22, paddingHorizontal: 6 }, welcomeIcon: { width: 76, height: 76, borderRadius: 24, backgroundColor: shop.soft, alignItems: 'center', justifyContent: 'center', marginBottom: 18 },
  welcomeTitle: { color: shop.ink, fontSize: 23, fontWeight: '800' }, welcomeCopy: { color: shop.muted, textAlign: 'center', fontSize: 13, lineHeight: 21, marginTop: 10, maxWidth: 380 }, suggestions: { alignSelf: 'stretch', gap: 8, marginTop: 24 }, suggestion: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: 8, padding: 14, borderWidth: 1, borderColor: shop.border, borderRadius: 13, backgroundColor: '#fff' }, suggestionText: { color: shop.ink, fontSize: 12, flex: 1 },
  messageRow: { flexDirection: 'row', gap: 8, alignItems: 'flex-start' }, userRow: { justifyContent: 'flex-end' }, miniAvatar: { width: 28, height: 28, borderRadius: 10, backgroundColor: shop.soft, alignItems: 'center', justifyContent: 'center', marginTop: 2 },
  bubble: { maxWidth: '88%', flexShrink: 1, borderRadius: 18, borderTopLeftRadius: 5, padding: 15, backgroundColor: '#fff', borderWidth: 1, borderColor: shop.border, ...cardShadow }, userBubble: { backgroundColor: shop.primary, borderColor: shop.primary, borderTopLeftRadius: 18, borderTopRightRadius: 5 }, messageText: { fontSize: 14, lineHeight: 22, color: shop.ink }, userText: { color: '#fff' },
  product: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 10, marginTop: 12, backgroundColor: shop.background, borderRadius: 12 }, productImage: { width: 52, height: 58, borderRadius: 8 }, productCopy: { flex: 1 }, productName: { color: shop.ink, fontSize: 12, fontWeight: '700', lineHeight: 18 }, productPrice: { color: shop.primary, fontSize: 13, fontWeight: '800', marginTop: 5 }, productStock: { color: shop.muted, fontSize: 9, marginTop: 4 },
  replyActions: { flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginTop: 14 }, replyAction: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 10, paddingVertical: 9, borderRadius: 10, backgroundColor: shop.soft }, replyActionText: { color: shop.primary, fontSize: 11, fontWeight: '700' },
  typing: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 12, paddingVertical: 6 }, notice: { padding: 18, borderRadius: 16, backgroundColor: shop.soft, gap: 10 }, noticeTitle: { color: shop.ink, fontWeight: '800', fontSize: 14 }, noticeText: { color: shop.muted, fontSize: 12, lineHeight: 20 }, link: { color: shop.primary, fontSize: 12, fontWeight: '700', paddingVertical: 6 }, errorBox: { padding: 14, backgroundColor: '#fff1f2', borderRadius: 12 }, errorText: { color: shop.danger, fontSize: 12, lineHeight: 20 },
  composerWrap: { padding: 14, borderTopWidth: 1, borderTopColor: shop.border, backgroundColor: '#fff' }, composer: { flexDirection: 'row', alignItems: 'flex-end', gap: 10, borderWidth: 1, borderColor: shop.border, borderRadius: 18, padding: 8, paddingLeft: 14, backgroundColor: shop.background }, input: { flex: 1, minHeight: 40, maxHeight: 120, fontSize: 14, color: shop.ink, paddingVertical: 10 }, send: { width: 42, height: 42, borderRadius: 14, alignItems: 'center', justifyContent: 'center', backgroundColor: shop.primary }, disabled: { opacity: 0.4 }, footnote: { fontSize: 9, color: shop.muted, textAlign: 'center', marginTop: 10, lineHeight: 14 },
});
