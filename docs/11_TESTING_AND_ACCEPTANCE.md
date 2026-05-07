# GymCoach — Testing and Acceptance

**Document type:** Quality assurance and acceptance specification  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Developers, QA reviewers, course graders, demo stakeholders  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/03_MVP_SCOPE.md`, `docs/09_UI_UX_GUIDELINES.md`, `docs/10_DEVELOPMENT_ROADMAP.md`

This document defines **how MVP quality is verified**. It contains **no implementation code**.

---

## 1. Testing goals

| Goal | Description |
|------|-------------|
| Demonstrable product | The project presents as a **working mobile application** on a physical device or officially supported emulator. |
| End-to-end MVP path | At least **one complete key user scenario** runs without blocking defects from start to statistics update. |
| Trust in local data | Profile, plans, sessions, and aggregates behave correctly across **app restarts**. |
| Predictable UX | Navigation, empty states, and errors match `docs/09_UI_UX_GUIDELINES.md` intent. |
| Controlled scope | Advanced features are tested **only** when implemented; otherwise noted as **future**. |
| Demo confidence | A repeatable **manual demo script** succeeds within a defined time window. |

Testing categories applied throughout:

1. Manual functional testing  
2. UI testing  
3. Data persistence testing  
4. Navigation testing  
5. Edge case testing  
6. Permission testing  
7. Performance testing  
8. Demo testing  

---

## 2. MVP acceptance scenario

**Primary scenario (must pass for MVP acceptance):**

A **new user** opens the app, **creates a training profile**, **views exercises**, **creates a workout plan for a date**, **completes the workout**, and **sees updated statistics** reflecting that completion.

This scenario is the **golden thread** for Sections 3–6 and Section 12.

---

## 3. Functional test cases

Each case uses **P0** (must pass for MVP), **P1** (should pass), **P2** (nice).

### TC-APP-01 — Cold launch

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | App installed; not running in foreground. |
| **Steps** | Launch app from launcher. |
| **Expected result** | App reaches first interactive screen (splash transitions or onboarding/home) without fatal error. |

### TC-APP-02 — Warm resume

| Field | Content |
|-------|---------|
| **Priority** | P1 |
| **Precondition** | App was backgrounded from mid-flow screen. |
| **Steps** | Return to app via recents. |
| **Expected result** | State restored or user sees clear recovery path; no corrupted navigation stack. |

### TC-NAV-01 — Primary destinations reachable

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Onboarding completed; profile exists. |
| **Steps** | From shell, open Home, Exercise library, Calendar, Statistics, Profile/Settings as implemented. |
| **Expected result** | Each destination renders meaningful content or guided empty state; back navigation behaves consistently. |

### TC-ONB-01 — First-time onboarding completion

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Fresh install or cleared app data. |
| **Steps** | Complete onboarding per design until profile setup or main gate. |
| **Expected result** | User understands next action; no blank terminal screens. |

### TC-PRF-01 — Profile create and save

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Fresh or incomplete profile path active. |
| **Steps** | Enter valid MVP fields (age, weight, goal, level, frequency); save. |
| **Expected result** | Confirmation or navigation forward; values visible on Profile screen. |

### TC-PRF-02 — Profile validation

| Field | Content |
|-------|---------|
| **Priority** | P1 |
| **Precondition** | Profile form open. |
| **Steps** | Attempt save with invalid fields (e.g., empty required, out-of-range numeric if enforced). |
| **Expected result** | Inline or summary errors; save blocked until corrected. |

### TC-EXL-01 — Exercise list loads

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Catalog seeded. |
| **Steps** | Open Exercise library. |
| **Expected result** | List displays exercises with names and key tags; scrolling usable. |

### TC-EXL-02 — Exercise detail

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Library open. |
| **Steps** | Open first exercise detail. |
| **Expected result** | Instructions and metadata visible; back returns to list. |

### TC-EXL-03 — Filter behavior (if implemented)

| Field | Content |
|-------|---------|
| **Priority** | P2 |
| **Precondition** | Filters exist. |
| **Steps** | Apply filter with matches and with no matches. |
| **Expected result** | Subsets correct; empty filter shows guidance per UI guidelines. |

### TC-PLN-01 — Create workout for date

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | At least two exercises in catalog. |
| **Steps** | Open plan creator; pick future date; add exercises; set sets/reps; add optional note; save. |
| **Expected result** | Save succeeds; plan retrievable for that date via calendar or equivalent. |

### TC-PLN-02 — Reject empty plan

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Plan creator open. |
| **Steps** | Attempt save with zero exercises. |
| **Expected result** | Validation prevents silent empty save; message explains requirement. |

### TC-CAL-01 — Planned workout visible

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | TC-PLN-01 succeeded. |
| **Steps** | Open Calendar; locate chosen date. |
| **Expected result** | Date shows planned indicator; open detail matches saved exercises. |

### TC-CAL-02 — Completed vs planned distinction

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | TC-EXE-01 completed for same planned workout. |
| **Steps** | Open Calendar for that date. |
| **Expected result** | UI distinguishes completed from merely planned per design (icon, color **plus** non-color cue). |

### TC-EXE-01 — Complete workout happy path

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Planned workout exists for accessible date. |
| **Steps** | Start workout; mark exercises or sets complete per UX; finish workout; confirm summary if shown. |
| **Expected result** | Session saved; calendar reflects completion; statistics inputs updated. |

### TC-EXE-02 — Abandon workout confirmation

| Field | Content |
|-------|---------|
| **Priority** | P1 |
| **Precondition** | Workout in progress with partial completion. |
| **Steps** | Attempt exit/back/abandon. |
| **Expected result** | Confirmation dialog; choosing cancel retains progress appropriately per product rules. |

### TC-STA-01 — Statistics after completion

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | TC-EXE-01 succeeded once. |
| **Steps** | Open Statistics. |
| **Expected result** | Completed workouts count increases; completion rate and weekly view reflect new data within defined formulas. |

### TC-PER-01 — Restart persistence smoke

| Field | Content |
|-------|---------|
| **Priority** | P0 |
| **Precondition** | Profile, plan, and completed session exist. |
| **Steps** | Force-close app; relaunch. |
| **Expected result** | Profile, planned items, and completion history still present; statistics consistent. |

---

## 4. UI test checklist

| Item | Pass criteria |
|------|----------------|
| Typography readability | Body text legible on smallest target device without system font scaling abuse. |
| Touch targets | Primary controls meet minimum size guidelines (`docs/09_UI_UX_GUIDELINES.md`). |
| Primary actions visible | Each MVP screen exposes an obvious primary action within one scroll where applicable. |
| Cards and spacing | Consistent padding; no accidental overlaps in portrait. |
| Dark/light | If only one theme ships, contrast still acceptable; no invisible text on cards. |
| Loading indicators | Skeleton or spinner present for slow loads; no indefinite blank screens. |
| Empty states | Headline + explanation + CTA on library/calendar/stats when appropriate. |
| Error banners | Actionable retry or navigation on persistence failures. |

---

## 5. Data persistence checklist

| Item | Pass criteria |
|------|----------------|
| Profile survives restart | Fields match last saved values. |
| Exercise catalog | Seeded data intact; IDs stable across launches. |
| Planned workouts | Correct linkage to dates after restart. |
| Session records | Completed session persists; calendar and stats agree. |
| Migration sanity | After internal schema bump (if any), app opens without crash or documented migration path executed. |
| Destructive reset | Settings reset (if present) clears expected entities only. |

---

## 6. Navigation checklist

| Item | Pass criteria |
|------|----------------|
| Back stack | Back from detail returns to list; no unexpected exit to launcher except root. |
| Deep duplication | Starting workout twice from same plan handled per rules (resume vs new session). |
| Tab state | Bottom nav preserves section state where specified. |
| Modal dismissal | Sheets/dialogs dismiss without leaving orphan routes. |

---

## 7. Edge case checklist

| Item | Pass criteria |
|------|----------------|
| First-ever launch | No reliance on missing profile without onboarding path. |
| Large exercise list | Scroll performance acceptable for MVP catalog size. |
| Same-day multiple sessions | Behavior defined (allowed or blocked) and consistent. |
| Device rotation | If supported, layouts do not lose inputs; if locked portrait, no broken landscape. |
| System date change | Calendar and statistics definitions documented; no silent corruption. |
| Low storage | Graceful failure saving with user-visible message (best effort). |
| Airplane mode | Core MVP flows remain usable offline. |

---

## 8. Future permission test checklist

Apply **only** when corresponding features ship.

| Flow | Preconditions | Steps | Expected |
|------|---------------|-------|----------|
| Camera permission education | Camera feature entry available | Open camera validation; observe pre-prompt screen | Rationale clear before OS dialog |
| Camera denied | Permission denied once | Attempt validation | Manual fallback or alternate path offered |
| Camera granted | Permission granted | Start preview | Preview stable; no crash on rotate |
| GPS / location foreground | Territory or route mode | Start tracking | Accuracy messaging visible |
| GPS denied | Denied | Attempt capture | Cannot proceed with territory claim; explanation shown |
| Background location | If implemented | Background continuation | OS disclosures satisfied; user aware |

---

## 9. Performance checklist

| Item | Pass criteria |
|------|----------------|
| Cold start | Acceptable time to interact on reference device (team-defined threshold). |
| Library scroll | No sustained jank scrolling MVP list. |
| Workout execution | Interactions respond without perceptible multi-second stalls. |
| Statistics aggregation | Dashboard computes within acceptable delay after session completes. |
| Memory | No continuous growth across repeated session cycles in manual soak (short session repetition). |

---

## 10. Demo checklist

| Item | Pass criteria |
|------|----------------|
| Script readiness | Demo follows `docs/03_MVP_SCOPE.md` Section 15 or equivalent scripted path. |
| Clean data option | Ability to reset or use scripted profile for predictable numbers. |
| Build flavor | Release/profile build without debug clutter if presenting externally. |
| Backup plan | Screen recording available if hardware fails. |
| Timing | Run-through completes within presentation slot. |

---

## 11. Release checklist

| Item | Pass criteria |
|------|----------------|
| Analyzer | `flutter analyze` clean or waivers documented with owner. |
| Build | Successful build for each targeted platform (iOS and/or Android). |
| Version label | Settings shows version/build identifier. |
| Known issues list | Documented for reviewers (non-blocking vs blocking). |
| Privacy posture | No secrets in repo; permissions justified in shipped features. |
| Scope honesty | Future features not presented as complete unless gated prototypes labeled. |

---

## 12. Definition of accepted MVP

The MVP is **accepted** when **all** P0 items below are satisfied and **no unresolved P0 defect** blocks the primary scenario.

### Acceptance criteria by area

| Area | Acceptance criteria |
|------|---------------------|
| **Onboarding** | First launch guides user forward; skip rules (if any) do not trap user; English copy consistent with project rules. |
| **Profile setup** | Required MVP fields captured, validated, visible after save, and restorable after restart. |
| **Exercise library** | Seeded catalog browseable; detail view complete for MVP fields; empty/filter states guided if applicable. |
| **Workout creation** | User assigns date, adds exercises, configures sets/reps (and notes if in scope), saves successfully; invalid saves blocked with clear errors. |
| **Calendar** | Planned workouts appear on correct dates; detail opens reliably; completed vs planned visually distinct with redundancy beyond color. |
| **Workout execution** | Session starts from plan; completion marks persist through finish; abandon path safe; summary or calendar confirms completion. |
| **Statistics** | Metrics update after completion; weekly view meaningful; empty state explains prerequisites. |
| **Local persistence** | Cold restart preserves profile, plans, sessions, and coherent statistics. |
| **App stability** | Primary scenario completes twice consecutively without crash or data loss. |
| **Demo readiness** | Demo checklist (Section 10) passes on presentation hardware. |

### Future feature testing notes

Document-level expectations when features graduate from roadmap:

| Feature | Testing focus |
|---------|----------------|
| **Camera permission** | Pre-education, denial, revoke mid-session, thermal throttling messaging. |
| **Camera validation** | Correct vs incorrect rep classification sanity suite per exercise profile; manual fallback parity. |
| **GPS permission** | Accuracy gating before territory eligibility; background disclosures. |
| **Route tracking** | Pause/resume; gap handling; battery warnings. |
| **Anti-cheat** | Synthetic tracks produce expected accept/reject codes; user-facing explanations non-accusatory. |
| **AI coach output validation** | Schema validation of structured plan; unsafe content filtered per product rules; edit-before-save enforced. |

---

## Traceability summary

| Artifact | Links to |
|----------|----------|
| Manual cases Section 3 | MVP scenario Section 2 |
| Checklists Sections 4–11 | UX guidelines and roadmap |
| MVP acceptance Section 12 | `docs/03_MVP_SCOPE.md` definition of completion |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial testing and acceptance baseline |

---

*End of document.*
