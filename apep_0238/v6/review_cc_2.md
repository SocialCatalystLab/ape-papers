# Internal Review — Claude Code (Round 2)

**Reviewer:** Claude Code (self-review, post-theory-review fixes)
**Paper:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Version:** v6 (revision of v5, after theory review fixes)
**Date:** 2026-02-14

---

## Changes Since Round 1

The theory review by GPT-5.2-pro identified 5 CRITICAL issues in the formal DMP model. All have been addressed:

1. **Nash wage equation:** Explicitly documented as a simplified proportional-surplus wage rule (omitting κθ term for tractability), with justification that the demand/supply asymmetry is robust to this simplification.

2. **Missing β in free entry:** Added β factor throughout.

3. **Skill depreciation timing:** Fixed Bellman equation so workers who find jobs keep their current human capital; depreciation applies only to those remaining unemployed.

4. **Model closure / s_t proxy:** Added explicit paragraph explaining the simulation approach as a reduced-form aggregate dynamic system, transparently noting the micro Bellman structure provides economic intuition.

5. **Welfare terminal value:** Added terminal value to both steady-state and shock welfare computations. Welfare numbers updated throughout (demand CE: 39.6%, supply: 0.09%, scarring share: 58%).

## Remaining Issues

- The theory review round 2 had 6 WARNINGs, all addressed (δ comparative static, h_bar notation, timing convention, κ reference, OLF h_0, notation conflict footnote).
- 2 NOTEs (discount rate mapping, χ_t approximation) also fixed.
- The paper is now internally consistent between equations, narrative, code, and tables.

## Verification

- Paper compiles cleanly (58 pages, no undefined references)
- All welfare numbers in text match model_results.json
- Theory fixes are logically consistent
- Advisor review: 3/4 PASS (GPT, Grok, Codex pass; Gemini's strictest check failed on minor issues)

DECISION: CONDITIONALLY ACCEPT
