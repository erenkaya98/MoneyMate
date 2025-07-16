'use client';

import { motion } from 'framer-motion';
import { RefreshCw, Settings, Plus, Menu } from 'lucide-react';
import { useState, useEffect } from 'react';

interface HeaderProps {
  onRefresh?: () => void;
  isRefreshing?: boolean;
  onMenuClick?: () => void;
}

export function Header({ onRefresh, isRefreshing = false, onMenuClick }: HeaderProps) {
  const [countdown, setCountdown] = useState(60);

  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          onRefresh?.();
          return 60;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [onRefresh]);

  return (
    <motion.header
      initial={{ opacity: 0, y: -50 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="sticky top-0 z-50 bg-background/80 backdrop-blur-lg border-b border-border/50 px-6 py-4"
    >
      <div className="flex items-center justify-between max-w-7xl mx-auto">
        {/* Left side - Menu and Logo */}
        <div className="flex items-center space-x-4">
          {/* Hamburger Menu */}
          <motion.button
            onClick={onMenuClick}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="p-2 rounded-full bg-muted/10 hover:bg-muted/20 text-muted transition-colors"
          >
            <Menu className="w-5 h-5" />
          </motion.button>

          {/* Logo */}
          <motion.div
            className="flex items-center space-x-3"
            whileHover={{ scale: 1.05 }}
            transition={{ duration: 0.2 }}
          >
            <motion.div
              className="w-8 h-8 rounded-full bg-gradient-to-r from-primary to-primary-dark flex items-center justify-center"
              animate={{ rotate: 360 }}
              transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            >
              <span className="text-white font-bold text-sm">₿</span>
            </motion.div>
            <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-primary-dark bg-clip-text text-transparent">
              MoneyMate
            </h1>
          </motion.div>
        </div>

        {/* Right side - Controls */}
        <div className="flex items-center space-x-3">
          {/* Add Currency Button */}
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="p-2 rounded-full bg-primary/10 hover:bg-primary/20 text-primary transition-colors"
          >
            <Plus className="w-5 h-5" />
          </motion.button>

          {/* Refresh Button */}
          <motion.button
            onClick={onRefresh}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="p-2 rounded-full bg-success/10 hover:bg-success/20 text-success transition-colors"
          >
            <motion.div
              animate={isRefreshing ? { rotate: 360 } : {}}
              transition={{ duration: 1, repeat: isRefreshing ? Infinity : 0, ease: "linear" }}
            >
              <RefreshCw className="w-5 h-5" />
            </motion.div>
          </motion.button>

          {/* Countdown Timer */}
          <motion.div
            className="relative"
            whileHover={{ scale: 1.05 }}
          >
            <motion.div
              className="w-12 h-12 rounded-full border-2 border-muted/30 flex items-center justify-center"
              animate={{ borderColor: countdown <= 10 ? '#ef4444' : '#64748b' }}
            >
              <span className={`text-sm font-mono font-bold ${countdown <= 10 ? 'text-danger' : 'text-muted'}`}>
                {countdown}
              </span>
            </motion.div>
            <motion.div
              className="absolute inset-0 rounded-full border-2 border-primary"
              style={{
                clipPath: `polygon(50% 0%, 50% 50%, ${50 + 50 * Math.cos(2 * Math.PI * (60 - countdown) / 60 - Math.PI / 2)}% ${50 + 50 * Math.sin(2 * Math.PI * (60 - countdown) / 60 - Math.PI / 2)}%, 50% 50%)`
              }}
              animate={{
                opacity: [0.5, 1, 0.5]
              }}
              transition={{
                duration: 1,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
          </motion.div>
        </div>
      </div>
    </motion.header>
  );
}