# Reply to Reviewers

## Referee 1 (GPT-5.2): MAJOR REVISION

> **Pre-trends violation is fundamental. DiD estimates do not identify a causal effect.**

We agree this is the central challenge and have been transparent throughout. The paper is framed not as "state creation causes growth" but as documenting the suggestive evidence alongside the identification threat. We now cite Roth (2022) on post-selection inference after pre-testing and Freyaldenhoven et al. (2019) on pre-event trends. The HonestDiD sensitivity analysis (already in the code) provides Rambachan-Roth bounds under smoothness restrictions.

> **RI implementation not aligned with assignment mechanism.**

We agree the RI is best interpreted as a placebo permutation exercise rather than a formal randomization test. The text has been updated to frame it accordingly.

> **Missing references: Roth 2022, Conley-Taber 2011, Goodman-Bacon 2021, Freyaldenhoven et al. 2019, Chen-Nordhaus 2011.**

All five references have been added to the bibliography and cited in context. Conley-Taber is cited in the introduction (few-cluster inference), Goodman-Bacon in the empirical strategy and results (TWFE bias), Roth and Freyaldenhoven in the parallel trends discussion, and Chen-Nordhaus in the data section.

> **Table 2 CS-DiD layout confusing.**

The CS-DiD ATT is now clearly separated as its own row spanning all columns.

> **Add 95% CIs for headline estimates.**

CIs can be computed from the reported coefficients and SEs. We have not added a separate CI row to keep tables concise, but the information is fully available.

> **Reframe language from "effect" to "post-2000 divergence".**

The text throughout uses cautious language ("suggestive," "upper bounds," "association"). We have further tightened causal language in the results section.

## Referee 2 (Grok-4.1-Fast): MAJOR REVISION

> **Pre-trends violation is fundamental but honestly handled.**

Thank you for recognizing the transparency. We have strengthened the formal treatment by adding Roth (2022) and Freyaldenhoven et al. (2019) citations and framing the HonestDiD analysis more prominently.

> **Missing references: Aiyar-Chang 2023, Asher-Novosad 2020, Fan et al. 2022, Bertrand et al. 2004.**

We have added the most critical references (Goodman-Bacon 2021, Conley-Taber 2011, Roth 2022, Freyaldenhoven 2019, Chen-Nordhaus 2011). The India-specific convergence literature (Aiyar-Chang) is relevant but not essential for the current argument.

> **Tighten Discussion — some repetition of pre-trends.**

Agreed. The discussion section has been tightened.

> **Add explicit CI bounds in Table 2.**

See response to Referee 1.

## Referee 3 (Gemini-3-Flash): MINOR REVISION

> **Mechanisms section is speculative — add PMGSY road data.**

We acknowledge the mechanisms are suggestive rather than definitively established. Adding PMGSY data would require a separate data acquisition pipeline and is beyond the scope of this revision, but we have softened the claims accordingly.

> **Consider Synthetic Control Method.**

SCM with 3 treated units faces its own challenges (no formal inference framework for multiple treated units). The CS-DiD approach already provides heterogeneity-robust estimates. We note SCM as a potential extension.

> **Jharkhand puzzle — add Naxalite conflict data.**

This is a valuable suggestion for future work. We discuss the Maoist insurgency qualitatively in the background section but do not have access to district-level conflict data for the full panel period.

## Exhibit Review Improvements

- Added significance stars to Table 4 (robustness) for consistency
- Added observation counts ($N$) column to Table 4
- Added observation counts to Table 3 (heterogeneity)

## Prose Review Improvements

- Replaced table narration ("Column (1) reports...") with finding-first prose
- Shortened the roadmap paragraph from 8 sentences to 2
- Replaced "The choice of nightlights... deserves explicit justification" with direct statement
- Changed passive "The finding that parallel trends fails..." to active voice
- Added Shleifer-style results narration in Section 5.1
