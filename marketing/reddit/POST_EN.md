# GymCoach — Reddit Post Package (EN)

> Screenshots: `marketing/reddit/screenshots/` — upload in numbered order.

---

## Recommended subreddits

| Subreddit | Best for |
|-----------|----------|
| r/FlutterDev | Technical showcase |
| r/SideProject | Indie project story |
| r/reactnative | Cross-platform comparison (optional) |
| r/fitness | Product-focused, less technical |
| r/opensource | If repo is public |

---

## Title (recommended)

**GymCoach — Flutter fitness app: workout planning, AI nutrition tracking, progress analytics & social feed**

Alternatives:
- *Built a personal gym coach in Flutter — planning, camera reps, territory map & more*
- *7 workouts/week, 79% plan completion — my side project fitness app in Flutter*

---

## Post body (copy/paste)

Hey everyone,

I've been building **GymCoach** — a mobile fitness app that combines structured workout planning, session tracking, progress analytics, and motivation in one clean dark UI.

This is a **side project / student project** — not on the App Store yet. Sharing here for feedback.

### What it does

**Home**
- Daily overview, calendar, upcoming sessions
- Featured workout cards with completion counts
- Nutrition tab with daily calorie goal

**Workouts**
- Create, edit, and run training sessions
- Exercise lists with completion rings
- Share completed workouts

**Progress & analytics**
- 7 sessions/week, 3-day streak, 79% monthly plan completion
- Daily calorie & session bar charts
- Muscle group distribution (donut chart)
- Sets / reps / volume metrics
- Personal records: longest session, max calories, most intense workout

**Nutrition AI**
- Natural language meal logging ("2 eggs, 200g chicken…")
- Macro estimation via Supabase Edge Function + OpenAI
- Daily target: ~1753 kcal

**Social feed**
- Stories, likes, comments, workout sharing
- Fitness-focused mini social network

**Territory Map** *(in development)*
- GPS-based territory capture game (MapLibre + Supabase PostGIS)

### Tech stack

| Layer | Stack |
|-------|-------|
| UI | Flutter 3.x, Material 3 |
| Backend | Supabase (PostgreSQL + Edge Functions) |
| Pose | Google ML Kit |
| Map | MapLibre GL, Geolocator |
| i18n | EN / RU |

Repo: [github.com/bekirs01/gymcoach](https://github.com/bekirs01/gymcoach)

### Gallery order

1. Progress overview — weekly metrics & monthly consistency
2. Home — calendar & featured workout
3. Workouts — session list
4. Nutrition AI — natural language meal entry
5. Analytics — daily calorie & session charts
6. Strength & volume — sets/reps/volume + muscle split
7. Social feed — Gym Coach community

### Feedback wanted

- UI/UX thoughts (especially Progress screen)
- Which feature feels most valuable?
- Is Nutrition AI + social feed overkill for a fitness app?

Thanks — happy to answer questions!

---

## First comment (post immediately after)

> **Stack details:** Flutter client + Supabase Edge Functions. Nutrition uses an `estimate-nutrition` edge function. Progress demo data is seeded locally — same pipeline as real session data. AMA on architecture or Flutter choices.

---

## Upload order

```
01_progress_overview.png   ← Cover / thumbnail
02_home_overview.png
03_workouts.png
04_nutrition_ai.png
05_analytics_charts.png
06_strength_volume.png
07_social_feed.png
```
