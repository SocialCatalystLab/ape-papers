# Human Initialization
Timestamp: 2026-02-03T16:30:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0158
**Parent Title:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap
**Parent Decision:** MINOR REVISION (Grok, Gemini) / MAJOR REVISION (GPT)
**Revision Rationale:** Major methodological upgrade per user request - replace CPS individual-level data with QWI administrative data to directly measure new hire earnings (addressing key reviewer concern about separating new hires from incumbents)

## Key Changes Planned

1. **New Primary Dataset:** Replace CPS with Census QWI (Quarterly Workforce Indicators)
   - Unit of analysis: county × quarter × sex × industry
   - Key variable: `EarnHirAS` (average monthly earnings of new hires)
   - Coverage: 1995-2023, all counties in treated states

2. **New Identification Strategy:** Two-pronged approach
   - **Main specification:** Staggered DiD at county × quarter level using Callaway-Sant'Anna
   - **Border robustness:** Contiguous county-pair design (à la Dube, Lester & Reich 2010)

3. **Restructure Paper:**
   - QWI analysis becomes main results (Sections 5-6)
   - CPS analysis moves to Appendix with condensed results
   - Border discontinuity design as key robustness check

## Original Reviewer Concerns Being Addressed

1. **GPT Reviewer:** "Bring in job posting data to measure compliance... separate new hires from incumbents"
   → QWI's `EarnHirAS` directly measures new hire earnings by sex

2. **GPT Reviewer:** "With only 6 treated states contributing post-treatment variation, standard cluster-robust inference may be unreliable"
   → County-level clustering provides ~300+ clusters vs 6 state clusters

3. **Grok Reviewer:** "Linked LEHD/employer data for incumbent/new-hire split"
   → QWI is derived from LEHD; provides exactly this split

4. **All Reviewers:** Strengthen identification credibility
   → Border county design provides tighter comparison group

## Inherited from Parent

- Research question: Same (effect of salary transparency laws on wages and gender gap)
- Policy variation: Same (CO, CT, NV, RI, CA, WA)
- Theory and predictions: Same (commitment mechanism, bargaining power heterogeneity)

## New Elements

- **Data Source:** Census QWI via API (replaces CPS ASEC)
- **Geographic Granularity:** County-level (vs state-level in parent)
- **Temporal Granularity:** Quarterly (vs annual in parent)
- **Identification Enhancement:** Border county-pair design
- **Outcome Variable:** `EarnHirAS` - average monthly earnings of new hires
