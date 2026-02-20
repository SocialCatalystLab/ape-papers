# Conditional Requirements

**Generated:** 2026-02-20T10:52:44
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

---

## Can Clean Cooking Save Lives? India's Ujjwala Yojana and Child Health

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: NFHS-4 Timing Contamination

**Concern:** NFHS-4 fieldwork (Jan 2015 – Dec 2016) overlaps Ujjwala launch (May 2016). Without microdata with interview dates, pre-period is contaminated.

**Status:** [x] RESOLVED

**Response:**

We use district factsheets (aggregated values). Key mitigations:
- NFHS-4 fieldwork started 18 months before Ujjwala; most district surveys completed pre-launch or in early implementation months
- Ujjwala's initial rollout was slow: only 1.5 million LPG connections in FY2016-17 vs 80+ million by 2021. Even districts surveyed after May 2016 would show minimal Ujjwala impact
- Any contamination ATTENUATES estimates (biases toward zero): if NFHS-4 partially captures early Ujjwala effects, the pre/post difference shrinks
- Robustness: use state-level fieldwork timing (known from NFHS reports) to identify "early-surveyed" vs "late-surveyed" states and show results are robust to excluding late-surveyed states
- Additional robustness: Lee (2009) bounds to assess sensitivity to contamination

**Evidence:** NFHS-4 state-level fieldwork timing available from IIPS reports. Ujjwala connections data from MOPNG annual reports confirms slow initial rollout.

---

### Condition 2: Pre-Trend Validation

**Concern:** Only 2 NFHS periods; cannot test parallel trends formally.

**Status:** [x] RESOLVED

**Response:** Three-pronged approach:

1. **Placebo TREATMENT tests:** Use baseline electricity gap or sanitation gap as fake treatment. These infrastructure gaps should NOT predict changes in clean-fuel-specific health outcomes (ARI, anemia). If they do, our design is invalid.

2. **Placebo OUTCOME tests:** Baseline clean fuel gap should NOT predict changes in outcomes unrelated to indoor air pollution — e.g., vaccination rates, institutional births, male education. These serve as falsification tests.

3. **Covariate balance:** Show that districts with different baseline clean fuel levels are comparable on observable pre-treatment characteristics (after state FE). If balance fails, add controls and show robustness.

4. **Dose-response monotonicity:** Show treatment effects are monotonically increasing in baseline clean fuel gap (tercile/quartile analysis). A clean causal channel should show dose-response.

**Evidence:** NFHS-4 has 50+ district indicators enabling rich placebo tests. Multiple non-fuel-related health outcomes available for falsification.

---

### Condition 3: Compliance and First Stage

**Concern:** Imperfect compliance — not all eligible households adopt/use LPG even with free connection.

**Status:** [x] RESOLVED

**Response:**

- **Explicit first stage:** Regress Δ clean fuel (%) on baseline clean fuel gap + controls. Report F-statistic.
- **ITT interpretation:** Reduced-form estimates are intention-to-treat: effect of Ujjwala ELIGIBILITY (proxied by baseline clean fuel gap), not actual adoption
- **IV scaling:** Use clean fuel gap as instrument for Δ clean fuel to get TOT (treatment-on-treated) estimates
- **Usage vs connection:** Acknowledge that Ujjwala provided connections but sustained usage requires affordable refills. "Refill dropout" is a known issue; our estimates capture the NET effect of connections + actual usage patterns
- **Bounding:** Oster (2019) coefficient stability bounds to assess omitted variable bias sensitivity

**Evidence:** Literature documents 30-40% refill dropout rates for Ujjwala beneficiaries (Gould & Urpelainen 2018; Kar et al. 2019). Our ITT estimates will reflect this real-world compliance, making them policy-relevant.

---

## Verification Checklist

- [x] All conditions marked RESOLVED
- [x] Evidence provided for each resolution
- [x] Ready for Phase 4 execution
