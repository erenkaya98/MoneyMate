# 💰 MoneyMate: Currency Converter App

Modern, oyunlaştırılmış ve App Store uyumlu döviz kuru uygulaması.

## 🚀 Özellikler

### ✨ Ana Özellikler (PRD Uyumlu)
- **Ana Ekran**: Güncel döviz kurları ile oyunlaştırılmış kartlar
- **Dönüştürücü**: Anlık döviz dönüşümü hesaplayıcı
- **Grafikler**: İnteraktif kur grafikleri ve trend analizi
- **Hesap/Ayarlar**: Uygulama kişiselleştirme ve ayarlar
- **Hamburger Menü**: Yan menü ile ek özellikler

### 🎮 Oyunlaştırma Özellikleri
- Animasyonlu kur kartları
- Haptic feedback butonları
- Yüzen para sembolleri
- Smooth animasyonlar ve geçişler
- Glassmorphism tasarım efektleri
- Gerçek zamanlı kur güncellemeleri

### 📱 App Store Uygunluğu
- **PWA (Progressive Web App)** desteği
- iOS Safari uyumluluğu
- Offline çalışma kapasitesi
- Apple Web App meta etiketleri
- Service Worker ile cache yönetimi
- App Store yayınlama hazırlığı

## 🛠 Teknoloji Stack

- **Framework**: Next.js 15.4.1 (App Router)
- **UI Library**: React 19
- **Styling**: TailwindCSS 4
- **Animasyonlar**: Framer Motion
- **Charts**: Chart.js + React Chart.js 2
- **Icons**: Lucide React
- **PWA**: next-pwa
- **TypeScript**: Full type safety

## 🏗 Kurulum

```bash
# Depoyu klonlayın
git clone <repo-url>
cd moneymate

# Bağımlılıkları yükleyin
npm install

# Geliştirme sunucusunu başlatın
npm run dev

# Production build
npm run build

# Linting
npm run lint
```

## 🌐 API Entegrasyonu

Uygulama gerçek zamanlı döviz kurları için Exchange Rate API kullanır:
- **Primary API**: ExchangeRate-API
- **Fallback**: Mock data sistemi
- **Offline Support**: Cache ve service worker
- **Auto-refresh**: 60 saniye otomatik güncelleme

## 📋 App Store Yayınlama

### PWA olarak Yayınlama
1. **Build**: `npm run build`
2. **Test**: Production build'i test edin
3. **Deploy**: Vercel/Netlify gibi platformlara deploy
4. **PWA Features**: 
   - App'i ana ekrana ekleme
   - Offline çalışma
   - Push notifications (gelecek)

### Native App'e Dönüştürme (Opsiyonel)
- **Capacitor** ile native wrapper
- **Cordova** alternatifi
- App Store submission

## 🎨 Tasarım Sistemi

### Renk Paleti
- **Primary**: #3b82f6 (Blue)
- **Success**: #10b981 (Green) 
- **Danger**: #ef4444 (Red)
- **Warning**: #f59e0b (Yellow)
- **Background**: #f8fafc (Light) / #0f172a (Dark)

### Animasyonlar
- **Framer Motion** tabanlı
- Smooth transitions
- Physics-based animations
- Haptic feedback simülasyonu

## 📱 Ekran Yapısı

1. **Ana Ekran** (`/`): Güncel kurlar listesi
2. **Dönüştürücü** (`/converter`): Para birimi dönüştürücü
3. **Grafikler** (`/charts`): Kur grafikleri ve analiz
4. **Hesap** (`/account`): Ayarlar ve kişiselleştirme

## 🔧 Geliştirme Notları

### Klasör Yapısı
```
app/                 # Next.js App Router pages
├── page.tsx         # Ana sayfa
├── converter/       # Dönüştürücü sayfası
├── charts/          # Grafik sayfası
├── account/         # Hesap sayfası
└── layout.tsx       # Root layout

components/          # React bileşenleri
├── ui/              # UI bileşenleri
└── layout/          # Layout bileşenleri

lib/                 # Utility functions
├── types.ts         # TypeScript types
├── api.ts           # API functions
└── mock-data.ts     # Mock data & real API integration

public/              # Static files
├── manifest.json    # PWA manifest
└── icons/           # App icons
```

### Performans
- **Bundle size**: ~146KB First Load JS
- **Lighthouse Score**: 90+ (PWA ready)
- **Cache Strategy**: 5 dakika API cache
- **Offline Support**: Service worker

## 🚀 Deploy

### Vercel (Önerilen)
```bash
npm install -g vercel
vercel
```

### Netlify
```bash
npm run build
# Upload .next/out folder
```

## 📈 Roadmap

### Fase 1 (Tamamlandı) ✅
- [x] Temel PWA yapısı
- [x] 4 ana ekran
- [x] Oyunlaştırma öğeleri
- [x] API entegrasyonu
- [x] Responsive tasarım

### Fase 2 (Gelecek)
- [ ] Real-time notifications
- [ ] Widget support
- [ ] Advanced charting
- [ ] Social sharing
- [ ] Premium features

## 📝 License

MIT License - Detaylar için LICENSE dosyasına bakın.

---

**MoneyMate** - Para birimi takibini eğlenceli hale getiren modern uygulama! 💰✨