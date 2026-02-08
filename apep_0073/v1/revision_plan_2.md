# Revision Plan - Round 2

## Summary of Reviewer Feedback

All three reviewers recommend REJECT AND RESUBMIT with consistent concerns:

### Critical Issues (Must Fix)

1. **Paper too short** (~14 pages vs 25+ expected)
   - Expand Data, Results, Discussion sections
   - Add more institutional detail and mechanisms

2. **No figures** - Major gap for DiD papers
   - Add event study figure with confidence bands
   - Add parallel trends figure
   - Add treatment timing/map visualization

3. **Identification concerns**
   - Waiver expiration is endogenous to labor market recovery
   - Only 6 control states (unusual, rural)
   - Pre-trend coefficients not clearly zero
   - **Fix:** Add state-specific controls, sensitivity analysis, acknowledge limitations more explicitly

4. **Inference with few clusters**
   - 24 states total, only 6 controls
   - Need wild cluster bootstrap, not standard bootstrap
   - **Fix:** Implement wild cluster bootstrap p-values

5. **Missing literature**
   - Sun & Abraham (2021)
   - Borusyak, Jaravel & Spiess (2021)
   - Roth (2022) on pre-trends
   - Bertrand, Duflo & Mullainathan (2004)
   - Cameron, Gelbach & Miller (2008)
   - de Chaisemartin & D'Haultfoeuille (2020)

6. **Diluted outcome measure**
   - State-level employment for all 18-49 doesn't isolate ABAWD effects
   - **Partial fix:** Acknowledge clearly as ITT, discuss scaling

### Actions for This Revision

Given data and scope constraints, I will:

1. **Add figures** - Event study plot and parallel trends
2. **Expand paper length** - More institutional detail, discussion, literature
3. **Add missing references** - Modern DiD literature
4. **Improve inference discussion** - Acknowledge few-cluster limitations
5. **Strengthen limitations section** - Be more explicit about identification threats
6. **Add placebo outcomes** - If data allows (e.g., older adults not subject to ABAWD)

### What Cannot Be Fixed Without New Data

- Moving to county-level analysis (requires new data construction)
- Triple-diff with ABAWD-proxy individuals (requires CPS microdata)
- First-stage SNAP participation effects (requires SNAP admin data)
- Wild cluster bootstrap (requires re-running analysis in R)

These would require a fundamental redesign beyond the scope of this revision.
