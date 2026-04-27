# GymCoach — Project Rules

Permanent source of truth for all development in this repository. Every contributor and automation must follow these rules without exception.

---

## 1. Project identity

- **Name:** GymCoach  
- **Platform:** Flutter / Dart mobile application  
- **Purpose:** A fitness coaching application that helps users create workout plans, track exercises, manage training schedules, and view progress statistics.  
- **Future scope (non-MVP unless explicitly approved):** Camera-based exercise validation, AI-generated training plans, competitive workout challenges, territory-based running map game, and related advanced features.

---

## 2. Main product goal

Deliver a reliable, maintainable mobile product that supports structured training: planning, execution tracking, scheduling, and measurable progress. MVP stability and clarity take precedence over speculative or experimental capabilities.

---

## 3. Global language rules

All of the following MUST be in **English only**:

- Source code (including identifiers embedded in code)
- UI strings visible to users
- File and directory names
- Class, mixin, enum, typedef, extension, and trait names
- Variables, functions, methods, parameters, and constants
- Error messages, assertions, and log output
- Inline documentation where documentation is permitted by source code rules (see Section 4)
- Repository documentation (unless a rare legal exception requires another language, documented separately)
- Git commit messages
- Implementation notes and technical specifications
- Prompts and instructions used with tooling when they become part of repo artifacts

**Strict prohibitions:**

- Do not write Turkish anywhere in the project.
- Do not write Russian anywhere in the project.
- Do not mix languages in identifiers, UI, or docs.
- Do not translate technical names into Turkish or Russian; use standard English technical naming.

---

## 4. Source code rules

- Do not write code comments.
- Do not add unnecessary explanations inside code.
- Do not use TODO comments.
- Do not leave commented-out code.
- Do not use placeholder names such as `test`, `temp`, `foo`, `bar`, `abc`, `screen1`, or `data2` except where a testing framework legitimately requires a conventional name (prefer descriptive test names even then).
- Use readable names so that comments are not needed.
- Prefer simple, maintainable code over clever or dense code.
- Keep functions small and focused.
- Keep widgets focused and reusable.
- Avoid large files when a feature can be split cleanly without harming cohesion.
- Avoid unnecessary abstractions before they are needed.
- Do not over-engineer the MVP.

---

## 5. Flutter architecture rules

- Use a **clean feature-based** project structure.
- **Separate concerns:** UI, state, domain logic, and data access must remain distinguishable and appropriately layered.
- Keep **business logic out of widgets** when practical; widgets should compose and render.
- Keep **routing centralized**.
- Keep **theme configuration centralized**.
- Place **reusable UI components** in a shared location consistent with the agreed structure.
- Keep **models clean and predictable**; prefer explicit types over ambiguous dynamic usage.
- Use **immutable data structures** where practical (e.g., immutable model classes, copy-with patterns where appropriate).
- Use **consistent naming** across features.
- Avoid duplicating UI logic; extract shared behavior thoughtfully.
- Avoid hardcoded magic values when they belong in theme, constants, or configuration.
- Make the UI **responsive** for common mobile screen sizes.

---

## 6. Naming rules

- Use **clear, professional English** for all names.
- Follow **Dart style** and **effective Dart** conventions for libraries, files, and APIs.
- Names MUST reflect **intent and domain** (training, workouts, schedules, progress), not implementation trivia.
- Avoid abbreviations unless they are universally understood in fitness or software (`id`, `url`, `api` are acceptable when conventional).
- Files and symbols MUST remain consistent with feature boundaries and public API clarity.

---

## 7. UI text rules

- All user-visible strings MUST be **English**.
- Wording MUST be **professional**, **consistent**, and **accessible** (clear verbs, avoid jargon without context).
- Prefer **sentence case** or **title case** consistently per component category; align with the centralized theme and copy guidelines once established.
- Errors shown to users MUST be **actionable** where possible (what happened, what to do next).
- Do not embed debug or internal identifiers in user-facing copy.

---

## 8. State management rules

- Choose **one primary state approach** per area of the app and stay consistent; do not mix incompatible patterns without a documented migration.
- Keep **state close** to where it is needed, but **lift** when multiple descendants require the same truth.
- Avoid **global mutable singletons** for domain state unless justified and encapsulated.
- Side effects (network, persistence, timers) MUST live in **appropriate layers**, not scattered inside unrelated widgets.
- Prefer **predictable data flow**: unidirectional updates where the chosen architecture supports it.

---

## 9. Package usage rules

- Do not add a dependency **without explaining why** it is needed (purpose, tradeoffs, and scope).
- Prefer **well-maintained**, **widely used** packages compatible with the project's Flutter channel.
- Avoid packages that force **non-English** tooling surfaces into the repo without mitigation.
- Lock versions responsibly per project policy (`pubspec.yaml`); follow team convention for version constraints.
- Remove unused dependencies when they are no longer required.

---

## 10. Security rules

- Never hardcode **secrets**, **API keys**, **tokens**, **private credentials**, **passwords**, or **personal data**.
- Use **secure storage** and environment-appropriate configuration for sensitive values.
- Never commit **generated private files** or machine-local artifacts not intended for the repository.
- Validate **permissions** (camera, location, health data, etc.) only when a feature truly requires them, and handle denial gracefully.
- Follow **platform guidelines** for data minimization and user consent where applicable.

---

## 11. Git and commit rules

- Commit messages MUST be **English**.
- Commit messages MUST **describe the real change** (what and why at a useful level).
- Do not mention **AI tools** in commit messages.
- Do not include phrases such as “Made with Cursor”, “Generated by AI”, or similar.
- Do not **rewrite Git history** unless explicitly requested.
- Do not **push** automatically unless explicitly requested.
- Keep commits **focused**; avoid mixing unrelated concerns.

---

## 12. Cursor working rules

- Always **inspect the existing project structure** before editing.
- Always **read this file** before starting implementation work.
- Always **read the related feature document** before implementing a feature (when such a document exists).
- Always create a **short implementation plan** before making large changes.
- Always keep changes **minimal**, **safe**, and **reversible**.
- Always **summarize modified files** after implementation.
- Always run **`flutter analyze`** when possible after substantive edits.
- Always **verify the app still builds** after meaningful code changes.
- If there is **uncertainty**, stop and **ask for clarification** instead of guessing.

---

## 13. Documentation rules

- Documentation MUST stay **aligned** with the actual implementation.
- When a major feature changes, update the **relevant documentation** in the same delivery cycle when feasible.
- Do not write **unrealistic** documentation that does not match the project.
- Clearly **separate MVP requirements** from **future ideas**.
- Mark **risky** or **future** features explicitly so implementers do not treat them as current scope.
- Keep documentation **practical**: oriented toward implementation decisions, constraints, and verification.

---

## 14. Forbidden actions

The following actions are forbidden unless explicitly approved:

- Introducing **Turkish** or **Russian** (or any non-English project language) into code, UI, names, or docs covered by Section 3.
- Adding **code comments**, **TODO comments**, **commented-out code**, or **placeholder identifiers** contrary to Sections 4 and 6.
- **Hardcoding secrets** or committing sensitive artifacts (Section 10).
- **Deleting or breaking** existing working functionality without explicit approval.
- Performing **large refactors** together with feature work in the same change set.
- **Installing packages** without justification (Section 9).
- Introducing **backend code** before Flutter MVP scope is clear.
- Implementing **AI**, **camera validation**, **GPS territory capture**, or **social features** before the core MVP is stable unless explicitly requested.

---

## 15. Definition of done

Work is done only when ALL applicable items hold:

- Changes respect **language**, **code**, **architecture**, **security**, and **Git** rules in this document.
- **No forbidden actions** were introduced.
- **`flutter analyze`** passes when tooling is available, or issues are documented with owner follow-up.
- The app **builds successfully** after meaningful code changes.
- **User-visible behavior** matches the intended MVP or approved scope.
- **Documentation** affected by the change is updated when the change is user-facing or architectural.

---

## 16. Pre-implementation checklist

Before writing or rewriting code:

- [ ] Read **`docs/00_PROJECT_RULES.md`** (this file).
- [ ] Inspect **current project structure** and locate the correct feature area.
- [ ] Read the **feature spec or doc** for the task, if it exists.
- [ ] Confirm **MVP vs future** scope for the change.
- [ ] Draft a **short plan** for non-trivial work (files to touch, layers affected, risks).
- [ ] Confirm **no new dependency** is needed, or document why one is required before adding it.

---

## 17. Post-implementation checklist

After completing implementation:

- [ ] Review diff for **English-only** identifiers and UI text.
- [ ] Confirm **no comments**, **TODOs**, **commented-out code**, or **placeholder names**.
- [ ] Run **`flutter analyze`** when possible.
- [ ] Run a **build** to confirm compilation.
- [ ] Summarize **modified files** and behavioral impact for reviewers or maintainers.
- [ ] Update **documentation** if behavior or architecture changed materially.

---

*End of document.*
