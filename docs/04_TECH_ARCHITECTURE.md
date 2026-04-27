# GymCoach — Technical Architecture

**Product:** GymCoach (Flutter/Dart mobile application)  
**Document type:** Technical architecture and evolution plan  
**Audience:** Flutter engineers, backend engineers, DevOps, security reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`, `docs/03_MVP_SCOPE.md`

This document defines structure, boundaries, and evolution paths. It intentionally contains **no source code**.

---

## 1. Architecture goals

| Goal | Description |
|------|-------------|
| Local-first MVP | Ship a complete training loop with offline persistence before any backend dependency. |
| Evolvable layering | Add REST integration, AI, camera validation, and territory features **without** rewriting the whole client. |
| Clear boundaries | Presentation, state, domain, and data remain distinguishable per feature. |
| Stable contracts | Route names, domain models, and repository interfaces stabilize early to reduce churn. |
| Testability | Core rules and repositories can be validated independently of widgets where practical. |
| Security and privacy by design | Secrets never in client source; permissions minimized; personal health-adjacent data handled carefully. |
| Team scalability | Feature folders allow parallel ownership and contained changes. |

---

## 2. Current technology stack

| Layer | Technology |
|-------|------------|
| Client | Flutter / Dart |
| Persistence (MVP) | Local storage abstraction (concrete implementation chosen per MVP plan; see Section 10) |
| Design references | Figma (recommended for UI specs and component definitions) |
| Version control | Git |
| IDE / tooling | Flutter SDK, Dart analyzer, platform toolchains (Xcode / Android SDK as needed) |

The repository should declare exact SDK constraints in project configuration files maintained by engineering.

---

## 3. Future technology stack

The following stack is **planned** for post-MVP phases when backend scope is approved. It does not constrain the MVP deliverable.

| Layer | Technology |
|-------|------------|
| Client | Flutter mobile app |
| Backend API | FastAPI (Python), REST |
| Primary database | PostgreSQL |
| Cache / ephemeral state | Redis (sessions, rate limits, leaderboards, job queues as designed) |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Design | Figma |

Integration assumes HTTPS, versioned API paths, and environment-specific base URLs injected at build or runtime—not hardcoded in source.

---

## 4. Folder structure recommendation

Recommended orientation under `lib/`:

```text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    constants/
    errors/
    utils/
    widgets/
  features/
    onboarding/
    profile/
    exercises/
    workout_plans/
    calendar/
    workout_execution/
    statistics/
    camera_validation/
    territory_map/
    ai_coach/
  shared/
    models/
    repositories/
    services/
```

**Notes:**

- Feature folders own their presentation and feature-local adapters; shared contracts live under `shared/` when cross-feature reuse is real.
- Empty future feature directories may remain absent until work starts; placeholders in documentation do not require empty stubs in code.
- `core/` holds cross-cutting concerns that are not product features (theme tokens, generic widgets, routing registration helpers).

---

## 5. Layer responsibilities

| Layer | Responsibility | Forbidden coupling |
|-------|------------------|-------------------|
| Presentation | Screens, composition, feature widgets, user-visible layout | Direct HTTP calls to backend from widgets; direct AI SDK calls from widgets |
| State | Screen lifecycle state, selections, command dispatch to domain/use cases | Embedding SQL or REST paths inside widgets |
| Domain | Entities, business rules, validation, use case orchestration | UI framework imports |
| Data | Repository implementations, local database, remote API clients, DTO mapping | UI-specific types |
| Core | Theme, routing table assembly, shared constants, reusable low-level widgets | Feature-specific business rules |

Dependency direction: **Presentation → State → Domain ← Data**. Domain never depends on Flutter framework types.

---

## 6. Feature module responsibilities

| Module | MVP responsibility | Future extension |
|--------|-------------------|------------------|
| `onboarding` | First-run flows, consent copy surfaces | Deeper personalization hooks |
| `profile` | Local profile CRUD, goals, training frequency | Sync with authenticated profile API |
| `exercises` | Catalog browsing, filters, detail | Remote catalog refresh, admin-driven updates |
| `workout_plans` | Plan authoring, sets/reps/notes | Shared templates, AI-suggested plans via domain services |
| `calendar` | Planned sessions, planned vs completed indicators | Cross-device calendar consistency via sync |
| `workout_execution` | Session runner, completion tracking | Camera-assisted validation hooks via injected service |
| `statistics` | Aggregates, weekly progress | Server-side analytics and comparisons |
| `camera_validation` | **Future:** capture pipeline, validation orchestration | Expanded pose models, exercise packs |
| `territory_map` | **Future:** GPS sessions, route recording, territory logic | Anti-cheat services, multiplayer territories |
| `ai_coach` | **Future:** coach prompts and plan adjustments behind services | Model/provider swaps |

Workout planning and execution remain independent of camera and map modules until those services are explicitly invoked through interfaces.

---

## 7. Routing strategy

| Principle | Application |
|-----------|-------------|
| Central registration | All routes defined or aggregated under `app/router/` with a single navigational source of truth. |
| Stable route names | String names or typed route classes documented; renamed routes require migration notes. |
| Deep links | Reserved pattern for future universal links; MVP may use named navigation only. |
| Arguments | Typed argument objects or query maps validated before presenting screens. |
| Feature isolation | Features export route builders or path constants consumed by the router—not scattered string literals. |

This reduces breakage when adding authenticated stacks or modal flows later.

---

## 8. State management strategy

**Policy:** Use one primary approach application-wide for predictability.

**Selection process:**

1. Inspect the repository’s existing dependencies. If a state management package is already adopted, **extend that approach** rather than introducing a second paradigm.
2. If none is present, prefer a **scalable, explicit** pattern common in production Flutter apps—for example declarative state with clear separation between immutable view state and side-effect handlers (popular packages in this space include Riverpod, Bloc, and Provider-style compositions). The concrete package choice is an engineering decision documented in the README or ADR, **without** mandating installation from this document.

**Guidelines:**

- State objects should be **immutable** where practical.
- Side effects (IO, timers, repository calls) belong in notifiers, blocs, controllers, or use case mediators—not buried inside leaf widgets.
- Feature-local state stays feature-local; only elevate shared session context (e.g., profile snapshot) when multiple features must read it.

---

## 9. Theme strategy

| Concern | Approach |
|---------|----------|
| Colors | Semantic tokens (primary, surface, error) defined once under `app/theme/`. |
| Typography | Text styles for titles, body, captions; avoid one-off font sizes in screens. |
| Spacing | Standard increments for padding and gutters. |
| Components | Buttons, cards, inputs, list tiles styled centrally in `core/widgets` or `app/theme` companions. |
| Dark mode | Define light/dark color schemes even if MVP ships light-only; avoids rework. |

Screens consume theme data via `Theme.of` or inherited theme accessors—not raw literals scattered across features.

---

## 10. Local data strategy

Evolution path compatible with student and production timelines:

| Phase | Purpose | Characteristics |
|-------|---------|-----------------|
| Prototype | Rapid UI iteration | In-memory repositories implementing the same interfaces as persistent ones |
| MVP | Real user journeys | Local database or embedded store with migrations |
| Growth | Optional sync readiness | Repository implementations swap local vs remote behind identical interfaces |

**Implementation options (non-exclusive):** relational SQLite-style stores, document-oriented local databases, or structured key-value stores. Selection criteria include migration support, query needs for calendar and statistics, and team familiarity.

**Rules:**

- Domain layer depends on **repository interfaces**, not concrete stores.
- Exercise catalog ships as bundled seed data; updates later via API **without** breaking entity identifiers if possible.

---

## 11. Repository pattern

| Concept | Definition |
|---------|------------|
| Interface | Lives in domain or `shared/repositories` depending on cross-feature reuse; describes asynchronous capabilities (load profile, save session, list exercises). |
| Local implementation | Implements interface using local persistence for MVP. |
| Remote implementation | Future: HTTP client + DTO mapping; handles auth headers and errors. |
| Composite implementation | Future: read-through/write-behind strategies for offline cache plus sync. |

Repositories return **domain entities** or failure types—not raw JSON and not UI models.

---

## 12. Backend integration plan

**Phasing:**

1. Freeze domain entities and repository contracts during MVP.
2. Introduce an API client module under data layer with explicit base URL configuration.
3. Implement remote repositories per aggregate (profile, exercises, plans, sessions, statistics).
4. Add authentication interceptors when accounts ship.

**Cross-cutting concerns:**

- Error taxonomy mapped to user-visible outcomes at presentation boundary.
- Pagination and filtering contracts for exercises and history screens.
- Idempotency strategy for session uploads where retries occur.

---

## 13. API integration plan

REST resources (illustrative paths; final naming versioned under `/v1/`):

| Domain area | Example responsibilities |
|-------------|-------------------------|
| Profiles | CRUD for user training profile |
| Exercises | Paginated catalog, filters, metadata |
| Workout plans | Templates and scheduled instances |
| Workout sessions | Start/finish payloads, completion records |
| Statistics | Server-derived aggregates if needed for social or integrity |
| Camera validation | Submission of clips or derived metrics; asynchronous results |
| Running routes | Geo tracks, elevation optional |
| Territories | Ownership polygons or tiles tied to validated routes |
| Challenges | Enrollment, scoring rules |
| Leaderboards | Rankings with Redis-backed fast reads |

Clients must tolerate **optional fields** and backward-compatible versioning.

---

## 14. Camera validation architecture

| Concern | Approach |
|---------|----------|
| Isolation | Lives only in `features/camera_validation` plus shared interfaces. |
| Boundary | Exposes a service that accepts capture configuration and returns **structured validation results** (scores, pass/fail flags, timestamps). |
| Coupling | Workout execution invokes the service through dependency injection; planning screens never import camera SDKs. |
| Pipeline | Capture → preprocess → model inference (on-device or server-assisted in future) → normalized result DTO → persisted via workout session repository if accepted. |
| Failure modes | Permission denial, thermal throttling, low light—handled with actionable UI states. |

This preserves replacement of inference backends without rewriting scheduling features.

---

## 15. AI coach architecture

| Concern | Approach |
|---------|----------|
| Isolation | All model or LLM calls reside behind `AiCoachService` or equivalent in `features/ai_coach` data layer. |
| UI rule | Presentation widgets send **intent** objects (goals, constraints); they never embed provider SDK keys or endpoints. |
| Domain mediation | Use cases validate suggestions against safety rules (volume caps, medical disclaimers managed by product/legal). |
| Output | Structured plan deltas or coaching messages mapped into domain entities before persistence. |
| Swappability | Providers change via configuration, not widget edits. |

---

## 16. Territory map architecture

| Concern | Approach |
|---------|----------|
| Separation | GPS sampling, map rendering, anti-cheat analytics, and territory rules split into distinct units inside `features/territory_map`. |
| Domain core | Pure functions or services compute eligibility and ownership updates from validated tracks. |
| UI | Map widgets subscribe to view models; they do not compute anti-cheat outcomes directly. |
| Anti-cheat | Server-assisted verification in future; client gathers sensor metadata per privacy policy. |
| Integration | Completed runs optionally emit session records consumable by statistics and challenges modules. |

---

## 17. Security considerations

| Topic | Requirement |
|-------|-------------|
| Secrets | API keys and tokens provided via secure build-time injection or OS secure storage—not committed source. |
| Transport | TLS for all remote calls when backend exists. |
| Authentication | Token refresh flows isolated in interceptors; no logging of bearer tokens. |
| Integrity | Certificate pinning considered for production builds handling competitive features. |
| Local storage | Sensitive tokens encrypted where platform APIs support it. |
| Supply chain | Dependency vetting and locked versions in CI. |

---

## 18. Privacy considerations

| Topic | Requirement |
|-------|-------------|
| Data minimization | Collect only fields needed for training features. |
| Location | GPS used only when territory or outdoor modules active; disclose in policy. |
| Camera | Explicit consent; explain retention of frames or derived metrics. |
| Profiles | Support local deletion and eventual remote deletion APIs. |
| Analytics | Anonymize identifiers; align with store policies. |

---

## 19. Performance considerations

| Area | Guidance |
|------|----------|
| UI thread | Async IO; avoid synchronous heavy work in build methods. |
| Lists | Virtualization for large exercise catalogs; image caching discipline. |
| Database | Indexes on date keys for calendar queries; batch writes after workouts. |
| Startup | Defer non-critical service initialization. |
| Battery | GPS and camera sessions use adaptive sampling where acceptable. |

---

## 20. Testing architecture

| Layer | Objective |
|-------|-----------|
| Unit | Domain rules, statistics calculations, validation logic |
| Repository | Fake implementations for deterministic scenarios |
| Widget | Critical flows (plan creation, workout completion toggles) |
| Integration | Golden path navigation across router |
| Future contract tests | HTTP fixtures against FastAPI OpenAPI schemas |

CI should run analyzer and tests on pull requests when GitHub Actions is adopted.

---

## 21. Build and deployment direction

| Stage | Direction |
|-------|-----------|
| Local builds | Debug and profile modes for iterative development |
| Release builds | Signed artifacts per platform stores |
| Configuration flavors | `dev`, `staging`, `prod` endpoints without code duplication |
| Containers | Backend services packaged in Docker; compose stacks for local integration |
| Automation | GitHub Actions pipelines for test, analyze, build; optional deployment gates |

Mobile release pipelines remain independent from backend deployment but share versioning discipline.

---

## 22. Architecture rules for Cursor

Automated assistants and contributors must:

1. Read `docs/00_PROJECT_RULES.md` and this architecture document before structural changes.  
2. Preserve **feature boundaries** and **layer directions** defined in Sections 5–6.  
3. Avoid introducing **direct network or AI calls** from presentation widgets (Sections 14–15).  
4. Keep **routing centralized** (Section 7) and **theme tokens centralized** (Section 9).  
5. Prefer **repository interfaces** when touching persistence or APIs (Sections 10–13).  
6. Treat camera, AI, and territory modules as **optional extensions** until MVP stability is confirmed (`docs/03_MVP_SCOPE.md`).  
7. Propose **package additions** only with justification; never install packages from documentation alone.  
8. Keep changes **minimal and reversible**; do not bundle large refactors with feature work.  
9. Run **`flutter analyze`** and verify **build success** after substantive edits when tooling is available.  
10. Summarize **touched files** after implementation sessions for reviewer traceability.

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial technical architecture baseline |

---

*End of document.*
