'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface HapticButtonProps {
  children: ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary' | 'success' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function HapticButton({ 
  children, 
  onClick, 
  variant = 'primary', 
  size = 'md',
  className = '' 
}: HapticButtonProps) {
  
  const handleClick = () => {
    // Simulate haptic feedback with visual feedback
    if (navigator.vibrate) {
      navigator.vibrate(50);
    }
    onClick?.();
  };

  const getVariantClasses = () => {
    switch (variant) {
      case 'primary':
        return 'bg-primary hover:bg-primary-dark text-white';
      case 'secondary':
        return 'bg-muted/20 hover:bg-muted/30 text-muted border border-muted/30';
      case 'success':
        return 'bg-success hover:bg-success/80 text-white';
      case 'danger':
        return 'bg-danger hover:bg-danger/80 text-white';
      default:
        return 'bg-primary hover:bg-primary-dark text-white';
    }
  };

  const getSizeClasses = () => {
    switch (size) {
      case 'sm':
        return 'px-3 py-2 text-sm';
      case 'md':
        return 'px-4 py-3 text-base';
      case 'lg':
        return 'px-6 py-4 text-lg';
      default:
        return 'px-4 py-3 text-base';
    }
  };

  return (
    <motion.button
      onClick={handleClick}
      whileHover={{ scale: 1.05, y: -2 }}
      whileTap={{ 
        scale: 0.95,
        boxShadow: "0 0 20px rgba(59, 130, 246, 0.5)"
      }}
      transition={{ 
        duration: 0.1,
        ease: "easeInOut"
      }}
      className={`
        rounded-xl font-semibold transition-all duration-200
        shadow-lg hover:shadow-xl
        active:shadow-inner
        ${getVariantClasses()}
        ${getSizeClasses()}
        ${className}
      `}
    >
      <motion.div
        initial={{ opacity: 1 }}
        whileTap={{ opacity: 0.8 }}
        transition={{ duration: 0.1 }}
      >
        {children}
      </motion.div>
    </motion.button>
  );
}