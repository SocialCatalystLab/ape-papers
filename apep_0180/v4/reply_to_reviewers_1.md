# Reply to Reviewers (Round 1)

## Reviewer 1 (GPT-5-mini): Major Revision

**1. Microdata reanalysis**
We agree this would strengthen the paper. However, automated retrieval of the Harvard Dataverse data requires interactive CAPTCHA authentication that precludes programmatic access. We have added a transparent acknowledgment of this limitation and demonstrate through the covariance sensitivity analysis (Table 8) that the MVPF is virtually invariant to the consumption-earnings correlation, changing by less than 0.002 across the full range of plausible correlations.

**2. Include admin cost uncertainty in bootstrap**
Administrative costs are well-documented from GiveDirectly's annual reports (15% consistently across multiple years). We treat this as a known parameter rather than a stochastic input. The sensitivity analysis (Section 6) tests the MVPF under alternative WTP assumptions (WTP ratio = 0.90), which implicitly captures variation in delivery efficiency.

**3. Missing references**
Added: Efron & Tibshirani (1994) for bootstrap inference on ratios; Deaton & Cartwright (2018) for external validity discussion; Hendren (2016) for the MCPF/policy elasticity debate. Citations integrated into relevant sections.

**4. MVPF accounting convention**
Added an explicit footnote in Section 3.1 clarifying the accounting: the government allocates $1,000 per recipient (gross cost), of which $150 funds administration and $850 reaches recipients. Net cost = $1,000 - $22.05 FE = $978. This follows the standard Hendren & Sprung-Keyser (2020) convention.

**5. Discount rate**
Now stated explicitly in the main text (Section 4.3): "r = 5%, with sensitivity from 3% to 10% in Section 6."

## Reviewer 2 (Grok-4.1-Fast): Minor Revision

**1. Bibliography errors**
Fixed: Banerjee et al. year corrected from (2019) to (2017) in the bibliographic entry. Bachas et al. reference noted.

**2. Additional references**
Added Hendren (2016) "The Policy Elasticity" and cited in the MCPF discussion.

**3. Template compliance**
Noted for future submission.

## Reviewer 3 (Gemini-3-Flash): Conditionally Accept

**1. Figure 1 tornado label overlap**
Fixed: Reduced label wrap width, increased figure height, and reduced axis text size.

**2. Non-recipient labor supply cost**
Good suggestion. We note that Egger et al. (2022) find non-recipient gains come from higher wages and business revenue in response to increased local demand. The price change is only 0.1%, supporting supply-side expansion rather than pure redistribution. We discuss this in Section 6.5 (Pecuniary vs. Real Spillovers).

**3. Hendren (2016) reference**
Added and cited in the MCPF discussion (Section 3.3).
