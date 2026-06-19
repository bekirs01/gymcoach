# GymCoach — Reddit Post (Türkçe)

> Görseller ve yükleme rehberi: [`README.md`](README.md)

---

## Başlık

**Önerilen (r/FlutterDev / r/SideProject):**
> GymCoach — Flutter ile kişisel antrenör uygulaması: planlama, AI beslenme, ilerleme analitiği ve sosyal feed

**Alternatifler:**
- *Antrenmanlarımı planlayan, takip eden ve analiz eden kendi fitness uygulamamı geliştirdim*
- *7 antrenman/hafta, %79 plan tamamlama — hepsini tek bir Flutter uygulamasında topladım*

---

## Post metni (kopyala / yapıştır)

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
- Haftalık 7 seans · 3 günlük streak · aylık %79 plan tamamlama
- Günlük kalori ve seans grafikleri
- Kas grubu dağılımı (donut chart)
- Set / tekrar / hacim metrikleri
- En uzun seans, max kalori, en yoğun antrenman

**Nutrition AI**
- Doğal dilde yemek girişi (*"2 yumurta, 200g tavuk…"*)
- Supabase Edge Function + OpenAI ile makro tahmini
- Günlük hedef: ~1753 kcal

**Sosyal feed**
- Story bar, beğeni/yorum, antrenman paylaşımı
- Fitness odaklı mini sosyal ağ

**Territory Map** *(geliştirme aşamasında)*
- GPS tabanlı bölge yakalama oyunu (MapLibre + Supabase PostGIS)

### Teknik stack

Flutter 3.x · Material 3 · Supabase (PostgreSQL + Edge Functions) · Google ML Kit · MapLibre GL · EN/RU lokalizasyon

Repo: [github.com/bekirs01/gymcoach](https://github.com/bekirs01/gymcoach)

### Galeri sırası

1. İlerleme özeti — haftalık metrikler, streak, aylık düzenlilik
2. Ana ekran — takvim + öne çıkan antrenman
3. Antrenmanlar — seans listesi ve tamamlama
4. Beslenme AI — Nutrition Coach ve hızlı giriş
5. Grafikler — günlük kalori/seans analitiği
6. Güç & hacim — set/tekrar/hacim + kas grubu dağılımı
7. Sosyal feed — Gym Coach topluluk akışı

### Sizden ricam

- UI/UX geri bildirimi (özellikle Progress ekranı)
- Hangi özellik sizin için en değerli?
- Beslenme AI ve sosyal feed mantıklı mı, yoksa gereksiz mi?

Teşekkürler — sorularınızı yanıtlamaya hazırım.

---

## İlk yorum

> **Tech stack detayı:** Flutter + Supabase Edge Functions. Beslenme tahmini `estimate-nutrition` edge function üzerinden çalışıyor. Progress ekranındaki demo veriler `progress_demo_seed` ile dolduruluyor — gerçek seans verisiyle aynı pipeline. Sorularınızı bekliyorum.
