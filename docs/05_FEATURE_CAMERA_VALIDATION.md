# GymCoach — Feature Specification: Camera-Based Exercise Validation

**Document type:** Feature specification (future / advanced)  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Product, design, Flutter engineers, ML engineers, QA, privacy reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`

This specification describes **behavior, constraints, and acceptance criteria** only. It contains **no implementation code**.

---

## 1. Feature overview

The camera validation module lets users select a **supported exercise**, capture live video from the device camera, and receive **automated assessment** of whether each repetition meets movement criteria. **Valid repetitions increment a counter**; invalid attempts do **not** count and trigger **actionable feedback**. Session outcomes can be **stored** and associated with workout execution for richer progress tracking.

This capability is **advanced** and **must not block** the core MVP (planning, scheduling, manual completion, statistics). The broader product may ship **without** camera validation until explicitly prioritized.

---

## 2. User problem

Many users perform exercises with **suboptimal form**, which can reduce training effectiveness and increase **injury risk**. Manual repetition counting during workouts is often **inaccurate or distracting**. Users need lightweight guidance that reinforces correct movement patterns **during** execution without replacing professional supervision.

---

## 3. Product value

| Value pillar | Description |
|--------------|-------------|
| Form awareness | Real-time or near-real-time cues aligned with the selected exercise. |
| Accurate counts | Repetitions counted only when criteria indicate a valid completion. |
| Engagement | Clear feedback loops reinforce successful reps and corrective adjustments. |
| Data quality | Workout history reflects validated repetition counts where the feature is used. |

**Primary goal:** Help users perform exercises **more correctly** and make workout tracking **more accurate**.

---

## 4. MVP limitation

| Rule | Detail |
|------|--------|
| Non-blocking | Full camera validation is **not** part of the baseline MVP. |
| Optional prototype | A **single-exercise prototype** (recommended: **squat**) is permitted **only after** the core workout planning, execution, and statistics flows are **stable** on device (`docs/03_MVP_SCOPE.md`). |
| Scope cap | Prototype supports **one** movement profile; no obligation to support push-up, lunge, etc., until post-MVP phases. |
| Quality bar | Prototype must demonstrate end-to-end flow (Section 6) at a **demo-suitable** reliability level; perfection is not required, but failures must be **graceful**. |

---

## 5. Supported exercise strategy

### 5.1 MVP prototype (if built)

| Exercise | Priority | Notes |
|----------|----------|-------|
| Squat | First | Clear vertical displacement and joint-angle patterns suitable for initial pose-based logic. |

### 5.2 Future expansion

| Exercise | Expansion wave |
|----------|----------------|
| Squat | Production-hardening after prototype |
| Push-up | Later |
| Jumping jack | Later |
| Lunge | Later |
| Plank | Later (hold-based timing differs from rep-based counting) |

Each new exercise requires its own **movement definition**, **threshold calibration**, **test matrix**, and **safety copy** before general availability.

---

## 6. Full user flow

| Step | Actor | System behavior |
|------|-------|------------------|
| 1 | User | Chooses a **supported** exercise from an explicit list or entry point tied to workout execution. |
| 2 | User | Opens **camera validation mode** for that exercise. |
| 3 | System | Requests **camera permission** with clear rationale. |
| 4 | System | Shows **camera preview** when permission granted and hardware available. |
| 5 | System | Displays **safety** and **positioning** instructions (framing, distance, lighting, footwear, clearance). |
| 6 | User | Starts the validation session after acknowledging instructions. |
| 7 | System | Runs **movement analysis** on incoming frames or derived pose features. |
| 8 | System | Increments count only on **correct** repetitions per rules (Section 9). |
| 9 | System | Does **not** count incorrect attempts; surfaces **feedback** (Section 10). |
| 10 | System | Continues until user ends session, timer expires, or fatal error path occurs. |
| 11 | System | Persists **session result** (Section 12) when persistence is enabled for the build. |

Exit paths: user cancels, permission denied, prolonged poor visibility, or explicit switch to **manual fallback** (Section 11).

---

## 7. UI states

These states drive screen layout, accessibility announcements, and transitions.

| State | User-visible intent | Typical transitions |
|-------|---------------------|-------------------|
| Permission not granted | Explain why camera is needed; primary action to open settings or retry | → Camera loading / denied terminal |
| Camera loading | Indicate initialization | → Ready or error |
| User not visible | Ask user to step into frame | → Body not detected / Ready |
| Body not detected | Pose pipeline sees no confident skeleton | → Ready when stable |
| Ready | Prompt to begin movement | → Movement started |
| Movement started | Tracking active | → Correct rep / Incorrect rep / Paused |
| Correct repetition | Brief positive confirmation; counter increments | → Movement started |
| Incorrect repetition | Corrective hint; counter unchanged | → Movement started |
| Session paused | Frozen analysis; resume control | → Movement started / Finished |
| Session finished | Summary of reps, validity ratio optional | → Exit or save |
| Manual fallback available | Offer manual counting without camera | → Manual mode |

States must remain **recoverable** where reasonable (e.g., lighting improves, user recenters).

---

## 8. Detection logic overview

High-level pipeline (implementation-agnostic):

| Stage | Purpose |
|-------|---------|
| Capture | Acquire preview frames at a controlled rate suitable for device thermal limits. |
| Preprocess | Resize, normalize orientation, optional ROI cropping guided by UI framing guides. |
| Body estimation | Estimate body landmarks or key joints via **on-device pose estimation** or equivalent movement detection suitable for mobile. |
| Feature extraction | Derive angles, velocities, phase labels (eccentric/concentric), symmetry proxies per exercise profile. |
| Rule / model evaluation | Apply exercise-specific thresholds or lightweight classifiers to classify phase transitions and completion. |
| Stabilization | Temporal smoothing and hysteresis to reduce jitter-driven false positives/negatives. |

**Libraries:** The project may evaluate vendor SDKs, on-device ML frameworks, or custom models; **no specific library is mandated** by this document. Selection must respect privacy (Section 14) and performance (Section 16).

---

## 9. Repetition counting rules

General principles (exercise-specific YAML/spec outside this document):

| Rule | Description |
|------|-------------|
| Phase completeness | A repetition counts only when **required phases** occur in order (e.g., descent and ascent for squat). |
| Threshold bands | Joint angles or displacement must remain within **configured bands** for qualifying segments. |
| Minimum dwell time | Phases must persist for **minimum durations** to reject bounce or noise. |
| Cooldown | After a counted rep, enforce a short **dead zone** before the next rep can register. |
| Quality gate | Borderline frames may be classified as **incorrect** rather than ambiguously counted. |

Plank-style holds use **time-in-position** rather than discrete repetitions; specification must be adjusted before plank ships.

---

## 10. Feedback rules

| Feedback type | When | Content guidance |
|-----------------|------|-------------------|
| Positive | Correct repetition | Short affirmation; optional subtle haptic |
| Corrective | Incorrect repetition | Specific cue (depth, knee tracking, torso angle) mapped to failure mode |
| Environmental | Poor visibility | Lighting, distance, full-body framing |
| Safety | Hazard patterns detected | Stop advising motion; suggest rest or manual mode |

Copy must remain **non-medical** and aligned with safety disclaimers (Section 15). Feedback frequency should avoid **spamming** the user during rapid attempts.

---

## 11. Manual fallback mode

| Aspect | Requirement |
|--------|-------------|
| Availability | User can opt into **manual repetition counting** when camera is unavailable, declined, or unreliable. |
| Parity | Manual mode integrates with the same **session result** structure without camera-derived metrics. |
| Transparency | Stored records indicate **validation mode** (camera-validated vs manual) for downstream statistics honesty. |
| Re-entry | User may switch modes only at defined breakpoints (session start or pause) to avoid data inconsistencies. |

---

## 12. Data model needs

Indicative entities (exact naming in implementation follows project conventions):

| Record | Fields (conceptual) |
|--------|---------------------|
| Validation session | Identifier, exercise id, start/end timestamps, device capabilities snapshot |
| Repetition event | Timestamp, outcome (correct/incorrect), optional failure reason code |
| Session summary | Total attempts, counted reps, optional average confidence |
| Media policy | Flags confirming **no raw frames retained** unless user opts into diagnostics |

Derived aggregates feed workout execution and statistics modules through **repository interfaces** (`docs/04_TECH_ARCHITECTURE.md`).

---

## 13. Permission handling

| Scenario | Behavior |
|----------|----------|
| First request | Show pre-permission education screen |
| Granted | Initialize preview and pose pipeline lazily |
| Denied | Offer manual fallback; do not dead-end workout |
| Restricted ( parental / enterprise ) | Explain limitation; manual fallback |
| Revoked mid-session | Pause; prompt to restore or switch mode |

Permission rationale strings must be **plain English** and aligned with store guidelines.

---

## 14. Privacy requirements

| Requirement | Detail |
|-------------|--------|
| Default local processing | **Camera frames must not be uploaded by default.** Prefer **on-device** inference. |
| Explicit consent for cloud | Any cloud-side inference or storage requires **clear opt-in**, separate from generic Terms. |
| Data minimization | Persist **counts and metadata**, not raw video, unless user explicitly enables diagnostic capture under policy. |
| Retention | Define retention limits for any optional uploads; support deletion requests consistent with app privacy posture. |
| Transparency | In-app summary of what leaves the device before cloud features activate |

---

## 15. Safety requirements

| Requirement | Detail |
|-------------|--------|
| Disclaimer | Persistent or prominent disclosure that the feature **does not replace** a qualified trainer, physician, or medical professional. |
| Injury stop cues | If repeated hazardous patterns are inferred, bias toward **stop** guidance rather than encouragement. |
| Scope honesty | Do not claim clinical diagnosis or injury prevention guarantees |
| Environmental warnings | Remind users to secure space, use appropriate footwear, and avoid unsafe surfaces |

---

## 16. Performance requirements

| Metric | Target guidance |
|--------|-----------------|
| Preview FPS | Smooth preview on representative mid-tier hardware |
| Inference latency | Feedback feels responsive; avoid multi-second lag under nominal load |
| Thermal | Throttle processing or reduce resolution when thermal state elevated |
| Battery | Avoid unnecessary background capture when app inactive |
| Memory | Bounded buffers; release surfaces on dispose |

Exact numeric targets belong in engineering performance budgets once hardware matrix is fixed.

---

## 17. Edge cases

| Edge case | Handling |
|-----------|----------|
| Poor lighting | Degraded detection; environmental feedback; avoid silent miscounts |
| Partial occlusion | Lower confidence; prompt repositioning |
| Multiple people in frame | Prefer largest confident skeleton or reject until single subject |
| Front vs side angle | Exercise profiles declare **required orientation**; mismatch yields instructional feedback |
| Mirrors / reflective clutter | May confuse pose; advise repositioning |
| Voice-over / TalkBack | State announcements remain coherent |
| Interruptions | Phone call, app background: pause session and preserve summary eligibility rules |
| Device diversity |_camera sensor differences_: calibrate per exercise pack |

---

## 18. Risks

| Risk | Mitigation |
|------|------------|
| False confidence | Conservative counting; manual fallback |
| Privacy backlash | Local-first processing; explicit cloud consent |
| Injury liability | Disclaimers; avoid medical claims |
| Model bias across body types | Diverse test cohort before broad rollout |
| Regulatory / store policy | Age gates if required; regional compliance review |
| Scope creep | Strict exercise rollout checklist |

---

## 19. Acceptance criteria

Feature-ready (non-prototype) when:

| ID | Criterion |
|----|-----------|
| AC-01 | Supported exercises list is accurate and gated; unsupported exercises cannot enter validation mode. |
| AC-02 | Full flow in Section 6 completes on reference hardware without crash in happy path. |
| AC-03 | All UI states in Section 7 are reachable and visually distinct. |
| AC-04 | Correct reps increment counter; incorrect reps do not. |
| AC-05 | Feedback aligns with dominant failure modes in test scenarios. |
| AC-06 | Manual fallback works end-to-end with correct session labeling. |
| AC-07 | No default upload of frames; cloud path gated by consent if implemented. |
| AC-08 | Safety disclaimer visible per Section 15. |
| AC-09 | Performance acceptable per Section 16 on agreed devices. |
| AC-10 | Automated tests cover counting edge cases where feasible; manual scripts cover remainder. |

Prototype acceptance relaxes AC-09 and exercise breadth but retains AC-06 through AC-08.

---

## 20. Future improvements

| Improvement | Description |
|-------------|-------------|
| Expanded exercise library | Additional profiles with calibrated thresholds |
| Adaptive coaching | Tone and density of cues tuned to user proficiency |
| Confidence visualization | Optional skeleton overlay for debugging modes |
| Wearable fusion | Heart rate context when integrations exist |
| Offline model packs | Downloadable models per region or bandwidth |
| Backend analytics | Aggregated anonymous quality metrics with strict governance |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial camera validation feature specification |

---

*End of document.*
