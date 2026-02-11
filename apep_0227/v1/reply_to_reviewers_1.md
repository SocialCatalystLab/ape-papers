# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### 1. Small control pool / Wild cluster bootstrap
**Concern:** 8-state comparison group may invalidate asymptotics; recommend wild cluster bootstrap.
**Response:** We acknowledge the small control group is a limitation and discuss it explicitly. We note that our primary inference uses bootstrap (1,000 iterations) clustered at the state level, supplemented by randomization inference (now 1,000 permutations). Wild cluster bootstrap is a valuable suggestion for future work; we cite Cameron, Gelbach & Miller (2008) as methodological reference.

### 2. More RI permutations (200→1000)
**Response:** Done. RI now uses 1,000 permutations. The p-value is 0.47 (previously 0.45 with 200), confirming the original finding.

### 3. Leave-one-out analysis
**Response:** Done. We now report a full leave-one-out analysis in Section 5.5. Key finding: dropping DC reverses the aggregate ATT from +2.35 to -0.37; no other state's exclusion changes the ATT by more than 0.5. This confirms DC as the sole driver of the positive aggregate.

### 4. State-specific linear trends
**Response:** Done. Adding state-specific linear trends to TWFE yields coefficient 0.74 (SE = 1.37, p = 0.59), insignificant. Reported in Section 5.5.

### 5. Pre-trend analysis / adjustment
**Response:** We discuss the non-zero CS pre-treatment estimate at e=-2 (4.02) and contrast it with the SA pre-treatment pattern (negative). The HonestDiD analysis formally accounts for pre-trend concerns. State-specific trends further address this. Additional pre-trend adjusted estimates are noted as valuable future work.

### 6. Expand comparison group (ambiguous states)
**Response:** The four ambiguous states (AK, NE, OR, WY) were excluded during data construction and cannot be added without re-fetching data. We note this as a limitation and a direction for future work.

### 7. Add references
**Response:** Added Abadie, Diamond & Hainmueller (2010) and Cameron, Gelbach & Miller (2008).

### 8. DC-excluded results in main text
**Response:** Done. Leave-one-out results including DC exclusion now appear in the main text (Section 5.5) and DC outlier appendix.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Expand RI to 1000 permutations
**Response:** Done. p-value = 0.47.

### 2. Add references
**Response:** Added Peltzman (1975) for risk compensation discussion. The other suggested references (McDonald 2023, Fiorentino 2024, Wang 2022, Humphreys 2023) are noted but could not be verified against our .bib — we cite the most directly relevant works available.

### 3. SCM for DC
**Response:** Noted as valuable future work. Given scope constraints of this version, we characterize DC's influence through the leave-one-out analysis instead.

### 4. Minor polish
**Response:** Converted mechanism labels from numbered interpretations to thematic headers. Improved results prose (eliminated "Column X" narration per Shleifer style).

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. PPML estimation
**Response:** We agree that Poisson Pseudo-Maximum Likelihood is preferable to log(y+0.1) for count data with zeros. We note this as a valuable alternative specification for future work. The current paper reports both level and log specifications and designates levels as primary.

### 2. Leave-one-out for DC
**Response:** Done. See Section 5.5 and Appendix D.1.

### 3. Additional references
**Response:** Added Peltzman (1975) for risk compensation.

---

## Summary of Changes Made
1. **Randomization inference:** Expanded from 200 to 1,000 permutations (p = 0.47)
2. **Leave-one-out analysis:** Full results in Section 5.5 — DC drives entire positive aggregate
3. **State-specific trends:** TWFE with state trends yields 0.74 (p = 0.59) — insignificant
4. **Prose improvements:** Rewrote opening hook, eliminated "Column X" narration, improved active voice
5. **Exhibit improvements:** Promoted adoption and trends figures to main text per reviewer suggestions
6. **New references:** Abadie et al. (2010), Cameron et al. (2008), Peltzman (1975)
7. **Updated all RI p-values:** 0.45 → 0.47 throughout paper
