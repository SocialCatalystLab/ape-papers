# Research Ideas

## Idea 1: Revisiting MGNREGA with Modern Econometrics: Heterogeneous Treatment Effects of India's Employment Guarantee

**Policy:** Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA), rolled out in 3 phases: Phase 1 (Feb 2006, 200 poorest districts), Phase 2 (Apr 2007, 130 additional districts), Phase 3 (Apr 2008, remaining ~270 districts). Assignment based on Planning Commission backwardness index. The gold-standard natural experiment in development economics.

**Outcome:** NFHS-4 (2015-16) vs NFHS-5 (2019-21) district factsheets (707 districts). Key indicators: female literacy, female school attendance, stunting, underweight, institutional births, improved sanitation. These capture LONG-RUN human capital effects of 10-15 years of guaranteed employment. The NFHS data is confirmed accessible (73K rows from GitHub, 707 districts with both NFHS-4 and NFHS-5 values).

**Identification:** Staggered DiD exploiting the 3-phase rollout. Phase 1 districts (treated 2006) had 10 years of MGNREGA by NFHS-4, 15 years by NFHS-5. Phase 3 districts (treated 2008) had 8 years and 13 years respectively. The key insight: while ALL districts are treated by 2008, the DOSE differs — Phase 1 districts accumulated 2 extra years of employment guarantee. Use exposure duration (years since MGNREGA implementation) as continuous treatment. Callaway-Sant'Anna framework with the 2-period NFHS panel. State fixed effects control for time-invariant confounders.

**Why it's novel:** While MGNREGA's labor market effects are well-studied (Imbert & Papp 2015 AEJ, Zimmermann 2020, Muralidharan et al. 2023 Econometrica), NO paper examines long-run human capital effects using modern heterogeneity-robust DiD methods. Previous studies used TWFE (now known to be biased with staggered treatment) and stopped at short-run outcomes (wages, employment). We estimate 15-year effects on the NEXT GENERATION — children born to MGNREGA-exposed mothers — using district-level health and education data.

**Feasibility check:**
- NFHS district data: **Confirmed accessible** — downloaded from GitHub. 707 districts with 50+ indicators.
- MGNREGA phase mapping: **Confirmed available** — Imbert & Papp (2015) replication package on OpenICPSR (project 113591). Also reconstructable from Zimmermann (2020) appendix tables listing districts by state and phase.
- Treatment variation: 200 Phase 1 + 130 Phase 2 + ~270 Phase 3 = 600+ districts. **Passes ≥20 rule.**
- Pre-periods: With 2 NFHS rounds (NFHS-4, NFHS-5) both post-treatment, we rely on cross-sectional variation in treatment DURATION rather than traditional pre/post. However, NFHS-4 itself serves as "earlier post" and NFHS-5 as "later post," identifying the marginal effect of additional exposure years.
- **Key concern:** Both NFHS rounds are post-treatment (all districts treated by 2008). Identification relies on exposure duration variation, not treatment onset. This is a reduced-form intensity design, not classic staggered DiD. Robustness: placebo test using pre-MGNREGA outcomes (e.g., electricity, which shouldn't respond to MGNREGA exposure duration).

---

## Idea 2: Can Clean Cooking Save Lives? India's Ujjwala Yojana and Child Health

**Policy:** Pradhan Mantri Ujjwala Yojana (PMUY), launched May 2016. Provides free LPG connections to Below Poverty Line (BPL) women. 100 million connections distributed by 2021. District-level variation in take-up driven by BPL population density and state implementation capacity.

**Outcome:** NFHS-4 (2015-16, PRE-Ujjwala) vs NFHS-5 (2019-21, POST-Ujjwala). Key indicators: "Households using clean fuel for cooking (%)" (direct first stage), acute respiratory infection (ARI) in children, anemia in women, stunting, child mortality. 707 districts.

**Identification:** Continuous treatment intensity DiD. Treatment exposure = (100 - NFHS-4 clean fuel %) / 100. Districts with LOW baseline clean fuel use had more BPL households eligible for Ujjwala → received more free LPG connections. First stage: clean fuel gap → Δ clean fuel. Reduced form: clean fuel gap → Δ health outcomes. This is a clean pre/post design: NFHS-4 (2015-16) predates Ujjwala (May 2016), NFHS-5 (2019-21) captures full post-treatment.

**Why it's novel:** Ujjwala is the world's largest clean cooking program. Only one working paper (Siddiqui et al. 2023) examines health effects, using state-level data. No district-level causal evaluation exists using the NFHS panel. Indoor air pollution from cooking is the leading environmental health risk in developing countries — this directly tests whether a supply-side fuel intervention works.

**Feasibility check:**
- NFHS data: **Confirmed accessible.** "Clean fuel" indicator exists in both NFHS-4 and NFHS-5 at district level.
- Treatment timing: Clean separation — NFHS-4 fieldwork (Jan 2015-Dec 2016) largely predates Ujjwala (May 2016). NFHS-5 fieldwork (2019-21) is fully post-treatment.
- Treatment variation: 707 districts with continuous baseline clean fuel variation. **Passes ≥20 rule.**
- Pre-periods: Only 2 periods (NFHS-4, NFHS-5). Cannot do event study. But the pre/post design is clean because Ujjwala launched BETWEEN the two surveys.
- **Key concern:** Design is similar to apep_0421 (baseline gap × post). However, the POLICY is different (cooking fuel vs water), the MECHANISM is different (indoor air pollution vs waterborne disease), and the OUTCOMES are different (ARI, anemia vs diarrhea). The clean temporal separation (Ujjwala launched May 2016, between NFHS rounds) is stronger than JJM (which launched Aug 2019, during NFHS-5 fieldwork).

---

## Idea 3: Does Rural Road Access Build Markets? PMGSY and Agricultural Commercialization

**Policy:** Pradhan Mantri Gram Sadak Yojana (PMGSY), launched Dec 2000. Provides all-weather road connectivity to unconnected habitations. Phase-wise implementation based on habitation population thresholds: >1000 (Phase 1), 500-999 (Phase 2), 250-499 (Phase 3). Over 750,000 km of roads constructed connecting 178,000+ habitations.

**Outcome:** NFHS-4/5 district indicators as proxies for economic development. Also: district-level agricultural data from ICRISAT Village Dynamics if accessible.

**Identification:** Population-threshold RDD. Habitations just above the 500-person threshold received roads earlier than those just below. At the district level: share of habitations near the population threshold creates an instrument for road connectivity intensity. Alternative: district-level PMGSY road-km as continuous treatment.

**Why it's novel:** Asher & Novosad (2020, AER) studied PMGSY using the population threshold RDD but focused on consumption, firms, and night lights. No paper examines PMGSY's effects on HEALTH and EDUCATION outcomes at district level. Road access → market access → dietary diversity → child nutrition is a plausible mechanism.

**Feasibility check:**
- NFHS data: Available. PMGSY road data: Available from PMGSY portal (omms.nic.in), though bulk download uncertain.
- **Key concern:** Replication of Asher & Novosad (2020 AER) design. Their paper is authoritative and in AER — hard to improve on. The RDD design requires habitation-level data (PMGSY OMMS), not district-level. NFHS operates at district level, creating an aggregation mismatch.
- **VERDICT:** Feasible but lower priority due to aggregation issues and overlap with existing AER paper.

---

## Idea 4: India's Mid-Day Meal Scheme and Long-Run Educational Attainment

**Policy:** National Programme of Mid-Day Meals in Schools, mandated by Supreme Court order (Nov 2001) for primary schools and extended to upper primary (2006). States implemented at different speeds from 2001-2008, creating staggered variation.

**Outcome:** NFHS-5 district data on education (female school attendance, literacy, 10+ years schooling). Also UDISE+ school data if accessible.

**Identification:** Cohort-exposure design. Children exposed to mid-day meals during primary school (ages 6-10) should show better educational attainment as adults. Cross-district variation in implementation timing creates different exposure cohorts. NFHS-5 captures outcomes for the "exposed generation" (born ~1996-2005, ages 16-25 in 2021).

**Why it's novel:** Afridi (2010 JDE) and Singh et al. (2014) studied short-run nutrition effects. No paper traces the LONG-RUN educational attainment effects using district-level data covering the fully exposed generation.

**Feasibility check:**
- NFHS data: Available. State-level implementation dates: Available from literature.
- **Key concern:** Implementation dates are hard to pin down precisely at district level. State-level variation gives only ~30 treatment units (states), which is sufficient, but implementation was often gradual rather than binary. The cohort-exposure design is more complex to implement than standard DiD.
- **VERDICT:** Interesting but challenging data construction. Lower priority.
