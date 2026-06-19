# GymCoach — Reddit Paylaşım Paketi (TR)

> Görseller: `marketing/reddit/screenshots/` klasöründe, yükleme sırasına göre numaralandırılmış.

---

## Önerilen subreddit'ler

| Subreddit | Post tipi | Not |
|-----------|-----------|-----|
| r/FlutterDev | Gallery + teknik detay | Flutter geliştiricileri |
| r/SideProject | Gallery + hikâye | Bağımsız proje vitrini |
| r/fitness | Gallery (daha az teknik) | Ürün odaklı, kısa metin |
| r/bodyweightfitness | Gallery | Antrenman takibi vurgusu |
| r/Turkey | Metin + 1–2 görsel | Türkçe topluluk |

**Flair:** `Showcase` / `Project` / `App` (subreddit'e göre)

**En iyi saat:** Salı–Perşembe, 18:00–22:00 (TR saati)

---

## Başlık seçenekleri

**A (önerilen — r/FlutterDev / r/SideProject):**
> GymCoach — Flutter ile kişisel antrenör uygulaması: planlama, AI beslenme, ilerleme analitiği ve sosyal feed

**B (kısa — r/fitness):**
> Antrenmanlarımı planlayan, takip eden ve analiz eden kendi fitness uygulamamı geliştirdim

**C (merak uyandıran):**
> 7 antrenman/hafta, %79 plan tamamlama — hepsini tek bir Flutter uygulamasında topladım

---

## Ana post metni (Türkçe — kopyala/yapıştır)

Merhaba,

Son aylarda **GymCoach** adlı bir fitness uygulaması geliştiriyorum. Amacım basit: antrenman planlamak, seansları tamamlamak, ilerlemeyi görmek ve motivasyonu kaybetmemek — hepsini tek, sade bir arayüzde birleştirmek.

Bu bir **side project / öğrenci projesi**; henüz App Store'da değil. Geri bildirim almak için burada paylaşıyorum.

### Ne yapıyor?

**Ana ekran**
- Günlük özet, takvim ve planlanan seanslar
- Öne çıkan antrenman kartları (görsel + tamamlanan seans sayısı)
- Beslenme sekmesi: günlük kalori hedefi ve hızlı kayıt

**Antrenmanlar**
- Plan oluşturma, düzenleme ve seans başlatma
- Egzersiz listesi, ilerleme halkaları (%100 tamamlama)
- Seans paylaşımı

**İlerleme & analitik**
- Haftalık 7 seans, 3 günlük streak, aylık %79 plan tamamlama
- Günlük kalori ve seans grafikleri
- Kas grubu dağılımı (donut chart)
- Set / tekrar / hacim metrikleri
- En uzun seans, max kalori, en yoğun antrenman

**Nutrition AI**
- Doğal dilde yemek girişi (“2 yumurta, 200g tavuk…”)
- Supabase Edge Function + OpenAI ile makro tahmini
- Günlük hedef: ~1753 kcal

**Sosyal feed**
- Story bar, beğeni/yorum, antrenman paylaşımı
- Fitness odaklı mini sosyal ağ

**Territory Map** *(geliştirme aşamasında)*
- GPS tabanlı bölge yakalama oyunu (MapLibre + Supabase PostGIS)

### Teknik stack

| Katman | Teknoloji |
|--------|-----------|
| UI | Flutter 3.x, Material 3, dark theme |
| Backend | Supabase (PostgreSQL + Edge Functions) |
| Pose | Google ML Kit (squat, plank, deadlift…) |
| Harita | MapLibre GL, Geolocator |
| Lokalizasyon | EN / RU (TR planlanıyor) |

Repo: [github.com/bekirs01/gymcoach](https://github.com/bekirs01/gymcoach)

### Ekran görüntüleri (sıra)

1. **İlerleme özeti** — haftalık metrikler, streak, aylık düzenlilik
2. **Ana ekran** — takvim + öne çıkan antrenman
3. **Antrenmanlar** — seans listesi ve tamamlama
4. **Beslenme AI** — Nutrition Coach kartı ve hızlı giriş
5. **Grafikler** — günlük kalori/seans analitiği
6. **Güç & hacim** — set/tekrar/hacim + kas grubu dağılımı
7. **Sosyal feed** — Gym Coach topluluk akışı

### Sizden ricam

- UI/UX geri bildirimi (özellikle Progress ekranı)
- Hangi özellik sizin için en değerli?
- Beslenme AI ve sosyal feed mantıklı mı, yoksa gereksiz mi?

Teşekkürler — sorularınızı yanıtlamaya hazırım.

---

## İlk yorum (hemen post attıktan sonra)

> **Tech stack detayı:** Flutter + Supabase Edge Functions. Beslenme tahmini `estimate-nutrition` edge function üzerinden çalışıyor. Progress ekranındaki demo veriler `progress_demo_seed` ile dolduruluyor — gerçek seans verisiyle aynı pipeline. Repo private değilse link yukarıda; sorularınızı bekliyorum.

---

## Görsel yükleme talimatı

Reddit'te **Images & Video → Post** seç → galeri modunda şu sırayla yükle:

```
01_progress_overview.png   ← Kapak (thumbnail)
02_home_overview.png
03_workouts.png
04_nutrition_ai.png
05_analytics_charts.png
06_strength_volume.png
07_social_feed.png
```

Her görsele Reddit'te kısa alt başlık (opsiyonel):

| # | Alt başlık |
|---|------------|
| 1 | Progress — haftalık özet & aylık düzenlilik |
| 2 | Home — takvim & planlanan seanslar |
| 3 | Workouts — seans listesi |
| 4 | Nutrition AI — doğal dilde yemek kaydı |
| 5 | Analytics — günlük kalori & seans grafikleri |
| 6 | Strength — set/tekrar/hacim & kas dağılımı |
| 7 | Social — fitness feed |

---

## r/FlutterDev için İngilizce kısa versiyon

**Title:** GymCoach — Flutter fitness app with workout planning, AI nutrition, progress analytics & social feed

**Body:** (Use the Turkish post structure above, translated. Key metrics: 7 sessions/week, 79% monthly completion, 3-day streak, Flutter + Supabase + ML Kit.)

---

## Kontrol listesi

- [ ] `.env` ve API anahtarları repoda **yok** (paylaşmadan önce kontrol et)
- [ ] Demo veriler gerçek kullanıcı verisi değil
- [ ] GitHub repo linki güncel
- [ ] İlk 30 dk içinde yorumlara cevap ver
- [ ] Self-promotion kurallarını oku (her subreddit farklı)
