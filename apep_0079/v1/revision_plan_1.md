# Revision Plan: Paper 106

## Summary of Reviews

All three external reviewers gave **REJECT AND RESUBMIT**. The feedback is highly consistent:

### Critical Issues (Must Fix)

1. **No credible identification** - Paper admits it can't estimate causal effects; this makes it unpublishable as-is
2. **Paper too short** - ~17 pages vs 25+ expected for top journals
3. **Must choose a path**: Either (A) methodological paper with formal framework/simulations OR (B) credible policy evaluation with longer pre-treatment data
4. **Missing key DiD literature** - Sun & Abraham (2021), Borusyak et al. (2024), de Chaisemartin & D'Haultfoeuille (2020), Conley & Taber (2011), Cameron & Miller (2015)
5. **95% CIs missing** in tables (only in figures)
6. **Few-cluster inference inadequate** - Need wild cluster bootstrap with 4-9 treated states
7. **Too many bullet lists** - Need prose-driven narrative
8. **No placebo tests or triple-differences**

### Recommended Path

All reviewers suggest **Path B: Credible Policy Evaluation** is more achievable:
- Extend CPS-FSS data to 2015-2024 using IPUMS
- This provides 7+ pre-treatment years for 2022 adopters
- Enables proper event studies with pre-trends assessment
- Can implement Sun-Abraham / Callaway-Sant'Anna with meaningful pre-periods

## Revision Strategy

### Phase 1: Extend Data (Critical)

**Files:** `code/01_fetch_data.R`

1. Fetch CPS-FSS 2015-2024 from IPUMS (requires API key)
2. Construct consistent food security measures across years
3. Merge with state USM adoption dates
4. Verify sample sizes by cohort-year

### Phase 2: Re-Run Analysis with Extended Data

**Files:** `code/03_main_analysis.R`, `code/04_robustness.R`

1. **Event study with pre-trends** (5+ pre-treatment years for 2022 adopters)
2. **Callaway-Sant'Anna** with proper reference period
3. **Wild cluster bootstrap** for inference (4 treated states in 2023 cohort)
4. **Triple-differences**: Compare HH with school-age children vs HH without children
5. **Placebo outcomes**: Non-food hardship measures
6. **HonestDiD sensitivity analysis** for parallel trends violations

### Phase 3: Expand Paper Content

**Files:** `paper.tex`

1. **Add missing references** with BibTeX:
   - Sun & Abraham (2021)
   - Borusyak, Jaravel & Spiess (2024)
   - de Chaisemartin & D'Haultfoeuille (2020)
   - Conley & Taber (2011)
   - Cameron & Miller (2015)
   - Gundersen & Ziliak (2015)

2. **Convert lists to prose** throughout:
   - Introduction "fundamental problems" → paragraph form
   - Discussion section → structured paragraphs

3. **Add 95% CIs to all tables**

4. **Expand sections**:
   - Results: Add event-study figure with pre-trends, triple-diff results, robustness
   - Discussion: Engage with selection into treatment, mechanisms
   - Add subsection on exposure intensity (fraction of months treated in recall window)

5. **Add new figures**:
   - Event study with pre-trends (main contribution)
   - Triple-diff comparison
   - HonestDiD sensitivity bounds

### Phase 4: Reframe Narrative

**Files:** `paper.tex`

If extended data shows:
- **Pre-trends are parallel**: Reframe as credible policy evaluation
- **Pre-trends are not parallel**: Keep methodological angle but formalize with longer data to demonstrate the problem

Either way, the paper becomes more publishable with actual pre-treatment data.

## Execution Order

1. Check IPUMS API availability
2. Fetch extended CPS-FSS data (2015-2024)
3. Rebuild analysis with extended sample
4. Generate new event-study figures
5. Add wild cluster bootstrap inference
6. Add triple-diff specification
7. Update paper.tex with new results
8. Add missing references
9. Convert lists to prose
10. Expand Discussion section
11. Recompile PDF
12. Run advisor review
13. Run external review

## Expected Outcome

With 2015-2024 data:
- 7 pre-treatment years for 2022 adopters
- 8 pre-treatment years for 2023 adopters
- Proper event study with credible pre-trends assessment
- Either find no effect (null result) or find an effect (positive finding)
- Paper length should reach 25+ pages with expanded content

## Risk Mitigation

- If IPUMS API unavailable: Use public Census FTP files for CPS-FSS
- If pre-trends fail: Pivot to methodological contribution with formal bias decomposition
- If sample sizes too small: Report power/MDE calculations
