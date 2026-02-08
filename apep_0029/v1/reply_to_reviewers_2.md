# Reply to External Reviewers - Round 2

**Date:** 2026-01-18

We thank both reviewers for their thorough and constructive feedback. While we acknowledge that the fundamental limitation—use of simulated rather than actual data—cannot be addressed until IPUMS delivers extract #127, we have substantially revised the paper to address the methodological and presentation concerns that can be fixed at this stage.

---

## Response to GPT 5.2

### 1. Literature Review (CRITICAL)

**Concern:** "The literature review is too thin—only 6 references... A general-interest journal expects 25-40 references minimum."

**Response:** We have expanded the bibliography from 6 to 17 references, adding foundational works in three categories:

- **RDD Methodology:** Lee & Lemieux (2010, JEL canonical review), Imbens & Lemieux (2008, JoE guide), McCrary (2008, density test), Calonico et al. (2014, robust inference), Cattaneo et al. (2015, local randomization)
- **Mothers' Pension History:** Moehling (2007) on family structure effects, Skocpol (1992) on political origins
- **Historical Labor/Notches:** Goldin (1990) on gender gap history, Goldin & Katz (2008) on education, Kleven & Waseem (2013) on notches, Saez (2010) on bunching

These references are now integrated into the text with proper citations throughout the methodology, discussion, and policy implications sections.

### 2. Bullet Points

**Concern:** "Several discussion subsections rely on bullet points."

**Response:** We have converted all bullet-pointed sections to flowing prose:
- Section 7.1 (Magnitude and Mechanisms): Now a single coherent paragraph
- Section 7.2 (Comparison to Prior Literature): Expanded to integrated prose
- Section 7.3 (Policy Implications): Three substantive paragraphs discussing benefit cutoffs, work requirements, and program design with citations to Goldin (1990) and Kleven & Waseem (2013)
- Section 7.4 (Limitations): Five paragraphs addressing each limitation in depth

### 3. CCT Inference

**Concern:** "No mention of Calonico-Cattaneo-Titiunik robust inference."

**Response:** We have added a new subsection (Section 4.3 "Modern RDD Inference") discussing:
- CCT bias-corrected point estimates and robust confidence intervals
- The local randomization framework of Cattaneo et al. (2015) for discrete running variables
- A commitment to implement rdrobust package with optimal bandwidth selection when real data arrive
- Explanation of why conventional estimates are appropriate for this pre-analysis plan stage

### 4. Figure 3 Scaling Issue

**Concern:** "The bandwidth=1 point shows a y-axis value of 1e11."

**Response:** We have:
- Excluded bandwidth=1 from the figure and analysis
- Added an explicit note in the figure caption explaining that BW=1 is numerically unstable due to limited mass points
- Expanded the text discussion to explain why local linear estimation fails with only 2 mass points on each side of the cutoff
- Updated the analysis code to run bandwidths [2,3,4,5,6] rather than [1,2,3,4,5,6]

### 5. Child Labor Confound

**Concern:** "The paper downplays the coincidence of the age-14 pension cutoff with the age-14 child labor threshold."

**Response:** We have strengthened the discussion of this limitation:
- The Limitations section now devotes a full paragraph to this issue
- We acknowledge that disentangling pension loss from child labor entry would require either observing child labor outcomes or exploiting variation in child labor enforcement
- We note that cross-state validation (showing effects only at states' specific pension cutoffs) provides evidence favoring the pension mechanism, while acknowledging this is not definitive

---

## Response to Gemini 3 Pro

### 1. References (FAIL)

**Concern:** "The bibliography contains only 5 references. This is unacceptable."

**Response:** Addressed above—expanded to 17 references with foundational works in all relevant areas. We cite Moehling (2007) specifically as requested, noting how our labor supply findings complement her family structure findings.

### 2. Prose (FAIL)

**Concern:** "Section 7.1 and Section 7.3 rely heavily on bullet points."

**Response:** Fully addressed—all sections now use paragraph prose. The Discussion section has grown substantially as a result.

### 3. Child Labor Interaction

**Concern:** "Instead of treating child labor laws merely as a confounder to be dismissed... explicitly model it."

**Response:** We have added acknowledgment that future work with real data could:
- Split the sample by states with strict vs. lenient child labor enforcement
- Examine whether the labor supply effect persists in states where child labor was banned until age 16
- Use difference-in-differences across state-cutoff groups

We note this as an extension rather than a limitation because the cross-state validation test already provides evidence that the pension mechanism is primary.

### 4. Modern Parallels

**Concern:** "Make a more explicit comparison to the 'benefits cliff' in modern policy."

**Response:** The Policy Implications section (7.3) now contains three paragraphs with explicit modern parallels:
- TANF time limits as analogous sharp cutoffs
- Medicaid income thresholds
- Childcare subsidy termination
- EITC gradual phase-outs as an alternative design

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Expand bibliography | DONE (6 → 17 refs) |
| Convert bullets to prose | DONE (all sections) |
| Add CCT methodology discussion | DONE (new Section 4.3) |
| Fix Figure 3 scaling | DONE (excluded BW=1) |
| Strengthen child labor discussion | DONE (expanded limitations) |
| Modern policy parallels | DONE (Section 7.3) |
| Recompile PDF | DONE (32 pages) |

---

## Remaining Limitation

Both reviewers correctly note that simulated data precludes publication as a research article. This remains true. The paper is positioned as a pre-analysis plan demonstrating a valid research design. Actual findings await IPUMS extract #127.

We believe the revised paper now meets the methodological and presentation standards expected for a pre-analysis plan submission, and the design is ready for execution with real data.
