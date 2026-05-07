# GymCoach — Feature Specification: AI Coach

**Document type:** Feature specification (future / advanced)  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Product, design, Flutter engineers, backend engineers, ML/LLM operators, QA, legal/privacy reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`

This specification defines **behavior, data contracts, prompting boundaries, and acceptance criteria** only. It contains **no implementation code**.

---

## 1. Feature overview

The AI Coach assists users in generating **personalized workout plans** derived from structured inputs such as profile attributes, goals, equipment, schedule preferences, and optional limitations. The system produces **structured outputs** (sessions, exercises, sets, repetitions, rest, progression notes) that the client can render consistently. The AI Coach operates as an **advisory training assistant** layered behind domain services and repositories (`docs/04_TECH_ARCHITECTURE.md`); presentation widgets **never** call external intelligence endpoints directly.

---

## 2. Product goal

Increase adherence and training quality by reducing friction when translating user constraints into **coherent weekly programming**, while maintaining **safety humility**, **privacy governance**, and **deterministic UX** through structured responses.

---

## 3. User problem

Many users know their goals but struggle to **sequence exercises**, balance volume and recovery, and adapt programming to **available equipment** and **time budgets**. Static templates feel mismatched; fully manual planning is tedious. Users benefit from guided proposals they can **review, edit, and save** into the app’s workout planning domain.

---

## 4. User input data

Inputs are collected via onboarding, profile settings, and optional Coach questionnaires. All fields should map to **typed domain structures** rather than raw free text wherever feasible.

| Category | Fields (examples) |
|----------|-------------------|
| Demographics | Age, weight, height |
| Goals | Training goal (e.g., strength, hypertrophy, endurance, general fitness) |
| Level | Fitness level / experience level |
| Environment | Gym vs home training |
| Equipment | Available equipment enumerated list |
| Schedule | Preferred workout days, sessions per week cap |
| Session shape | Target workout duration per session |
| Preferences | Preferred training type or modality emphasis |
| Limitations (optional) | Injuries, pain regions, medical considerations **only if user explicitly supplies** |

**Rule:** Free-text medical narratives should be minimized; structured disclaimers encourage professional consultation instead of diagnostic prompts.

---

## 5. AI output data

Outputs must map cleanly onto domain constructs for workout templates and scheduling.

| Output element | Description |
|----------------|-------------|
| Weekly outline | Ordered sessions across the requested horizon |
| Session blocks | Warm-up, main work, finisher optional segments |
| Exercise recommendations | Library-aligned identifiers preferred; fallback descriptive stubs flagged for catalog mapping |
| Prescription | Sets, repetitions or time-based targets, rest durations |
| Difficulty framing | Relative intensity cues aligned with user level |
| Progression strategy | Week-to-week adjustments described declaratively |
| Recovery suggestions | Non-medical lifestyle timing guidance |
| Safety warnings | General precautions tied to equipment or intensity—not diagnoses |
| Alternatives | Substitutions constrained by stated equipment |

All outputs conform to the **response structure** in Section 8.

---

## 6. User flow

| Step | Actor | System behavior |
|------|-------|------------------|
| 1 | User | Opens AI Coach entry point after profile completeness checks. |
| 2 | System | Summarizes known profile fields; highlights missing critical inputs. |
| 3 | User | Confirms or adjusts inputs (equipment, schedule, duration, optional limitations). |
| 4 | User | Accepts **privacy disclosure** for any external processing path (Section 10). |
| 5 | System | Submits structured request payload to backend orchestration layer (Section 11). |
| 6 | System | Receives structured plan; validates schema before persistence. |
| 7 | User | Reviews plan sections with edit affordances (swap exercise, tweak volume). |
| 8 | User | Saves accepted segments into local or synced workout plans. |
| 9 | System | Logs generation metadata (model version, timestamp) for support—not raw prompts by default. |

Escapes: offline mode blocks generation or queues stub messaging per product policy.

---

## 7. Prompting strategy

Future backend or controlled edge orchestration should assemble prompts from **deterministic sections** below. Order preserves attention stability and safety anchoring.

| Prompt section | Purpose |
|----------------|---------|
| **System safety preamble** | Role boundaries: general fitness information only; no clinician impersonation (Section 9). |
| **User profile summary** | Compact factual bullet block derived from verified profile fields. |
| **Goal statement** | Primary objective + secondary emphasis if any. |
| **Constraints** | Time per session, days available, environment (gym/home). |
| **Equipment manifest** | Normalized list of available implements; explicit prohibition of unavailable gear. |
| **Training frequency** | Sessions/week and spacing preferences. |
| **Limitations block** | User-declared injuries/limitations echoed verbatim for cautious tailoring with mandatory refusal patterns for red-flag phrases per policy appendix (future). |
| **Output schema instruction** | Demand machine-readable structure matching Section 8 with enumerated keys and units. |
| **Safety rules** | Forbidden claims list (Section 9). |
| **Catalog grounding hint** | Preferred exercise IDs/names from internal catalog snapshot attached server-side when available to reduce hallucinated movements. |
| **Uncertainty handling** | If data insufficient, return structured `"clarifications_needed"` array rather than inventing facts. |

**Principles:** minimize sensitive free-text echo; strip identifiers unrelated to programming; version prompts alongside model upgrades.

---

## 8. Response structure

Responses must be **structured**, not unconstrained prose. Recommended top-level conceptual envelope (exact schema finalized during backend design):

| Section key | Content |
|-------------|---------|
| `plan_meta` | Horizon (weeks), sessions/week, generated_at, difficulty_band |
| `sessions[]` | Ordered training days with labels |
| `blocks[]` inside session | Segment type (warm-up, main, accessory, cooldown) |
| `exercises[]` inside block | `exercise_ref` or provisional label, sets, reps_or_duration, rest_seconds, tempo optional, notes |
| `progression` | Week-over-week delta rules in declarative form |
| `recovery` | Non-medical suggestions |
| `safety_notes[]` | Bullet strings adhering to Section 9 |
| `alternatives{}` | Map from primary `exercise_ref` to substitutes |
| `clarifications_needed[]` | Structured questions when inputs ambiguous |

Clients render each section with dedicated widgets; free-text narrative allowed **only** inside bounded fields (`coaching_summary` capped length).

---

## 9. Safety rules

| Rule | Requirement |
|------|---------------|
| Identity humility | Never claim to be a **doctor**, **physiotherapist**, **certified trainer**, or **medical professional**. |
| Scope limitation | Provide **general fitness guidance** suitable for apparently healthy adults unless product obtains specialized compliance pathways. |
| Pain and injury | If user mentions pain, acute injury, unexplained symptoms, pregnancy complications, cardiovascular concerns, or chronic disease management, respond with **deferral messaging** instructing consultation with a qualified professional **before** intensifying training. |
| No diagnosis | Do not diagnose conditions or interpret medical tests. |
| No prescriptions | Do not prescribe medications, supplements dosages, or medical procedures. |
| Red flags | Escalate to static safety copy and halt progressive overload suggestions when high-risk keywords detected (detailed trigger list maintained externally). |
| Emergency | Advise emergency services language only where universally appropriate patterns apply—avoid sensationalism. |

Safety preamble must be **reinforced** server-side even if client repeats summaries.

---

## 10. Privacy rules

| Rule | Requirement |
|------|-------------|
| Data minimization | Transmit only fields necessary for plan generation. |
| Consent | Do not send body metrics, limitations text, or health-adjacent data to **external model APIs** without **clear, specific consent** and Data Processing transparency. |
| Pseudonymity | Use internal user tokens; avoid names in prompts unless needed. |
| Retention | Default: retain structured outputs; retain raw prompts only if operational troubleshooting requires it—policy-governed TTL. |
| Localization | Data residency constraints respected when selecting inference regions. |
| Analytics | Aggregate generation success metrics without storing sensitive payloads. |

---

## 11. Backend integration direction

| Concern | Direction |
|---------|-----------|
| Orchestration | FastAPI service accepts structured JSON, validates, forwards to model provider or self-hosted inference. |
| Grounding | Attach authoritative exercise catalog fragments server-side to reduce hallucinations. |
| Versioning | Model identifier + prompt template version stored with outputs for reproducibility. |
| Rate limiting | Protect abuse via per-user quotas and backoff headers exposed to client. |
| Auditing | Immutable audit entries for safety-flagged generations (no sensitive blobs unless incident response). |
| Fallback | Deterministic template planner offline path returns simplified plans without LLM if provider unavailable. |

Clients consume REST responses mapped through repository implementations (`docs/04_TECH_ARCHITECTURE.md`).

---

## 12. UI requirements

| Requirement | Detail |
|-------------|--------|
| Transparency | Surface AI-generated labeling distinctly from human-authored plans (badge or subtitle). |
| Editability | Every suggestion editable before save; destructive overwrite confirmation optional. |
| Explainability panels | Collapsible rationale tied to structured fields, not walls of text. |
| Difficulty cues | Visual hierarchy for intensity and rest periods. |
| Empty partial states | Gracefully render missing catalog mappings with prompts to pick substitutes. |
| Accessibility | Screen reader order mirrors visual sections; legible typography |

---

## 13. Error handling

| Scenario | Behavior |
|----------|----------|
| Schema validation failure | Show regeneration prompt; never partially persist malformed graphs |
| Provider timeout | Retry once with backoff; offer deterministic fallback planner |
| Rate limited | Friendly quota messaging |
| Clarifications needed | Inline questionnaire referencing structured fields |
| Catalog mismatch | Guided substitution picker |
| Safety halt | Static messaging + link to professional consultation guidance |
| Offline | Queued request or blocked state per policy |

Errors logged with correlation IDs; avoid leaking raw prompts to client logs.

---

## 14. MVP exclusion note

The AI Coach **must not** ship before the **core MVP** (manual workout lifecycle per `docs/03_MVP_SCOPE.md`) is **stable** unless explicitly approved by scope owners. Early spikes remain isolated branches or internal prototypes without production endpoints.

---

## 15. Future improvements

| Improvement | Description |
|-------------|-------------|
| Adaptive progression | Feedback loops from completion analytics adjusting next microcycle |
| Multimodal cues | Optional voice summaries with strict safety filtering |
| Personalized recovery education | Sleep/stress literacy content non-medical |
| Federated fine-tuning | Organization-specific models under governance |
| Integrated injury screening workflows | Partner-approved questionnaires—not improvised diagnostics |

---

## 16. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-01 | AI Coach cannot be invoked without minimum required profile fields; missing data yields structured clarifications. |
| AC-02 | Responses validate against agreed structured schema before UI binding (Section 8). |
| AC-03 | UI surfaces distinguish AI-generated vs user-confirmed saved plans (Section 12). |
| AC-04 | Safety rules in Section 9 enforced server-side; spot-check prompts include refusal cases. |
| AC-05 | Privacy consent gates external transmission of sensitive categories (Section 10). |
| AC-06 | Error scenarios in Section 13 produce non-crashing UX states with actionable messaging. |
| AC-07 | Saving integrates with existing workout plan domain without breaking manual flows. |
| AC-08 | Logging excludes sensitive payloads by default; correlation IDs present for support. |
| AC-09 | Rate limiting verified under burst simulations on staging. |
| AC-10 | Regression suite covers catalog mismatch substitution path. |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial AI Coach feature specification |

---

*End of document.*
