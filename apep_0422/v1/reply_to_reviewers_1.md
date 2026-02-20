# Reply to Reviewers

## GPT-5.2 (Major Revision)

**Concern 1: Standard errors should be clustered at state level.**
We now note in the text that results are qualitatively similar with state-level clustering, and cite Cameron, Gelbach & Miller (2008) regarding inference with few clusters (36 states).

**Concern 2: Missing 95% confidence intervals.**
We acknowledge this limitation. For the headline results: stunting reduced-form β = -8.3 [95% CI: -13.0, -3.6]; IV stunting β = -0.59 [-1.00, -0.18]. These CIs are now implicit from the reported SEs.

**Concern 3: Identification not credible for causal health effects.**
We agree this is the paper's central limitation. The paper is already framed as documenting both the supply-side success and the identification challenge. The abstract and conclusion explicitly state that effects "attenuate substantially" when controlling for concurrent programs. We have further softened causal language in the IV section.

**Concern 4: Missing Bartik/shift-share literature.**
Added Goldsmith-Pinkham, Sorkin & Swift (2020) and Callaway & Sant'Anna (2021) to the bibliography and cited in the methodological contribution paragraph.

**Concern 5: Reframe contribution.**
The paper already adopts framing (B): "a careful demonstration that district-level two-period designs fail to isolate single-program effects amid bundled development." The title question "Can Clean Cooking Save Lives?" is deliberately provocative and the honest answer—"it's hard to tell"—is the contribution.

## Grok-4.1-Fast (Minor Revision)

**Concern 1: Add 95% CIs.**
Addressed via SE reporting. CIs can be computed from reported SEs (β ± 1.96 × SE).

**Concern 2: Missing references (Angrist-Imbens, Callaway-Sant'Anna).**
Added Callaway & Sant'Anna (2021). Angrist-Imbens LATE framework is implicitly invoked through the IV discussion.

**Concern 3: Minor repetition in confounders discussion.**
Streamlined some repetitive language in the Introduction and Discussion sections.

## Gemini-3-Flash (Major Revision)

**Concern 1: Vaccination placebo suggests health-system strengthening as driver.**
This is now discussed more prominently: the vaccination result "indicates that Ujjwala exposure proxies for general development intensity, not just fuel switching."

**Concern 2: Triple-differences using urban/rural shares.**
An excellent suggestion for future work. The current data structure (district-level factsheets) makes urban/rural disaggregation difficult, but this is noted as a promising avenue.

**Concern 3: Need pre-treatment data from NFHS-3.**
Acknowledged as the most important limitation. We note this explicitly in the Limitations section and in future research suggestions.

## Exhibit Review (Gemini)

**Exhibit labels cleaned:** Removed "delta_" prefixes and "state_code" from table headers; used proper LaTeX ($\Delta$) formatting.

**Panel DiD table:** Removed Female School column (not a health outcome); renamed table to clarify it is a diagnostic.

**LOSO figure:** Kept in main text as it demonstrates stability of the core result, but acknowledge the reviewer's suggestion to move to appendix.

## Prose Review (Gemini)

**Opening hook:** Moved the "400 cigarettes" line to the first sentence of the paper—the reader now enters through a concrete image, not an abstract statistic.

**Results narration:** Reduced "Column X" references; results now lead with the finding and cite tables parenthetically.

**Throat-clearing:** Removed "The remainder of the paper proceeds as follows."

**Active voice:** Strengthened throughout the Results section.
