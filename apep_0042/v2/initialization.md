# Revision Initialization: apep_0042 -> apep_NEW

## Revision Information

This is a **revision** of paper apep_0042:
- **Parent Paper ID:** apep_0042
- **Title:** Do State Automatic IRA Mandates Affect Self-Reported Employer Retirement Plan Coverage?
- **Parent Rating:** 14.9 conservative (rank 51)

## Revision Goals

Address code integrity issues and substantive reviewer concerns:

1. **Code Integrity Fixes (CRITICAL)**
   - Add treatment timing provenance with official statute citations
   - Fix placebo logic inconsistency (treatment targets large employers for registration, but coverage effect should concentrate at small firms)

2. **Methodological Improvements**
   - Add triple-difference (DDD) design exploiting firm-size phase-in
   - Upgrade inference with wild cluster bootstrap
   - Add randomization inference (2000 permutations)
   - Systematic leave-one-out for all 11 treated states

3. **Substantive Additions**
   - Expand mechanism discussion for CPS outcome measurement
   - Better explain why CPS may not capture auto-IRA participation
   - Pre-trends joint test with formal Wald statistic

## Parent Paper Location

All parent artifacts read from: `papers/apep_0042/`

## Data Source

Same as parent: CPS ASEC 2010-2024 via IPUMS-CPS

## Revision Plan File

See: `revision_plan.md` for detailed implementation plan
