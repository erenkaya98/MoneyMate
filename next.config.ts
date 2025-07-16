import type { NextConfig } from "next";
// @ts-ignore - PWA types may not be available
import withPWA from 'next-pwa';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  trailingSlash: true,
  output: 'export',
  compiler: {
    removeConsole: process.env.NODE_ENV === "production",
  },
  experimental: {
    optimizePackageImports: ["framer-motion", "lucide-react"],
  },
};

const pwaConfig = withPWA({
  dest: 'public',
  register: true,
  skipWaiting: true,
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/api\.exchangerate-api\.com\/.*/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'exchange-rates-cache',
        expiration: {
          maxEntries: 10,
          maxAgeSeconds: 5 * 60, // 5 minutes
        },
      },
    },
  ],
});

export default pwaConfig(nextConfig);