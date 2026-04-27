# GymCoach — MVP Scope (Strict)

**Product:** GymCoach (Flutter mobile application)  
**Document type:** Scope control and delivery baseline  
**Audience:** Product owner, engineering, design, QA, academic reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`

This document is authoritative for MVP boundaries. Anything not listed under MVP features or MVP technical scope is **out of scope** unless formally revised here.

---

## 1. MVP objective

Deliver a **working mobile application** that implements **one complete, end-to-end user scenario** suitable for a **student project timeline**: profile setup, exercise discovery, planning a workout for a date, executing the workout with completion tracking, and viewing simple statistics—all with **local persistence** and **no backend**.

Success for the MVP is **demonstrable utility on a device**, not feature parity with the full product vision.

---

## 2. MVP problem statement

Independent trainees need a **simple, reliable way** to turn intent into action: record who they are training for (basic profile), pick appropriate movements from a **small catalog**, **schedule** a session, **complete** it with clear progress markers, and **see** whether they are sticking to the plan over time.

The MVP validates that this loop works **offline-first** with **minimal complexity**.

---

## 3. Main MVP user scenario

**Primary scenario (must be complete):**

1. User launches the app and completes onboarding / profile setup (including goal, level, and frequency).  
2. User browses the exercise library and understands each exercise (muscle group, difficulty, equipment, short instructions).  
3. User creates a **planned workout** for a **selected date**: adds exercises, sets sets and repetitions, optional notes, saves.  
4. User opens the **calendar**, sees the planned workout on that date, opens details (planned vs completed state).  
5. User **starts** the workout, **marks** exercises or sets as completed, **finishes** and saves the **result**.  
6. User opens **statistics** and sees totals, completion rate, completed exercises, and **weekly** progress consistent with stored data.

If this scenario cannot be demonstrated on a physical device or officially supported emulator, the MVP is **not complete**.

---

## 4. MVP user journey

| Stage | User action | System outcome |
|-------|-------------|----------------|
| Entry | Open app first time | Onboarding / profile prompts |
| Profile | Enter age, weight, height (if used), goal, level, preferred frequency | Data persisted locally |
| Discovery | Browse / filter exercises | List and detail from local catalog |
| Planning | Pick date, build workout, set sets/reps/notes, save | Planned workout stored and linked to date |
| Orientation | View calendar | Dates show planned items; states visible |
| Execution | Start workout from plan | Session UI; per-set or per-exercise completion |
| Closure | Finish workout | Session saved as completed with linkage to plan/date |
| Insight | Open statistics | Aggregates and weekly view update from real data |

**Strict ordering for implementation:** persistence and domain model first where feasible, then library and profile screens, then planning and calendar, then execution, then statistics. UI polish follows working flows.

---

## 5. MVP feature list

### 5.1 Onboarding and profile setup (required)

| Feature | Detail |
|---------|--------|
| Age | Captured and stored |
| Weight | Captured and stored |
| Height | Include only if product/design needs it for messaging; otherwise optional field—**decision locked at build start** |
| Fitness goal | Single or limited set of enumerated goals |
| Training level | Enumerated level |
| Preferred training frequency | e.g., sessions per week; used for light UX hints only, not automated scheduling engines |

### 5.2 Exercise library (required)

| Field / behavior | MVP |
|------------------|-----|
| Exercise name | Required |
| Target muscle group | Required |
| Difficulty | Required |
| Short instruction | Required |
| Equipment requirement | Required |
| Optional image placeholder | Asset placeholder or empty state acceptable |
| Optional category filter | Simple filter by muscle group or category if time permits |

Catalog is **seeded locally** (bundled JSON/SQLite/static list). No CMS.

### 5.3 Workout plan creation (required)

| Feature | MVP |
|---------|-----|
| Select a date | Required |
| Add exercises from library | Required |
| Set sets | Required |
| Set repetitions | Required |
| Optional notes | Required |
| Save planned workout | Required |

One planned workout per date is acceptable if it simplifies the student scope; multiple per date is optional only if already supported without scope creep.

### 5.4 Calendar (required)

| Feature | MVP |
|---------|-----|
| View planned workouts by date | Required |
| Open workout details | Required |
| Completed vs planned state | Required visual distinction |

### 5.5 Workout execution (required)

| Feature | MVP |
|---------|-----|
| Start workout | Required |
| Mark each exercise completed | Required (may combine with set-level tracking below) |
| Track completed sets or full exercise completion | At least one clear model; both need not exist if one satisfies UX |
| Finish workout | Required |
| Save workout result | Required and reflected in calendar/statistics |

### 5.6 Statistics (required)

| Metric | MVP |
|--------|-----|
| Total planned workouts | Required |
| Completed workouts | Required |
| Completion rate | Required (defined as completed ÷ planned over agreed window, documented in implementation) |
| Completed exercises | Required |
| Weekly progress | Required (simple chart or list acceptable) |

### 5.7 Local persistence (required)

| Stored entity | MVP |
|---------------|-----|
| User profile | Required |
| Planned workouts | Required |
| Completed workout results | Required |
| Exercise data | Required (catalog + any user favorites only if in scope) |

No cloud sync.

---

## 6. MVP data model summary

Indicative entities (exact naming in code follows project conventions):

| Entity | Purpose |
|--------|---------|
| `UserProfile` | Age, weight, height (optional), goal, level, preferred frequency |
| `Exercise` | Catalog row: name, muscle group, difficulty, instruction, equipment, optional image key |
| `PlannedWorkout` | Date key, list of planned exercises with sets, reps, notes |
| `WorkoutSession` | Reference to plan/date, started/finished timestamps, completion records |
| `CompletionRecord` | Per exercise or per set flags as implemented |
| Derived stats | Computed from planned + session data for dashboard |

Schema migrations: keep **versioned** even for MVP to avoid demo-day data loss across iterations.

---

## 7. MVP screen list

| Screen | Purpose |
|--------|---------|
| Onboarding / welcome | Value proposition, entry to profile |
| Profile setup / edit | Capture MVP profile fields |
| Exercise list | Browse/filter catalog |
| Exercise detail | Instructions and metadata |
| Create / edit planned workout | Date picker, exercise picker, sets/reps/notes |
| Calendar | Month or agenda view with markers |
| Planned workout detail | Summary and state |
| Active workout | Execution flow, completion toggles |
| Workout summary | Post-finish confirmation |
| Statistics | Aggregates and weekly progress |
| Settings (minimal) | Optional: units, reset local data—only if required by course rubric |

Deep linking and excessive navigation polish are **not** required for MVP completion.

---

## 8. MVP technical scope

| Area | In scope | Out of scope |
|------|----------|--------------|
| Platform | Flutter/Dart, iOS and/or Android targets per course | Web desktop primary target |
| Architecture | Feature-based folders; UI vs state vs data separation per project rules | Microservices, separate backend repo |
| Persistence | Local database or equivalent (e.g., SQLite via drift/isar/hive—**package choice justified**) | PostgreSQL, Redis, remote DB |
| Auth | None | Backend authentication |
| Networking | Not required for core MVP | REST sync, WebSockets |
| Analytics | Optional stub only | Full production analytics pipeline |
| CI | Optional | Mandatory enterprise CI |

**Build quality:** `flutter analyze` and successful `flutter build` for chosen targets before demo.

---

## 9. MVP design scope

| Topic | MVP expectation |
|-------|-----------------|
| Visual design | Consistent spacing, typography, primary navigation pattern |
| Components | Reusable buttons, list tiles, form fields where duplicated |
| Responsiveness | Common phone widths; portrait-first acceptable if documented |
| Accessibility | Minimum touch targets; semantic labels on critical controls |
| Copy | English only; concise labels |
| Motion | Optional; no dependency on heavy animation |

Full brand system and dark/light themes are **optional** unless required by stakeholders.

---

## 10. MVP testing scope

| Layer | Minimum |
|-------|---------|
| Manual | Script covering Section 15 demo scenario on device |
| Unit | Core calculations for statistics and completion rate |
| Widget / integration | At least one golden path test optional but strongly encouraged |
| Regression | Re-run manual script before presentation |

Automated E2E on CI is **optional** for student MVP.

---

## 11. Features explicitly excluded from MVP

The following **must not** block MVP delivery and **must not** be implemented as part of the MVP baseline unless this document is formally updated:

- Full AI coach  
- Full-body pose validation for many exercises  
- Real-time multiplayer  
- Territory map ownership logic  
- Backend authentication  
- PostgreSQL integration  
- Redis  
- Payment system  
- Complex nutrition tracking  
- Full social network  
- Advanced analytics  

Any spike work on excluded items must remain **non-production branches** and must not replace MVP milestones.

---

## 12. Optional extensions

| Extension | Condition |
|-----------|-----------|
| Camera validation prototype | **Only after** main MVP scenario is stable on device: **one exercise only** (e.g., squats), proof-of-concept quality, clear consent and fallback when camera denied |
| Extra statistics charts | Only if core metrics already correct |
| Multiple workouts per day | Only if schedule remains simple |

Optional work **never** redefines MVP completion criteria.

---

## 13. Risk control

| Risk | Control |
|------|---------|
| Scope creep | This document is binding; new ideas go to backlog |
| Time overrun | Cut optional extensions first; simplify calendar UI second |
| Data loss | Local migrations tested; export/delete optional |
| Unclear completion rules | Section 14 is the checklist |
| Demo failure | Section 15 rehearsed on target hardware |

---

## 14. Definition of MVP completion

MVP is **complete** only when **all** apply:

1. **Device demo:** Primary scenario (Section 3) runs end-to-end on a mobile device or approved emulator without crashes in the happy path.  
2. **Features:** All items in Section 5 marked required are implemented.  
3. **Persistence:** App restart preserves profile, catalog usage, plans, and completed sessions appropriately.  
4. **Statistics:** Numbers match controlled test data (manual verification).  
5. **Quality:** Project builds successfully; static analysis addressed per course or team policy.  
6. **Documentation:** User-facing flow documented for demo (short README or user guide acceptable); technical notes align with actual behavior.  
7. **Exclusions respected:** No excluded backend or AI/map/social systems required to run the demo.

---

## 15. Demo scenario for presentation

**Title:** “Plan, train, measure”

**Duration target:** 3–5 minutes

**Steps:**

1. Reset or use a fresh profile; complete onboarding with realistic age, weight, goal, level, frequency.  
2. Open exercise library; filter or scroll; open one exercise detail.  
3. Create a workout for **tomorrow’s date** with **two exercises**, distinct sets and reps, add a note on one.  
4. Show calendar entry for that date; confirm **planned** state.  
5. Optionally advance device date for demo or use **today’s date** if policy allows—**consistent with stored plan**.  
6. Start workout; complete sets/exercises; finish; confirm **completed** state on calendar.  
7. Open statistics; show planned vs completed counts, completion rate, completed exercises count, weekly summary.

**Talking points:** Offline-first value, student-realistic scope, clear separation from future AI/camera/map features.

---

## Scope change protocol

Changes to MVP boundaries require:

1. Short rationale (time, risk, learning outcome).  
2. Explicit **add** or **remove** against Sections 5–8 and 11.  
3. Updated acceptance checklist impact (Section 14).

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial MVP scope baseline |

---

*End of document.*
