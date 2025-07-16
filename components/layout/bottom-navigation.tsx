'use client';

import { motion } from 'framer-motion';
import { Home, ArrowLeftRight, TrendingUp, User } from 'lucide-react';
import { usePathname } from 'next/navigation';
import Link from 'next/link';

const navItems = [
  { 
    href: '/', 
    icon: Home, 
    label: 'Kurlar',
    color: 'text-primary'
  },
  { 
    href: '/converter', 
    icon: ArrowLeftRight, 
    label: 'Dönüştürücü',
    color: 'text-success'
  },
  { 
    href: '/charts', 
    icon: TrendingUp, 
    label: 'Grafikler',
    color: 'text-warning'
  },
  { 
    href: '/account', 
    icon: User, 
    label: 'Hesap',
    color: 'text-muted'
  },
];

export function BottomNavigation() {
  const pathname = usePathname();

  return (
    <motion.nav
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="fixed bottom-0 left-0 right-0 z-50 bg-card/95 backdrop-blur-lg border-t border-border/50"
    >
      <div className="flex items-center justify-around px-6 py-3 max-w-md mx-auto">
        {navItems.map((item, index) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          
          return (
            <Link key={item.href} href={item.href}>
              <motion.div
                className="relative flex flex-col items-center space-y-1 p-2"
                whileTap={{ scale: 0.9 }}
                whileHover={{ scale: 1.1 }}
                transition={{ duration: 0.1 }}
              >
                {/* Active indicator */}
                {isActive && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute -top-1 w-8 h-1 bg-primary rounded-full"
                    transition={{ duration: 0.3, ease: "easeInOut" }}
                  />
                )}
                
                {/* Icon */}
                <motion.div
                  className={`p-2 rounded-xl ${isActive ? 'bg-primary/10' : 'bg-transparent'}`}
                  animate={{
                    scale: isActive ? 1.1 : 1,
                    rotate: isActive ? [0, 5, -5, 0] : 0
                  }}
                  transition={{ duration: 0.3 }}
                >
                  <Icon 
                    className={`w-5 h-5 ${isActive ? 'text-primary' : 'text-muted'}`}
                  />
                </motion.div>
                
                {/* Label */}
                <motion.span
                  className={`text-xs font-medium ${isActive ? 'text-primary' : 'text-muted'}`}
                  animate={{
                    fontWeight: isActive ? 600 : 400,
                    scale: isActive ? 1.05 : 1
                  }}
                  transition={{ duration: 0.2 }}
                >
                  {item.label}
                </motion.span>
                
                {/* Haptic feedback simulation */}
                <motion.div
                  className="absolute inset-0 rounded-xl"
                  whileTap={{
                    backgroundColor: "rgba(59, 130, 246, 0.1)",
                    scale: 0.95
                  }}
                  transition={{ duration: 0.1 }}
                />
              </motion.div>
            </Link>
          );
        })}
      </div>
    </motion.nav>
  );
}