# GymCoach — UI and UX Guidelines

**Document type:** UI/UX specification and design system direction  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Designers, Flutter engineers, product owners, QA  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`

All user-visible copy referenced here must follow **English-only** project rules. This document contains **no implementation code**.

---

## 1. UX principles

| Principle | Application |
|-----------|-------------|
| Immediate clarity | Within seconds of opening a screen, the user understands purpose and the **single best next step**. |
| Obvious primary actions | One dominant primary control per view where possible; secondary actions de-emphasized. |
| Simple workout creation | Plan creation follows a linear path: date → exercises → prescription → save; advanced options collapsed. |
| Visible progress | Dashboard and statistics surfaces celebrate streaks, completion counts, and weekly rhythm without clutter. |
| Restraint | Avoid dense charts, excessive badges, and competing focal points; whitespace is functional. |
| Motivation through structure | Energy comes from **clear goals**, **tracked completions**, and **honest feedback**—not gimmicky visuals alone. |
| Mobile-first | Touch ergonomics, thumb reach, and readable density tuned for phone portrait primary use. |
| Constructive empty states | Empty views teach what to do next; never feel like errors. |
| Useful errors | Errors state what failed, why it matters, and **what to try next** (retry, check settings, go back). |

---

## 2. Visual principles

| Principle | Direction |
|-----------|-----------|
| Tone | Modern, clean, energetic, approachable—serious enough for demos and portfolios. |
| Layout | Mobile-first grids; single-column primary flows; avoid cramming desktop patterns onto phones. |
| Dashboard | Clean hero summary (next workout / today) plus scannable cards; avoid dashboard soup. |
| Components | Modern cards with subtle elevation or tonal separation; **rounded** corners consistently applied. |
| Calls to action | Strong **primary** buttons with high contrast against surfaces; one primary per logical step. |
| Calendar | Legible date cells; clear distinction between planned, completed, and empty days. |
| Exercise presentation | Simple exercise cards: title, muscle tag, difficulty, optional thumbnail placeholder. |
| Hierarchy | Fitness-focused typography scale: title → section → supporting meta; limit simultaneous emphasis. |
| Spacing | Consistent rhythm using a small set of spacing tokens (see Section 8). |
| Typography | Readable body sizes; comfortable line height for instructions during workouts. |
| Contrast | WCAG-minded pairing for text and interactive elements (see Section 10). |
| Decoration | Minimal ornament; motion and color signal importance sparingly. |

---

## 3. Navigation model

| Layer | Behavior |
|-------|----------|
| Primary shell | Bottom navigation or navigation rail **not required** for MVP if shallow depth is maintained; prefer **bottom nav** when ≥4 top-level destinations (Home, Train/Library, Calendar, Stats, Profile). |
| Stack discipline | Push detail flows onto a stack; provide predictable **back** behavior. |
| Deep links | Reserved for future; MVP uses named routes only. |
| Global entry | **Home dashboard** as default post-onboarding; quick access to **next scheduled** workout. |
| Modal tasks | Short confirmations, filters, and pickers use **bottom sheets** or compact **dialogs**—not full-screen detours when avoidable. |
| Workout execution | Immersive full-screen mode with minimal chrome; exit guarded by confirmation when session active. |

Centralized routing and route naming align with `docs/04_TECH_ARCHITECTURE.md`.

---

## 4. Screen map

```text
Splash / Loading
       → Onboarding → Profile Setup → Home Dashboard
Home ──→ Exercise Library → Exercise Detail
      └→ Workout Plan Creator → Calendar → Planned Workout Details
                                              → Workout Execution → Completion Summary → Statistics
Home ──→ Statistics
Home ──→ Profile → Settings

Future entry points (gated):
       → Camera Validation
       → Territory Map
       → AI Coach
```

---

## 5. MVP screen specifications

Each screen lists **purpose**, **primary action**, **secondary actions**, **main content**, **empty state**, **loading state**, **error state**.

### 5.1 Splash or initial loading screen

| Aspect | Specification |
|--------|----------------|
| Purpose | Brand presence; initialize local services; route to onboarding or home. |
| Primary action | Implicit transition when ready (no mandatory tap unless policy requires). |
| Secondary actions | None or discreet “Continue” if initialization requires acknowledgment. |
| Main content | Logo/wordmark, subtle motion optional, version/build label optional in settings-only placement. |
| Empty state | N/A |
| Loading state | Lightweight indicator if startup exceeds threshold; avoid blocking splash indefinitely. |
| Error state | If critical init fails: short message + retry + link to settings or support info. |

### 5.2 Onboarding screen

| Purpose | Explain value in 2–3 beats; route to profile setup or home. |
| Primary action | **Get started** / **Continue**. |
| Secondary actions | Skip only if product allows partial deferral of profile. |
| Main content | Benefit headlines, minimal illustration, pagination dots if multi-step. |
| Empty state | N/A |
| Loading state | Skeleton or spinner only if prefetching catalog. |
| Error state | Rare; offer retry if asset or config load fails. |

### 5.3 Profile setup screen

| Purpose | Capture training profile fields required for MVP personalization. |
| Primary action | **Save** / **Continue**. |
| Secondary actions | Back; edit later link if optional fields remain. |
| Main content | Form sections grouped logically (body metrics, goals, preferences). |
| Empty state | Show form with helpful defaults and inline hints—not a blank page. |
| Loading state | Saving indicator on primary button; disable double submit. |
| Error state | Field-level validation messages; generic failure banner with retry for persistence errors. |

### 5.4 Home dashboard

| Purpose | Orientation hub: what is next, quick actions, motivation snapshot. |
| Primary action | **Start next workout** or **Plan workout** depending on schedule state. |
| Secondary actions | Navigate to library, calendar, statistics; secondary chip for “Browse exercises”. |
| Main content | Next session card, week snapshot, shortcuts row. |
| Empty state | Prompt to create profile segment if incomplete; otherwise prompt to **plan first workout** with illustration. |
| Loading state | Skeleton cards for dashboard sections. |
| Error state | Banner if stats aggregation fails; core navigation still works. |

### 5.5 Exercise library

| Purpose | Discover and select exercises for planning. |
| Primary action | Open **exercise detail** or **add to plan** context action. |
| Secondary actions | Search, filter chips, favorites if in scope. |
| Main content | Scrollable list of exercise cards; optional category headers. |
| Empty state | No matches from filter: suggest clearing filters; catalog truly empty is a **data defect**—show reload and support message. |
| Loading state | List placeholders (shimmer acceptable). |
| Error state | Retry load; offline-friendly message referencing local catalog expectation. |

### 5.6 Exercise detail

| Purpose | Instruction clarity before adding to a plan or referencing mid-session. |
| Primary action | **Add to workout** / **Done** when read-only. |
| Secondary actions | Share deferred; back navigation. |
| Main content | Title, tags, equipment, difficulty, concise instructions, optional media placeholder. |
| Empty state | Rare; if media missing, show framed placeholder—not broken image icon alone. |
| Loading state | Skeleton for async detail if ever remote; local MVP loads instantly. |
| Error state | Missing exercise reference: friendly not-found with return to library. |

### 5.7 Workout plan creator

| Purpose | Compose a planned workout for a chosen date with prescriptions. |
| Primary action | **Save workout**. |
| Secondary actions | Add exercise, reorder (drag handles), discard changes with confirm. |
| Main content | Date selector, exercise list lines with sets/reps/rest/notes editors. |
| Empty state | Prompt to **add first exercise** with CTA to library picker. |
| Loading state | Saving state on primary; spinner when opening heavy pickers if needed. |
| Error state | Validation banner (e.g., zero exercises); persistence retry. |

### 5.8 Calendar

| Purpose | See planned and completed workouts across time. |
| Primary action | Select date → open **planned workout details**. |
| Secondary actions | Month/week toggle if implemented; jump to today. |
| Main content | Month grid or agenda list with state markers. |
| Empty state | Explain no workouts yet; CTA to **create workout**. |
| Loading state | Lightweight skeleton for month metadata. |
| Error state | Failed to read local DB: retry + non-destructive messaging. |

### 5.9 Planned workout details

| Purpose | Inspect scheduled workout before starting or editing. |
| Primary action | **Start workout** when appropriate state. |
| Secondary actions | **Edit plan**, **Reschedule**, **Cancel/skip** with confirmation. |
| Main content | Exercise roster, prescription summary, status badge (planned/completed). |
| Empty state | Invalid navigation guard should prevent; if orphaned record, offer delete cleanup. |
| Loading state | Brief spinner when hydrating linked entities. |
| Error state | Missing linkage; return user to calendar with toast-style summary. |

### 5.10 Workout execution

| Purpose | Guide session completion with minimal friction. |
| Primary action | **Complete set** / **Complete exercise** / **Finish workout** depending on step model. |
| Secondary actions | Pause (optional), previous exercise, abandon with confirm. |
| Main content | Current exercise headline, prescription, completion toggles, progress indicator. |
| Empty state | Should not occur mid-session; entry guarded by valid plan. |
| Loading state | Minimal when transitioning exercises; avoid blocking overlays. |
| Error state | Save failure: blocking dialog with retry; never silently lose completions. |

### 5.11 Workout completion summary

| Purpose | Reinforce accomplishment; summarize session metrics. |
| Primary action | **Done** / **View statistics**. |
| Secondary actions | Share deferred MVP unless required. |
| Main content | Completed exercises count, duration if tracked, positive reinforcement copy. |
| Empty state | N/A |
| Loading state | Brief confirmation animation while persisting final aggregates. |
| Error state | Partial save warning with explicit retry path. |

### 5.12 Statistics

| Purpose | Make adherence and volume visible over time. |
| Primary action | Change period filter (week emphasis MVP). |
| Secondary actions | Drill into detail lists if implemented later. |
| Main content | Key metrics cards, weekly chart or list, completion rate. |
| Empty state | Explain statistics appear after first completed workout; CTA to schedule. |
| Loading state | Skeleton charts/cards. |
| Error state | Aggregation failure with retry; show last successful snapshot if cached optional future. |

### 5.13 Profile

| Purpose | View and edit persisted profile fields outside first-run setup. |
| Primary action | **Save changes**. |
| Secondary actions | Navigate to settings; sign-out placeholder hidden until accounts exist. |
| Main content | Same field groups as setup with current values. |
| Empty state | Redirect to setup if profile mandatory but missing. |
| Loading state | Fetch/spinner minimal for local MVP. |
| Error state | Validation + persistence retry pattern. |

### 5.14 Settings

| Purpose | Adjust preferences and access informational links. |
| Primary action | Contextual saves per section or global **Save**. |
| Secondary actions | Open external links (privacy policy placeholder), reset local data with destructive confirm. |
| Main content | Toggles, units, notification preferences if applicable, app version. |
| Empty state | N/A; always show grouped settings list. |
| Loading state | Applying toggle feedback inline. |
| Error state | Failure to persist preference with rollback UI state. |

---

## 6. Future screen notes

High-level UX expectations without committing MVP resources.

| Screen | Notes |
|--------|-------|
| **Camera validation** | Full-screen preview with unobtrusive guidance overlays; prominent privacy reminder; manual fallback entry always visible; thermal/low-light messaging. |
| **Territory map** | Map-first layout with clear GPS status; safety disclaimers before tracking; anti-cheat rejection explained plainly post-run. |
| **AI Coach** | Structured plan preview panels matching AI output schema; visible disclaimer that guidance is non-medical; edit-before-save mandatory. |

---

## 7. Component guidelines

| Component | Guidelines |
|-----------|------------|
| **Cards** | Corner radius token consistent; padding uniform; optional subtle border for dark surfaces. |
| **Buttons** | Primary filled, secondary tonal or outlined; destructive separated; disabled states readable. |
| **Inputs** | Single-column labels above fields on mobile; inline errors below fields; avoid placeholder-as-label-only. |
| **Icons** | Simple linear or rounded sets; pair every icon-only control with tooltip or label **except** universally understood icons (search, close). |
| **Progress** | Linear bars for weekly completion; circular mini indicators acceptable on cards; show numeric context (e.g., 3 of 5). |
| **Lists** | Adequate row height; dividing lines or spacing—not both excessively. |
| **Chips / filters** | Scroll horizontally when many; clear selected state beyond color alone. |

---

## 8. Design system rules

### 8.1 Colors

| Role | Direction |
|------|-----------|
| Primary | Energetic accent (e.g., vivid green, teal, or orange family)—single brand hue. |
| Secondary | Supporting accent for charts or tags sparingly. |
| Surface | Neutral backgrounds layered (canvas → card → inset). |
| Semantic | Success, warning, error, info tokens distinct and not interchangeable. |

Centralize tokens under app theme (`docs/04_TECH_ARCHITECTURE.md`).

### 8.2 Typography

| Role | Direction |
|------|-----------|
| Display / titles | Bold, tight line height for headers. |
| Body | Minimum comfortable reading size on small phones (see Section 10). |
| Labels | Slightly smaller but never illegible; medium weight for field labels. |
| Numbers | Tabular lining figures for stats where supported. |

### 8.3 Spacing

Use a **4 px base grid**; standard increments (4, 8, 12, 16, 24, 32). Section spacing larger than intra-card spacing.

### 8.4 Navigation

Bottom navigation icons + labels; active state uses combined **weight + color + indicator**.

### 8.5 Modals and bottom sheets

Use **bottom sheets** for selectors and filters; **dialogs** for destructive confirmations and blocking errors during workouts sparingly.

### 8.6 Permission screens

Pre-permission education screen **before** OS dialog; explain benefit and consequence of denial; always offer alternative path when feasible.

---

## 9. Empty, loading, and error states

| Pattern | Rule |
|---------|------|
| Empty | Illustration or icon + headline + one sentence + **primary CTA** aligned to next task. |
| Loading | Prefer skeletons for structured layouts; spinners only for short opaque waits. |
| Error | Title + explanation + **primary retry** + secondary dismiss/back; never silent failure for saves. |
| Offline (local MVP) | Most flows still succeed; errors emphasize storage corruption or migration failure narrowly. |

---

## 10. Accessibility rules

| Topic | Rule |
|-------|------|
| Font sizes | Respect platform text scaling; avoid locking body text below readable minimums on smallest targets. |
| Contrast | Body text and interactive labels meet or approach WCAG AA for critical flows; decorative graphics exempt. |
| Touch targets | Minimum approximately **44×44 logical px** for tappable controls; spacing prevents mis-taps. |
| Language | Plain English; avoid jargon unless defined once nearby. |
| Feedback | Haptics optional; always pair with visual **and** textual confirmation for destructive acts. |
| Color independence | Never encode state **only** by hue (completed vs planned uses icon/text/shape in addition). |
| Focus order | Logical traversal for screen readers on forms and execution toggles. |

---

## 11. Figma planning notes

| Topic | Guidance |
|-------|----------|
| Frames | Design primary flows at **375×812** (or team baseline) plus one compact width stress test. |
| Tokens | Define color, type, spacing, radius as variables; sync naming with Flutter theme tokens. |
| Components | Build atomic inputs, cards, list rows, nav bars; compose screens only from components. |
| States | Every interactive component documents default, pressed, disabled, error. |
| Handoff | Annotate motion sparingly; specify elevations and corner radii numerically. |

---

## 12. UI implementation rules for Flutter

Conceptual rules only—no widget code.

| Rule | Detail |
|------|--------|
| Theme centralization | All colors and text styles flow from `ThemeData` extensions or equivalent centralized definitions. |
| Responsiveness | Use `LayoutBuilder` or breakpoints sparingly; prefer flexible columns and scroll views over fixed heights. |
| Composition | Break screens into small private widgets files aligned with feature folders—not monolithic build methods. |
| State separation | UI reacts to view models or state holders; avoid embedding formatting logic unrelated to presentation. |
| Performance | List virtualization for exercise catalogs; const constructors where possible; avoid rebuilding heavy subtrees. |
| Assets | Declare exercise placeholders consistently; precache critical images after splash if needed. |
| Localization readiness | Even with English-only MVP, avoid hardcoded concatenations that block future `intl` adoption if scope changes. |
| Testing hooks | Stable keys or semantics labels on critical controls for integration tests. |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial UI/UX guidelines baseline |

---

*End of document.*
