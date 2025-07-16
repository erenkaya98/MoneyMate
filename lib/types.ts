export interface Currency {
  code: string;
  name: string;
  symbol: string;
  flag: string;
  rate: number;
  change24h: number;
  trend: 'up' | 'down' | 'stable';
}

export interface CurrencyPair {
  from: Currency;
  to: Currency;
  rate: number;
}

export interface AnimationConfig {
  duration: number;
  easing: string;
  delay?: number;
}