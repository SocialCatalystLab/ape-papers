# Research Ideas: Broadband Internet and Moral Foundations in Local Governance

## Idea 1: Broadband Adoption Thresholds and Moral Language Shifts (RECOMMENDED)

### Research Question
Does crossing a high-broadband adoption threshold cause shifts in the moral foundations expressed by local government officials during public meetings?

### Policy/Treatment
- **Treatment Definition:** Place crosses 70% household broadband subscription threshold
- **Treatment Data:** ACS Table B28002 (2013-2022), place-level, annual
- **Variation:** Staggered adoption across ~1,000 U.S. places
- **Treatment Timing:** Most places cross threshold between 2015-2020

### Outcome
- **Primary Outcomes:**
  1. Individualizing foundations score (Care + Fairness) per 1,000 words
  2. Binding foundations score (Loyalty + Authority + Sanctity) per 1,000 words
  3. Universalism vs. Communal ratio (Individualizing/Binding)
- **Data:** LocalView database — 153,452 local government meeting transcripts (2006-2023)
- **Measurement:** Extended Moral Foundations Dictionary (eMFD) word counts
- **Geographic ID:** State FIPS + Place FIPS (7-digit code)

### Identification Strategy
**Primary: Staggered Difference-in-Differences**
- Callaway-Sant'Anna (2021) estimator for heterogeneous treatment effects
- Treatment: First year place crosses 70% broadband threshold
- Control: Never-treated places (never reach 70%) + not-yet-treated
- Event study: τ ∈ {-5, ..., +5} relative to treatment

**Key Identification Assumptions:**
1. Parallel trends in moral foundations absent treatment
2. No anticipation effects
3. Treatment timing uncorrelated with unobserved shocks to moral language

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 2-4 years for most places (2013-treatment) | MARGINAL |
| Selection into treatment | Richer/urban places adopt faster | WEAK → address with IV |
| Comparison group | Never-treated are rural/poor → different | MARGINAL |
| Treatment clusters | ~1,000 places × 48 states | STRONG |
| Concurrent policies | Tech policy, social media, 2016/2020 elections | MARGINAL |
| Outcome-Policy Alignment | Broadband → information access → speech | STRONG |

**Mitigation Strategies:**
- IV robustness using terrain ruggedness (Nunn-Puga)
- Control for time-varying covariates (income, education, demographics)
- Placebo tests on pre-period outcomes
- Sensitivity analysis (Rambachan-Roth HonestDiD)

### Why Novel
1. **New outcome:** No prior work on internet → moral/political language in governance
2. **New data:** LocalView released ~2023, underutilized
3. **Theoretical contribution:** Tests whether digital connectivity polarizes or homogenizes local political discourse
4. **Policy relevance:** Digital divide → governance divide?

### Feasibility Confirmed
- [x] LocalView data downloaded and processed (153,452 meetings)
- [x] MFD scoring implemented and validated
- [x] ACS broadband API tested (place-level, 2013+)
- [x] Geographic identifiers match (st_fips)
- [x] Sufficient temporal overlap (2013-2022)

---

## Idea 2: Continuous Broadband Exposure and Moral Foundations (ALTERNATIVE)

### Research Question
Does marginal increase in broadband penetration affect moral language in local governance?

### Treatment
- **Treatment:** Continuous measure of household broadband rate (0-100%)
- **Model:** Two-way fixed effects with place + year FEs
- **Specification:** $Y_{pt} = \alpha_p + \gamma_t + \beta \cdot Broadband_{pt} + X_{pt}'\delta + \varepsilon_{pt}$

### Pros/Cons
- **Pro:** Uses full variation, no arbitrary threshold
- **Con:** TWFE with continuous treatment has interpretation issues
- **Con:** No clean event study visualization

### Role in Paper
Secondary specification for robustness; compare to threshold DiD results.

---

## Idea 3: Instrumental Variables — Terrain Ruggedness (ROBUSTNESS)

### Research Question
Same as Idea 1, but using exogenous variation in broadband driven by geography.

### Instrument
- **IV:** Terrain ruggedness index (Nunn-Puga 2012)
- **Mechanism:** Rugged terrain → higher broadband deployment costs → slower adoption
- **Exclusion:** Terrain affects language only through broadband (debatable for agriculture-dependent areas)

### First Stage
$Broadband_{pt} = \alpha_p + \gamma_t + \pi \cdot Ruggedness_p \times PostRollout_t + X_{pt}'\delta + \nu_{pt}$

### Why Include
- Addresses endogeneity of broadband adoption
- Standard in broadband literature (Kolko 2012, Ivus & Boland 2015)
- Strengthens causal interpretation

---

## Idea 4: ARRA Broadband Grants as Quasi-Experiment (EXTENSION)

### Research Question
Did ARRA-funded broadband infrastructure projects (2009-2013) affect moral foundations in nearby local governments?

### Treatment
- **Treatment:** Receipt of BTOP/BIP broadband grant in county
- **Data:** NTIA grant recipient database ($7.2B across 553 projects)
- **Timing:** Grants awarded 2010-2011, projects completed 2011-2015

### Pros/Cons
- **Pro:** Grant allocation more exogenous than adoption
- **Con:** Grant-level variation, not place-level
- **Con:** LocalView coverage thin pre-2013

### Role in Paper
Appendix robustness check if main results hold.

---

## Summary Ranking

| Idea | Novelty | Identification | Feasibility | Relevance | TOTAL |
|------|---------|----------------|-------------|-----------|-------|
| 1. Threshold DiD | 9/10 | 6/10 | 9/10 | 8/10 | 32/40 |
| 2. Continuous TWFE | 7/10 | 5/10 | 9/10 | 7/10 | 28/40 |
| 3. IV Ruggedness | 8/10 | 8/10 | 7/10 | 8/10 | 31/40 |
| 4. ARRA Grants | 8/10 | 7/10 | 5/10 | 7/10 | 27/40 |

**Recommendation:** Pursue Idea 1 (Threshold DiD) as main specification, with Ideas 2-4 as robustness checks in appendix.

---

## Theoretical Framework: Broadband → Moral Foundations

### Mechanisms

**H1: Information Exposure Hypothesis**
- Broadband increases exposure to diverse viewpoints via national news/social media
- Effect: ↑ Individualizing (exposure to liberal media) OR ↓ (echo chambers)

**H2: Echo Chamber Hypothesis**
- Broadband enables self-selection into like-minded information bubbles
- Effect: Amplification of pre-existing moral orientations

**H3: Nationalization Hypothesis**
- Broadband connects local politics to national discourse
- Effect: Convergence toward national partisan moral language

**H4: Deliberation Hypothesis**
- Broadband facilitates citizen engagement and feedback
- Effect: More responsive, moderate language to satisfy diverse constituents

### Haidt's Moral Foundations Theory
- **Individualizing foundations** (Care, Fairness): Associated with liberal/progressive politics
- **Binding foundations** (Loyalty, Authority, Sanctity): Associated with conservative politics
- **Universalism vs. Communal**: Higher-order dimension capturing this divide

### Predicted Effects
- If broadband → nationalization: Expect divergence in moral language based on local partisan lean
- If broadband → echo chambers: Expect amplification of baseline moral orientation
- If broadband → deliberation: Expect moderation/convergence

---

## Data Sources Confirmed

1. **LocalView Database**
   - Source: Harvard Dataverse
   - Coverage: 153,452 meetings, 1,033 places, 49 states, 2006-2023
   - Variables: st_fips, place_name, meeting_date, caption_text_clean
   - Status: ✅ Downloaded and processed

2. **ACS Table B28002 (Broadband)**
   - Source: Census API
   - Coverage: All places, 2013-2022 (5-year estimates)
   - Variables: B28002_001 (total HH), B28002_004 (broadband HH)
   - Status: ✅ API tested, working

3. **Extended Moral Foundations Dictionary (eMFD)**
   - Source: Hopp et al. (2021)
   - Coverage: ~3,000 moral words across 5 foundations + sentiment
   - Status: ✅ Downloaded and implemented

4. **Terrain Ruggedness Index**
   - Source: Nunn & Puga (2012)
   - Coverage: County-level for all U.S. counties
   - Status: ⏳ To download

5. **FCC Form 477 (Robustness)**
   - Source: FCC
   - Coverage: County-level, 2008-2022
   - Status: ⏳ To download for pre-2013 extension
