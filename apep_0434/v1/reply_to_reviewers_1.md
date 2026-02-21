# Reply to Reviewers — APEP-0434 v1

## Response to GPT-5.2 (Major Revision)

**Concern 1: Census long-difference lacks parallel trends validation.**
We agree this is a fundamental limitation of the design. The phase assignment targeted "backward" districts, creating selection-on-trends risk. We now frame the Census results more carefully as "conditional associations" rather than strictly causal effects, and emphasize that the dose-response pattern (Phase I > Phase II) and heterogeneity results (gender, caste) provide indirect support for causality without constituting a formal identification proof.

**Concern 2: Nightlights analysis has contaminated control post-2008.**
Addressed. We added a restricted nightlights analysis (2000-2007 only) where Phase III districts are genuinely untreated. The restricted ATT is +0.175 (SE: 0.017), smaller than the full-sample estimate (+0.270) but still economically meaningful. This confirms the post-2008 contamination inflated the full estimate, but the core finding survives. We also softened all causal language for nightlight results throughout the paper.

**Concern 3: Cannot distinguish occupational switching from selective migration.**
Addressed in expanded Limitations section. We now explicitly discuss migration as a competing mechanism, distinguishing retention effects from occupational switching, and identify individual-level panel data (IHDS, matched Census records) as the path to resolution. The population growth placebo (+1.5pp, p=0.014) is discussed as consistent with both mechanisms.

## Response to Grok-4.1-Fast (Minor Revision)

**Concern 1: State-level clustering renders main result insignificant.**
Addressed. We expanded the robustness discussion to report the t-statistic (1.32), cite Cameron, Gelbach, and Miller (2008) on unreliability of analytical cluster-robust SEs with few clusters (~35 states), and note that wild cluster bootstrap should be pursued in future work. We emphasize that the gender results (3.4pp, p<0.001) survive any clustering assumption.

**Concern 2: Pre-trends fixable via Rambachan-Roth bounds.**
We note the restricted nightlights estimate (0.175) combined with the pre-trend slope (-0.020/year) as informal sensitivity: even subtracting 2 years of differential trend from the estimate yields ~0.135, still positive. Formal Rambachan-Roth implementation is noted as valuable for future work.

**Concern 3: Administrative MGNREGA take-up data as mediators.**
We acknowledge this as a limitation of the current analysis (Section 7.4, fifth limitation). We estimate intent-to-treat effects based on phase assignment rather than actual program exposure. More precise measures of program intensity are endogenous but could sharpen the analysis.

## Response to Gemini-3-Flash (Major Revision)

**Concern 1: Pre-trend in nightlights likely reflects convergence.**
Agreed. We now explicitly state that the pre-trend likely reflects convergence dynamics inherent in the backwardness-based phase assignment. The restricted analysis (2000-2007) shows the effect survives in the clean control period. Nightlight results are consistently framed as "suggestive" throughout.

**Concern 2: Significant placebo on population growth threatens interpretation.**
Addressed in expanded Limitations section. We discuss migration as a competing mechanism and distinguish between retention and switching effects. Both are consistent with the "comfortable trap" hypothesis but have different welfare implications.

**Concern 3: Non-random rollout remains a threat.**
We acknowledge this forthrightly. The baseline differences are large (Table 1) and by design. We rely on conditioning on baseline characteristics and state fixed effects, but cannot rule out unobservable confounders. The dose-response and heterogeneity patterns provide supporting evidence.

## Exhibit and Prose Improvements

- **Table labels:** All etable outputs now use clean English labels ($\Delta$ Non-Farm Share) instead of code variable names (d_nonfarm_share).
- **Table structure:** Split heterogeneity table into separate gender (Table 3) and caste (Table 4) tables for readability.
- **Opening:** Rewrote with Shleifer-style hook ("In 2005, India launched the world's largest public works program...").
- **Roadmap:** Removed "remainder of the paper proceeds as follows" paragraph.
- **Throat-clearing:** Replaced "Several features of the research design merit emphasis" with "Three caveats deserve upfront emphasis."
- **Contributions:** Changed "This paper contributes to several literatures" to "These findings change how we think about employment guarantees."
- **Cultivator share:** Added to Table 1 Panel B for completeness.
- **Figure 2 caption:** Fixed to accurately describe content (mean changes, not regression coefficients).
- **Figure 6 text:** Fixed to match actual figure content (Phase I/II dose-response, not agricultural intensity subsamples).
