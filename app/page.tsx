'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Header } from '@/components/ui/header';
import { CurrencyCard } from '@/components/ui/currency-card';
import { FloatingElements } from '@/components/ui/floating-elements';
import { HapticButton } from '@/components/ui/haptic-button';
import { Sidebar } from '@/components/layout/sidebar';
import { mockCurrencies, updateCurrencyRates, fetchRealTimeCurrencies } from '@/lib/mock-data';
import { Currency } from '@/lib/types';

export default function Home() {
  const [currencies, setCurrencies] = useState<Currency[]>(mockCurrencies);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    
    try {
      // Try to fetch real-time data
      const updatedCurrencies = await fetchRealTimeCurrencies();
      setCurrencies(updatedCurrencies);
    } catch (error) {
      console.error('Failed to refresh rates:', error);
      // Fallback to mock update
      setCurrencies(updateCurrencyRates(currencies));
    }
    
    setIsRefreshing(false);
  };

  const handleCurrencyClick = (currency: Currency) => {
    console.log('Currency clicked:', currency.code);
    // Future: Navigate to detailed view
  };

  return (
    <div className="min-h-screen bg-background relative">
      <FloatingElements count={8} />
      <Header 
        onRefresh={handleRefresh} 
        isRefreshing={isRefreshing}
        onMenuClick={() => setSidebarOpen(true)}
      />
      <Sidebar 
        isOpen={sidebarOpen} 
        onClose={() => setSidebarOpen(false)} 
      />
      
      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Welcome Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mb-8"
        >
          <h2 className="text-3xl font-bold text-foreground mb-2">
            Live Currency Rates
          </h2>
          <p className="text-muted text-lg">
            Track real-time exchange rates with beautiful animations
          </p>
        </motion.div>

        {/* Currency Grid */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
        >
          {currencies.map((currency, index) => (
            <CurrencyCard
              key={currency.code}
              currency={currency}
              index={index}
              onClick={() => handleCurrencyClick(currency)}
            />
          ))}
        </motion.div>

        {/* Floating Action Hints */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 1.2 }}
          className="mt-12 text-center"
        >
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="inline-flex items-center space-x-2 text-muted"
          >
            <span>✨</span>
            <span className="text-sm">Click on any currency for detailed charts</span>
            <span>📈</span>
          </motion.div>
        </motion.div>

        {/* Stats Section */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 1.4 }}
          className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-6"
        >
          <div className="glass rounded-2xl p-6 text-center">
            <motion.div
              className="text-3xl font-bold text-success mb-2"
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            >
              {currencies.filter(c => c.trend === 'up').length}
            </motion.div>
            <p className="text-muted">Currencies Up</p>
          </div>
          
          <div className="glass rounded-2xl p-6 text-center">
            <motion.div
              className="text-3xl font-bold text-danger mb-2"
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
            >
              {currencies.filter(c => c.trend === 'down').length}
            </motion.div>
            <p className="text-muted">Currencies Down</p>
          </div>
          
          <div className="glass rounded-2xl p-6 text-center">
            <motion.div
              className="text-3xl font-bold text-primary mb-2"
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut", delay: 1 }}
            >
              {currencies.length}
            </motion.div>
            <p className="text-muted">Total Tracked</p>
          </div>
        </motion.div>

        {/* Interactive Demo Section */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 1.6 }}
          className="mt-16 text-center"
        >
          <h3 className="text-2xl font-bold text-foreground mb-6">Experience the Magic</h3>
          <div className="flex flex-wrap justify-center gap-4">
            <HapticButton 
              variant="primary" 
              onClick={() => handleRefresh()}
              className="animate-pulse-glow"
            >
              🔄 Refresh Rates
            </HapticButton>
            <HapticButton 
              variant="success" 
              onClick={() => alert('Coming soon: Add your favorite currencies!')}
            >
              ⭐ Add Favorite
            </HapticButton>
            <HapticButton 
              variant="secondary" 
              onClick={() => alert('Coming soon: Dark mode toggle!')}
            >
              🌙 Toggle Theme
            </HapticButton>
          </div>
        </motion.div>
      </main>
    </div>
  );
}