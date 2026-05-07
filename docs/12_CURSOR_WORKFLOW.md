# GymCoach — Cursor Workflow

**Document type:** Contributor and automation workflow  
**Product:** GymCoach (Flutter repository)  
**Audience:** Human developers and Cursor agents operating in this codebase  

This document defines **how Cursor and contributors must work here**. Documentation is the **source of truth** for architecture, scope, naming discipline, and flows. This file contains **no implementation code**.

---

## 1. Purpose

| Goal | Description |
|------|-------------|
| Align implementation | Cursor must **not** invent architecture, features, naming, or user flows that **conflict** with repository documentation. |
| Reduce rework | Read specs **before** editing so changes stay small, reversible, and MVP-aligned. |
| Protect scope | Advanced work stays gated until MVP stability unless explicitly approved. |
| Ensure verifiability | Every implementation round ends with **traceable** file summaries and test guidance. |

---

## 2. Global rules

Cursor and contributors **must**:

- Always read `docs/00_PROJECT_RULES.md` **first** before substantive edits.
- Always read `docs/01_PRODUCT_VISION.md` before **product-related** work (positioning, flows, priorities).
- Always read `docs/03_MVP_SCOPE.md` before deciding **what** to implement.
- Always read `docs/04_TECH_ARCHITECTURE.md` before **creating or restructuring** folders, layers, routing, or theme.
- Always read the **related feature document** before implementing camera validation, AI coach, territory map, statistics behavior, or workout domain logic beyond MVP stubs.
- Use **English only** everywhere in the project (no Turkish or Russian, no mixed-language identifiers or UI copy).
- **Not** write code comments, TODO comments, or commented-out code (per project rules).
- **Not** create unnecessary files or drive-by refactors.
- **Not** change unrelated files or delete working behavior without explicit approval.
- **Not** add packages without **explaining why** they are needed and what alternatives were considered.
- **Not** add backend code before **frontend MVP requirements** are clear and scoped.
- **Not** implement advanced features before MVP unless **explicitly requested**.
- Keep changes **small**, **scoped**, and **easy to verify**.
- After implementation, **summarize changed files**.
- Run **`flutter analyze`** when possible and report outcomes honestly.
- Report errors **exactly**—do not conceal analyzer failures, build failures, or runtime exceptions.

---

## 3. Required reading order

Before starting implementation on a typical task, read in this order:

1. `docs/00_PROJECT_RULES.md`  
2. `docs/01_PRODUCT_VISION.md`  
3. `docs/03_MVP_SCOPE.md`  
4. `docs/04_TECH_ARCHITECTURE.md`  
5. **Related feature document** (as applicable), for example:  
   - `docs/05_FEATURE_CAMERA_VALIDATION.md`  
   - `docs/06_FEATURE_TERRITORY_MAP.md`  
   - `docs/07_FEATURE_AI_COACH.md`  
   - `docs/08_DATA_MODEL_AND_API_PLAN.md` for entities and persistence alignment  
   - `docs/09_UI_UX_GUIDELINES.md` for UI work  
   - `docs/10_DEVELOPMENT_ROADMAP.md` for phase alignment  
6. `docs/11_TESTING_AND_ACCEPTANCE.md`  

For narrowly scoped fixes (e.g., typo in one file), still read **`docs/00_PROJECT_RULES.md`**; expand reading depth proportional to blast radius.

---

## 4. Safe editing rules

| Rule | Detail |
|------|--------|
| Inspect first | List or navigate existing structure; match established patterns. |
| Minimal diff | Touch only files required for the task. |
| Preserve behavior | Do not refactor working code unless required for the change. |
| Naming | Follow English professional naming; align with domain vocabulary in docs. |
| No speculative files | Do not add architecture diagrams, extra READMEs, or helpers “for later” without request. |
| Reversibility | Prefer incremental commits or logically separable edits where applicable. |

---

## 5. Feature implementation process

1. **Inspect** the existing project structure (especially `lib/` layout vs `docs/04_TECH_ARCHITECTURE.md`).  
2. **Read** relevant documentation (Section 3).  
3. **Produce** a short implementation plan (files to touch, layers affected, risks).  
4. **Wait for approval** if the change is **large**, ambiguous, or cross-cutting—do not guess scope expansion.  
5. **Implement** only the requested scope; defer nice-to-haves unless approved.  
6. Run **static analysis** (`flutter analyze`) when tooling is available.  
7. **Summarize** changed files and behavioral impact.  
8. **Explain** how to test the result (manual steps aligned with `docs/11_TESTING_AND_ACCEPTANCE.md` where possible).  

---

## 6. Package installation rules

| Rule | Detail |
|------|--------|
| No silent installs | Do not add dependencies automatically without user-visible justification. |
| Justification | State **purpose**, **tradeoffs**, and **why** lighter alternatives are insufficient when relevant. |
| Prefer stability | Favor maintained, widely adopted packages compatible with the project Flutter constraints. |
| MVP weight | Avoid heavy SDKs for MVP unless they unblock core scope (e.g., local persistence with justified choice). |
| Phase gating | Do **not** add camera, map, AI SDKs, or HTTP client stacks for backend integration **before** the related roadmap phase or explicit approval (`docs/10_DEVELOPMENT_ROADMAP.md`, `docs/03_MVP_SCOPE.md`). |

---

## 7. Testing rules

| Expectation | Detail |
|-------------|--------|
| MVP thread | Verify the **primary acceptance scenario** when touching flows it depends on (`docs/11_TESTING_AND_ACCEPTANCE.md` Section 2). |
| Persistence | After storage changes, verify **cold restart** behavior when feasible. |
| Regression mindset | Re-run targeted manual checks listed for affected modules (navigation, calendar, execution, statistics). |
| Automated tests | Add or extend tests when project already patterns them; do not block small fixes on large harness work unless requested. |
| Honesty | Report failing tests or analyzer issues verbatim with reproduction steps. |

---

## 8. Documentation update rules

| Situation | Action |
|-----------|--------|
| Behavior matches docs | No doc edit required. |
| Implemented behavior diverges from docs | Update the **minimum** relevant doc(s) in the same delivery cycle when the divergence is user-visible or architectural. |
| New feature flag or scope change | Update `docs/03_MVP_SCOPE.md` or requirements via explicit stakeholder decision—do not silently widen MVP. |
| New endpoints or entities | Reflect in `docs/08_DATA_MODEL_AND_API_PLAN.md` when backend/client contracts change. |

Do **not** write documentation that describes features that do not exist.

---

## 9. Error handling rules

| Rule | Detail |
|------|--------|
| Transparency | Surface analyzer errors, build errors, and stack traces **accurately**—no paraphrasing into success. |
| Root cause | When diagnosing, cite observable evidence (command output, failing step). |
| Scope | Fix errors introduced by the current change set first; pre-existing failures must be called out separately. |
| No hiding | Do not suppress errors with broad catches or silent fallbacks unless product rules explicitly demand it (they currently do not). |

---

## 10. Final response format after implementation

After each implementation session, responses **must** include:

1. **Summary** — What changed and why, tied to the request.  
2. **Changed files** — List with paths.  
3. **Verification result** — `flutter analyze` / build outcome when run; note if not run and why.  
4. **How to test** — Concrete manual steps or test cases.  
5. **Remaining risks** — Edge cases, tech debt, or follow-ups explicitly acknowledged.  
6. **Next recommended step** — Single sensible continuation aligned with roadmap and MVP.  

---

## 11. Forbidden actions

| Forbidden | Rationale |
|-----------|-----------|
| Contradicting docs without updating them | Creates source-of-truth drift |
| Turkish or Russian content | Violates global language rules |
| Comments and TODOs in code | Violates project rules |
| Large refactors bundled with features | Hard to review and revert |
| Backend or infra code ahead of MVP clarity | Scope explosion |
| Camera / AI / map packages early | Phase violation |
| Invented screen flows | UX must follow `docs/09_UI_UX_GUIDELINES.md` and MVP scope |
| Pushing secrets or keys | Security violation |
| Auto-push or history rewrite | Unless explicitly requested |

---

## 12. Cursor checklist before every task

- [ ] Read `docs/00_PROJECT_RULES.md`.  
- [ ] For product or feature work: read `docs/01_PRODUCT_VISION.md` and `docs/03_MVP_SCOPE.md`.  
- [ ] For structure or layering: read `docs/04_TECH_ARCHITECTURE.md`.  
- [ ] Read the **specific feature doc** if touching that domain.  
- [ ] Read `docs/11_TESTING_AND_ACCEPTANCE.md` when changing user-visible flows or persistence.  
- [ ] Inspect current codebase layout and similar implementations.  
- [ ] Draft a **short plan** for non-trivial edits.  
- [ ] Confirm change size; **pause for approval** if large or ambiguous.  
- [ ] Implement **minimal** scope.  
- [ ] Run `flutter analyze` (and build when meaningful).  
- [ ] Output **Summary / Changed files / Verification / How to test / Risks / Next step**.  

---

## Related references

| Topic | Document |
|-------|----------|
| Requirements breadth | `docs/02_REQUIREMENTS.md` |
| Data and API planning | `docs/08_DATA_MODEL_AND_API_PLAN.md` |
| Roadmap phasing | `docs/10_DEVELOPMENT_ROADMAP.md` |

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial Cursor workflow baseline |

---

*End of document.*
