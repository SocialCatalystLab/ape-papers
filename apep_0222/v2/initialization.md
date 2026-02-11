# Human Initialization
Timestamp: 2026-02-11T18:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0222
**Parent Version:** v1
**Parent Title:** The Dog That Didn't Bark: Educational Content Restriction Laws and Teacher Labor Markets
**Tournament Rating:** 19.6 (17W-33L)

### Motivation for Revision

All three referees and tournament judges flagged **NAICS 61 breadth** as the #1 weakness --- it lumps K-12 schools with colleges, tutoring, and other educational services, diluting any K-12-specific effect. The female share result (the only non-null finding) uses TWFE only, not the CS estimator used for all other outcomes.

### Key Changes

1. **Switch primary analysis from NAICS 61 to NAICS 6111** (Elementary and Secondary Schools) to isolate the K-12 workforce directly affected by content restriction laws
2. **Run CS estimates for female share** alongside TWFE for methodological consistency
3. **Add formal MDE calculations** at 80% power for all outcomes
4. **Add NAICS 61 vs 6111 comparison** as robustness check showing results unchanged at broader aggregation
5. **Add NAICS 6112** (Junior Colleges, Colleges, Universities) for decomposition
6. **New figures:** Female share CS event study (Fig 7), NAICS 6111 vs 61 comparison event study (Fig 8)

## Questions Asked

(Inherited from parent --- revision mode)

## User Responses

(Inherited from parent --- revision mode)

## Setup Results

- **Domain:** Education policy / teacher labor markets
- **Method:** DiD (Callaway-Sant'Anna)
- **Data era:** Modern (2015-2024)
- **Risk appetite:** Novel angle
