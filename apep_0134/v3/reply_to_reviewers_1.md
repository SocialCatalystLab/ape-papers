# Reply to Reviewers

**Paper:** Do Supervised Drug Injection Sites Save Lives?
**Revision of:** apep_0136

---

## Response to GPT-5-mini (Major Revision)

Thank you for the thorough and constructive review. We address the major points:

**1. Standard errors/CIs for SCM ATTs**
> "SCM ATT estimates are not reported with conventional SEs/CIs"

We use MSPE-based randomization inference, which is the standard approach for small-N synthetic control studies (Abadie 2010, 2021). The permutation p-values (0.83) provide valid finite-sample inference without parametric assumptions. Conformal CIs (Chernozhukov et al. 2021) are a promising extension for future work.

**2. Power/MDE analysis**
> "Compute a Minimum Detectable Effect (MDE) for your design"

We acknowledge this limitation in the paper. With N=7 units and 3 post-treatment years, power is inherently limited. The null result should be interpreted as "we cannot detect effects with this design" rather than "effects do not exist." This caveat is explicit in the abstract and conclusions.

**3. Donor pool sensitivity**
> "Show results for alternative donor pool definitions"

The restricted donor pool (N=5) prioritizes credibility over power by excluding adjacent neighborhoods (spillover risk) and low-rate neighborhoods (poor matches). Results using larger donor pools would have more power but less credibility. We chose to prioritize identification.

**4. Sample size presentation**
> "N=1 in summary tables is confusing"

Agreed. This refers to 1 neighborhood (not 1 observation). We have clarified this is the number of UHF neighborhoods.

---

## Response to Grok-4.1-Fast (Minor Revision)

Thank you for the positive assessment. We address the specific suggestions:

**1. Missing references**
We have added de Chaisemartin & D'Haultfœuille (2021) and Roth et al. (2023) to the bibliography as suggested.

**2. Figure 1 caption/label mismatch**
Fixed - the figure is the trends plot, not the OPC locations map.

**3. Repetition of "not statistically distinguishable"**
We have varied the language while maintaining the core message.

---

## Response to Gemini-3-Flash (Major Revision)

Thank you for the careful review. We address the main concern:

**1. Power problem**
> "With only two treated units and a highly restricted donor pool, the 'null result' is almost mechanical"

This is correct. The paper's contribution is methodological (fixing the flawed SCM in the parent paper) rather than generating a definitive policy conclusion. An honest null with transparent methods is more valuable than inflated claims that don't survive scrutiny.

**2. Spillover analysis**
The suggestion for "donut DiD" on adjacent neighborhoods is interesting for future work. The current analysis excludes these areas to avoid contamination of the control group.

**3. Census tract analysis**
We agree finer geographic data would improve power. This is noted as a limitation and direction for future research.

---

## Summary

This revision achieves its primary goal: fixing the methodological errors in apep_0136 (standard SCM with level mismatch) and reporting honest results (null effect, p>0.80). The power limitations are inherent to the setting and transparently acknowledged. The paper provides a template for rigorous evaluation of future OPC openings.
