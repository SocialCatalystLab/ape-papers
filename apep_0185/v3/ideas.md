# Research Ideas: Revision of apep_0186

## Parent Paper Summary
**Paper ID:** apep_0186
**Title:** Social Network Minimum Wage Exposure: A New County-Level Measure Using the Facebook Social Connectedness Index
**Decision:** MAJOR REVISION (GPT), REJECT AND RESUBMIT (Gemini), MINOR REVISION (Grok)

## Key Reviewer Concerns
1. **Lack of causal identification** - Paper was purely descriptive, needed causal strategy
2. **Missing 95% CIs** - Tables lacked confidence intervals
3. **Shift-share inference concerns** - Network exposure resembles Bartik instrument
4. **Temporal interpolation of employment data** - QCEW limitations noted

---

## Idea 1: Distance-Based IV for Network MW Exposure (SELECTED)

**Policy:** State minimum wage variation 2010-2023
**Outcome:** County-level employment (QWI quarterly data)
**Identification:** Instrument network exposure with MW in DISTANT (400-600km) social connections

**Why it's novel:**
- First paper to use distance-filtered SCI weights as IV for network exposure
- Addresses exclusion restriction by excluding local connections
- Provides causal estimates of network spillover effects

**Feasibility check:**
- [x] Variation exists: 51 states × 14 years of MW variation
- [x] Data accessible: QWI via Census API, SCI from HDX
- [x] Not overstudied: Novel IV approach for network exposure
- [x] First stage strong: Distant MW predicts local network exposure

**Approach:**
1. Construct IV using 400-600km distance window
2. Run 2SLS with county + state×time FE
3. Validate with Goldsmith-Pinkham tests
4. Test exclusion restriction with GOP vote share placebo

---

## Idea 2: Political Economy Extension

**Outcome:** Republican presidential vote share (2008-2020)
**Identification:** Same IV strategy as Idea 1

**Purpose:**
- Test exclusion restriction: If distant MW affects voting, exclusion violated
- Novel finding: Network information diffusion to political behavior

**Feasibility:**
- [x] MIT Election Data Lab has county-level returns
- [x] Can match to Q4 network exposure
- [x] 4 elections provide panel variation

---

## Idea 3: Industry Heterogeneity

**Test:** Effects should be larger in "high-bite" industries (retail, food service)

**Mechanism validation:** If network exposure works through MW information, effects concentrate where MW binds.

---

## Selected Approach

**Primary:** Idea 1 (Distance-based IV for employment effects)
**Secondary:** Idea 2 (Political economy as exclusion test)
**Validation:** Idea 3 (Industry heterogeneity)

This combination provides:
1. Credible causal identification
2. Mechanism validation
3. Exclusion restriction support
