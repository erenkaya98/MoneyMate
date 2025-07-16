'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowUpDown, Star, Zap } from 'lucide-react';
import { Header } from '@/components/ui/header';
import { HapticButton } from '@/components/ui/haptic-button';
import { mockCurrencies } from '@/lib/mock-data';
import { Currency } from '@/lib/types';

export default function ConverterPage() {
  const [amount, setAmount] = useState<string>('100');
  const [fromCurrency, setFromCurrency] = useState<Currency>(mockCurrencies[0]); // USD
  const [toCurrency, setToCurrency] = useState<Currency>(mockCurrencies[3]); // TRY
  const [result, setResult] = useState<number>(0);
  const [favorites, setFavorites] = useState<string[]>([]);

  useEffect(() => {
    if (amount && fromCurrency && toCurrency) {
      const numAmount = parseFloat(amount) || 0;
      const convertedAmount = (numAmount / fromCurrency.rate) * toCurrency.rate;
      setResult(convertedAmount);
    }
  }, [amount, fromCurrency, toCurrency]);

  const swapCurrencies = () => {
    setFromCurrency(toCurrency);
    setToCurrency(fromCurrency);
  };

  const addToFavorites = () => {
    const pairKey = `${fromCurrency.code}-${toCurrency.code}`;
    if (!favorites.includes(pairKey)) {
      setFavorites([...favorites, pairKey]);
    }
  };

  const quickAmounts = [10, 50, 100, 500, 1000];

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
            Döviz Dönüştürücü
          </h1>
          <p className="text-muted">
            Anlık kurlarla hızlı dönüşüm yapın
          </p>
        </motion.div>

        {/* Amount Input */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="mb-6"
        >
          <label className="block text-sm font-medium text-muted mb-2">
            Miktar
          </label>
          <motion.input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full text-3xl font-bold bg-card border border-border rounded-2xl px-6 py-4 text-center focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all"
            placeholder="0"
            whileFocus={{ scale: 1.02 }}
          />
        </motion.div>

        {/* Quick Amount Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="flex justify-center gap-2 mb-8"
        >
          {quickAmounts.map((quickAmount) => (
            <motion.button
              key={quickAmount}
              onClick={() => setAmount(quickAmount.toString())}
              className="px-3 py-1 text-sm bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-colors"
              whileTap={{ scale: 0.95 }}
            >
              {quickAmount}
            </motion.button>
          ))}
        </motion.div>

        {/* Currency Selection */}
        <div className="space-y-4 mb-8">
          {/* From Currency */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="bg-card border border-border rounded-2xl p-6"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <span className="text-3xl">{fromCurrency.flag}</span>
                <div>
                  <h3 className="font-bold text-lg">{fromCurrency.code}</h3>
                  <p className="text-sm text-muted">{fromCurrency.name}</p>
                </div>
              </div>
              <div className="text-right">
                <p className="text-lg font-bold">{amount || '0'}</p>
                <p className="text-sm text-muted">{fromCurrency.symbol}</p>
              </div>
            </div>
          </motion.div>

          {/* Swap Button */}
          <motion.div
            className="flex justify-center"
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            <motion.button
              onClick={swapCurrencies}
              className="p-3 bg-primary text-white rounded-full shadow-lg"
              whileHover={{ scale: 1.1, rotate: 180 }}
              whileTap={{ scale: 0.9 }}
              transition={{ duration: 0.3 }}
            >
              <ArrowUpDown className="w-6 h-6" />
            </motion.button>
          </motion.div>

          {/* To Currency */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="bg-card border border-border rounded-2xl p-6"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <span className="text-3xl">{toCurrency.flag}</span>
                <div>
                  <h3 className="font-bold text-lg">{toCurrency.code}</h3>
                  <p className="text-sm text-muted">{toCurrency.name}</p>
                </div>
              </div>
              <div className="text-right">
                <motion.p
                  key={result}
                  initial={{ scale: 1.2, color: '#10b981' }}
                  animate={{ scale: 1, color: 'inherit' }}
                  transition={{ duration: 0.3 }}
                  className="text-lg font-bold"
                >
                  {result.toFixed(2)}
                </motion.p>
                <p className="text-sm text-muted">{toCurrency.symbol}</p>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Action Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="space-y-4"
        >
          <HapticButton
            onClick={addToFavorites}
            variant="secondary"
            className="w-full flex items-center justify-center space-x-2"
          >
            <Star className="w-5 h-5" />
            <span>Favorilere Ekle</span>
          </HapticButton>

          <HapticButton
            onClick={() => navigator.share?.({
              title: 'MoneyMate Dönüşüm',
              text: `${amount} ${fromCurrency.code} = ${result.toFixed(2)} ${toCurrency.code}`,
            })}
            variant="primary"
            className="w-full flex items-center justify-center space-x-2"
          >
            <Zap className="w-5 h-5" />
            <span>Sonucu Paylaş</span>
          </HapticButton>
        </motion.div>

        {/* Exchange Rate Info */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="mt-8 text-center text-sm text-muted"
        >
          <p>
            1 {fromCurrency.code} = {(toCurrency.rate / fromCurrency.rate).toFixed(4)} {toCurrency.code}
          </p>
          <p className="mt-1">
            Kurlar anlık olarak güncellenmektedir
          </p>
        </motion.div>
      </main>
    </div>
  );
}