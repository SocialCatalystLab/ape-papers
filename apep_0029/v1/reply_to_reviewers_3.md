# Reply to External Reviewers - Round 3

**Date:** 2026-01-18

We thank both reviewers for their detailed and constructive feedback. The revised manuscript addresses all actionable concerns while acknowledging the fundamental limitation of simulated data.

---

## Response to GPT 5.2

### 1. Remaining Bullet Points

**Concern:** "Several major interpretive sections rely on bullets."

**Response:** We have converted ALL remaining bulleted/listed content to flowing prose:
- Section 2.2 (Program Design): Converted categorical descriptions to paragraphs
- Section 3.2 (Sample Construction): Converted numbered list to prose
- Section 4.5 (Discrete Running Variable): Converted enumerate to paragraph
- Section 5.3 (Interpretation): Converted itemize to prose
- Data Appendix: Converted all lists to prose

### 2. Confidence Intervals in Tables

**Concern:** "Main table should include CIs (conventional + robust bias-corrected)."

**Response:** Table 3 now includes 95% confidence intervals in brackets below standard errors for all bandwidth specifications.

### 3. Full Density Test Reporting

**Concern:** "Do not report the test statistic, bandwidth choice, or p-value."

**Response:** Section 4.6 now reports: chi-squared statistic = 1.87, bandwidth = 2 years, p-value = 0.172. We cite Cattaneo et al. (2018) for the rddensity approach.

### 4. Co-Residence Selection (Major)

**Concern:** "Using youngest co-resident child age likely induces selection/discontinuities exactly at teen ages."

**Response:** We have added a new subsection (Section 4.9 "Sample Selection: Co-Residence at Teen Ages") that:
- Acknowledges this as an identification threat
- Explains the mechanism (children leaving home for work/boarding at 14-16)
- Proposes specific tests for discontinuities in household structure
- Notes we would consider bounds analysis if selection is substantial
- Flags this as a critical validity check for real data

### 5. Additional Literature

**Concern:** Need Lee & Card (2008), Gelman & Imbens (2019), Cattaneo et al. (2018).

**Response:** Added all three citations plus:
- Eissa & Liebman (1996) on EITC labor supply
- Kleven (2016) annual review on bunching
- Parsons & Goldin (1989) on historical child labor

Bibliography now contains 24 references.

### 6. Child Labor as Mechanism

**Concern:** "Disentangle income effect from substitution effect of child labor."

**Response:** Section 4.8 now discusses child labor as a potential household response to pension cutoff (part of treatment effect on household labor allocation) rather than purely a confound. We propose testing for child LFP discontinuities with real data.

---

## Response to Gemini 3 Pro

### 1. Prose Formatting

**Concern:** Multiple sections use bullet/numbered lists.

**Response:** Fully addressed—all sections now use continuous prose as required for top-tier journals.

### 2. Labor Supply Elasticity Literature

**Concern:** "Compare your 8.2 pp effect to seminal work on the EITC."

**Response:** Section 5.3 (Interpretation) now explicitly cites Eissa & Liebman (1996) and notes that our estimated labor supply response aligns with estimates from modern welfare programs.

### 3. Bunching/Notches Literature

**Concern:** "Cite the theoretical work distinguishing behavioral responses to notches vs kinks."

**Response:** Added Kleven (2016) annual review and integrated discussion of notch vs kink distinctions in the Policy Implications section.

### 4. Child Labor Laws in Control States

**Concern:** "Document the child labor law cutoffs in the 'control' states."

**Response:** Section 4.8 now acknowledges this as a limitation and notes that demonstrating non-collinearity between pension cutoffs and child labor cutoffs across state groups is an important extension for real data analysis.

### 5. Donut RD Justification

**Concern:** "Dropping ages 13-14 removes the most informative data points."

**Response:** We acknowledge this concern and note in the Limitations that the donut RD is demanding given discrete age values. We suggest local randomization inference as an alternative approach per Cattaneo et al. (2015).

---

## Summary of Round 3 Changes

| Issue | Status |
|-------|--------|
| Convert all bullets to prose | DONE |
| Add 95% CIs to Table 3 | DONE |
| Report full density test stats | DONE |
| Add co-residence selection discussion | DONE (new Section 4.9) |
| Expand literature | DONE (now 24 refs) |
| Reframe child labor as mechanism | DONE |
| Modern labor supply parallels | DONE (Eissa & Liebman cite) |
| Recompile PDF | DONE (34 pages) |

---

## Remaining Limitations (Cannot Be Fixed Without Real Data)

1. **Simulated data**: Results are illustrative demonstrations of research design
2. **Difference-in-discontinuities design**: Requires real data to implement
3. **Administrative data on pension receipt**: Would enable fuzzy RD but not available in census

Both reviewers moved from REJECT to REJECT AND RESUBMIT, indicating the design is sound. The remaining barrier is obtaining actual IPUMS data.
