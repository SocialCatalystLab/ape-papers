# Initial Research Plan

## Paper Title
**The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya**

## Research Question
What is the MVPF of unconditional cash transfers (UCTs) in rural Kenya, and how do general equilibrium spillovers affect the welfare calculus?

## Contribution
This paper makes the first application of the Marginal Value of Public Funds (MVPF) framework to a developing country cash transfer program. While the MVPF library (Hendren & Sprung-Keyser 2020) contains 200+ US policy evaluations, no MVPF has been calculated for the UCT programs now used in 50+ developing countries. We exploit the unique experimental design of Egger et al. (2022 Econometrica) that provides (a) gold-standard RCT identification and (b) unprecedented measurement of general equilibrium spillovers with a fiscal multiplier of 2.5.

## Identification Strategy
**Method:** RCT-based calibration (NOT DiD)

The identification comes from published experimental estimates:
1. **Haushofer & Shapiro (2016 QJE):** Village and household-level randomization in Rarieda District (N=1,372)
2. **Egger et al. (2022 Econometrica):** Saturation cluster randomization in Siaya County (N=10,546)

This is NOT a difference-in-differences design. The RCT treatment assignment provides clean causal identification without concerns about parallel trends or staggered timing.

## Exposure Alignment (Required for Phase Gate)

**Who is actually treated?** Poor rural households in western Kenya meeting GiveDirectly eligibility criteria (thatched roof housing, living on <$2/day).

**Primary estimand population:** Direct transfer recipients who receive ~$1,000 USD via M-Pesa mobile money.

**Placebo/control population:** Eligible households in control villages who did not receive transfers.

**Design:** Pure RCT (randomized at village and household level). NOT DiD or staggered adoption.

## Expected Effects and Mechanisms

### Direct Effects (on recipient households)
- **Consumption:** +$293 PPP (12% increase) at 18 months
- **Assets:** +$174 PPP (24% increase)
- **Wage earnings:** +$182 PPP
- **Psychological wellbeing:** Large improvements in life satisfaction, stress

### Spillover Effects (on non-recipients)
- **Consumption:** +13% for non-recipients in treatment villages
- **Business revenue:** +30-46% increase across all enterprises
- **Price inflation:** <1% (minimal distortion)

### Mechanisms
1. **Demand stimulus:** Cash injections increase local demand
2. **Labor market:** Higher wages from increased labor demand
3. **Credit constraints:** Assets enable investment/borrowing
4. **Insurance:** Reduced precautionary savings, more risk-taking

## MVPF Calculation Framework

### Numerator: Willingness to Pay (WTP)

**Specification A (Direct recipients only):**
WTP_direct = $1,000 × (1 - admin_cost) = $850

For cash transfers, WTP = transfer amount (infra-marginal recipients value $1 at $1).

**Specification B (Including spillovers):**
WTP_social = WTP_direct + WTP_spillovers

Where WTP_spillovers = (consumption gain for non-recipients) × (number of non-recipient HHs in treatment villages)

### Denominator: Net Government Cost

Net_Cost = Gross_Transfer - Fiscal_Externalities

Fiscal externalities:
1. **VAT revenue:** 0.16 × (consumption gain) × (persistence years)
2. **Reduced future transfers:** Estimated from asset accumulation reducing welfare dependence
3. **Income tax:** Near zero (informal sector), but included in sensitivity analysis

### Primary Specification

MVPF = WTP / Net_Cost

Under baseline assumptions:
- WTP ≈ $850 (direct) or $1,100-1,300 (with spillovers)
- Net Cost ≈ $900-950 (after VAT recapture)
- Expected MVPF ≈ 0.9-1.4

### Planned Robustness Checks

1. **Persistence assumptions:** 1-year, 3-year, 5-year effect horizons
2. **Tax incidence scenarios:** Formal vs. informal, VAT vs. income tax
3. **Discount rate sensitivity:** 3%, 5%, 7%
4. **MCPF adjustment:** 1.0, 1.3, 1.5 marginal cost of public funds
5. **Spillover inclusion:** With/without GE effects
6. **Comparison to US policies:** Benchmark against EITC, TANF, food stamps MVPFs

## Data Sources

### Primary Data
1. **Haushofer & Shapiro (2016 QJE):** Replication data on Harvard Dataverse (doi:10.7910/DVN/M2GAZN)
   - Household-level panel: baseline, 9-month, 3-year follow-up
   - Variables: consumption, assets, earnings, employment, wellbeing

2. **Egger et al. (2022 Econometrica):** Replication files from Econometric Society
   - Village-level data, enterprise data, price data
   - General equilibrium effects, fiscal multiplier estimates

### Supplementary Data
3. **Kenya tax data:**
   - VAT rates: Kenya Revenue Authority (16% standard)
   - Income tax schedule: PWC Tax Summaries
   - Informal sector share: BLS/IEA Kenya (~80%)

4. **Exchange rates/PPP:** World Bank ICP data for USD-KES PPP conversion

## Analysis Plan

### Phase 1: Data Assembly
- Download replication data from Harvard Dataverse and Econometric Society
- Merge household-level and village-level datasets
- Construct MVPF-relevant variables

### Phase 2: Replicate Key Results
- Reproduce main treatment effects from Haushofer & Shapiro
- Reproduce spillover estimates from Egger et al.
- Validate sample sizes and standard errors

### Phase 3: MVPF Calculation
- Calculate WTP (direct and with spillovers)
- Calculate fiscal externalities
- Compute net government cost
- Form MVPF ratio with confidence intervals

### Phase 4: Sensitivity Analysis
- Vary persistence assumptions
- Vary tax incidence assumptions
- Vary discount rates
- Vary MCPF assumptions

### Phase 5: Comparison
- Compare Kenya UCT MVPF to US cash transfer MVPFs
- Discuss implications for development policy

## Limitations (Pre-registered)

1. **Fiscal externality uncertainty:** Rural Kenya's informal economy makes tax externality estimation imprecise
2. **Persistence uncertainty:** 3-year follow-up may not capture lifetime effects
3. **Counterfactual government:** We assume hypothetical government funding; actual funder was private charity
4. **External validity:** One region of Kenya; may not generalize to other settings
5. **No behavioral responses:** We don't model labor supply responses to anticipated transfers

## Timeline

- Week 1: Data download and cleaning
- Week 2: Replicate key treatment effects
- Week 3: MVPF calculation and sensitivity analysis
- Week 4: Write paper, create figures/tables
- Week 5: Review and revision
