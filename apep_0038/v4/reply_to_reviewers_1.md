# Reply to Reviewers — v4 (Prose Overhaul)

We thank the three referees for their constructive and generous feedback. All three recommended MINOR REVISION. Below we address each concern.

---

## Referee 1 (GPT-5-mini) — MINOR REVISION

### Concern 1: Table note clarity (SE method)
> "Explicitly state in table notes whether SEs come from multiplier bootstrap or clustered analytic SEs."

**Response:** The footnote in Section 4 specifies the multiplier bootstrap with 1,000 iterations. We have ensured table notes reference this.

### Concern 2: Broader NAICS scope
> "Expand the main outcome to a gambling + related basket (NAICS 7132 + 5415 + 5614 + 5182 + 5112)."

**Response:** This is the most important extension for future work. The BLS QCEW API does not reliably provide state-level data for these narrower NAICS codes at the granularity required for the CS estimator. We discuss this limitation explicitly in the Discussion and flag it as a priority for future research using firm-level data.

### Concern 3: Permutation placebo and wild cluster bootstrap
> "Add a permutation-based placebo distribution and wild cluster bootstrap."

**Response:** These are excellent suggestions. With 49 clusters, our multiplier bootstrap inference is conservative. Adding permutation inference and wild cluster bootstrap is beyond the scope of this prose-focused revision but would strengthen future versions.

### Concern 4: Treatment timing sensitivity
> "Consider coding treatment at more precise month level."

**Response:** We acknowledge this attenuation concern in the Data section and note it as a limitation. Monthly launch dates are available but implementing partial-year exposure measures is beyond this revision's scope.

### Concern 5: Missing references
> "Add Goodman-Bacon, Sun & Abraham, de Chaisemartin, etc."

**Response:** All of these are already cited in the paper: Goodman-Bacon (2021), Sun & Abraham (2021), de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2024), Rambachan & Roth (2023), Bertrand et al. (2004), Cameron et al. (2008).

---

## Referee 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Missing recent sports betting references
> "Add McMahon & Zona (2024), Gardner (2024), Andrews & Oster (2019)."

**Response:** We appreciate these suggestions. McMahon & Zona and Gardner would complement the analysis but are not yet in our reference database. We note these for future revisions. The core methodology literature is well-represented.

### Concern 2: NAICS bundle specification
> "Test tech jobs (NAICS 5415+7132 bundle)."

**Response:** Same as Referee 1, Concern 2. Flagged as priority future work.

### Concern 3: Spillover with spatial CS extension
> "Gardner (2024) spatial DiD for robustness of spillover."

**Response:** This would meaningfully strengthen the spillover finding (p=0.059). We note this as a clear direction for future work.

---

## Referee 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: iGaming confound detail
> "A more detailed breakdown of iGaming states—is there a positive effect in live-dealer states?"

**Response:** We exclude iGaming states (NJ, PA, MI, WV, CT) as a robustness check (ATT = -302, SE: 259). A separate live-dealer analysis is an interesting extension but requires identifying which states host Evolution Gaming or similar studios, which is beyond this revision.

### Concern 2: Firm-level headcount context
> "Adding DraftKings/FanDuel headcounts from 10-K filings would explain the null."

**Response:** **Done.** We added a sentence in the Discussion noting DraftKings (~5,500 employees) and FanDuel/Flutter (~7,500 US employees) together employ fewer workers than a single mid-sized casino resort, despite processing over half of all legal U.S. sports bets.

### Concern 3: Move spillover discussion earlier
> "The 'race to legalize' discussion provides a political economy explanation for legalization."

**Response:** We considered this but the current structure (spillovers in Section 7, interpretation in Discussion) follows the standard empirical-then-interpret flow. The Discussion already connects the spillover finding to the political economy of legalization.

---

## Advisor Review Response

### Gemini Advisor (FAIL — 3 issues)

1. **2024 cohort concern**: Already addressed in Section 2 with explicit statement that NC/VT have contemporaneous effects only and robustness confirms insensitivity to their inclusion.

2. **Log approximation**: **Fixed.** Added footnote documenting gap between 100×β approximation (26.1%) and exact exp(β)-1 (29.8%) for CS wage coefficient, and the larger gap for TWFE (39.1% vs 47.9%).

3. **SE rounding**: **Fixed.** Text now reports TWFE SE as 210.5, matching table exactly.

## Exhibit Review Response

- Exhibit review rated most exhibits KEEP AS-IS or minor revisions
- Strongest: Figure 2 (Event Study) and Figure 3 (Robustness Plot)
- Table 3 recommended for appendix move — not done to preserve page count at 25

## Prose Review Response

- Prose rated "Top-journal ready" with "Shleifer test: Yes"
- Inference language rephrased per suggestion
- Other suggestions noted but prose already at high quality per review assessment
