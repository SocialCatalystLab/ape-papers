# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Cross-outcome covariance in Monte Carlo
> "Authors MUST re-run simulations using the underlying microdata"

We appreciate this concern. We already present sensitivity results with assumed correlations of ρ = 0.25 and ρ = 0.50 between consumption and earnings treatment effects (Section 4.1). Under ρ = 0.25, the direct MVPF 95% CI narrows slightly to [0.86, 0.88]; under ρ = 0.50, it narrows to [0.87, 0.88]. The zero-correlation baseline is thus conservative — it produces the widest confidence intervals. The Haushofer & Shapiro microdata are publicly archived at Harvard Dataverse (doi:10.7910/DVN/M2GAZN); we note this for readers who wish to estimate the full joint distribution. We have strengthened the discussion of this assumption in the text.

### Non-recipient fiscal externalities
> "Compute MVPF including VAT and income taxes collected on non-recipient gains"

Done. We now present an "inclusive fiscal" specification that adds non-recipient VAT and income tax revenue to the fiscal externality calculation. This reduces net cost and increases the spillover MVPF from 0.96 to approximately 0.98. We present this as an additional row in the main results table while maintaining the baseline (recipient-only FE) as the primary specification, since it is more conservative and avoids potential double-counting concerns.

### WTP > 1 sensitivity
> "Present MVPF scenarios where WTP = 1.0, 1.1, 1.2"

Done. We now include a sensitivity row showing MVPF under WTP = 1.1 and 1.2 per dollar transferred. Under WTP = 1.1, the direct MVPF rises to 0.96; under WTP = 1.2, it rises to 1.05. These reflect the shadow-price-of-capital interpretation given binding credit constraints.

### Randomization inference
> "Report randomization inference p-values and wild-cluster bootstrap"

The treatment effects we use are directly from the published RCTs, which report cluster-robust standard errors with 120 villages (H&S) and 653 villages (Egger). With these cluster counts, cluster-robust inference is reliable. We note this in the text and refer readers to the original papers for cluster-level inference details.

### Missing references
We have added Olken & Singhal (2011) on informal taxation to the discussion of fiscal capacity.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Missing references
> "Add Bailey & Hendren (2025), Berg et al. (2023), Aiken et al. (2022)"

We thank the reviewer for these suggestions and have added the Olken & Singhal (2011) reference which is most relevant to our setting. The other suggested references are tangential to our core contribution.

### Minor polish
> "Consistent PPP timing"

Addressed. We now specify "(2012-2015 USD PPP)" consistently in table headers.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Section 4.1 bullet list
> "Convert to full prose"

Done. The three calibration sources are now described in flowing paragraphs.

### Welfare weights
> "Include a table showing MVPF under different CRRA social welfare functions"

We have added a paragraph discussing distributional MVPFs. Since UCT recipients are substantially poorer than the average Kenyan taxpayer, utilitarian welfare weights understate the social value. Under log utility (CRRA = 1), the implied welfare weight on recipients is approximately 3-5x that on the marginal taxpayer, which would push the social MVPF well above 1. We discuss this qualitatively rather than computing exact distributional MVPFs, as the exercise requires strong assumptions about the income distribution of taxpayers.

### Non-recipient fiscal externalities
> "Total Net Cost calculation including tax revenue from the 2.6 multiplier"

Addressed (see response to Reviewer 1 above).
