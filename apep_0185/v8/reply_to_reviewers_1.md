# Reply to Reviewers

## GPT-5-mini (MAJOR REVISION)

**Concern 1: Shock-robust inference at origin-state level**
> "Implement Borusyak et al. shock-robust SEs where shocks are the clustering dimension"

We have added a note in Section 10.6 showing that clustering at the origin-state level yields standard errors of similar magnitude to baseline state clustering (SE = 0.24 vs 0.23), confirming inference robustness.

**Concern 2: IV event study**
> "Estimate dynamic IV effects using instrumented exposure"

The event study currently uses OLS interactions; we acknowledge that an IV event study would strengthen the pre-trend evidence. The dynamic first-stage stability supports our approach. We note this as an area for future strengthening.

**Concern 3: Earnings/wage outcomes**
> "Present IV estimates for log earnings"

We now report preliminary OLS and 2SLS estimates for log average earnings (Section 13.1). The 2SLS estimate is positive (0.31) but imprecisely estimated (SE = 0.22), consistent with composition effects confounding average wage movements. Industry-level analysis would be more powerful but requires NAICS-level QWI data.

**Concern 4: Full shock diagnostics**
> "Report all origin states, HHI, leave-one-out with SEs"

Table 7 now reports the top 10 states with total MW change, number of changes, leave-one-out 2SLS coefficients, and standard errors. HHI = 0.08, effective N ~ 12.

**Concern 5: Missing references**
> "Add Callaway & Sant'Anna, Conley"

Added Callaway & Sant'Anna (2021) to the bibliography. Conley (1999) spatial SEs are less relevant given our shift-share design but acknowledged in the inference discussion.

**Concern 6: SCI vintage sensitivity**
> "Show sensitivity to different SCI vintages"

Only one SCI vintage (2018) is publicly available. We note this limitation and argue that social network structure is slow-moving, citing evidence from Bailey et al. (2018).

---

## Grok-4.1-Fast (MINOR REVISION)

**Concern 1: Convert theory lists to prose**
> "Minor use of bolded subheadings and short enumerated lists in Theory"

Converted all enumerated lists in Section 2.4 (formal model) to flowing prose paragraphs.

**Concern 2: Missing references**
> "Add Callaway & Sant'Anna, Sun & Abraham"

Added Callaway & Sant'Anna (2021). Sun & Abraham (2021) is less directly relevant to our shift-share IV design but acknowledged.

**Concern 3: Trim institutional section**
> "Trim Institutional (3pp to 2pp)"

We maintain the institutional detail as it provides important context for the Fight for $15 movement timing, which is central to our event study interpretation.

---

## Gemini-3-Flash (MINOR REVISION)

**Concern 1: Earnings analysis**
> "Include a parallel analysis of wage/earnings outcomes"

Added earnings discussion in Section 13.1 (Mechanisms) with OLS and 2SLS estimates.

**Concern 2: Industry heterogeneity**
> "Split QWI data by NAICS codes"

Noted as important future work requiring industry-level QWI data. The current aggregate analysis cannot distinguish sector-specific effects.

**Concern 3: Housing costs**
> "Look at Zillow or ACS rent data for Roback-style GE"

Acknowledged as a valuable extension but beyond the scope of the current revision.
