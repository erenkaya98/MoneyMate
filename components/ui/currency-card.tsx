'use client';

import { motion } from 'framer-motion';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { Currency } from '@/lib/types';

interface CurrencyCardProps {
  currency: Currency;
  index: number;
  onClick?: () => void;
}

export function CurrencyCard({ currency, index, onClick }: CurrencyCardProps) {
  const getTrendIcon = () => {
    switch (currency.trend) {
      case 'up':
        return <TrendingUp className="w-4 h-4 text-success" />;
      case 'down':
        return <TrendingDown className="w-4 h-4 text-danger" />;
      default:
        return <Minus className="w-4 h-4 text-muted" />;
    }
  };

  const getTrendColor = () => {
    switch (currency.trend) {
      case 'up':
        return 'text-success';
      case 'down':
        return 'text-danger';
      default:
        return 'text-muted';
    }
  };

  const getCardGradient = () => {
    const gradients = [
      'from-blue-500/10 to-purple-500/10',
      'from-green-500/10 to-teal-500/10',
      'from-orange-500/10 to-red-500/10',
      'from-purple-500/10 to-pink-500/10',
      'from-teal-500/10 to-blue-500/10',
      'from-red-500/10 to-orange-500/10',
      'from-pink-500/10 to-purple-500/10',
      'from-indigo-500/10 to-blue-500/10',
    ];
    return gradients[index % gradients.length];
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 50, scale: 0.9 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{
        duration: 0.5,
        delay: index * 0.1,
        ease: [0.68, -0.55, 0.265, 1.55]
      }}
      whileHover={{
        scale: 1.02,
        y: -5,
        transition: { duration: 0.2 }
      }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className={`
        relative overflow-hidden rounded-2xl p-6 cursor-pointer
        bg-gradient-to-br ${getCardGradient()}
        border border-border/50
        shadow-lg hover:shadow-xl
        backdrop-blur-sm
        group
      `}
    >
      {/* Animated background circles */}
      <motion.div
        className="absolute -top-8 -right-8 w-16 h-16 rounded-full bg-primary/10"
        animate={{
          scale: [1, 1.2, 1],
          rotate: [0, 180, 360],
        }}
        transition={{
          duration: 20,
          repeat: Infinity,
          ease: "linear"
        }}
      />
      <motion.div
        className="absolute -bottom-6 -left-6 w-12 h-12 rounded-full bg-primary/5"
        animate={{
          scale: [1.2, 1, 1.2],
          rotate: [360, 180, 0],
        }}
        transition={{
          duration: 15,
          repeat: Infinity,
          ease: "linear"
        }}
      />

      {/* Content */}
      <div className="relative z-10">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3">
            <motion.span
              className="text-3xl"
              animate={{ rotate: [0, 10, -10, 0] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            >
              {currency.flag}
            </motion.span>
            <div>
              <h3 className="font-bold text-lg text-foreground">{currency.code}</h3>
              <p className="text-sm text-muted font-medium">{currency.name}</p>
            </div>
          </div>
          <motion.div
            className="flex items-center space-x-1"
            animate={currency.trend !== 'stable' ? { y: [0, -2, 0] } : {}}
            transition={{ duration: 1, repeat: Infinity, ease: "easeInOut" }}
          >
            {getTrendIcon()}
          </motion.div>
        </div>

        {/* Rate */}
        <div className="mb-3">
          <motion.div
            className="text-2xl font-bold text-foreground"
            key={currency.rate}
            initial={{ scale: 1.1, color: currency.trend === 'up' ? '#10b981' : currency.trend === 'down' ? '#ef4444' : '#64748b' }}
            animate={{ scale: 1, color: 'inherit' }}
            transition={{ duration: 0.3 }}
          >
            {currency.symbol}{currency.rate.toFixed(4)}
          </motion.div>
        </div>

        {/* Change */}
        <motion.div
          className={`text-sm font-semibold ${getTrendColor()}`}
          animate={currency.trend !== 'stable' ? { opacity: [0.7, 1, 0.7] } : {}}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        >
          {currency.change24h > 0 ? '+' : ''}{currency.change24h.toFixed(2)}%
          <span className="text-muted ml-1">24h</span>
        </motion.div>
      </div>

      {/* Hover effect */}
      <motion.div
        className="absolute inset-0 bg-gradient-to-r from-primary/5 to-transparent opacity-0 group-hover:opacity-100"
        transition={{ duration: 0.3 }}
      />
    </motion.div>
  );
}