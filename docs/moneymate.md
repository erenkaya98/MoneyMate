# MoneyMate: Currency Converter App - Ürün Gereksinimleri Belgesi (PRD)

---

## 1. Giriş

### 1.1 Amaç
Bu belge, iOS platformu için geliştirilecek olan **"MoneyMate: Currency Converter App"** mobil uygulamasının ürün gereksinimlerini ve kapsamını tanımlar. Uygulamanın temel amacı, kullanıcılara anlık ve kişiselleştirilebilir döviz kurlarını sunmak, farklı para birimleri arasında kolayca dönüşüm yapma imkanı sağlamak ve detaylı grafiklerle finansal takibi basitleştirmektir.

### 1.2 Hedef Kitle
* Finansla uğraşanlar ve günlük/anlık kur takibi yapanlar.
* Ticaretle ilgilenenler (trader'lar) ve döviz hareketlerini analiz edenler.
* Anlık döviz kurlarını merak eden geniş kullanıcı kitlesi.
* Uluslararası seyahat edenler ve yurt dışı işlemleri olan bireyler.

### 1.3 Başarı Metrikleri
* **Aylık Tekrarlayan Gelir (MRR):** $1,000 hedefi.
* App Store'da yüksek kullanıcı yorumları ve puanları (hedeflenen ortalama 4.5+ yıldız).
* Belirlenen süre içinde hedeflenen uygulama indirme sayısına ve aylık aktif kullanıcı sayısına ulaşmak.
* Uygulama içi reklam gösterim ve tıklanma oranları.

---

## 2. Ürün Tanımı

**MoneyMate**, kullanıcıların güncel döviz kurlarını anlık olarak takip etmelerini ve farklı para birimleri arasında hızlı ve kolay dönüşümler yapmalarını sağlayan, modern ve kullanıcı dostu bir iOS mobil uygulamasıdır. Uygulama, sezgisel bir kullanıcı arayüzü, kişiselleştirilebilir özellikler ve detaylı grafiksel analiz araçları sunarak kullanıcıların finansal işlemlerini akıllıca yönetmelerine yardımcı olmayı hedefler. Reklam destekli gelir modeliyle başlayacak ve potansiyel olarak abonelik modeline geçiş yapabilecektir.

---

## 3. Özellikler ve Kullanıcı Akışları

### 3.1 Ana Ekran: Güncel Kurlar (Home/Current Rates Screen)

* **Ekran Başlığı:** Ekranın üst ortasında **"MoneyMate"** başlığı yer alacaktır.
* **Üst Kısım (Navigation Bar):**
    * **Sol Üst Köşe:** Bir **hamburger menü ikonu** bulunacaktır. Bu menüye tıklandığında, uygulama ayarları, yardım, gizlilik politikası gibi ek seçeneklere erişim sağlanacaktır.
    * **Sağ Üst Köşe:** İki önemli öğeyi barındıracaktır:
        * **"Para Birimi Ekle/Yönet" Butonu:** Bir **artı ikonu (+) veya kalem ikonu** ile temsil edilecek ve "Para Birimi Yönetimi" ekranına geçiş sağlayacaktır.
        * **Dinamik Güncelleme Sayacı:** Yuvarlak bir daire içinde, kur verilerinin bir sonraki otomatik güncellemelerine kalan süreyi **1 dakikadan geriye doğru sayan (countdown)** bir sayaç olacaktır (örn: "0:58"). Sayaç sıfırlandığında kurlar güncellenecek ve sayaç yeniden başlayacaktır.
* **Orta Kısım: Kur Listesi (Ana Bölüm):**
    * Her bir para birimi için ayrı, net ve okunaklı satırlar görüntülenecektir. Varsayılan olarak **USD, EUR, GBP, TRY** kurları listelenecektir.
    * Her satırda şu bilgiler yer alacaktır:
        * **Para Birimi Kodu:** (Örn: USD, EUR) - Belirgin bir fontta.
        * **Para Birimi Adı:** (Örn: Amerikan Doları, Euro) - Daha küçük bir fontta.
        * **Güncel Kur:** (Örn: 1 USD = **32.50 TRY**) - Büyük ve okunabilir bir fontta.
        * **24 Saatlik Değişim:** Yüzdesel (%) değişim değeri (örn: **+0.25%** veya **-0.10%**) ve yanında değişim yönünü gösteren bir **ok ikonu** (yukarı yeşil ▲ veya aşağı kırmızı ▼) ile gösterilecektir.
    * Liste **akıcı bir şekilde kaydırılabilir** olacaktır.
    * Listeyi aşağı çekerek (pull-to-refresh) **manuel güncelleme** imkanı sunulacaktır.
    * Herhangi bir para birimi satırına **tıklanıldığında**, ilgili para biriminin **detaylı grafik ekranına** geçiş yapılacaktır.
* **Alt Kısım (Bottom Navigation Bar):** Kullanıcıların ana bölümler arasında kolayca geçiş yapmasını sağlayacak ve aşağıdaki 4 ana bölüm için uygun ikonlar içerecektir:
    * **"Kurlar"** (Ana Ekran)
    * **"Dönüştürücü"**
    * **"Grafikler"**
    * **"Hesap"**

### 3.2 Döviz Dönüştürme Ekranı (Converter Screen)

* **Ekran Başlığı:** Ekranın üst ortasında **"Dönüştür"** başlığı yer alacaktır.
* **Dönüşüm Bölümü:**
    * **Giriş Miktarı Alanı:** Kullanıcının dönüştürmek istediği miktarı gireceği büyük ve belirgin bir **sayısal giriş alanı** bulunacaktır. Girilen her sayı değişiminde **anlık olarak dönüşüm sonucu** güncellenecektir.
    * **Kaynak Para Birimi Seçici:** Giriş miktarının altında, mevcut para birimi ve değiştirme butonu yer alacaktır. Tıklandığında **tüm dünya para birimlerinin olduğu bir seçim listesi** açılacaktır.
    * **"Dönüşüm Yönü" İkonu:** Kaynak ve hedef para birimi seçicileri arasında, iki para birimi arasında dönüşüm yönünü gösteren **çift yönlü bir ok ikonu** bulunacaktır.
    * **Hedef Para Birimi Seçici:** Kaynak para biriminin altında, dönüştürülecek para birimi ve değiştirme butonu yer alacaktır. Tıklandığında yine tüm dünya para birimlerinin olduğu bir **seçim listesi** açılacaktır.
* **Dönüşüm Sonucu Alanı:** Hesaplanan dönüşüm sonucu **büyük, kalın ve net bir fontla** gösterilecektir (örn: "32.50 TRY").
* **Favori Çift Ekleme / Favori Çiftler Alanı:**
    * Mevcut kaynak ve hedef para birimi çiftini **favorilere eklemesini sağlayacak bir buton veya ikon** bulunacaktır.
    * Bu bölümün altında **sık kullanılan favori dönüşüm çiftlerinin listesi** yer alacak ve kullanıcı bu favori çiftlere tıklayarak hızlıca ilgili dönüşümü gerçekleştirebilecektir.
* **Alt Kısım (Bottom Navigation Bar):** Ana ekranlardaki gibi olacaktır; **"Dönüştürücü"** ikonu vurgulanacaktır.

### 3.3 Grafik Ekranı (Chart Screen)

* **Ekran Başlığı:** Kullanıcının incelediği para birimi çiftini belirten bir başlık (örn: **"USD/TRY Grafiği"**) yer alacaktır.
* **Grafik Alanı:**
    * Ekranın büyük bir kısmını kaplayan, **interaktif bir çizgi grafiği** bulunacaktır.
    * Kullanıcı grafiğe dokunup parmağını hareket ettirdiğinde, belirli bir noktadaki **tarih/saat ve o anki kur değerini gösteren bir ipucu (tooltip)** dinamik olarak görüntülenecektir.
    * **Y ekseni:** Kur değerlerini gösterecektir. **X ekseni:** Zaman aralığını gösterecektir.
* **Zaman Dilimi Seçim Kontrolü:** Grafiğin altında, kullanıcının farklı zaman aralıklarını kolayca seçebileceği bir **segment kontrolü** (veya buton grubu) yer alacaktır:
    * **1s** (1 Saat), **2s** (2 Saat), **4s** (4 Saat), **1g** (1 Gün), **1h** (1 Hafta), **1a** (1 Ay), **1y** (1 Yıl).
* **Alt Kısım (Bottom Navigation Bar):** Ana ekranlardaki gibi olacaktır; **"Grafikler"** ikonu vurgulanacaktır.

### 3.4 Hesap Ekranı (Account Screen)

* **Ekran Başlığı:** Ekranın üst ortasında **"Hesap"** veya **"Ayarlar"** başlığı yer alacaktır.
* **Ayarlar Listesi:**
    * **"Dil Ayarları":** Uygulamanın dilini değiştirmek için bir bölüm.
    * **"Bildirim Ayarları":** (Gelecek özellikler için yer tutucu).
    * **"Gizlilik Politikası":** Uygulamanın gizlilik politikasını gösteren ekran bağlantısı.
    * **"Kullanım Koşulları":** Uygulamanın kullanım koşullarını gösteren ekran bağlantısı.
    * **"Hakkında":** Uygulama sürümü, geliştirici bilgileri ve telif hakkı.
    * **"Geri Bildirim Gönder":** Kullanıcılardan geri bildirim almak için e-posta veya form bağlantısı.
* **Alt Kısım (Bottom Navigation Bar):** Ana ekranlardaki gibi olacaktır; **"Hesap"** ikonu vurgulanacaktır.

### 3.5 Para Birimi Ekle/Yönet Ekranı (Manage Currencies Screen)

* **Ekran Başlığı:** "Para Birimlerini Yönet" veya "Listemi Düzenle".
* **Arama Çubuğu:** Para birimlerini aramak için bir arama çubuğu.
* **Tüm Para Birimleri Listesi:** Tüm dünya para birimlerinin alfabetik listesi, her birinin yanında ana ekranda görünüp görünmeyeceğini belirten bir **açma/kapama anahtarı (toggle switch)** bulunacaktır.
* **Kaydet/Bitti Butonu:** Yapılan değişiklikleri kaydetmek için bir buton.

### 3.6 Yardımcı Ekranlar (Hamburger Menüden Erişilebilir)

* **Ayarlar:** (Hesap ekranı detaylarını içerir)
* **Yardım/Sıkça Sorulan Sorular (SSS)**
* **Uygulamayı Paylaş**
* **Puan Ver / Yorum Yap**

---

## 4. Kullanıcı Arayüzü (UI) ve Kullanıcı Deneyimi (UX)

* **Tasarım Prensibi:** Apple'ın Human Interface Guidelines'ına (HIG) uygun, temiz, modern ve sezgisel bir arayüz tasarlanacaktır.
* **Dinamik Arayüz:** Akıcı animasyonlar, kullanıcı etkileşimini artıran dinamik öğeler ve genel olarak **premium bir hissiyat** sunulacaktır.
* **Erişilebilirlik:** Uygulama, farklı cihaz boyutları (iPhone SE'den en yeni iPhone modellerine), karanlık mod ve erişilebilirlik seçenekleriyle (Dynamic Type, VoiceOver) uyumlu olacaktır.

---

## 5. Gelir Modeli

* **Reklam Destekli Model:** Uygulama, başlangıçta reklamlar aracılığıyla gelir elde edecektir. Reklam yerleşimi ve sıklığı, kullanıcı deneyimini olumsuz etkilemeyecek şekilde optimize edilecektir (örneğin, alt banner reklamlar veya dönüşüm sonrası geçiş reklamları).
* **Gelecek Potansiyeli:** Kullanıcı tabanı oluştuktan ve değer kanıtlandıktan sonra, reklamsız deneyim, daha sık güncelleme, daha fazla geçmiş veri veya ek özellikler sunan abonelik tabanlı premium bir model entegrasyonu değerlendirilecektir.

---

## 6. Teknik Gereksinimler

* **Platform:** iOS
* **Minimum iOS Sürümü:** **iOS 16.0 ve üzeri.**
* **Programlama Dili:** **Swift**.
* **UI Çerçevesi:** **SwiftUI** (Ana geliştirme arayüzü olarak tercih edilecektir).
* **API Entegrasyonu:**
    * Döviz kurları için harici bir üçüncü taraf API kullanılacaktır.
    * Başlangıçta **günlük 1000-5000 istek hakkı veren ve 10-15 dakikalık güncelleme sıklığı** sunan freemium bir API (örn: ExchangeRate-API, CurrencyAPI.com) tercih edilecektir.
    * API'den gelen veriler cihazda önbelleğe alınacak ve çevrimdışı kullanım için depolanacaktır.
    * API yanıtı alınamadığında veya bağlantı sorunlarında, kullanıcı dostu bir "Şu Anda Bakımdayız!" temalı hata ekranı/mesajı görüntülenecektir.
* **Veri Yönetimi ve Kalıcılık:**
    * Cihaz içi veri depolama (favori birimler, ayarlar vb.) için **SwiftData (iOS 17+) veya Core Data** kullanılacaktır. UserDefaults basit ayarlar için kullanılabilir.
    * Eğer gelecekte sunucu tarafında bir veritabanı ihtiyacı doğarsa, **PostgreSQL veya MySQL** gibi ilişkisel bir veritabanı çözümü tercih edilecektir.
* **Ağ Katmanı:** **URLSession** ve **Async/Await** desenleri API isteklerini yönetmek için kullanılacaktır.
* **Grafik Kütüphanesi:** Grafik ekranları için **Apple'ın kendi grafik çerçevesi** kullanılacaktır (iOS 16+ desteği sayesinde).
* **Lokalizasyon:** Uygulama içi tüm metinler `Localizable.strings` dosyaları kullanılarak çok dilli yapıya uygun hale getirilecektir. Tarih, saat ve para birimi formatları için yerleşik `Formatter` sınıfları kullanılacaktır.
* **Çevrimdışı Mod:** Hafta sonları ve internet bağlantısının olmadığı durumlarda, uygulama en son güncellenen kurları kullanarak dönüşüm ve kur görüntüleme işlevini sürdürecektir. Kullanıcıya çevrimdışı modda olduğu belirtilecektir.

---

## 7. App Store Optimizasyonu (ASO) ve Pazarlama

* **Uygulama Adı:** **MoneyMate: Currency Converter App**
* **App Store Listeleme:**
    * Çekici ve bilgilendirici uygulama simgesi ve açılış ekranı.
    * Etkileyici başlık, alt başlık ve açıklama.
    * Uygulamanın ana özelliklerini ve UI/UX'ini sergileyen yüksek kaliteli ekran görüntüleri ve potansiyel olarak kısa bir uygulama önizleme videosu.
* **Anahtar Kelimeler:** "Döviz çevirici", "para birimi", "kur", "döviz kuru", "finans", "ticaret", "güncel döviz", "tl dolar", "euro tl", "canlı kur", "para çevirme", "MoneyMate" ve ilgili diğer anahtar kelimeler hedeflenecektir.
* **Benzersiz Satış Noktaları (USP):**
    * **Anlık ve Kişiselleştirilebilir Ana Ekran:** Kullanıcının istediği kurları anında takip edebilme ve listeyi özelleştirebilme.
    * **Basit, Hızlı ve Dinamik Kullanıcı Deneyimi:** Kullanım kolaylığına ve estetik bir arayüze odaklanma.
    * **Hafta Sonu Çevrimdışı Dönüşüm Yeteneği:** İnternet bağlantısı olmasa bile güvenilir hafta sonu dönüşümleri.
    * **Detaylı Grafiksel Kur Geçmişi:** Kullanıcılara 1 saatten 1 yıla kadar çeşitli zaman dilimlerinde kur trendlerini görsel olarak sunma.

---

## 8. Geliştirme Yol Haritası ve Tahmini Zaman Çizelgesi

**Toplam Tahmini Geliştirme Süresi:** Yaklaşık **7-8 Hafta** (Tek geliştirici için)

* **Aşama 1: Planlama ve Ön Çalışmalar (Hafta 1)**
    * API Araştırması ve Seçimi (2-3 Gün)
    * Proje Kurulumu ve Temel Altyapı Kararları (2-3 Gün)
* **Aşama 2: UI/UX Geliştirme ve Temel Fonksiyonellik (Hafta 2-4)**
    * Ana Ekran (Güncel Kurlar) Geliştirme (5-7 Gün)
    * Döviz Dönüştürme Ekranı Geliştirme (4-6 Gün)
    * Grafik Ekranı Geliştirme (4-6 Gün)
    * Bottom Navigation Bar Entegrasyonu (1-2 Gün)
* **Aşama 3: Yardımcı Ekranlar ve İyileştirmeler (Hafta 5-6)**
    * Hesap Ekranı (Ayarlar) Geliştirme (3-4 Gün)
    * Para Birimi Ekle/Yönet Ekranı Geliştirme (3-4 Gün)
    * Hata Yönetimi ve Kullanıcı Geri Bildirimleri (2-3 Gün)
    * Lokalizasyon İyileştirmeleri (1-2 Gün)
    * Küçük UI/UX İyileştirmeleri (2-3 Gün)
* **Aşama 4: Test ve Dağıtım Öncesi Hazırlık (Hafta 7-8)**
    * Kapsamlı Testler (4-6 Gün)
    * App Store Optimizasyonu (ASO) Materyalleri Hazırlığı (3-4 Gün)
    * Dağıtım Hazırlığı (1-2 Gün)
