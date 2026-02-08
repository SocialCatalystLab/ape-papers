# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 mode - harsh, skeptical)
**Paper:** The Price of Distance: Cannabis Dispensary Access and the Composition of Fatal Crashes in Prohibition States
**Date:** January 2024

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length**: Approximately 28-30 pages main text (before references/appendix). PASS.
- **References**: Bibliography includes key methodology papers (Cameron et al. 2008) and domain papers (Anderson et al. 2013, Hansen et al. 2020). Adequate.
- **Prose**: Major sections written in full paragraphs. PASS.
- **Section depth**: Each section has multiple substantive paragraphs. PASS.
- **Figures**: Figures 1-3 show data with proper axes and legends. PASS.
- **Tables**: All tables contain real numbers, no placeholders. PASS.

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors**: All regression tables report clustered SEs in parentheses. PASS.

b) **Significance Testing**: Stars indicate significance levels. PASS.

c) **Confidence Intervals**: Not explicitly reported in tables, but SEs allow construction. Minor issue.

d) **Sample Sizes**: N reported for all regressions. PASS.

e) **DiD with Staggered Adoption**: This is NOT a DiD paper - it uses continuous cross-sectional variation in driving time as treatment. The staggered legal openings (NV 2017, CA 2018) create time variation but the identification is cross-sectional within states. The design does not suffer from standard staggered DiD concerns. PASS.

f) **RDD**: Not applicable.

**Wild cluster bootstrap**: Appropriately implemented given 8 clusters. Bootstrap p-value (0.032) reported. PASS.

### 3. IDENTIFICATION STRATEGY

**Strengths:**
- Novel identification using continuous driving time variation
- State and year FE address obvious confounds
- Placebo tests (daytime crashes, elderly drivers) support alcohol-specific mechanism
- Heterogeneity by border distance is compelling

**Concerns:**
1. **Exclusion restriction**: What if areas near legal borders differ systematically from interior areas in ways correlated with both driving distance AND alcohol crash composition? The paper acknowledges this but doesn't fully resolve it.

2. **Selection on unobservables**: Drivers who crash near borders may differ from those who crash far from borders for reasons other than cannabis access.

3. **No pre-period**: Cannot test parallel trends since variation is fundamentally cross-sectional within each state-year.

4. **Magnitude interpretation**: The effect (1.7 pp for doubling drive time) is modest but statistically significant. Would benefit from more context on what magnitude of substitution this implies.

### 4. LITERATURE

**Adequately cited:**
- Anderson, Hansen, Rees (2013) - foundational
- Hansen, Miller, Weber (2020) - related
- Cameron, Gelbach, Miller (2008) - inference

**Missing citations that should be added:**
- Cerdá et al. (2012) on medical marijuana and traffic fatalities
- Aydelotte et al. (2019) on crash risk after legalization
- Santaella-Tenorio et al. (2017) meta-analysis
- Work on cross-border policy spillovers more generally

### 5. WRITING QUALITY

**Strengths:**
- Clear exposition of identification strategy
- Results section flows logically
- Tables are well-formatted

**Areas for improvement:**
- Introduction could be more "grabby" - lead with the surprising finding or puzzle
- Some paragraphs are dense and could be broken up
- Conclusion is somewhat abrupt

### 6. CONSTRUCTIVE SUGGESTIONS

1. **Heterogeneity by driver age**: The elderly driver placebo is clever, but could also examine heterogeneity by young vs. middle-aged drivers
2. **Weekend vs. weekday effects**: Substitution should be stronger on weekends when recreational use is more common
3. **Event study around CA/NV openings**: Use the staggered openings more aggressively
4. **Falsification using interior crashes**: Show no effect very far from borders

### 7. OVERALL ASSESSMENT

**Key Strengths:**
- Novel identification approach using continuous geographic variation
- Clean research design with well-defined treatment
- Appropriate statistical inference for small cluster count
- Plausible mechanism with supporting heterogeneity

**Critical Weaknesses:**
- Cross-sectional identification is not as clean as a true DiD
- Missing some relevant literature
- Magnitude interpretation could be clearer

**Specific Suggestions:**
1. Add missing literature citations
2. Strengthen discussion of identification threats
3. Add heterogeneity analyses (weekend, driver age)
4. Contextualize magnitude better

---

## DECISION: MINOR REVISION
