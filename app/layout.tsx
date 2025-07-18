import type { Metadata, Viewport } from "next";
import { BottomNavigation } from "@/components/layout/bottom-navigation";
import "./globals.css";

// Fallback to system fonts for now
const geistSans = {
  variable: "--font-geist-sans",
};

const geistMono = {
  variable: "--font-geist-mono",
};

export const metadata: Metadata = {
  title: "MoneyMate: Currency Converter",
  description: "Track real-time exchange rates with beautiful animations",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "MoneyMate",
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/icons/icon-192x192.png",
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#3b82f6",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr">
      <head>
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="MoneyMate" />
        <link rel="apple-touch-icon" href="/icons/icon-192x192.png" />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased pb-20`}
      >
        {children}
        <BottomNavigation />
      </body>
    </html>
  );
}