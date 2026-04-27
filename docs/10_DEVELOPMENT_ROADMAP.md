# GymCoach — Development Roadmap

**Document type:** Implementation roadmap  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Student developers, technical supervisors, reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`, `docs/09_UI_UX_GUIDELINES.md`

This roadmap assumes starting from a **minimal or empty Flutter project** and delivering a **working MVP** on device. It contains **no implementation code**.

**Ordering rule:** Advanced capabilities (camera validation beyond optional prototype, AI coach, territory map, backend, social features, leaderboards) **must not** precede or block the core MVP unless explicitly approved.

---

## 1. Roadmap overview

| Dimension | Summary |
|-----------|---------|
| Goal | A demo-ready mobile app: profile → exercises → plan → calendar → execution → statistics with **local persistence**. |
| Structure | Twelve phases: foundation through polish (MVP), optional camera prototype, future backend planning. |
| Constraint | Each phase produces **working software** or **documented decisions**; avoid speculative architecture depth before flows exist. |
| Quality bar | Successful device run-through of the primary scenario (`docs/03_MVP_SCOPE.md`); `flutter analyze` and build succeed per team policy. |

Legend used in phases:

- **Priority:** P0 (must), P1 (should), P2 (nice)
- **Difficulty:** Low / Medium / High (relative to a student timeline)

---

## 2. Phase-by-phase plan

### Phase 1: Project foundation

| Aspect | Detail |
|--------|--------|
| **Objective** | Establish conventions, structure, and visual/navigation skeleton so later features plug in cleanly. |
| **Tasks** | Confirm docs (`docs/*`) and rules are read; align `lib/` with feature-first layout (`docs/04_TECH_ARCHITECTURE.md`); add theme tokens (colors, type, spacing targets); register centralized router with placeholder routes. |
| **Priority** | P0 |
| **Difficulty** | Low–Medium |
| **Dependencies** | Flutter SDK installed; empty/default project runs. |
| **Expected output** | Runnable app with themed shell and named routes; folder scaffold matches architecture doc. |
| **Definition of done** | App launches; theme applied globally; navigation between placeholder destinations works; project passes analyzer with no unexplained violations. |
| **Risks** | Over-building folder depth before first screen—mitigate by keeping empty features minimal until Phase 2–3. |

### Phase 2: Core UI shell

| Aspect | Detail |
|--------|--------|
| **Objective** | Deliver the persistent **app layout** and shared widgets matching `docs/09_UI_UX_GUIDELINES.md`. |
| **Tasks** | Bottom nav or equivalent primary shell; scaffold with safe areas; shared buttons, cards, list rows, section headers; stub screens wired to navigation. |
| **Priority** | P0 |
| **Difficulty** | Medium |
| **Dependencies** | Phase 1 complete. |
| **Expected output** | Users can move among main tabs/sections with consistent chrome. |
| **Definition of done** | No dead-end navigation from shell; reusable components used by stubs; responsive on one reference phone size. |
| **Risks** | Navigation rework later—mitigate by freezing route names early. |

### Phase 3: Onboarding and profile

| Aspect | Detail |
|--------|--------|
| **Objective** | Capture MVP profile fields and persist locally (initially may use simple storage upgraded in Phase 9). |
| **Tasks** | Onboarding flow; profile form (age, weight, height optional, goal, level, preferred frequency); validation UX; save path via repository abstraction. |
| **Priority** | P0 |
| **Difficulty** | Medium |
| **Dependencies** | Phase 2 shell; domain/repo interfaces defined lightly in Phase 1–2. |
| **Expected output** | First-run experience completes; profile visible/edit later from Profile screen. |
| **Definition of done** | Data survives hot restart when persistence layer exists (or documented interim limit until Phase 9); empty/error states per UI guidelines. |
| **Risks** | Schema churn—use stable field names aligned with `docs/08_DATA_MODEL_AND_API_PLAN.md`. |

### Phase 4: Exercise library

| Aspect | Detail |
|--------|--------|
| **Objective** | Provide browseable **Exercise** catalog from mock or seeded data. |
| **Tasks** | Exercise entity/model; mock seed list; list UI with cards; detail screen; optional category/muscle filter chips. |
| **Priority** | P0 |
| **Difficulty** | Medium |
| **Dependencies** | Phase 2–3 (routing and shared widgets). |
| **Expected output** | Users can open library and inspect exercises meaningfully. |
| **Definition of done** | Catalog loads without frame drops on scroll for MVP list sizes; detail shows all MVP fields from scope doc. |
| **Risks** | Asset weight if images added—use placeholders first. |

### Phase 5: Workout plan creation

| Aspect | Detail |
|--------|--------|
| **Objective** | Let users compose a **planned workout** for a selected date with sets, reps, notes. |
| **Tasks** | Date picker; exercise picker from catalog; line editor for sets/reps/rest/notes; save as planned workout linked to date and optional template model. |
| **Priority** | P0 |
| **Difficulty** | Medium–High |
| **Dependencies** | Phase 4 exercises; repository contracts for plans. |
| **Expected output** | Saved plan appears in data layer and can be retrieved by date. |
| **Definition of done** | Cannot save zero-exercise plan; validation messages clear; aligns with `docs/03_MVP_SCOPE.md`. |
| **Risks** | UX complexity—keep single-plan-per-date unless already trivial to extend. |

### Phase 6: Calendar

| Aspect | Detail |
|--------|--------|
| **Objective** | Visualize **planned** workouts on dates and open details; distinguish **completed** vs planned. |
| **Tasks** | Calendar or agenda view; markers per date; navigate to planned workout detail; reflect completion status from sessions when present. |
| **Priority** | P0 |
| **Difficulty** | Medium–High |
| **Dependencies** | Phase 5 planned workouts; session status linkage stubbed until Phase 7 but UI slot reserved. |
| **Expected output** | Scheduled workouts visible on correct dates. |
| **Definition of done** | Tapping a marked date opens consistent detail screen; empty month explains next action. |
| **Risks** | Third-party calendar packages—justify any dependency; fallback to list-by-date acceptable for MVP. |

### Phase 7: Workout execution

| Aspect | Detail |
|--------|--------|
| **Objective** | Execute a session: start → mark completion → finish → persist **WorkoutSession** and **ExerciseResult**. |
| **Tasks** | Execution screen with progression; per-exercise or per-set completion per chosen model; finish flow; link session to planned workout; handle abandon confirm. |
| **Priority** | P0 |
| **Difficulty** | High |
| **Dependencies** | Phase 5–6; persistence from Phase 9 ideally landed in parallel or incrementally (start with in-memory then migrate—prefer completing Phase 9 before polish). |
| **Expected output** | Completed workout updates calendar state and feeds statistics inputs. |
| **Definition of done** | No silent loss of completions on save failure; summary screen after finish (Phase connects to completion summary UX). |
| **Risks** | State bugs across app resume—test backgrounding during execution manually. |

### Phase 8: Statistics

| Aspect | Detail |
|--------|--------|
| **Objective** | Surface aggregates: planned totals, completed totals, completion rate, completed exercises, weekly progress. |
| **Tasks** | Derive metrics from local repositories; statistics screen with cards/simple chart; weekly filter MVP. |
| **Priority** | P0 |
| **Difficulty** | Medium |
| **Dependencies** | Phase 5–7 data completeness; Phase 9 for accuracy across restarts. |
| **Expected output** | Metrics match controlled manual test data. |
| **Definition of done** | Empty statistics state guides user to first completion; formulas documented in QA notes. |
| **Risks** | Definition drift on completion rate—document denominator (e.g., planned in window vs total planned). |

### Phase 9: Local persistence

| Aspect | Detail |
|--------|--------|
| **Objective** | Replace mocks/in-memory stores with **durable** local storage and migrations. |
| **Tasks** | Implement repository backends for profile, exercises seed, plans, planned workouts, sessions, results; migration/version strategy; optional reset in settings. |
| **Priority** | P0 |
| **Difficulty** | High |
| **Dependencies** | Stable entity shapes from Phases 3–8; aligns with `docs/08_DATA_MODEL_AND_API_PLAN.md` MVP entities. |
| **Expected output** | Cold start restores user state; reinstall expectations documented (loss acceptable for student MVP unless export added). |
| **Definition of done** | Kill app and relaunch: profile, plans, completions intact; analyzer clean. |
| **Risks** | Late introduction causes rework—start repository interfaces in Phase 1 and swap implementations incrementally. |

### Phase 10: Testing and polish

| Aspect | Detail |
|--------|--------|
| **Objective** | Stabilize for grading and demo: manual QA, edge cases, UI consistency, performance sanity. |
| **Tasks** | Manual test script covering primary scenario; edge cases (empty catalog, midnight rollover, edit mid-plan); UI polish per guidelines; jank check on low-end device if available; optional widget/unit tests for calculations. |
| **Priority** | P0 |
| **Difficulty** | Medium |
| **Dependencies** | Phases 1–9 feature-complete for MVP scope. |
| **Expected output** | Known defect list triaged; demo build artifact. |
| **Definition of done** | Primary scenario passes twice on device; `flutter analyze` clean; release/debug build succeeds for target platform. |
| **Risks** | Scope creep—defer cosmetics below blocker bugs. |

### Phase 11: Optional camera prototype

| Aspect | Detail |
|--------|--------|
| **Objective** | **Only if** Phase 10 stable: single-exercise (e.g., squat) proof-of-concept aligned with `docs/05_FEATURE_CAMERA_VALIDATION.md`. |
| **Tasks** | Permission education screen; preview; stub or lightweight pose/rep logic; manual fallback; clearly labeled experimental UI. |
| **Priority** | P2 |
| **Difficulty** | High |
| **Dependencies** | MVP demo-ready; legal/safety copy present. |
| **Expected output** | Demo path optional branch; does not break core flows when skipped. |
| **Definition of done** | Feature flag or isolated entry; graceful denial paths; no regression in Phases 3–10 flows. |
| **Risks** | Time sink and hardware variance—acceptable only if schedule allows. |

### Phase 12: Future backend planning

| Aspect | Detail |
|--------|--------|
| **Objective** | Produce **planning artifacts** for FastAPI, PostgreSQL, Redis, Docker, GitHub Actions—no requirement to implement server in student MVP timeline unless course mandates. |
| **Tasks** | Finalize REST sketches (`docs/08_DATA_MODEL_AND_API_PLAN.md`); ERD refinement; Redis use cases; container sketch for API + DB; CI workflow outline (lint, test, build). |
| **Priority** | P1 (documentation) / P2 (implementation) |
| **Difficulty** | Medium (planning only) |
| **Dependencies** | Stable client domain models from MVP. |
| **Expected output** | Written plan suitable for future sprint breakdown; optional prototype repo outside critical path. |
| **Definition of done** | Reviewer can trace entities from mobile to proposed endpoints; risks recorded. |
| **Risks** | Premature backend coding steals MVP time—keep deliverable **document-first** unless explicitly requested. |

---

## 3. Priority table

| Phase | Priority | Rationale |
|-------|----------|-----------|
| 1 Foundation | P0 | Blocks consistent delivery |
| 2 UI shell | P0 | User-visible structure |
| 3 Profile | P0 | MVP scenario start |
| 4 Exercises | P0 | Planning dependency |
| 5 Plan creation | P0 | Core authoring |
| 6 Calendar | P0 | Scheduling visibility |
| 7 Execution | P0 | Completion loop |
| 8 Statistics | P0 | Progress proof |
| 9 Persistence | P0 | Realistic product behavior |
| 10 Polish | P0 | Demo quality |
| 11 Camera prototype | P2 | Explicitly optional |
| 12 Backend planning | P1 docs / P2 code | After MVP clarity |

---

## 4. Dependency map

```text
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5 ──► Phase 6 ──┐
                                                                      │
                                                      Phase 9 ◄───────┼──► integrates with 3–8
                                                                      │
                                                                      ▼
                                                             Phase 7 ──► Phase 8
                                                                      │
                                                                      ▼
                                                             Phase 10 (gates MVP)

Phase 11 optional ─ depends on Phase 10 complete
Phase 12        ─ depends on MVP domain stability (after Phase 9–10)
```

**Note:** Phase 9 can begin incrementally once entities stabilize (after Phase 3 earliest); aim for full durability before treating MVP as done.

---

## 5. MVP milestone

**MVP milestone achieved when:**

- Phases **1–10** are complete per each phase’s definition of done.
- Primary user scenario runs **end-to-end on a mobile device** (`docs/03_MVP_SCOPE.md` Section 15).
- Local persistence restores critical objects after app restart.
- Documentation reflects actual behavior at a high level (README or short user note acceptable).

---

## 6. Optional extension milestones

| Milestone | Contains |
|-----------|----------|
| Camera prototype | Phase 11 only; single exercise; non-blocking |
| Backend readiness | Phase 12 planning deliverables; implementation is separate project phase |

---

## 7. What must not be built early

| Item | Reason |
|------|--------|
| FastAPI/PostgreSQL/Redis production paths | Diverts time before client loop works |
| AI coach surfaces | Depends on structured plans and backend policies |
| Territory map / GPS anti-cheat | Heavy product + compliance surface |
| Social feeds, multiplayer, leaderboards | Backend and moderation burden |
| Full camera validation catalog | ML and QA scope explosion |
| Payments, accounts, OAuth (unless course-required) | Not MVP per scope docs |

Spikes must stay **non-integrated** or behind flags until MVP milestone passes.

---

## 8. Recommended implementation order

Strict sequence for core path:

1. Phase **1 → 2** (foundation + shell)  
2. Phase **3 → 4** (profile + exercises)  
3. Phase **5 → 6** (plans + calendar)  
4. Phase **7** (execution)—overlap Phase **9** persistence implementation **starting no later than first execution prototype**  
5. Phase **8** (statistics)  
6. Close Phase **9** if any interim storage remains in-memory  
7. Phase **10**  
8. Phase **11** only if time and stability allow  
9. Phase **12** documentation anytime after entities stabilize; implementation later  

---

## 9. Demo preparation plan

| Step | Action |
|------|--------|
| 1 | Freeze scope one week before demo; list known bugs explicitly. |
| 2 | Prepare fresh profile data storyline (believable age/weight/goal). |
| 3 | Pre-create **optional** second plan if live typing risky under time pressure. |
| 4 | Rehearse **Section 15** demo script from `docs/03_MVP_SCOPE.md` with timer. |
| 5 | Capture backup screen recording if live demo hardware uncertain. |
| 6 | Run release/profile build on demo device; disable debug banners. |
| 7 | Verify airplane-mode behavior showcases offline MVP strength. |

---

## 10. Final delivery checklist

| Item | Check |
|------|-------|
| Primary scenario works on device | ☐ |
| Profile persists across restart | ☐ |
| Plans and completions persist across restart | ☐ |
| Statistics consistent with test cases | ☐ |
| `flutter analyze` addressed | ☐ |
| App builds for intended platform(s) | ☐ |
| UI follows spacing/contrast baselines | ☐ |
| Empty and error states reviewed | ☐ |
| README or equivalent documents run instructions | ☐ |
| Advanced features not falsely implied as complete | ☐ |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial development roadmap |

---

*End of document.*
