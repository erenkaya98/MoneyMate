import { Currency } from './types';
import { currencyAPI } from './api';

export const mockCurrencies: Currency[] = [
  {
    code: 'USD',
    name: 'US Dollar',
    symbol: '$',
    flag: '🇺🇸',
    rate: 1,
    change24h: 0.15,
    trend: 'up'
  },
  {
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flag: '🇪🇺',
    rate: 0.92,
    change24h: -0.08,
    trend: 'down'
  },
  {
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    flag: '🇬🇧',
    rate: 0.79,
    change24h: 0.25,
    trend: 'up'
  },
  {
    code: 'TRY',
    name: 'Turkish Lira',
    symbol: '₺',
    flag: '🇹🇷',
    rate: 32.45,
    change24h: -0.12,
    trend: 'down'
  },
  {
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    flag: '🇯🇵',
    rate: 149.85,
    change24h: 0.05,
    trend: 'stable'
  },
  {
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C$',
    flag: '🇨🇦',
    rate: 1.36,
    change24h: 0.18,
    trend: 'up'
  },
  {
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A$',
    flag: '🇦🇺',
    rate: 1.52,
    change24h: -0.22,
    trend: 'down'
  },
  {
    code: 'CHF',
    name: 'Swiss Franc',
    symbol: 'Fr',
    flag: '🇨🇭',
    rate: 0.89,
    change24h: 0.03,
    trend: 'stable'
  }
];

// Simüle edilmiş anlık kur güncellemeleri
let seedValue = 12345; // Deterministic seed

const deterministicRandom = (): number => {
  seedValue = (seedValue * 9301 + 49297) % 233280;
  return seedValue / 233280;
};

export const generateRandomRate = (baseRate: number): number => {
  const variation = (deterministicRandom() - 0.5) * 0.02; // %1 değişim
  return Number((baseRate * (1 + variation)).toFixed(4));
};

export const generateRandomChange = (): number => {
  return Number(((deterministicRandom() - 0.5) * 2).toFixed(2)); // -1% ile +1% arası
};

export const updateCurrencyRates = (currencies: Currency[]): Currency[] => {
  return currencies.map((currency, index) => {
    const newChange = generateRandomChange();
    return {
      ...currency,
      rate: generateRandomRate(currency.rate),
      change24h: newChange,
      trend: newChange > 0.1 ? 'up' : newChange < -0.1 ? 'down' : 'stable'
    };
  });
};

// Real-time API integration
export const fetchRealTimeCurrencies = async (): Promise<Currency[]> => {
  try {
    const data = await currencyAPI.fetchExchangeRates('USD');
    
    const updatedCurrencies = mockCurrencies.map(currency => {
      if (currency.code === 'USD') {
        const change = generateRandomChange();
        return {
          ...currency,
          rate: 1,
          change24h: change,
          trend: (change > 0.1 ? 'up' : change < -0.1 ? 'down' : 'stable') as 'up' | 'down' | 'stable'
        };
      }
      
      const newRate = data.rates[currency.code] || currency.rate;
      const change = ((newRate - currency.rate) / currency.rate) * 100;
      
      return {
        ...currency,
        rate: newRate,
        change24h: Number(change.toFixed(2)),
        trend: (change > 0.1 ? 'up' : change < -0.1 ? 'down' : 'stable') as 'up' | 'down' | 'stable'
      };
    });
    
    return updatedCurrencies;
  } catch (error) {
    console.error('Failed to fetch real-time rates:', error);
    // Fallback to mock data
    return updateCurrencyRates(mockCurrencies);
  }
};