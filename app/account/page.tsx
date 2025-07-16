'use client';

import { motion } from 'framer-motion';
import { 
  Settings, 
  Globe, 
  Bell, 
  Shield, 
  FileText, 
  MessageCircle, 
  Star, 
  Share2,
  ChevronRight,
  Moon,
  Sun
} from 'lucide-react';
import { useState } from 'react';
import { Header } from '@/components/ui/header';
import { HapticButton } from '@/components/ui/haptic-button';

export default function AccountPage() {
  const [darkMode, setDarkMode] = useState(false);
  const [notifications, setNotifications] = useState(true);

  const menuItems = [
    {
      icon: Globe,
      title: 'Dil Ayarları',
      subtitle: 'Türkçe',
      action: () => alert('Dil ayarları yakında!'),
      color: 'text-primary'
    },
    {
      icon: notifications ? Bell : Bell,
      title: 'Bildirimler',
      subtitle: notifications ? 'Açık' : 'Kapalı',
      action: () => setNotifications(!notifications),
      color: 'text-success',
      toggle: true,
      value: notifications
    },
    {
      icon: darkMode ? Moon : Sun,
      title: 'Karanlık Mod',
      subtitle: darkMode ? 'Açık' : 'Kapalı',
      action: () => setDarkMode(!darkMode),
      color: 'text-warning',
      toggle: true,
      value: darkMode
    },
    {
      icon: Shield,
      title: 'Gizlilik Politikası',
      subtitle: 'Veri güvenliği ve gizlilik',
      action: () => window.open('/privacy', '_blank'),
      color: 'text-muted'
    },
    {
      icon: FileText,
      title: 'Kullanım Koşulları',
      subtitle: 'Uygulama kullanım şartları',
      action: () => window.open('/terms', '_blank'),
      color: 'text-muted'
    },
    {
      icon: Star,
      title: 'Uygulamayı Değerlendir',
      subtitle: 'App Store\'da 5 yıldız ver',
      action: () => alert('App Store\'a yönlendiriliyor...'),
      color: 'text-warning'
    },
    {
      icon: Share2,
      title: 'Uygulamayı Paylaş',
      subtitle: 'Arkadaşlarınla paylaş',
      action: () => navigator.share?.({
        title: 'MoneyMate: Currency Converter',
        text: 'En iyi döviz kuru uygulaması!',
        url: window.location.origin,
      }),
      color: 'text-primary'
    },
    {
      icon: MessageCircle,
      title: 'Geri Bildirim Gönder',
      subtitle: 'Önerilerinizi paylaşın',
      action: () => window.open('mailto:support@moneymate.app', '_blank'),
      color: 'text-success'
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-md mx-auto px-6 py-8">
        {/* Page Title */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <h1 className="text-3xl font-bold text-foreground mb-2">
            Hesap & Ayarlar
          </h1>
          <p className="text-muted">
            Uygulamayı kişiselleştirin
          </p>
        </motion.div>

        {/* Profile Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="bg-gradient-to-r from-primary/10 to-primary-dark/10 rounded-3xl p-6 mb-8 border border-primary/20"
        >
          <div className="flex items-center space-x-4">
            <motion.div
              className="w-16 h-16 rounded-full bg-gradient-to-r from-primary to-primary-dark flex items-center justify-center"
              animate={{ rotate: 360 }}
              transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            >
              <span className="text-white text-2xl font-bold">M</span>
            </motion.div>
            <div>
              <h3 className="text-xl font-bold text-foreground">MoneyMate Kullanıcısı</h3>
              <p className="text-muted">Premium özellikler yakında!</p>
            </div>
          </div>
        </motion.div>

        {/* Settings Menu */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="space-y-3"
        >
          {menuItems.map((item, index) => (
            <motion.div
              key={item.title}
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6, delay: 0.1 * index }}
              className="bg-card border border-border rounded-2xl overflow-hidden"
            >
              <motion.button
                onClick={item.action}
                className="w-full p-4 flex items-center justify-between text-left hover:bg-muted/10 transition-colors"
                whileTap={{ scale: 0.98 }}
              >
                <div className="flex items-center space-x-4">
                  <motion.div
                    className={`p-2 rounded-xl bg-muted/10 ${item.color}`}
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    transition={{ duration: 0.2 }}
                  >
                    <item.icon className="w-5 h-5" />
                  </motion.div>
                  <div>
                    <h4 className="font-semibold text-foreground">{item.title}</h4>
                    <p className="text-sm text-muted">{item.subtitle}</p>
                  </div>
                </div>
                
                {item.toggle ? (
                  <motion.div
                    className={`w-12 h-6 rounded-full p-1 transition-colors ${
                      item.value ? 'bg-primary' : 'bg-muted/30'
                    }`}
                    whileTap={{ scale: 0.95 }}
                  >
                    <motion.div
                      className="w-4 h-4 bg-white rounded-full shadow-md"
                      animate={{ x: item.value ? 24 : 0 }}
                      transition={{ duration: 0.2, ease: "easeInOut" }}
                    />
                  </motion.div>
                ) : (
                  <ChevronRight className="w-5 h-5 text-muted" />
                )}
              </motion.button>
            </motion.div>
          ))}
        </motion.div>

        {/* App Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-8 text-center text-sm text-muted"
        >
          <p className="mb-2">MoneyMate Currency Converter</p>
          <p>Versiyon 1.0.0</p>
          <p className="mt-2">© 2024 MoneyMate. Tüm hakları saklıdır.</p>
        </motion.div>

        {/* Premium CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 1 }}
          className="mt-8"
        >
          <HapticButton
            variant="primary"
            className="w-full bg-gradient-to-r from-primary to-primary-dark"
            onClick={() => alert('Premium özellikler yakında!')}
          >
            <div className="flex items-center justify-center space-x-2">
              <Star className="w-5 h-5" />
              <span>Premium'a Yükselt</span>
            </div>
          </HapticButton>
        </motion.div>
      </main>
    </div>
  );
}