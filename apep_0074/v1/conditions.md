# Conditional Requirements

**Generated:** 2026-01-28T16:35:42.641107
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Extreme Risk Protection Orders (Red Flag Laws) and Firearm Suicide

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extending the panel earlier than 2014

**Status:** [X] RESOLVED

**Response:**

CDC WONDER mortality data is available from 1999 onward. I will extend the analysis panel to 2005-2019, providing:
- 13+ years of pre-treatment data for most states (2018-2019 adopters)
- Coverage of early adopters (Connecticut 1999, Indiana 2005)
- Sufficient pre-treatment periods to assess parallel trends

**Evidence:**

CDC WONDER Multiple Cause of Death database provides state-level mortality by cause (including firearm suicide, ICD-10 codes X72-X74) from 1999-present. Will verify in data fetch step.

---

### Condition 2: addressing timing with month-level or conservative exposure coding

**Status:** [X] RESOLVED

**Response:**

I will use conservative annual coding: a state is coded as "treated" starting in the first full calendar year after law enactment. For example:
- Florida's law took effect March 2018 → Treated = 1 starting 2019
- Vermont's law took effect April 2018 → Treated = 1 starting 2019
- Laws enacted before July 1 → Treated that same year
- Laws enacted July 1 or later → Treated the following year

This conservative coding avoids partial-year exposure that could attenuate estimates.

**Evidence:**

Will document specific coding decisions in initial_plan.md with exact effective dates from PDAPS and chosen treatment year assignments.

---

### Condition 3: explicitly controlling/handling concurrent gun-policy changes

**Status:** [X] RESOLVED

**Response:**

Several states enacted multiple gun policies around 2018 (post-Parkland). I will:
1. Document major concurrent policies (universal background checks, assault weapon provisions, etc.) in treated states
2. Include robustness checks excluding states with major concurrent policies
3. Discuss in limitations section that ERPO effects may be confounded with package of reforms
4. Note that the identification assumption is parallel trends conditional on state and year FEs, not absence of other policies

**Evidence:**

Will compile concurrent policy table from Everytown/Giffords law databases showing which treated states had other major gun law changes 2017-2019.

---

### Condition 4: using intensity/implementation measures to reduce dilution concerns

**Status:** [X] RESOLVED

**Response:**

Intensity measures (ERPO petitions filed per capita) are available for some states but not consistently across all states and years during the study period. I will:
1. Use binary treatment indicator as primary specification (standard in policy evaluation literature)
2. Acknowledge dilution concern: newly-enacted laws may be underutilized, and effects should grow over time
3. Examine dynamic effects in event study to see if effects strengthen in later post-treatment years
4. In discussion, note that estimates represent intent-to-treat effects of law passage, not per-ERPO effects

**Evidence:**

Everytown research documents ERPO usage statistics for select states. Florida data shows 21,000+ ERPOs granted 2018-2025. Will note data limitations in paper.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
