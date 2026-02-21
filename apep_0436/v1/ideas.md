# Research Ideas

## Idea 1: MGNREGA and Structural Transformation: Did India's Employment Guarantee Accelerate or Retard the Shift from Farm to Non-Farm Work?

**Policy:** Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA). Phased rollout: Phase I (Feb 2006, 200 poorest districts), Phase II (Apr 2007, +130 districts), Phase III (Apr 2008, all remaining ~310 rural districts). Assignment based on Planning Commission Backwardness Index.

**Outcome:** Worker composition from Census PCA (1991, 2001, 2011) at village level via SHRUG: share of main workers classified as cultivators (`main_cl`), agricultural laborers (`main_al`), household industry workers (`main_hh`), and other workers (`main_ot`). Primary outcome = non-farm worker share = (main_hh + main_ot) / total_main_workers. Secondary: annual nightlights (DMSP 1994-2013, VIIRS 2012-2023) as proxy for non-farm economic activity at district level.

**Identification:** Staggered DiD exploiting the three-phase rollout. Phase III districts (treated Apr 2008) serve as late-adopter controls for Phase I (treated Feb 2006). Callaway & Sant'Anna (2021) heterogeneity-robust estimator with three cohort groups. Pre-trend validation: Census 1991→2001 worker composition changes should be parallel across phase groups. Nightlights provide annual pre/post series for event study plots. Cluster SEs at state level (28+ clusters).

**Why it's novel:**
- No published paper has studied MGNREGA's effect on structural transformation (farm-to-non-farm worker shift) at village level using SHRUG.
- Existing literature focuses on direct employment/wage effects (Imbert & Papp 2015), nightlights at district level (Cook & Shah 2020), or GE effects from a single-state RCT (Muralidharan et al. 2023). Nobody has examined the Census worker composition channel.
- Theory is genuinely ambiguous: demand stimulus (higher rural incomes → more non-farm demand) vs. labor cost shock (higher reservation wage → fewer non-farm firms). The sign of the effect is unknown ex ante.
- Asher & Novosad (2020) used identical SHRUG data infrastructure to study roads (PMGSY) → structural transformation. We apply the same data to MGNREGA — the logical companion question.

**Feasibility check:**
- ✅ Variation: 3 clean phases across 640+ districts, staggered over 26 months.
- ✅ Data access: All SHRUG data (Census PCA 1991/2001/2011, nightlights, crosswalks) available locally. ~640K village observations.
- ✅ Pre-periods: Census 1991 and 2001 provide two pre-treatment cross-sections; nightlights 1994-2005 provide 12 annual pre-periods at district level.
- ✅ Treated clusters: 200 districts (Phase I) across 27+ states.
- ✅ Novelty: No APEP paper on India. No published paper on MGNREGA → structural transformation at village level.
- ✅ Power: 640K villages, 200+ treated districts per cohort. Massively powered.

**DiD feasibility gate:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | ✅ Census 1991, 2001 + nightlights 1994-2005 |
| Treated clusters | ✅ 200 districts (Phase I) across many states |
| Selection into treatment | ⚠️ Based on backwardness index (non-random but standard in literature) |
| Comparison group | ✅ Phase III districts (later adopters, similar but less poor) |
| Outcome-policy alignment | ✅ Worker composition directly measures structural change |

---

## Idea 2: The Long Shadow of Guaranteed Work: MGNREGA's Effect on Female Labor Force Participation Beyond the Worksite

**Policy:** Same MGNREGA phased rollout as Idea 1, but focused on the 33% women's participation mandate.

**Outcome:** Female-specific Census worker variables: female total workers (`tot_work_f`), female main cultivators (`main_cl_f`), female agricultural laborers (`main_al_f`), female other workers (`main_ot_f`), female non-workers (`non_work_f`). Primary outcome = female non-MGNREGA labor force participation rate.

**Identification:** Same staggered DiD as Idea 1 but with gender-specific outcomes. Triple-difference: Phase × Post × Female to isolate gender-specific effects.

**Why it's novel:** Most MGNREGA-gender papers use small surveys or PLFS data. Nobody has used the Census-level (640K villages) decomposition of female worker types to study whether MGNREGA's women's quota affected female participation in non-MGNREGA work categories.

**Feasibility check:**
- ✅ All data from Idea 1, gender-disaggregated at village level.
- ⚠️ Risk: This is essentially a sub-analysis of Idea 1, not a standalone paper.

---

## Idea 3: One Nation One Ration Card and Interstate Migration in India

**Policy:** ONORC (One Nation One Ration Card) — allows PDS beneficiaries to use subsidized grain at any fair price shop nationwide. Staggered state adoption: pilot Aug 2019 (4 states), expanded through June 2022 (all 36 states/UTs).

**Outcome:** Interstate migration rates from PLFS quarterly bulletins (state-level), nightlights growth in migration-receiving districts (Delhi NCR, Mumbai, Bengaluru, Chennai), GST revenue as proxy for formal economic activity.

**Identification:** Staggered DiD across states, with adoption dates clearly documented by the Ministry of Consumer Affairs. States joined ONORC at different times over 3 years.

**Why it's novel:** ONORC is understudied — only Tumbe & Jha (2024) have examined it. The "welfare lock" hypothesis (PDS ties workers to home states) is policy-relevant for all developing countries with place-based safety nets.

**Feasibility check:**
- ✅ Variation: 36 states, staggered over 3 years (Aug 2019 – June 2022).
- ✅ Data: Nightlights (VIIRS) available through 2023. GST revenue publicly available monthly by state.
- ⚠️ COVID confound: March 2020 lockdown caused massive reverse migration. ONORC rollout (2019-2022) overlaps perfectly with COVID disruption. This is a SEVERE identification threat. Disentangling ONORC effects from COVID recovery is extremely difficult.
- ⚠️ PLFS microdata requires MoSPI registration (may not be available).

---

## Idea 4: Jal Jeevan Mission and Rural Child Health in India

**Policy:** Jal Jeevan Mission (JJM) — piped water to every rural household. Launched Aug 2019, district-level completion dates vary from 2020-2024 (188 districts achieved 100% "Har Ghar Jal" by Aug 2024).

**Outcome:** NFHS-5 (2019-21) vs NFHS-4 (2015-16) child health indicators (stunting, wasting, diarrhea prevalence) at district level. UDISE+ school enrollment data as secondary outcome.

**Identification:** Staggered DiD using district-level JJM completion dates. Early-completing districts (mostly in smaller states) vs. late-completing districts.

**Why it's novel:** JJM is very recent and understudied. Water-health link is well-established but JJM's scale (largest piped water program globally) is unprecedented.

**Feasibility check:**
- ⚠️ COVID confound: JJM launched Aug 2019, COVID from March 2020. NFHS-5 fieldwork overlapped with COVID (2019-21). Severe contamination risk.
- ⚠️ Data: NFHS microdata requires DHS registration. JJM district completion dates available from jaljeevanmission.gov.in but need web scraping.
- ⚠️ Pre-periods: Only NFHS-4 as pre-treatment (single cross-section before JJM).
- ❌ Few pre-periods for credible DiD at district level.
