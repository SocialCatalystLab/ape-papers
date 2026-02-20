# Revision Plan (Round 1)

## Paper: "Did India's Employment Guarantee Transform the Rural Economy?"
## APEP-0426, v1
## Date: 2026-02-20

---

## Summary of Reviewer Feedback

- **GPT-5.2:** MAJOR REVISION — concerns about reconstructed treatment, placebo test, compressed rollout, cluster inference
- **Grok-4.1-Fast:** MINOR REVISION — missing references, framing improvements
- **Gemini-3-Flash:** MINOR REVISION — medium-run vs long-run framing, cluster inference, estimator reconciliation

## Changes Made

### 1. Estimand Reframing (Addresses GPT #3, Gemini)
- Added explicit caveat distinguishing medium-run (2006-2013, cleanly identified) from long-run (2014-2023, assumption-dependent) estimates
- Located in main results section after CS-DiD interpretation

### 2. Estimator Divergence Explanation (Addresses GPT #5, Gemini)
- Added paragraph explaining why CS-DiD (near zero) and Sun-Abraham (-0.167***) diverge
- CS drops 2006 cohort and uses not-yet-treated; SA uses last-treated as reference
- Phase III districts may have differential growth paths due to lower baseline backwardness

### 3. Cluster Inference Discussion (Addresses GPT #4, Gemini)
- Added discussion of ~30 state clusters being above the threshold where CRSEs become unreliable
- Cited Cameron, Gelbach, & Miller (2008)

### 4. Pre-Trends Caution (Addresses GPT #2)
- Added citation of Roth (2022) on interpreting pre-trend tests
- Emphasized significant placebo does not invalidate the null finding (CIs already span zero)

### 5. Missing References (Addresses all reviewers)
- Added: Roth (2022), Cameron et al. (2008), Foster & Rosenzweig (2004), Zimmermann (2021)
- Integrated citations at appropriate locations in text

### 6. Prose Improvements (Addresses exhibit + prose reviews)
- Improved opening hook (scale-first framing)
- Improved results narration (less "Column X reports")
- Stronger conclusion ending ("larger canvas visible from space")
- Added policy implications subsection

### 7. Expanded Limitations (Addresses GPT #1)
- Detailed discussion of each limitation with mechanism through which it biases results
- Measurement error from reconstructed phases → attenuation bias
- Universal treatment → no power for uniform effects
- Nightlights proxy limitations in rural India
- DMSP-VIIRS calibration caveat

### 8. Technical Fixes
- Changed CS-DiD from doubly robust to regression-based estimator (code and text)
- Updated all CS-DiD numbers (ATT: 0.033, SE: 0.144)
- Updated Bacon decomposition table with actual numeric estimates
- Fixed CONTRIBUTOR_GITHUB underscore escaping
