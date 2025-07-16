'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { 
  X, 
  Settings, 
  HelpCircle, 
  Share2, 
  Star, 
  Info,
  Moon,
  Sun,
  Globe,
  Bell
} from 'lucide-react';
import { useState } from 'react';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const [darkMode, setDarkMode] = useState(false);

  const menuItems = [
    {
      icon: Settings,
      title: 'Genel Ayarlar',
      subtitle: 'Uygulama tercihleri',
      action: () => console.log('Settings'),
      color: 'text-primary'
    },
    {
      icon: Globe,
      title: 'Dil ve Bölge',
      subtitle: 'Türkçe, Türkiye',
      action: () => console.log('Language'),
      color: 'text-success'
    },
    {
      icon: darkMode ? Moon : Sun,
      title: 'Tema',
      subtitle: darkMode ? 'Karanlık' : 'Açık',
      action: () => setDarkMode(!darkMode),
      color: 'text-warning'
    },
    {
      icon: Bell,
      title: 'Bildirimler',
      subtitle: 'Kur uyarıları ve haberler',
      action: () => console.log('Notifications'),
      color: 'text-blue-500'
    },
    {
      icon: HelpCircle,
      title: 'Yardım ve SSS',
      subtitle: 'Sık sorulan sorular',
      action: () => console.log('Help'),
      color: 'text-purple-500'
    },
    {
      icon: Share2,
      title: 'Uygulamayı Paylaş',
      subtitle: 'Arkadaşlarınla paylaş',
      action: () => navigator.share?.({
        title: 'MoneyMate',
        url: window.location.origin
      }),
      color: 'text-green-500'
    },
    {
      icon: Star,
      title: 'Puan Ver',
      subtitle: 'App Store\'da değerlendir',
      action: () => console.log('Rate'),
      color: 'text-yellow-500'
    },
    {
      icon: Info,
      title: 'Hakkında',
      subtitle: 'Versiyon 1.0.0',
      action: () => console.log('About'),
      color: 'text-gray-500'
    },
  ];

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm"
            onClick={onClose}
          />
          
          {/* Sidebar */}
          <motion.div
            initial={{ x: -300, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            exit={{ x: -300, opacity: 0 }}
            transition={{ 
              duration: 0.4, 
              ease: [0.68, -0.55, 0.265, 1.55] 
            }}
            className="fixed left-0 top-0 bottom-0 z-50 w-80 bg-card border-r border-border shadow-2xl"
          >
            {/* Header */}
            <div className="p-6 border-b border-border bg-gradient-to-r from-primary/10 to-primary-dark/10">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <motion.div
                    className="w-10 h-10 rounded-full bg-gradient-to-r from-primary to-primary-dark flex items-center justify-center"
                    animate={{ rotate: 360 }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                  >
                    <span className="text-white font-bold">₿</span>
                  </motion.div>
                  <div>
                    <h2 className="text-xl font-bold text-foreground">MoneyMate</h2>
                    <p className="text-sm text-muted">Menü & Ayarlar</p>
                  </div>
                </div>
                <motion.button
                  onClick={onClose}
                  className="p-2 rounded-full bg-muted/20 hover:bg-muted/30 transition-colors"
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                >
                  <X className="w-5 h-5 text-muted" />
                </motion.button>
              </div>
            </div>

            {/* Menu Items */}
            <div className="flex-1 overflow-y-auto p-4">
              <div className="space-y-2">
                {menuItems.map((item, index) => (
                  <motion.button
                    key={item.title}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1, duration: 0.3 }}
                    onClick={item.action}
                    className="w-full p-4 rounded-2xl text-left hover:bg-muted/10 transition-all group"
                    whileHover={{ scale: 1.02, x: 5 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    <div className="flex items-center space-x-4">
                      <motion.div
                        className={`p-3 rounded-xl bg-muted/10 ${item.color} group-hover:scale-110 transition-transform`}
                        whileHover={{ rotate: 5 }}
                      >
                        <item.icon className="w-5 h-5" />
                      </motion.div>
                      <div className="flex-1">
                        <h3 className="font-semibold text-foreground group-hover:text-primary transition-colors">
                          {item.title}
                        </h3>
                        <p className="text-sm text-muted">{item.subtitle}</p>
                      </div>
                    </div>
                  </motion.button>
                ))}
              </div>
            </div>

            {/* Footer */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8, duration: 0.3 }}
              className="p-6 border-t border-border bg-muted/5"
            >
              <div className="text-center text-sm text-muted">
                <p className="mb-1">MoneyMate v1.0.0</p>
                <p>© 2024 Tüm hakları saklıdır</p>
              </div>
            </motion.div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}