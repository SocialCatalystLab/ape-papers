# Internal Review (Claude Code) — Round 1

**Role:** Internal Claude Code self-review
**Timestamp:** 2026-02-06T19:00:00
**Paper:** paper.pdf (revision of apep_0197)

---

## Summary

This is a revision of apep_0197 addressing three structural problems: (1) unclear labor market model with earnings buried, (2) missing job flow analysis, and (3) uninterpretable magnitudes due to a weight normalization bug.

## Issues Found and Fixed During Internal Review

### Critical Issues (all resolved)

1. **Weight normalization bug**: SCI weights not re-normalized after NA filtering, causing 20% of observations to fall below the theoretical floor of log($7.25). Fixed by re-normalizing after all filtering. Validation: 0% below floor.

2. **Empty tables**: Earnings table (tab:main_earnings) and job flows table (tab:jobflows) had placeholder cells. Fixed by populating with actual regression coefficients.

3. **Sample size inconsistencies**: Text reported 134,317/3,053 in some places and 135,700/3,108 in others. The 3,053 is the SCI-only universe; 3,108 is after merging with QWI (Virginia independent cities). Fixed throughout with explicit explanation of the pipeline.

4. **Job flow narrative mismatch**: Text claimed "reduced separations" but table showed separations INCREASE. Corrected to "churn/dynamism" interpretation — both hires and separations increase, consistent with information-driven labor market activity.

5. **USD magnitude inconsistency**: Abstract said "4-6%" but introduction said "9%". The actual coefficient is β=0.0902 (9%). Fixed throughout.

6. **Pre-trend dishonesty**: Several passages claimed joint F-test "does not reject" parallel trends, but the actual test REJECTS (F(4,50)=3.90, p=0.008). Fixed all references to honestly report the rejection.

7. **Prob-weighted coefficient**: Shock-robust table reported 0.28 but actual is 0.323. Fixed.

8. **Panel balance claim**: Text said "balanced" but 135,700 ≠ 3,108 × 44 = 136,752. Changed to "nearly balanced" with 99.2% coverage.

### Non-Critical Issues Noted

- Paper could benefit from appendix with detailed robustness tables (Sun & Abraham, LOSO, R&R sensitivity)
- Industry-level (high-bite sector) analysis would strengthen mechanism claims
- Extended pre-period (QCEW pre-2012) would address pre-trend concern
- LATE/complier characterization could be expanded

## Assessment

After fixes, the paper is internally consistent with no placeholder cells, honest pre-trend reporting, and properly tempered causal language. Ready for external review.

DECISION: MINOR REVISION
