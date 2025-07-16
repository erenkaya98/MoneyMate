'use client';

import { motion } from 'framer-motion';
import { useEffect, useState } from 'react';

interface FloatingElementsProps {
  count?: number;
}

export function FloatingElements({ count = 6 }: FloatingElementsProps) {
  const [isClient, setIsClient] = useState(false);
  const [elements, setElements] = useState<Array<{ id: number; symbol: string; delay: number; duration: number; x: number; y: number }>>([]);

  useEffect(() => {
    setIsClient(true);
    
    const symbols = ['💰', '💎', '💸', '💵', '💶', '💷', '💴', '₿', '🪙', '💳'];
    const newElements = Array.from({ length: count }, (_, i) => ({
      id: i,
      symbol: symbols[i % symbols.length], // Deterministic symbol selection
      delay: i * 0.8, // Deterministic delay
      duration: 15 + (i % 5) * 2, // Deterministic duration
      x: (i * 150) % window.innerWidth, // Deterministic x position
      y: window.innerHeight + 50
    }));
    setElements(newElements);
  }, [count]);

  if (!isClient) {
    return null; // Don't render on server
  }

  return (
    <div className="fixed inset-0 pointer-events-none overflow-hidden z-0">
      {elements.map((element) => (
        <motion.div
          key={element.id}
          className="absolute text-2xl opacity-10"
          initial={{
            x: element.x,
            y: element.y,
            rotate: 0,
            scale: 0.5
          }}
          animate={{
            y: -100,
            rotate: 360,
            scale: [0.5, 1, 0.5],
            x: element.x + (element.id % 2 === 0 ? 100 : -100)
          }}
          transition={{
            duration: element.duration,
            delay: element.delay,
            repeat: Infinity,
            ease: "linear"
          }}
        >
          {element.symbol}
        </motion.div>
      ))}
    </div>
  );
}