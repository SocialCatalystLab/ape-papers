# Human Initialization
Timestamp: 2026-02-02T22:30:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

- **Parent Paper:** apep_0136
- **Parent of Parent:** apep_0134
- **Revision Type:** Major revision (methodological fix)
- **Changes Made:**
  1. Fix SCM methodology: Use de-meaned + ridge augmented SCM per Ferman & Pinto (2021)
  2. Address level mismatch: East Harlem (42-92/100k) vs controls (20-55/100k)
  3. Fix figure-analysis disconnect: Figures now use actual augsynth output
  4. Fix internal consistency: MSPE ranks, p-values, effect sizes match throughout
  5. Report honest results: Whatever the properly-estimated effect is
  6. Add methodological citations: Abadie (2021), Ben-Michael et al. (2021)

## Key Issues Being Addressed

### From Integrity Scan (SEVERE verdict):
- METHODOLOGY_MISMATCH: "Synthetic control" was just control means
- DATA_PROVENANCE: Augsynth fits not saved to results
- STATISTICAL_IMPOSSIBILITY: SE=0 in event study reference year

### From Gemini Advisor Review (FAIL):
- MSPE Rank inconsistency: Table 2 says 1/24, Figure 5 shows Rank 4
- Narrative mismatch: Text says "synthetic rises" but figure shows it falls
- Placeholder values: "N/A†" in Table 2

### Root Cause Identified:
- East Harlem is outside the convex hull of control units
- Standard SCM is methodologically inappropriate
- De-meaned SCM (fixedeff=TRUE) addresses this per literature

## Expected Outcome

Either:
- **Effect emerges** with proper methodology → Report with caveats
- **Effect remains small/null** → Report honest null result (valuable contribution)

Goal is methodological correctness, not manufacturing results.
