# GymCoach — Data Model and Future API Plan

**Document type:** Data architecture and API planning  
**Product:** GymCoach (Flutter MVP evolving toward FastAPI backend)  
**Audience:** Flutter engineers, backend engineers, DBAs, security reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`

This document defines **conceptual entities**, **relationships**, **validation intent**, and **future REST surface areas**. It contains **no implementation code** for client or server.

---

## 1. Data model overview

The GymCoach domain centers on **profiles**, **exercise knowledge**, **planned work**, **executed sessions**, and **derived outcomes**. MVP persists these aggregates **locally** with repository abstractions. Future phases introduce **authenticated remote records**, **spatial territory data**, **challenge mechanics**, **AI-generated plans**, and **camera validation telemetry**.

Design principles:

- Stable **identifiers** (UUIDs recommended at persistence boundaries) to simplify sync later.
- **Immutable-by-default** session logs with explicit correction workflows only if product requires them.
- **Separation** between catalog **Exercise** definitions and per-session **ExerciseResult** facts.
- **Explicit MVP vs future** tagging per entity to prevent scope creep.

Supporting structural entity **WorkoutExercise** models planned movements embedded in templates or session snapshots.

---

## 2. MVP entities

| Entity | MVP role |
|--------|----------|
| **UserProfile** | Training-related attributes for personalization and statistics context. |
| **Exercise** | Canonical or seeded catalog row describing a movement. |
| **WorkoutPlan** | Reusable template grouping ordered movements and default prescriptions. |
| **PlannedWorkout** | Scheduled instance linking a plan (or inline composition) to a calendar date. |
| **WorkoutSession** | Executed training event with lifecycle timestamps and status. |
| **WorkoutExercise** | Ordered line item prescribing sets/reps/rest for a plan or session snapshot. |
| **ExerciseResult** | Completion facts per prescribed movement within a session. |

---

## 3. Future entities

| Entity | Future role |
|--------|-------------|
| **CameraValidationSession** | Capture summary and repetition validity outcomes tied to a session or exercise execution. |
| **RunningRoute** | GPS track metadata for outdoor gameplay or analytics. |
| **Territory** | Polygonal or simplified spatial ownership derived from validated routes. |
| **Challenge** | Competitive rule container referencing territories or broader contests. |
| **LeaderboardEntry** | Ranked aggregates scoped by challenge or global boards. |
| **AiCoachRequest** | Structured prompt payload and consent metadata for AI generation. |
| **AiCoachPlan** | Versioned structured plan output suitable for import into **WorkoutPlan**. |

---

## 4. Entity field tables

Fields are **indicative**; exact naming follows engineering conventions. Types describe intent, not SQL dialect.

### 4.1 UserProfile (MVP)

| Field | Type (conceptual) | Purpose |
|-------|-------------------|---------|
| `id` | UUID | Primary key |
| `display_name` | string | Presentation |
| `age` | int | Programming context |
| `weight_kg` | decimal | Programming context |
| `height_cm` | decimal optional | Context |
| `goal` | enum | Training objective |
| `fitness_level` | enum | Experience band |
| `preferred_frequency_per_week` | int | Scheduling hints |
| `preferred_training_environment` | enum optional | Home vs gym |
| `created_at`, `updated_at` | timestamp | Audit |

**Validation rules:** Age within plausible bounds; positive metrics where applicable; enums restricted to allowed vocabularies; strings length-capped.

### 4.2 Exercise (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `name` | string | Title |
| `muscle_group` | enum or string tag | Filtering |
| `difficulty` | enum | UX sorting |
| `equipment` | enum set / tags | Constraint matching |
| `instructions_short` | string | Guidance |
| `media_asset_key` | string optional | Local or CDN reference |
| `category` | string optional | Secondary grouping |

**Validation rules:** Non-empty name; controlled difficulty vocabulary; instruction length limits.

### 4.3 WorkoutPlan (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `owner_profile_id` | UUID FK | Ownership |
| `name` | string | Label |
| `notes` | string optional | User commentary |
| `created_at`, `updated_at` | timestamp | Audit |

**Validation rules:** Name length bounds; owner required when accounts exist (local MVP may imply singleton profile).

### 4.4 PlannedWorkout (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `profile_id` | UUID FK | Scope |
| `scheduled_date` | date | Calendar anchor |
| `workout_plan_id` | UUID FK optional | Template linkage |
| `status` | enum | planned / completed / skipped |
| `planned_snapshot_note` | string optional | Inline rationale |

**Validation rules:** One-active-semantics per date configurable by product; valid FK references; date not absurdly far in past/future per policy.

### 4.5 WorkoutSession (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `profile_id` | UUID FK | Scope |
| `planned_workout_id` | UUID FK optional | Linkage |
| `started_at`, `finished_at` | timestamp | Lifecycle |
| `status` | enum | in_progress / completed / abandoned |
| `validation_mode` | enum optional future-proof | manual vs camera-assisted |

**Validation rules:** `finished_at` ≥ `started_at`; terminal states immutable except explicit admin tooling later.

### 4.6 WorkoutExercise (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `parent_id` | UUID FK | **WorkoutPlan** or **WorkoutSession** polymorphic association resolved via separate typed tables or dual FK discipline |
| `exercise_id` | UUID FK | Catalog reference |
| `position` | int | Ordering |
| `target_sets` | int | Prescription |
| `target_reps` | int optional | Rep-based |
| `target_duration_sec` | int optional | Time-based alternative |
| `rest_seconds` | int optional | Recovery |
| `notes` | string optional | User cues |

**Validation rules:** Exactly one of rep vs duration emphasis per product rule; positive integers where applicable; position unique per parent.

### 4.7 ExerciseResult (MVP)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `workout_session_id` | UUID FK | Container |
| `workout_exercise_id` | UUID FK | Line association |
| `completed_sets` | int | Progress |
| `completed_at` | timestamp optional | Last update |
| `status` | enum | pending / partial / completed / skipped |

**Validation rules:** `completed_sets` ≤ prescribed sets unless overflow explicitly allowed; consistent linkage to session.

### 4.8 CameraValidationSession (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `workout_session_id` | UUID FK optional | Context |
| `exercise_id` | UUID FK | Movement profile |
| `started_at`, `ended_at` | timestamp | Bounds |
| `correct_rep_count` | int | Outcome |
| `incorrect_attempt_count` | int | Feedback density |
| `failure_codes[]` | structured codes | Analytics |

**Validation rules:** Counts non-negative; consent flags stored separately in privacy tables when needed.

### 4.9 RunningRoute (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `profile_id` | UUID FK | Runner |
| `started_at`, `ended_at` | timestamp | Duration |
| `distance_m` | decimal | Derived |
| `polyline_reference` | external geometry handle | Storage abstraction |
| `validation_outcome` | enum | accepted / rejected / flagged |

**Validation rules:** Geometry existence implied before territory linkage; anti-cheat outcome mandatory before scoring.

### 4.10 Territory (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `owner_profile_id` | UUID FK | Ownership |
| `origin_route_id` | UUID FK | Provenance |
| `name` | string | Display |
| `area_sq_m` | decimal | Metric |
| `geometry_reference` | spatial handle | Map rendering |

**Validation rules:** Naming moderation rules; minimum/maximum area thresholds.

### 4.11 Challenge (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `title` | string | Marketing |
| `rules_payload` | structured JSON | Mechanics |
| `starts_at`, `ends_at` | timestamp | Window |

**Validation rules:** Chronological consistency; rules schema versioned.

### 4.12 LeaderboardEntry (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `challenge_id` | UUID FK optional | Scope |
| `profile_id` | UUID FK | Participant |
| `score` | decimal | Ranking metric |
| `rank` | int computed | Ephemeral or cached |

**Validation rules:** Score derivation reproducible from source sessions; ties documented.

### 4.13 AiCoachRequest (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `profile_id` | UUID FK | Subject |
| `payload_snapshot` | structured JSON | Inputs |
| `consent_flags` | bitmask / enums | Privacy gates |
| `created_at` | timestamp | Audit |

**Validation rules:** Payload schema versioned; sensitive sections gated.

### 4.14 AiCoachPlan (future)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `request_id` | UUID FK | Lineage |
| `structured_plan` | structured JSON | Importable |
| `model_version` | string | Traceability |

**Validation rules:** Strict schema validation prior to client persistence.

---

## 5. Entity relationships

| Relationship | Cardinality | Notes |
|--------------|-------------|-------|
| Profile → WorkoutPlan | 1:N | Ownership |
| Profile → PlannedWorkout | 1:N | Scheduling |
| WorkoutPlan → WorkoutExercise | 1:N | Template lines |
| PlannedWorkout → WorkoutPlan | N:1 optional | Template reuse |
| PlannedWorkout → WorkoutSession | 1:0..1 | Completion linkage |
| WorkoutSession → WorkoutExercise | 1:N | Snapshot lines if denormalized from plan |
| WorkoutSession → ExerciseResult | 1:N | Execution facts |
| Exercise → WorkoutExercise | 1:N | Catalog reuse |
| WorkoutSession → CameraValidationSession | 1:0..N | Future adjunct |
| Profile → RunningRoute | 1:N | Future |
| RunningRoute → Territory | 1:0..1 | Future capture |
| Territory → Profile | N:1 | Ownership transfers later |
| Challenge → LeaderboardEntry | 1:N | Future |
| AiCoachRequest → AiCoachPlan | 1:1 typical | Future |

Exact relational modeling may use snapshot copies of **WorkoutExercise** rows under sessions to preserve historical truth if templates change.

---

## 6. Local storage strategy

| Aspect | Guidance |
|--------|----------|
| Repository interfaces | Domain retrieves aggregates via abstract repositories (`docs/04_TECH_ARCHITECTURE.md`). |
| MVP store | Embedded relational or document database with migration versioning. |
| Seeding | **Exercise** catalog bundled; identifiers stable for future sync. |
| Singleton profile | Local MVP may allow exactly one active profile row until accounts arrive. |
| Filesystem media | Optional deferred; asset keys only in MVP. |
| Clock reliance | Device time affects scheduling; document limitations until trusted server timestamps exist. |

---

## 7. Migration path to backend

| Phase | Actions |
|-------|---------|
| Freeze identifiers | Ensure client-generated UUIDs acceptable to server or map on first sync. |
| Introduce auth | Tokens stored in secure storage; attach `Authorization` headers in remote repositories. |
| Upsert strategy | Profiles and plans upload with version vectors or `updated_at` concurrency. |
| Conflict policy | Last-write-wins initially; richer merges only where justified. |
| Catalog sync | Pull server exercises; reconcile local favorites referencing stable IDs. |
| Session upload | Immutable POST with idempotency keys for flaky networks. |
| Feature flags | Territory and AI entities gated until endpoints live. |

---

## 8. Future REST API endpoint plan

Base path assumed `/v1`. Payloads JSON. IDs path parameters where noted. **Planning only.**

### 8.1 Profile

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/profiles/me` | Fetch current user profile |
| PUT | `/profiles/me` | Update profile |
| DELETE | `/profiles/me` | Account deletion request |

### 8.2 Exercises

| GET | `/exercises` | Paginated catalog with filters |
| GET | `/exercises/{exercise_id}` | Detail |

### 8.3 Workout plans

| GET | `/workout-plans` | List templates |
| POST | `/workout-plans` | Create template |
| GET | `/workout-plans/{plan_id}` | Detail including lines |
| PATCH | `/workout-plans/{plan_id}` | Update metadata |
| DELETE | `/workout-plans/{plan_id}` | Soft delete optional |

### 8.4 Planned workouts / scheduling

| GET | `/planned-workouts` | Query by date range |
| POST | `/planned-workouts` | Schedule instance |
| PATCH | `/planned-workouts/{id}` | Reschedule / status |
| DELETE | `/planned-workouts/{id}` | Cancel |

### 8.5 Workout sessions

| POST | `/workout-sessions` | Start or finalize session envelope |
| GET | `/workout-sessions/{id}` | Detail |
| PATCH | `/workout-sessions/{id}` | Late corrections if policy allows |

Nested alternative: `/workout-sessions/{id}/results` for **ExerciseResult** bulk upsert.

### 8.6 Statistics

| GET | `/statistics/summary` | Aggregates for dashboards |
| GET | `/statistics/weekly` | Weekly rollups |

Server may compute from OLTP or materialized views.

### 8.7 Camera validation results

| POST | `/camera-validation-sessions` | Submit summarized outcomes |
| GET | `/camera-validation-sessions/{id}` | Retrieval |

Raw media uploads excluded unless separate consent-gated media pipeline exists.

### 8.8 AI coach

| POST | `/ai-coach/requests` | Submit structured generation request |
| GET | `/ai-coach/plans/{plan_id}` | Fetch structured output |
| POST | `/ai-coach/plans/{plan_id}/import` | Promote into **WorkoutPlan** |

### 8.9 Running routes

| POST | `/running-routes` | Submit finalized route summary |
| GET | `/running-routes/{id}` | Detail |

### 8.10 Territories

| GET | `/territories` | Spatial queries (bounding box params) |
| POST | `/territories/capture` | Attempt capture from validated route |
| PATCH | `/territories/{id}` | Rename within rules |

### 8.11 Leaderboards

| GET | `/leaderboards/{scope}` | Fetch ranks (`global`, `challenge:{id}`) |

Caching layers may transparently accelerate reads.

---

## 9. PostgreSQL strategy

| Topic | Approach |
|-------|----------|
| OLTP schema | Normalized tables mirroring Section 4 with FK constraints |
| Indexing | `(profile_id, scheduled_date)` for calendar queries; session time ranges for analytics |
| JSON columns | Only for versioned `rules_payload`, AI structured plans where migration churn high |
| Spatial | PostGIS for territories and route geometries when gameplay launches |
| Migrations | Managed migration tool in backend repository |
| Auditing | Append-only tables for ownership transfers optional |

---

## 10. Redis strategy

| Use case | Redis pattern |
|----------|---------------|
| Leaderboard caching | Sorted sets with periodic reconciliation to Postgres |
| Temporary challenge state | Ephemeral hashes per participant session TTL |
| Anti-cheat queues | Streams or lists feeding worker consumers |
| Rate limiting | Token buckets keyed by user IP + account ID |
| Session cache | Short-lived OAuth/session metadata—not replacing refresh token vault |

Durability expectations documented per structure (pure cache vs queue needing persistence flags).

---

## 11. Authentication planning

| Aspect | Direction |
|--------|-----------|
| Protocol | OAuth2/OpenID Connect preferred for mobile; bearer access tokens |
| Refresh | Rotation with secure storage on device |
| Authorization | Row-level ownership enforced server-side (`profile_id` matches token subject) |
| Anonymous MVP | No auth until backend; future linkage maps anonymous UUID to account with migration UX |
| Service accounts | Separate keys for worker consumers only |

---

## 12. Validation rules

| Layer | Responsibility |
|-------|----------------|
| Client | Fast feedback on missing enums, lengths, numeric bounds |
| API gateway | Schema validation reject early |
| Domain services | Cross-field rules (prescription coherence) |
| Database | Constraints and NOT NULL discipline |

Global constraints: pagination limits; maximum batch sizes for nested exercise lines; rejection of unknown enum values with version negotiation headers optional.

---

## 13. Privacy and security rules

| Topic | Rule |
|-------|------|
| Transport | TLS mandatory |
| Secrets | Never embedded in apps; rotate keys via CI secrets |
| PII minimization | Collect only necessary profile attributes |
| Health adjacent data | Higher sensitivity; explicit consent for AI or cloud inference |
| Location | Future GPS data classified strictly; retention TTL |
| Logging | Redact tokens and payloads containing limitations text |
| Access audits | Admin reads restricted and logged when operational |

---

## 14. Data migration risks

| Risk | Mitigation |
|------|------------|
| ID collisions | Standardize UUID generation strategy early |
| Partial uploads | Idempotent endpoints and retry semantics |
| Schema drift | Version migrations both locally and server-side |
| Timezone errors | Store UTC instants; render local |
| Catalog divergence | Merge strategy for renamed exercises |
| Privacy breaches during sync | Encrypt backups; minimize mirrored sensitive JSON |

---

## 15. Implementation order

| Order | Deliverable |
|-------|-------------|
| 1 | Local repositories + MVP entities (Section 2) |
| 2 | Seed **Exercise** catalog + CRUD screens consuming repositories |
| 3 | **WorkoutPlan** + **WorkoutExercise** authoring persistence |
| 4 | **PlannedWorkout** scheduling indexes optimized locally |
| 5 | **WorkoutSession** + **ExerciseResult** logging |
| 6 | Statistics derivations reading local aggregates |
| 7 | Introduce FastAPI `/profiles`, `/exercises`, `/workout-plans`, `/planned-workouts`, `/workout-sessions`, `/statistics` |
| 8 | Authentication integration |
| 9 | Redis leaderboard cache once social surfaces exist |
| 10 | Spatial stack + territories + running routes |
| 11 | Camera validation ingestion endpoints |
| 12 | AI coach structured endpoints + import pipeline |

Stages 7–12 require backend initiative gates independent of Flutter MVP stability checkpoints.

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial data model and API planning baseline |

---

*End of document.*
