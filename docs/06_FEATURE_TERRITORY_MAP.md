# GymCoach — Feature Specification: Territory-Based Running Map Game

**Document type:** Feature specification (future / advanced)  
**Product:** GymCoach (Flutter mobile application)  
**Audience:** Product, design, Flutter engineers, backend engineers, GIS specialists, QA, privacy reviewers  
**Related documents:** `docs/00_PROJECT_RULES.md`, `docs/02_REQUIREMENTS.md`, `docs/03_MVP_SCOPE.md`, `docs/04_TECH_ARCHITECTURE.md`

This specification defines **behavior, rules, and acceptance criteria** only. It contains **no implementation code**.

---

## 1. Feature overview

The territory map game transforms **outdoor running** into a **competitive, map-based** experience. Users **record GPS routes** while running. When a route satisfies **closure**, **integrity**, and **game rules**, the enclosed region becomes **capturable territory** assigned to the runner (subject to validation and anti-cheat). Users may **name** territories. Territories render on a **map layer**. Other participants may **challenge or capture** territory according to published rules. **Leaderboards** summarize competitive outcomes such as captured area, territorial control duration, or challenge success rate—exact scoring is configurable per product phase.

---

## 2. Product goal

**Increase motivation** for regular outdoor running by binding movement to **visible progress on a map**, **ownership**, and **social competition** without sacrificing safety or privacy controls.

---

## 3. User problem

Many runners **lose motivation** over time. Traditional trackers emphasize distance and pace alone; some users respond better to **game loops**, **status**, and **light competition**. A territory layer adds **spatial stakes** and **replayability** if fairness (anti-cheat) and **privacy** are respected.

---

## 4. Core game loop

| Phase | Description |
|-------|-------------|
| Prepare | User selects territory run mode, reviews safety and GPS readiness. |
| Track | App records route points with timestamps while running. |
| Validate | Server-side or on-device checks assess closure, area plausibility, speed realism, and GPS quality. |
| Capture | Valid enclosed loop yields a territory polygon or captured region linked to the user. |
| Name | User assigns a display name with moderation constraints. |
| Display | Territory appears on map with ownership metadata (subject to privacy modes). |
| Compete | Rivals attempt captures or traversals per rules; ownership updates when criteria met. |
| Rank | Leaderboards reflect agreed scoring dimensions. |

---

## 5. User flow

| Step | Actor | System behavior |
|------|-------|------------------|
| 1 | User | Opens territory mode from an approved entry point (future navigation). |
| 2 | System | Shows prerequisites: GPS quality hint, battery, weather advisory copy (non-alarming). |
| 3 | User | Grants **location** permissions appropriate to foreground or background tracking policy. |
| 4 | User | Starts GPS route capture; optional countdown for readiness. |
| 5 | System | Streams location fixes into route builder with accuracy filters (Section 12). |
| 6 | User | Runs outdoors along intended path attempting closure (Section 7). |
| 7 | System | Provides lightweight cues (distance from start, loop progress) without distracting unsafe UI. |
| 8 | User | Ends session explicitly or via auto-stop rules when closure detected. |
| 9 | System | Runs validation pipeline (Sections 11–12); accepts, rejects, or flags **pending review**. |
| 10 | User | If accepted, names territory within naming rules (Section 9). |
| 11 | System | Persists territory, updates map visualization, refreshes personal stats. |
| 12 | User | Views leaderboard or rival territories according to privacy settings (Section 15). |

Alternate flows: failed GPS, anti-cheat rejection with explanation, manual discard of session.

---

## 6. Route tracking rules

| Rule | Description |
|------|-------------|
| Session lifecycle | Route belongs to a single session with immutable recorded points once finalized (corrections only via admin tooling if ever added). |
| Sampling strategy | Record fixes at adaptive intervals balancing accuracy vs battery; drop outliers exceeding accuracy thresholds. |
| Pause handling | Pauses freeze elapsed movement scoring but preserve continuity rules defined by engineering spec (paused segments excluded from speed averages). |
| Background continuity | If background tracking allowed, OS constraints must be documented; inconsistent gaps influence validation outcomes. |
| Minimum duration | Sessions shorter than a configured minimum may auto-reject unless labeled exploratory mode without capture eligibility. |
| Minimum distance | Path length thresholds prevent trivial micro-loops unless explicitly permitted for tutorials. |

---

## 7. Territory capture rules

| Rule | Description |
|------|-------------|
| Closure detection | Territory eligible when route forms a **closed** or **near-closed** loop per geometric tolerance (e.g., end point within radius **R** meters of start for **T** seconds). |
| Enclosure validity | Polygon derived from simplified polyline must have positive area above **A_min** and below **A_max** to reduce GPS artifacts and unrealistic mega-claims. |
| Self-intersection | Disallow overly chaotic self-crossings unless classified as valid multipolygon under explicit rules. |
| Single capture per session | One capture outcome per validated session unless product defines splits. |
| Overlap policy | New territories overlapping existing ones trigger **ownership resolution** (Section 8) rather than silent stacking. |
| Time window | Captures may be restricted to daylight or configured hours if legally or operationally required (region-specific flags). |

---

## 8. Territory ownership rules

| Concept | Behavior |
|---------|----------|
| Initial capture | First validated enclosure awards ownership to runner subject to uniqueness constraints. |
| Challenge types | Future phases may define **traverse-to-weaken**, **boundary-run**, or **timed siege** mechanics—must be enumerated before launch. |
| Capture by rival | Successful rival run meeting challenge criteria transfers or splits ownership per configured model (hard transfer vs contested zone). |
| Cooldowns | Optional immunity windows post-capture to reduce harassment near homes or workplaces when paired with privacy tools. |
| Stale territories | Decay or expiration policies optional to prevent permanent map clutter; must be communicated in UX. |
| Disputes | Automated rejection precedes manual moderation hooks if social scale demands it. |

Exact formulas belong in a companion game-design appendix once backend exists.

---

## 9. Territory naming rules

| Requirement | Detail |
|-------------|--------|
| Length bounds | Minimum and maximum character counts enforced client and server. |
| Charset | Unicode subset aligned with moderation tooling; strip zero-width characters. |
| Prohibited content | Hate, harassment, sexual content, personal data dumps—blocked via filters plus reporting. |
| Uniqueness | Optional uniqueness per region tile vs global uniqueness—product decision. |
| Rename policy | Limited free renames per interval to reduce abuse. |
| Fallback | System-generated neutral labels when user skips naming. |

---

## 10. Leaderboard rules

| Dimension | Notes |
|-----------|-------|
| Scope | Global, regional, friends-only, or clan scopes configurable; privacy-first defaults for MVP of this feature. |
| Metrics | Total captured area, weekly gains, successful defenses, streaks—pick **one primary** metric per board to avoid confusion. |
| Eligibility | Only validated sessions contribute; rejected routes excluded retroactively. |
| Tie-breaking | Timestamp or secondary metric documented. |
| Refresh cadence | Near-real-time vs hourly aggregation—affects Redis usage in future backend. |
| Opt-out | Users can hide presence from public boards while retaining personal stats locally if supported. |

---

## 11. Anti-cheat rules

Sessions may be **rejected** or **marked invalid** when signals indicate non-running transport or spoofing.

| Signal | Example threshold concept |
|--------|---------------------------|
| Average speed | Above plausible sustained running pace for terrain-adjusted profile |
| Maximum instantaneous speed | Spike inconsistent with human sprint patterns |
| GPS jumps | Teleport-like coordinate deltas within implausible time deltas |
| Straight-line high-speed segments | Highway-like geometry at automobile speeds |
| Completion too fast | Area-per-minute exceeds calibrated bounds |
| Poor GPS accuracy | HDOP / accuracy radius persistently above ceiling |
| Background inconsistencies | Gaps or resumed coordinates incompatible with continuous motion |
| Sensor fusion (future) | Accelerometer inconsistency with claimed pace |

**Outcomes:** hard reject, soft flag for manual review, or degraded trust score affecting leaderboard eligibility—policy table required before production social launch.

---

## 12. GPS accuracy requirements

| Requirement | Guidance |
|-------------|----------|
| Fix filtering | Ignore fixes worse than agreed horizontal accuracy meters except when no better fix available within timeout. |
| Warm-up | Require stable accuracy streak before capture-eligible phase begins. |
| Urban canyon handling | Detect multipath; warn user when polygon confidence low; may block capture. |
| Sampling density | Ensure vertices adequate for polygon stability without overfitting noise. |
| Altitude | Optional; elevation not primary unless slope-adjusted anti-cheat introduced. |
| Permissions | Foreground-only vs background documented per OS; degrade gracefully when reduced to coarse permission. |

Hardware-specific tuning belongs in engineering performance budgets.

---

## 13. Map UI states

| State | Purpose |
|-------|---------|
| Pre-run briefing | Permissions, GPS quality, safety reminders |
| Waiting for GPS fix | Spinner / guidance to open sky |
| Tracking active | Polyline draw, subtle closure proximity cue |
| Pause | Paused banner; map frozen |
| Validation pending | Post-run processing animation |
| Accepted capture | Naming prompt |
| Rejected route | Actionable reasons mapped from anti-cheat codes |
| Territory overview | Owned vs contested visualization |
| Leaderboard | Rank list with empty states |
| Error / offline | Offline capture prohibited or queued policies communicated |

Map rendering must avoid unsafe interaction while moving; voice or audio cues optional future enhancement.

---

## 14. Data model needs

Conceptual entities (names illustrative):

| Entity | Role |
|--------|------|
| RunSession | Owner user id, timestamps, device metadata, validation outcome |
| TrackPoint | Lat, lon, accuracy, timestamp, optional speed |
| TerritoryPolygon | Geometry reference, area metric, owner id, name, created_at |
| OwnershipEvent | Transfer audit trail |
| LeaderboardRow | Scoped ranking aggregates |
| AntiCheatReport | Structured rejection codes |

Geometry storage should suit backend spatial queries (PostGIS or equivalent) when server authoritative logic launches.

---

## 15. Privacy requirements

| Requirement | Detail |
|-------------|--------|
| Location sensitivity | Treat precise routes as **special category** data under applicable regulations mindset; minimize retention. |
| Exact route sharing | **Optional**; default avoids publishing full polyline publicly. |
| Territory display abstraction | Option to **blur**, **snap to grid**, or **buffer** polygons near frequent start locations (e.g., home) if user opts in to hiding anchors. |
| Social exposure | Separate toggles for map visibility, name on leaderboard, and rival notifications. |
| Data deletion | User-initiated deletion propagates to server aggregates where feasible; document eventual consistency. |
| Analytics | Aggregate movement analytics without storing raw routes unless consented. |

---

## 16. Safety requirements

| Requirement | Detail |
|-------------|--------|
| Environmental awareness | Users warned to obey traffic laws, use sidewalks, remain alert—game incentives must not encourage unsafe road crossings. |
| Disclaimer | Feature does not replace coaching or medical advice related to cardiac risk. |
| Weather | Surface stale advisory pointers without guaranteeing real-time hazard detection. |
| Night running | Encourage visibility gear; optional restriction policies per region. |
| Minors | Age-gating or parental controls if required by jurisdiction. |

---

## 17. Edge cases

| Case | Handling |
|------|----------|
| GPS drift forming fake loops | Area caps + smoothing + rejection |
| Indoor treadmill runs | Not eligible unless product introduces alternate validation |
| Ferry / train accidental segments | Speed + path disjoint detection rejects |
| Parallel runners | Attribution ambiguity avoided via session signing timestamps server-side |
| Crossing national borders | Spatial rule flags if contests restricted geographically |
| Battery death mid-run | Partial sessions marked incomplete; no capture |
| Clock skew | Server authoritative timestamps where possible |
| Duplicate submissions | Idempotent session ids |

---

## 18. MVP exclusion note

This feature **must not** ship as part of the **first GymCoach MVP** unless explicitly approved by scope owners (`docs/03_MVP_SCOPE.md`). Core workout planning, execution, and statistics remain priority. Territory gameplay demands ** sustained GPS UX**, **anti-cheat**, **privacy**, and likely **backend authority**—all deferred until MVP stability and compliance review.

---

## 19. Future implementation plan

| Phase | Deliverable |
|-------|-------------|
| Discovery | Legal review of location collection; competitor benchmarking |
| Client skeleton | Feature module boundaries only (`docs/04_TECH_ARCHITECTURE.md`) |
| Offline prototype | Local polyline recording without social surfaces |
| Server authority | FastAPI services validating polygons; Postgres + PostGIS; Redis leaderboards |
| Anti-cheat v1 | Speed + jump heuristics; telemetry dashboards |
| Social beta | Friends-only visibility default |
| Hardening | Abuse tooling, moderation for names, expanded cheat signals |

Dependencies across mobile OS permissions, map SDK licensing, and infrastructure costs must be estimated before phase commitments.

---

## 20. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-01 | Users can start and stop a tracked outdoor session with clear lifecycle states (Section 13). |
| AC-02 | Closure and enclosure rules (Sections 6–7) reproducibly accept known-good fixtures and reject known-bad fixtures in test harnesses. |
| AC-03 | Successful captures produce named territories adhering to Section 9. |
| AC-04 | Territories render on map with ownership differentiation consistent with data model (Section 14). |
| AC-05 | Anti-cheat examples in Section 11 produce documented outcomes on synthetic tracks. |
| AC-06 | Privacy toggles behave as described; default does not publish precise routes publicly (Section 15). |
| AC-07 | Safety copy surfaces during onboarding to run mode (Section 16). |
| AC-08 | Leaderboards include only validated sessions and honor opt-out (Section 10). |
| AC-09 | Battery and thermal behavior documented against reference devices after prolonged tracking (linked engineering artifact). |
| AC-10 | Backend-backed phases expose audit logs for ownership transfers when multiplayer enabled. |

Prototype phases may defer AC-08 and AC-10 until server infrastructure exists; document phase tagging when signing off releases.

---

## Document control

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-05-07 | Initial territory map feature specification |

---

*End of document.*
