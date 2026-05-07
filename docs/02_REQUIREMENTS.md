# GymCoach — Requirements Specification

**Document type:** Product and engineering requirements  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Analysts, product managers, Flutter developers, designers, backend developers, testers  
**Language:** English only (see `docs/00_PROJECT_RULES.md`)

---

## 1. Project overview

GymCoach is a mobile fitness coaching application built with Flutter/Dart. It supports individuals who want structured training: defining goals, browsing exercises, assembling workouts and programs, scheduling sessions, executing workouts, and reviewing progress through statistics.

The project follows a full product lifecycle mindset: user problem research, requirements gathering, MVP selection, design, technical planning, development, testing, launch, success measurement, and maintained documentation—not only shipping code.

**Required project result:** A working application on a mobile device that implements core user scenarios end-to-end for the MVP scope defined in Section 8.

**Evaluation criteria (program-level):**

| Criterion | Description |
|-----------|-------------|
| Device usability | The app runs and is usable on a physical or emulated mobile device. |
| Implemented scenarios | At least one key user scenario is fully implemented; MVP targets multiple scenarios in Section 11. |
| Problem definition | The user problem is defined and assumptions are validated or documented (Section 3). |
| Success metrics | Measurable outcomes are formulated (Section 15). |
| Testing | The solution is tested per acceptance criteria (Section 12). |
| Documentation | Technical and user-facing documentation exists and aligns with implementation (`docs/` and in-app copy policy). |

---

## 2. Business goal

Establish GymCoach as a credible training companion that increases user adherence to personal workouts through clear planning, scheduling, and visible progress—without requiring backend infrastructure for the MVP where local persistence suffices.

Long-term business intent includes differentiated features (AI coaching, camera validation, challenges, social and map-based running). Those are explicitly deferred until the core MVP is stable unless separately approved.

---

## 3. User problem

**Problem statement:** People who train independently often lack a single place to turn intentions into repeatable plans, remember what to do each session, see how consistency improves over time, and align exercises with a stated goal (e.g., strength, endurance, general fitness).

**Pain points:**

- Fragmented notes, spreadsheets, or memory-based tracking.
- Difficulty scheduling workouts alongside daily life.
- Unclear link between chosen exercises and personal goals.
- Low motivation without visible progress.

**Validation approach:** Problem assumptions should be validated through lightweight research (interviews, surveys, or prototype feedback) and documented; MVP metrics (Section 15) confirm whether the product reduces friction for planning and completion.

---

## 4. Stakeholders

| Stakeholder | Interest |
|-------------|----------|
| End users (trainees) | Simple flows, reliable workouts, progress clarity. |
| Product / program owner | MVP scope control, roadmap, metrics. |
| Engineering (Flutter) | Clear requirements, stable architecture, testability. |
| Design | UX consistency, accessibility, responsive layouts. |
| Backend / platform (future) | Sync APIs, identity, content governance when introduced. |
| QA / testers | Traceable acceptance criteria, reproducible scenarios. |
| Compliance / security advisors (as needed) | Privacy, data handling, permission minimization. |

---

## 5. User roles

| Role | Description | MVP relevance |
|------|-------------|---------------|
| **Guest user** | Uses the app without an authenticated account; data stored locally on device. | MVP: primary path for local-first MVP. |
| **Registered user** | Authenticated identity reserved for future backend-linked accounts and sync. | Future; define flows and data model hooks without blocking MVP. |
| **Active trainee** | Creates plans, schedules sessions, completes workouts, reviews statistics. | MVP: core persona. |
| **Challenge participant** | Joins competitive or structured challenges (social or leaderboard-style). | Future. |
| **Admin / content manager** | Curates exercise library, policies, or featured content via tools or backend. | Future; only if centralized content governance is adopted. |

---

## 6. Functional requirements

Identifiers use `FR-xxx` for traceability.

### 6.1 Onboarding

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-ONB-01 | First launch presents a concise value proposition and primary actions (continue as guest, optional future sign-in placeholder). | Yes |
| FR-ONB-02 | User can complete or skip non-blocking onboarding steps according to product rules without losing core access. | Yes |
| FR-ONB-03 | Onboarding respects accessibility basics (readable text, sufficient contrast per design system). | Yes |

### 6.2 User profile setup

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-PRF-01 | User can create or edit a profile with fields agreed in design (e.g., display name, optional demographics only if needed). | Yes |
| FR-PRF-02 | User can select at least one fitness goal (e.g., strength, endurance, general fitness, mobility). | Yes |
| FR-PRF-03 | User can select training level or experience band (e.g., beginner, intermediate, advanced). | Yes |
| FR-PRF-04 | Profile data persists locally for guest users. | Yes |
| FR-PRF-05 | Profile syncs to backend when accounts exist. | Future |

### 6.3 Exercise library

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-EXL-01 | App provides a browsable exercise catalog with name, muscle groups or tags, and execution hints as defined by content. | Yes |
| FR-EXL-02 | User can filter or search exercises by goal-relevant attributes where implemented. | Yes |
| FR-EXL-03 | Exercises can be marked as favorites or recently used if specified by UX. | Optional MVP |
| FR-EXL-04 | Remote content updates via backend or CMS. | Future |

### 6.4 Workout plan creation

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-WKP-01 | User can create a named workout plan (template). | Yes |
| FR-WKP-02 | User can add exercises to a plan with ordering and prescribed parameters (sets, reps, duration, rest as applicable). | Yes |
| FR-WKP-03 | User can build multi-session programs by grouping plans or scheduling recurring logic per agreed model. | MVP: minimal program structure |
| FR-WKP-04 | User can duplicate or edit existing plans. | Yes |
| FR-WKP-05 | Plans respect selected goal and level where rules engine or filtering applies. | Yes |

### 6.5 Calendar scheduling

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-CAL-01 | User can assign a workout plan to a calendar date. | Yes |
| FR-CAL-02 | User can view upcoming and past scheduled sessions. | Yes |
| FR-CAL-03 | User can reschedule or cancel a scheduled session without losing the underlying plan template. | Yes |
| FR-CAL-04 | Optional reminders integrate with OS notification APIs when approved. | Optional MVP |

### 6.6 Workout execution

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-EXE-01 | User can start a scheduled or ad-hoc workout session from a plan. | Yes |
| FR-EXE-02 | During execution, user sees current exercise, parameters, and navigation (next, previous, complete session). | Yes |
| FR-EXE-03 | Session can be paused or abandoned with state rules defined by UX (save partial progress vs discard). | Yes |
| FR-EXE-04 | Timers or rest periods appear if specified by plan design. | Optional MVP |

### 6.7 Exercise completion tracking

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-TRK-01 | User can mark each exercise set or exercise as completed during a session. | Yes |
| FR-TRK-02 | Completion timestamps or ordinal completion order are stored for statistics. | Yes |
| FR-TRK-03 | Editing completion after session end follows explicit rules (allowed window or read-only). | Design decision |

### 6.8 Statistics

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-STA-01 | User can view weekly aggregates (sessions completed, exercises completed, time trained if captured). | Yes |
| FR-STA-02 | User can view trends over selectable periods where data exists. | MVP: at least weekly |
| FR-STA-03 | Statistics reflect only local data for guest users. | Yes |
| FR-STA-04 | Cross-device statistics when sync exists. | Future |

### 6.9 Local data persistence

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-DAT-01 | Profiles, plans, schedules, sessions, and completions persist across app restarts. | Yes |
| FR-DAT-02 | Data migrations preserve user content on app updates when schema evolves. | Yes |
| FR-DAT-03 | User can export or delete local data per privacy requirements. | MVP: delete path minimum |

### 6.10 Settings

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-SET-01 | User can adjust preferences defined by product (units, theme if applicable, notification toggles). | Yes |
| FR-SET-02 | User can view app version and legal or informational links as required. | Yes |

### 6.11 Future: camera validation

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-CAM-01 | Capture pose or movement via device camera; compare to reference or heuristic model. | No |
| FR-CAM-02 | Provide real-time feedback on form quality or repetition eligibility. | No |
| FR-CAM-03 | Clear consent and performance fallback when camera unavailable. | No |

### 6.12 Future: AI coach

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-AI-01 | Generate or adapt workout plans based on goals, fatigue signals, or history. | No |
| FR-AI-02 | Natural-language coaching prompts with safety guardrails. | No |

### 6.13 Future: running map

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-MAP-01 | Territory capture along GPS-tracked routes with map visualization. | No |
| FR-MAP-02 | GPS anti-cheat or integrity signals for competitive modes. | No |

### 6.14 Future: backend sync

| ID | Requirement | MVP |
|----|-------------|-----|
| FR-SYN-01 | Authenticated sync of profile, plans, sessions, and statistics. | No |
| FR-SYN-02 | Conflict resolution strategy documented and implemented. | No |
| FR-SYN-03 | Admin-driven exercise catalog updates propagate to clients. | No |

---

## 7. Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-PERF-01 | Performance | Cold start and primary navigation remain responsive on mid-tier devices; list scrolling stays smooth for catalog sizes defined in test data. |
| NFR-PERF-02 | Performance | Heavy work (IO, aggregation) avoids blocking the UI thread; async patterns per Flutter best practices. |
| NFR-USE-01 | Usability | Primary tasks achievable in few steps; copy is concise and consistent (English). |
| NFR-RES-01 | Mobile responsiveness | Layouts adapt to common phone sizes and orientations per product decision (portrait-first acceptable if documented). |
| NFR-REL-01 | Reliability | No unhandled exceptions in core flows; crashes rare and actionable via logs in debug builds. |
| NFR-MNT-01 | Maintainability | Feature-based structure; separation of UI, state, domain, and data per project rules. |
| NFR-SCL-01 | Scalability | Data model and repositories tolerate growth in exercises and history without prohibitive rebuilds. |
| NFR-PRV-01 | Privacy | Collect minimal data; document what is stored locally; no secrets in repo. |
| NFR-SEC-01 | Security | Secure handling of credentials when backend arrives; local storage uses appropriate APIs. |
| NFR-ACC-01 | Accessibility | Touch targets, scalable text support, semantic labels for key controls as feasible in MVP. |
| NFR-OFF-01 | Offline-friendly MVP | Core creation, scheduling, execution, and statistics work without network for MVP. |
| NFR-TST-01 | Testability | Business logic unit-testable; critical flows covered by widget or integration tests as agreed. |

---

## 8. MVP requirements

The MVP MUST deliver:

1. Guest-first experience with local persistence (FR-DAT-01, FR-ONB-01).  
2. Profile setup including goal and level (FR-PRF-01–FR-PRF-04).  
3. Exercise library sufficient for realistic demos (FR-EXL-01–FR-EXL-02).  
4. Workout plan creation and editing (FR-WKP-01–FR-WKP-05 scoped to minimal program structure).  
5. Calendar scheduling for assigning plans to dates (FR-CAL-01–FR-CAL-03).  
6. Workout execution with navigation and completion marking (FR-EXE-01–FR-EXE-03, FR-TRK-01–FR-TRK-02).  
7. Weekly progress statistics (FR-STA-01–FR-STA-03).  
8. Settings essentials (FR-SET-01–FR-SET-02).  
9. Compliance with non-functional MVP expectations (Section 7): offline-first core, responsiveness, basic accessibility, testability.

MVP explicitly excludes AI coach, camera validation, repetition counting beyond manual marking, social competition, running map, GPS anti-cheat, and backend sync unless separately approved.

---

## 9. Future requirements

Summarized from Sections 6 and 8; planned after MVP stability:

| Theme | Capabilities |
|-------|----------------|
| AI workout coach | FR-AI-01, FR-AI-02 |
| Camera and reps | FR-CAM-01–FR-CAM-03; automated repetition counting |
| Challenges and social | Challenge participation; competition mechanics |
| Running map | FR-MAP-01 |
| GPS integrity | FR-MAP-02 |
| Backend and roles | FR-SYN-01–FR-SYN-03; registered user; admin/content tools |

---

## 10. Out-of-scope features for MVP

| Item | Rationale |
|------|-----------|
| Server-side accounts and sync | Deferred until API and conflict strategy exist. |
| AI-generated programming | Safety, scope, and infra not assumed for MVP. |
| Camera pose validation | Hardware variance and ML scope. |
| Social feeds and leaderboards | Moderation and backend complexity. |
| Territory running game | Maps, GPS policies, anti-cheat. |
| Full CMS for exercises | Local or bundled catalog for MVP. |

---

## 11. User scenarios

### MVP scenarios

**Scenario 1 — First-time profile**  
A user opens the app for the first time, completes onboarding, creates a profile, selects a fitness goal and training level, and lands on the main training surface with persistent profile data.

**Scenario 2 — Goal and level**  
A user adjusts fitness goal or training level in settings or profile; subsequent recommendations or filters for exercises and templates reflect the change where implemented.

**Scenario 3 — Browse exercises**  
A user opens the exercise library, searches or filters, opens exercise details, and optionally adds an exercise to a new or existing plan.

**Scenario 4 — Plan for a date**  
A user creates a workout plan, adds exercises with parameters, assigns the plan to a chosen calendar date, and sees it in the upcoming schedule.

**Scenario 5 — Complete workout**  
A user starts the workout from the schedule, moves through exercises, marks completion for sets or exercises, finishes the session, and sees the session recorded.

**Scenario 6 — Weekly progress**  
A user opens statistics, selects the current week, and sees aggregates aligned with completed sessions and exercises.

### Future scenarios

**Scenario 7 — Camera-validated exercise**  
A user enables camera permission, performs an exercise with live validation feedback, and receives guidance or pass/fail against criteria defined when the feature ships.

**Scenario 8 — Territory run**  
A user starts an outdoor run with GPS, follows a route on the map, captures territory segments per game rules, and views updated map state subject to anti-cheat checks.

---

## 12. Acceptance criteria

Generic acceptance patterns for MVP stories:

| Area | Acceptance criteria |
|------|---------------------|
| Onboarding / profile | Fresh install: user can complete profile and relaunch app with data intact. |
| Library | Catalog loads; search/filter returns expected subsets; detail view matches selected exercise. |
| Plans | Created plan appears in list; edits persist; duplicate behaves as specified. |
| Calendar | Assigned date shows scheduled workout; reschedule moves instance without corrupting template. |
| Execution | Session reflects plan order; completion state persists after app backgrounded and resumed. |
| Statistics | Weekly view matches synthetic test data; empty state handled gracefully. |
| Settings | Changed preference persists; destructive actions confirm when specified. |
| Quality gates | `flutter analyze` clean or documented exceptions; app builds; critical-path manual test passes. |

---

## 13. Data requirements

| Entity | Key fields (indicative) | MVP storage |
|--------|-------------------------|-------------|
| User profile | Identifier (local), display name, goal, level | Local DB / secure storage |
| Exercise | Id, name, tags, instructions, media refs optional | Bundled seed + local overrides optional |
| Workout plan | Id, name, ordered exercise entries with parameters | Local |
| Program | Id, name, ordered plan references if multi-plan programs exist | Local |
| Scheduled session | Id, date, plan reference, status | Local |
| Session log | Id, start/end, per-exercise completion records | Local |
| Statistics aggregates | Derived from logs | Derived locally |
| Future account | External user id, tokens | Remote only when sync ships |

Schema versioning and migrations MUST be planned before first production-facing release.

---

## 14. Permission requirements

| Permission | MVP | Future | Notes |
|------------|-----|--------|-------|
| Notifications | Optional | Common | For reminders; user-controlled. |
| Camera | No | Yes | Validation feature. |
| Location / GPS | No | Yes | Running map; background policies TBD. |
| Health integrations | Optional future | Optional | Platform-specific. |
| Network | Not required for MVP core | Yes when sync/AI | Degrade gracefully offline. |

Minimum-permission principle: request permissions only when a feature needs them, with in-context rationale.

---

## 15. Success metrics

| Metric | Definition | Target direction |
|--------|------------|------------------|
| Activation rate | Users completing profile setup after install | Increase |
| Weekly active workouts | Distinct users completing ≥1 session per week | Increase |
| Plan creation rate | Users creating ≥1 plan in first week | Increase |
| Session completion rate | Started sessions marked completed vs abandoned | Increase |
| Retention (W2) | Users returning in week two | Increase |
| Crash-free sessions | Sessions without fatal errors | Maximize |
| Time to first workout | Install to first completed session | Decrease |
| Qualitative satisfaction | Interview or survey scores | Increase |

Baseline and measurement instruments should be defined before launch; analytics wiring may be future if privacy policy requires.

---

## 16. Risks and constraints

| Risk / constraint | Impact | Mitigation |
|-------------------|--------|------------|
| Scope creep into AI/camera/maps | MVP delay | Enforce Section 10 and governance reviews. |
| Poor offline data migrations | Data loss | Versioned schema, migration tests. |
| Over-engineered architecture | Slow delivery | Project rules on abstractions and MVP focus. |
| Unclear validation of user problem | Wrong features | Lightweight research and metric review. |
| Device diversity performance | UX degradation | Profile mid-tier devices in test matrix. |
| Future sync conflicts | Data integrity | Design conflict resolution before backend cutover. |
| Regulatory / health claims | Legal exposure | Avoid medical claims; terms and disclaimers as needed. |

---

## 17. Requirement priority table

Priorities: **P0** (must ship MVP), **P1** (should ship MVP if capacity), **P2** (post-MVP).

| ID | Priority | Notes |
|----|----------|-------|
| FR-ONB-01–FR-ONB-03 | P0 | |
| FR-PRF-01–FR-PRF-04 | P0 | FR-PRF-05 future |
| FR-EXL-01–FR-EXL-02 | P0 | FR-EXL-03 P1 |
| FR-WKP-01–FR-WKP-05 | P0 | Program depth may start minimal |
| FR-CAL-01–FR-CAL-03 | P0 | FR-CAL-04 P1 |
| FR-EXE-01–FR-EXE-03 | P0 | FR-EXE-04 P1 |
| FR-TRK-01–FR-TRK-02 | P0 | FR-TRK-03 design-bound |
| FR-STA-01–FR-STA-03 | P0 | FR-STA-04 future |
| FR-DAT-01–FR-DAT-03 | P0 | |
| FR-SET-01–FR-SET-02 | P0 | |
| FR-CAM-*, FR-AI-*, FR-MAP-*, FR-SYN-* | P2 | Explicit future |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial requirements baseline |

---

*End of document.*
