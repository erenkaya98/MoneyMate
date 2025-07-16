import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  trailingSlash: true,
  output: 'export',
  distDir: 'out',
  basePath: '/MoneyMate',
  assetPrefix: '/MoneyMate',
  images: {
    unoptimized: true,
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === "production",
  },
  experimental: {
    optimizePackageImports: ["framer-motion", "lucide-react"],
  },
};

export default nextConfig;