# Revision Plan - Round 2 (Responding to GPT 5.2 Review)

**Date:** 2026-01-21
**Reviewer:** GPT 5.2 (External)
**Decision:** REJECT AND RESUBMIT

## Reviewer's Main Concerns (Repeated from Round 1)

### 1. Urban/Rural Imputation is Fundamental Problem

The reviewer correctly identifies that our urban status is imputed using `rbinom(n(), 1, urban_rate)` from state-year urbanization rates. This is not a fixable issue with our current data - we would need to:
- Download data with actual URBAN variable (not available consistently across full-count census years)
- Use county-level analysis (would require new data acquisition and redesign)
- Use farm/non-farm status (changes conceptual focus)

**Resolution:** Given time constraints, we acknowledge this as a fundamental limitation and reframe the contribution:
- The paper documents **overall suffrage effects** which are credible
- The heterogeneity analysis is **suggestive** and explores correlation with state urbanization rates
- We are transparent that individual-level urban/rural effects cannot be identified

### 2. Staggered DiD Implementation Issues

The reviewer notes we claim modern methods but show TWFE results, and the Sun-Abraham implementation failed.

**Resolution:**
- We removed the broken Sun-Abraham results (completed in Round 1)
- We acknowledge that decennial data limits dynamic inference
- We focus on TWFE as the main specification with appropriate caveats

### 3. Internal Inconsistencies

The reviewer notes treated state counts differ across tables.

**Resolution:** Audit all tables for consistency.

## Actions Taken

1. ✅ Fixed event study figures (Round 1)
2. ✅ Removed Sun-Abraham from tables (Round 1)
3. ✅ Added caveats about urban imputation (Round 1)
4. ✅ Softened claims throughout (Round 1)
5. ✅ Added missing DiD references (Round 1)

## Actions for This Round

1. **Acknowledge fundamental limitation prominently:** Add clear statement in abstract and introduction that the urban-rural heterogeneity analysis is exploratory and uses imputed status.

2. **Reframe contribution:** The paper's contribution is:
   - Documenting overall suffrage effect on female LFP (2.3pp, credible)
   - Exploring whether this effect correlates with state urbanization (suggestive)
   - NOT: Identifying causal effects on actually-urban vs actually-rural women

3. **Clarify 1920 census timing:** Add note that 1920 census reference date is January 1, 1920, before the 19th Amendment was ratified in August 1920.

## Honest Assessment

Given the fundamental data limitations:
- The urban-rural heterogeneity finding is **not publication-ready** for top journals
- The overall suffrage effect on female LFP is credible and may be publishable
- The paper would benefit from better geographic data (county-level or actual URBAN variable)

We proceed with the current draft acknowledging these limitations, completing the required 5 review rounds, and publishing to the APEP repository as a working paper that identifies both findings and limitations for future research.
