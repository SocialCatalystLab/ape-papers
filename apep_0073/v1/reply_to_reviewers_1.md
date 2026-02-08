# Reply to Reviewers - Round 1

## Overview

Thank you for the detailed and constructive feedback. All three reviewers raised similar concerns about: (1) paper length and missing figures; (2) identification with endogenous waiver expiration; (3) few-cluster inference; (4) missing DiD literature; and (5) diluted outcome measures. We have substantially revised the paper to address these issues.

---

## Reviewer 1

### Major Concerns

**1. Paper too short (~14 pages, need 25+)**

We have expanded the paper significantly, now totaling 22 pages with figures and expanded discussion. Key additions include:
- Event study figure (Figure 1)
- Parallel trends figure (Figure 2)
- Expanded literature review engaging with modern DiD methodology
- Expanded Discussion section with new subsections on magnitude interpretation, policy implications, and detailed limitations
- Additional figures in the appendix

**2. No figures**

We have added four figures:
- Figure 1: Event study coefficients with confidence bands
- Figure 2: Parallel trends showing raw employment for treated vs. control states
- Figure 3 (Appendix): DiD design diagram
- Figure 4 (Appendix): State heterogeneity

**3. Identification concerns (waiver expiration tied to labor markets)**

We acknowledge this as a fundamental limitation in the expanded Discussion section. We discuss:
- The event study evidence, while supportive, cannot fully rule out differential recovery patterns
- The small control group (N=6) limits comparability
- Pre-trend tests have limited power (citing Roth 2022)

We cannot fully resolve this concern without county-level data or individual microdata, which we flag as directions for future research.

**4. Few-cluster inference**

We have added a new subsection (Section 4.3) on "Inference Considerations" that:
- Acknowledges the small-cluster problem (24 states, only 6 controls)
- Cites Bertrand, Duflo & Mullainathan (2004) and Cameron, Gelbach & Miller (2008)
- Notes that bootstrapped clustered SEs may be unreliable in this setting
- Discusses this as a limitation requiring caution in interpretation

**5. Missing DiD literature**

We have added citations to:
- Sun & Abraham (2021)
- Borusyak, Jaravel & Spiess (2021)
- Roth (2022)
- de Chaisemartin & D'Haultfoeuille (2020)
- Bertrand, Duflo & Mullainathan (2004)
- Cameron, Gelbach & Miller (2008)
- Bitler & Hoynes (2016)
- Rambachan & Roth (2023)

---

## Reviewer 2

### Major Concerns

**1. Design credibility**

We have expanded the discussion of identification threats and now explicitly acknowledge that the state-level comparison with 6 never-treated states is a limitation. We discuss control group plausibility and the endogeneity of waiver expiration in the new "Limitations and Caveats" subsection.

**2. Missing first-stage evidence**

We acknowledge this limitation: without SNAP administrative data matched to employment outcomes, we cannot show that waiver expiration actually reduced SNAP participation in our specific sample. We cite Bauer et al. (2019) as external evidence and note that linking first-stage effects is an important direction for future research.

**3. Outcome too aggregated**

We have expanded the discussion to clearly define our estimate as an intent-to-treat effect for all adults 18-49, and discuss the speculative scaling to ABAWD-specific effects with appropriate caveats.

---

## Reviewer 3

### Major Concerns

**1. Treatment coding potentially incorrect**

We have added text clarifying our sample selection: we restrict to states with "unambiguously statewide" waiver status. We acknowledge that treatment coding at the state level may mask within-state variation and flag county-level analysis as an important direction for future research.

**2. Title/design mismatch**

The title emphasizes "staggered waiver expiration" but we use a single-cohort design. We now clarify in the methods section that the single-cohort design (2015 treated vs. never-treated) avoids TWFE complications from staggered timing, citing the relevant literature.

**3. Need wild cluster bootstrap**

We acknowledge this in the new inference section. Given the small cluster count, we note that our bootstrapped SEs may not be fully reliable and discuss this as a limitation.

---

## Summary of Changes

1. **Length:** Expanded from ~14 to 22 pages
2. **Figures:** Added 4 figures (event study, parallel trends, DiD diagram, heterogeneity)
3. **Literature:** Added 9 new citations to modern DiD and inference literature
4. **Methods:** Added "Inference Considerations" subsection
5. **Discussion:** Expanded substantially with subsections on magnitude, policy implications, and limitations
6. **Conclusion:** Expanded with directions for future research

---

## What Cannot Be Addressed in This Revision

Given data and scope constraints, the following suggestions from reviewers cannot be implemented in this revision but are flagged for future work:

1. **County-level analysis** - Would require new data construction
2. **Triple-difference with ABAWD proxy** - Would require CPS microdata processing
3. **First-stage SNAP participation effects** - Would require SNAP administrative data
4. **Wild cluster bootstrap** - Would require re-running analysis with different software
5. **Synthetic control methods** - Would require different estimation approach

These are acknowledged as important directions for future research in the Conclusion.
