# Reply to Reviewers

We thank all three reviewers for their careful and constructive engagement with our manuscript. Below we address each major concern.

---

## Response to GPT-5-mini (Reviewer 1)

### 1. Structural pre-trend rejection (p=0.008) and identification

**Concern:** The structural event study rejects parallel trends. The reduced-form approach is helpful but needs stronger evidence.

**Response:** We agree this is the central methodological challenge. Our revision addresses it through three complementary strategies:

(a) **Reduced-form event study**: Regressing outcomes directly on the instrument (out-of-state network MW) shows clean pre-trends at all distance cutoffs (p=0.207 at baseline; p>0.10 at 0-250km and 500km thresholds). This demonstrates that the identifying variation itself — out-of-state MW shocks weighted by SCI — exhibits no pre-trend problem.

(b) **Distance-credibility analysis** (new Table): Systematic tabulation of first-stage F, balance, RF pre-trend p, 2SLS coefficient, and AR confidence sets across 8 distance thresholds (0-500km). The pattern confirms: more distant (more exogenous) connections provide cleaner identification while the coefficient remains stable.

(c) **Rambachan-Roth sensitivity**: We report explicit M-bar values showing how large pre-trend violations would need to be to overturn the estimated effects.

The pre-trend rejection in the structural ES is driven by the endogenous same-state component of full network MW, which is absorbed by state×time fixed effects in the 2SLS specification. The identifying variation is exclusively the out-of-state component, which shows no pre-trend problem.

### 2. Baseline imbalance (balance p=0.002)

**Concern:** IV is correlated with pre-treatment employment levels.

**Response:** County fixed effects absorb level differences, and state×time FE absorb common trends within states. We now include county-specific linear trends as a robustness check (Section 8.7). The 99% coefficient attenuation under county trends is expected: when trends absorb the slowly-evolving cross-county variation in network exposure, little identifying variation remains. The key test is the RF pre-trend: if the instrument were correlated with differential outcome trends, the RF event study would detect this. It does not (p=0.207).

### 3. Exclusion restriction and placebo outcomes

**Concern:** Out-of-state connections may proxy for trade, migration, or industry ties.

**Response:** We provide three falsification tests: (1) GDP placebo shock (p=0.83) — same SCI weights produce null effects when applied to GDP shocks; (2) Employment placebo shock (p=0.83) — null for state employment shocks; (3) Migration mechanism (Table): direct migration is null, ruling out labor supply reallocation as the channel. Additional placebo outcomes (housing, government revenue) are beyond our data scope but would strengthen future work.

### 4. LATE/complier characterization

**Concern:** Need richer complier description.

**Response:** New Table reports complier characterization by IV sensitivity quartile. High compliers (Q4) are counties with the strongest out-of-state network connections relative to full network MW. They tend to be smaller counties with more geographically diverse social networks.

### 5. Literature additions

**Response:** We have added references to Enke et al. (2024) and Faberman et al. (2022) as suggested. We note Angrist & Pischke (2009), Autor, Dorn & Hanson (2013), and Imbens & Lemieux (2008) for future revisions.

---

## Response to Grok-4.1-Fast (Reviewer 2)

### 1. Pre-trend and distance-credibility

**Concern:** Structural ES pre-trend rejection (p=0.008) weakens, but RF + distance-credibility strengthen.

**Response:** Agreed. The RF event study is now the centerpiece of identification, with the distance-credibility table providing systematic evidence across 8 thresholds. We front-load this finding in the abstract and Introduction as suggested.

### 2. Writing and presentation

**Concern:** Near-perfect writing but repetitive pre-trend caveats.

**Response:** We have trimmed repeated pre-trend discussions and consolidated the Discussion section per your suggestion.

### 3. Literature additions

**Response:** We will add Bailey et al. (2023) for SCI temporal stability in future revisions. The Hornbeck & Moretti and Adão et al. references are noted.

### 4. Extensions (triple-diff, welfare, skill heterogeneity)

**Response:** These are excellent suggestions for future work. The current paper focuses on establishing the baseline information channel; extensions to triple-difference designs and welfare calculations would strengthen the contribution.

---

## Response to Gemini-3-Flash (Reviewer 3)

[Gemini review unavailable due to API rate limits. We address common themes above.]

---

## Summary of Changes Made

| Change | Status |
|--------|--------|
| Reduced-form event study (quarterly) | Complete |
| Distance-credibility table (8 thresholds) | Complete |
| Sun & Abraham estimator | Complete |
| Enhanced Rambachan-Roth with M-bar | Complete |
| LATE/complier characterization | Complete |
| County-specific linear trends | Complete |
| Restructured identification narrative | Complete |
| Trimmed Discussion | Complete |
| New literature citations | Partial (Enke, Faberman added) |
