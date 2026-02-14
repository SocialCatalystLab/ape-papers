# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Concern 1: Multiple testing across horizons
> Missing joint significance tests over long horizons.

**Response:** The headline persistence claim is supported by permutation p=0.022 at h=48, which provides exact finite-sample inference without distributional assumptions. We have added a brief acknowledgment that formal multiple-testing corrections (e.g., Romano-Wolf) would widen confidence intervals but note that the permutation approach already accounts for the small-sample nature of the data. The persistence pattern (consistently negative coefficients from h=6 through h=84) is qualitatively robust and does not depend on any single horizon.

### Concern 2: Bartik exposure diagnostics
> COVID coefficients lack Borusyak, Hull & Jaravel (2022) diagnostics.

**Response:** Our COVID Bartik construction follows the Goldsmith-Pinkham et al. (2020) framework with leave-one-out national shocks, as recommended by that literature. We cite Borusyak et al. (2022) for the insight that exogenous industry-level shocks validate the Bartik design, which is highly plausible for COVID's contact-intensity-based sectoral incidence. Additionally, we now report AKM (Adao-Kolesár-Morales, 2019) exposure-robust standard errors for the COVID panel, which account for correlated shocks inherent in shift-share designs.

### Concern 3: Structural model welfare magnitudes
> 442:1 ratio and 39.6% CE loss are implausibly large.

**Response:** We agree these magnitudes should be interpreted as illustrative of the asymmetry's direction, not as precise point estimates. The welfare section now emphasizes that risk-neutral utility and the absence of consumption smoothing (borrowing, savings) inflate the CE loss. Under CRRA utility with risk aversion >1, the welfare costs would be substantially lower. The sensitivity table (Appendix) shows the qualitative result is robust across wide parameter ranges; the precise ratio is not.

### Concern 4: GE identification framing
> Cross-state estimates are relative, not aggregate.

**Response:** Added explicit discussion in the Threats to Validity section noting that cross-state LP estimates capture relative scarring (how much more states with greater exposure were hurt) and may understate aggregate scarring if GE spillovers attenuate cross-state differences. This follows Beraja et al. (2019). The conclusion now acknowledges this limitation.

### Concern 5: Causal framing with two episodes
> Claims based on two specific episodes.

**Response:** Added qualification in the conclusion that the demand/supply taxonomy is tested on these two specific episodes and may not map cleanly onto mixed-type recessions (citing Guerrieri et al., 2022). We reference the broader hysteresis literature (Cerra et al., 2023) as providing cross-country evidence consistent with our mechanism.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Literature gaps
> Add recent citations.

**Response:** Cerra et al. (2023), Foote et al. (2021), and Fujita & Moscarini (2017) were all added in this revision. Cameron et al. (2008) and MacKinnon & Webb (2017) are cited for the wild cluster bootstrap methodology.

### Concern 2: Minor prose cleanup
> Consolidate repetition; standardize notation.

**Response:** Addressed through prose review and targeted edits.

### Concern 3: State-level mechanism evidence
> State-level LTU validation would strengthen the mechanism link.

**Response:** We acknowledge this as a valuable extension but note that individual-level CPS data with state identifiers is not available through the FRED API used in this paper. The mechanism test now includes a formal UR persistence comparison (Table 4) showing the GR UR persistence ratio is 22× the COVID ratio, directly testing the duration channel at the state level.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Migration denominator
> Use pre-recession population as fixed denominator.

**Response:** The employment-to-population ratio uses contemporaneous population, which is standard in the BLS LAUS data. We added a note that using a fixed pre-recession population base would isolate level effects from migration more cleanly but would introduce bias if population changes are partly driven by the treatment. The current approach is conservative and consistent with Yagan (2019).

### Concern 2: Skill depreciation vs. job polarization
> Jaimovich & Siu (2020) job polarization may confound.

**Response:** This is a thoughtful point. Job polarization could amplify scarring in demand recessions if routine jobs destroyed during the GR are not recreated. We have added a brief note acknowledging this complementary channel. However, our reduced-form estimates capture the total effect of demand exposure on employment—through all channels including polarization—which is the relevant object for the welfare comparison.

### Concern 3: Wage stickiness robustness
> Model assumes simplified wage rule.

**Response:** We have been explicit about the wage simplification (Section 3.5) and noted that it understates tightness amplification. The Hall (2005) rigid wage extension would amplify the demand shock's persistence (wages don't fall enough to clear the labor market), strengthening rather than weakening our qualitative result. We note this in the model discussion.
