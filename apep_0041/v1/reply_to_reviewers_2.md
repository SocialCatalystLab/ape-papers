# Reply to Reviewers - Round 2

## Response to External Reviewer (GPT 5.2) - Round 1

We thank the reviewer for their thorough and constructive feedback. Below we address each major concern.

### Major Concerns

**1. Paper length (15 pages vs. 25+ required).** The paper has been substantially expanded from 15 to 29 pages. Key additions include:
- Expanded Institutional Background section (now with detailed program descriptions for each state, Table 1 comparing programs, and discussion of take-up patterns)
- New Conceptual Framework section outlining theoretical mechanisms and expected heterogeneity
- Substantially expanded Related Literature section with new subsections on parallel trends testing, inference with few clusters, and additional citations
- Expanded Data section with clarification of aggregation approach and data limitations
- New Triple-Difference Design subsection with full results and interpretation
- Expanded Discussion section with subsections on interpretation, why parallel trends fail, inference limitations, alternative identification strategies, and methodological lessons
- Expanded bibliography with 18 references (up from 8)

**2. Few-cluster inference.** We have added a full subsection (Section 8.4 "Limitations of Inference") addressing inference with few treated clusters. We discuss Cameron, Gelbach & Miller (2008) on bootstrap-based improvements and Conley & Taber (2011) on randomization inference. We acknowledge that with only 4-5 treated states, even these methods face limitations. Importantly, we note that inference challenges are secondary to the parallel trends failure—the point estimates themselves are essentially zero.

**3. Internal inconsistencies (individual vs. state-year analysis).** We have clarified in Section 5.2 that:
- Individual-level data (469,793 observations) are aggregated to state-year level (867 observations)
- Aggregation serves two purposes: treatment varies at state-year level, and the `did` package requires panel data at treatment level
- Each state-year cell is weighted by sum of individual survey weights

**4. California exclusion.** California's exclusion from pre-treatment analysis is now explained consistently:
- Section 2.4 notes California adopted PFL in 2004, before our sample period begins in 2005
- Section 5.3 explicitly notes "Fourth, California adopted PFL in 2004, one year before our sample begins"
- Figure 5 note explains California lacks pre-treatment data

**5. Design improvements.**
- **Triple-difference:** Now prominently featured in Section 7.6 with full equation, estimation approach, results table (Table 4), and interpretation. The DDD estimate (0.87 pp, SE 0.52 pp) is smaller than naive TWFE and closer to the C-S null result.
- **Synthetic DiD:** Discussion of Arkhangelsky et al. (2021) added to Section 8.5 as a potential alternative approach for future research.
- We acknowledge that the fundamental issue is pre-trends failure, not estimator choice.

**6. Literature expansion.** The bibliography has been expanded from 8 to 18 references, including:
- Conley & Taber (2011) on inference with few policy changes
- Cameron, Gelbach & Miller (2008) on bootstrap-based improvements with clustered errors
- Arkhangelsky et al. (2021) on synthetic difference-in-differences
- Ruhm (1998) on economic consequences of parental leave
- Lalive et al. (2014) on parental leave in Austria
- Schönberg & Ludsteck (2014) on expansions in maternity leave coverage
- Athey & Imbens (2022) on design-based analysis in DiD settings
- Borusyak, Jaravel & Spiess (2024) on revisiting event-study designs
- de Chaisemartin & D'Haultfœuille (2022) on intertemporal treatment effects
- Klerman, Daley & Pozniak (2012) on FMLA coverage
- Appelbaum & Milkman (2014) on PFL take-up in California

**7. Production quality.** No encoding artifacts were identified. The paper has been recompiled with full resolution figures.

### Summary of Changes

| Issue | Status | Location |
|-------|--------|----------|
| Paper length | Fixed (29 pages) | Throughout |
| Few-cluster inference | Addressed | Section 8.4 |
| Individual vs state-year | Clarified | Section 5.2 |
| California exclusion | Explained consistently | Sections 2.4, 5.3, Appendix |
| Triple-difference | Added prominently | Section 7.6, Table 4 |
| Literature | Expanded (18 citations) | Section 3, Bibliography |
| Conceptual framework | Added | Section 4 |

The revised paper is now 29 pages with substantially expanded content addressing all reviewer concerns.
