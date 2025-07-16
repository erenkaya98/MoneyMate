'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js';
import { Header } from '@/components/ui/header';
import { mockCurrencies } from '@/lib/mock-data';
import { Currency } from '@/lib/types';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function ChartsPage() {
  const [selectedCurrency, setSelectedCurrency] = useState<Currency>(mockCurrencies[0]);
  const [timeRange, setTimeRange] = useState<string>('1d');
  const [chartData, setChartData] = useState<any>(null);

  const timeRanges = [
    { key: '1h', label: '1s', name: '1 Saat' },
    { key: '4h', label: '4s', name: '4 Saat' },
    { key: '1d', label: '1g', name: '1 Gün' },
    { key: '1w', label: '1h', name: '1 Hafta' },
    { key: '1m', label: '1a', name: '1 Ay' },
    { key: '1y', label: '1y', name: '1 Yıl' },
  ];

  useEffect(() => {
    // Generate mock chart data
    const generateMockData = () => {
      const baseRate = selectedCurrency.rate;
      const dataPoints = timeRange === '1h' ? 60 : timeRange === '4h' ? 48 : 
                        timeRange === '1d' ? 24 : timeRange === '1w' ? 7 :
                        timeRange === '1m' ? 30 : 12;
      
      const labels = [];
      const data = [];
      
      for (let i = 0; i < dataPoints; i++) {
        if (timeRange === '1h') {
          labels.push(`${String(23 - Math.floor(i / 60)).padStart(2, '0')}:${String(59 - (i % 60)).padStart(2, '0')}`);
        } else if (timeRange === '4h') {
          labels.push(`${String(23 - Math.floor(i / 12)).padStart(2, '0')}:${String((5 - (i % 12)) * 10).padStart(2, '0')}`);
        } else if (timeRange === '1d') {
          labels.push(`${String(i).padStart(2, '0')}:00`);
        } else if (timeRange === '1w') {
          const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
          labels.push(days[i % 7]);
        } else if (timeRange === '1m') {
          labels.push(`${i + 1}`);
        } else {
          const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
          labels.push(months[i]);
        }
        
        // Generate realistic price movement
        const variation = (Math.sin(i * 0.5) + Math.random() * 0.4 - 0.2) * 0.02;
        data.push(baseRate * (1 + variation));
      }
      
      return {
        labels,
        datasets: [
          {
            label: `${selectedCurrency.code}/TRY`,
            data,
            borderColor: selectedCurrency.trend === 'up' ? '#10b981' : 
                        selectedCurrency.trend === 'down' ? '#ef4444' : '#3b82f6',
            backgroundColor: (selectedCurrency.trend === 'up' ? '#10b981' : 
                            selectedCurrency.trend === 'down' ? '#ef4444' : '#3b82f6') + '20',
            borderWidth: 3,
            fill: true,
            tension: 0.4,
            pointBackgroundColor: selectedCurrency.trend === 'up' ? '#10b981' : 
                                 selectedCurrency.trend === 'down' ? '#ef4444' : '#3b82f6',
            pointBorderColor: '#ffffff',
            pointBorderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 8,
          },
        ],
      };
    };

    setChartData(generateMockData());
  }, [selectedCurrency, timeRange]);

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        mode: 'index' as const,
        intersect: false,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        titleColor: '#ffffff',
        bodyColor: '#ffffff',
        borderColor: '#3b82f6',
        borderWidth: 1,
        cornerRadius: 8,
        displayColors: false,
        callbacks: {
          title: (context: any) => {
            return context[0].label;
          },
          label: (context: any) => {
            return `${selectedCurrency.code}/TRY: ${context.parsed.y.toFixed(4)}`;
          },
        },
      },
    },
    scales: {
      x: {
        display: true,
        grid: {
          color: 'rgba(148, 163, 184, 0.1)',
        },
        ticks: {
          color: '#64748b',
          maxTicksLimit: 6,
        },
      },
      y: {
        display: true,
        grid: {
          color: 'rgba(148, 163, 184, 0.1)',
        },
        ticks: {
          color: '#64748b',
          callback: function(value: any) {
            return value.toFixed(4);
          },
        },
      },
    },
    interaction: {
      mode: 'nearest' as const,
      axis: 'x' as const,
      intersect: false,
    },
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Page Title */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <h1 className="text-3xl font-bold text-foreground mb-2">
            Kur Grafikleri
          </h1>
          <p className="text-muted">
            Detaylı analiz ve trend takibi
          </p>
        </motion.div>

        {/* Currency Selector */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="mb-6"
        >
          <div className="flex gap-3 overflow-x-auto pb-2">
            {mockCurrencies.slice(0, 6).map((currency) => (
              <motion.button
                key={currency.code}
                onClick={() => setSelectedCurrency(currency)}
                className={`flex items-center space-x-2 px-4 py-2 rounded-xl whitespace-nowrap transition-all ${
                  selectedCurrency.code === currency.code
                    ? 'bg-primary text-white shadow-lg'
                    : 'bg-card border border-border hover:bg-muted/10'
                }`}
                whileTap={{ scale: 0.95 }}
              >
                <span className="text-lg">{currency.flag}</span>
                <span className="font-medium">{currency.code}</span>
              </motion.button>
            ))}
          </div>
        </motion.div>

        {/* Chart Container */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="bg-card border border-border rounded-3xl p-6 mb-6"
        >
          {/* Chart Header */}
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-3">
              <span className="text-2xl">{selectedCurrency.flag}</span>
              <div>
                <h3 className="text-xl font-bold">{selectedCurrency.code}/TRY</h3>
                <p className="text-sm text-muted">{selectedCurrency.name}</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-2xl font-bold">
                {selectedCurrency.rate.toFixed(4)}
              </p>
              <p className={`text-sm font-medium ${
                selectedCurrency.trend === 'up' ? 'text-success' : 
                selectedCurrency.trend === 'down' ? 'text-danger' : 'text-muted'
              }`}>
                {selectedCurrency.change24h > 0 ? '+' : ''}{selectedCurrency.change24h.toFixed(2)}%
              </p>
            </div>
          </div>

          {/* Chart */}
          <div className="h-80">
            {chartData && (
              <Line data={chartData} options={chartOptions} />
            )}
          </div>
        </motion.div>

        {/* Time Range Selector */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="flex justify-center gap-2 mb-8"
        >
          {timeRanges.map((range) => (
            <motion.button
              key={range.key}
              onClick={() => setTimeRange(range.key)}
              className={`px-4 py-2 rounded-xl font-medium transition-all ${
                timeRange === range.key
                  ? 'bg-primary text-white shadow-lg'
                  : 'bg-card border border-border hover:bg-muted/10'
              }`}
              whileTap={{ scale: 0.95 }}
              title={range.name}
            >
              {range.label}
            </motion.button>
          ))}
        </motion.div>

        {/* Stats Grid */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4"
        >
          {[
            { label: 'En Yüksek', value: (selectedCurrency.rate * 1.02).toFixed(4), color: 'text-success' },
            { label: 'En Düşük', value: (selectedCurrency.rate * 0.98).toFixed(4), color: 'text-danger' },
            { label: 'Ortalama', value: selectedCurrency.rate.toFixed(4), color: 'text-muted' },
            { label: 'Volatilite', value: '%1.2', color: 'text-warning' },
          ].map((stat, index) => (
            <motion.div
              key={stat.label}
              className="bg-card border border-border rounded-2xl p-4 text-center"
              whileHover={{ scale: 1.02 }}
              transition={{ duration: 0.2 }}
            >
              <p className="text-sm text-muted mb-1">{stat.label}</p>
              <p className={`text-lg font-bold ${stat.color}`}>{stat.value}</p>
            </motion.div>
          ))}
        </motion.div>
      </main>
    </div>
  );
}