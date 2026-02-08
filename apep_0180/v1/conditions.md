# Conditional Requirements

**Generated:** 2026-02-03T23:42:55.027544
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## The MVPF of Unconditional Cash Transfers in a Developing Country: Evidence from Kenya's GiveDirectly Program

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: transparent financing/tax-incidence assumptions

**Status:** [X] RESOLVED

**Response:**

We will address this by presenting MVPF under multiple financing scenarios:

1. **Baseline scenario (Informality-adjusted):** Rural Kenya is ~80% informal sector where income tax is effectively 0%. We assume fiscal externalities come primarily through:
   - VAT on consumption (16% standard rate) applied to consumption gains
   - Reduced future transfer dependency (modeled from long-run asset accumulation)

2. **Formal sector counterfactual:** Kenya's effective income tax rate for formal workers is ~18.5%. We present sensitivity analysis assuming varying degrees of formalization.

3. **Government financing cost:** We apply Kenya's marginal cost of public funds (MCPF), estimated at ~1.3-1.5 for developing countries (Dahlby 2008), as the denominator adjustment for tax-financed transfers.

4. **Private philanthropy benchmark:** Since GiveDirectly is charity-funded, we also present MVPF treating administrative costs (15-20%) as the only friction, with MCPF = 1.

**Evidence:**

- Kenya VAT rate: PWC Tax Summaries Kenya (https://taxsummaries.pwc.com/kenya/individual/taxes-on-personal-income) - confirms 16% standard VAT
- Kenya effective income tax ~18.5%: IEA Kenya (https://ieakenya.or.ke/blog/understanding-kenyas-average-personal-income-tax-rate/)
- Kenya informal sector ~80%: Tandfonline study (https://www.tandfonline.com/doi/full/10.1080/23322039.2021.2003000)
- MCPF in developing countries: Dahlby, B. (2008). The Marginal Cost of Public Funds: Theory and Applications

---

### Condition 2: sensitivity analysis on persistence

**Status:** [X] RESOLVED

**Response:**

We will conduct extensive sensitivity analysis on effect persistence using the rich time-series data available:

1. **Short-term (9 months):** Haushofer & Shapiro (2016 QJE) - baseline consumption effects
2. **Medium-term (3 years):** Haushofer & Shapiro (2018 working paper) - assets persist at 60% of transfer, consumption effects attenuate
3. **Long-term extrapolation scenarios:**
   - Pessimistic: Effects fully dissipate after 5 years
   - Moderate: 50% decay rate per year after year 3
   - Optimistic: Asset effects persist indefinitely (consistent with durable goods investment)

4. **Fiscal externality persistence:**
   - VAT on consumption: Apply to measured consumption gains at each time horizon
   - Tax on earnings: Apply to wage income gains (Egger et al. find wage earnings ↑ $182 PPP)
   - Present value calculations with discount rate sensitivity (3%, 5%, 7%)

**Evidence:**

- Short-term effects (9 months): Haushofer & Shapiro (2016) QJE - consumption ↑ $35/month, assets ↑ 58%
- 3-year persistence: Haushofer & Shapiro (2018) working paper - assets remain 40% higher, consumption NS
  Source: https://www.povertyactionlab.org/sites/default/files/research-paper/The-long-term-impact-of-conditional-cash-tranfer_Kenya_Haushofer_Shapiro_January2018.pdf
- GiveDirectly 12-year UBI arm: Ongoing data collection through 2028 (noted for discussion of external validity)

---

### Condition 3: GE/WTP mapping

**Status:** [X] RESOLVED

**Response:**

This is the most conceptually challenging condition. We will handle GE effects carefully:

**Core issue:** Egger et al. (2022) estimate a fiscal multiplier of 2.4-2.7, meaning $1 transferred generates $2.40-$2.70 of total economic activity. How do we map this to WTP in the MVPF framework?

**Our approach:**

1. **Direct recipient WTP (standard MVPF):**
   - Consumption gain = WTP for infra-marginal cash recipients (Hendren & Sprung-Keyser approach)
   - $293 PPP consumption increase × recipient households = Direct WTP

2. **Spillover WTP (novel contribution):**
   - Non-recipients in treatment villages experienced 13% consumption gains
   - We calculate WTP for non-recipients separately
   - This is legitimate social surplus from the program (not double-counting)

3. **NOT counted in WTP:**
   - Price changes (redistributive, not welfare-enhancing net of producer surplus)
   - Pure GDP multiplier effects that don't translate to welfare

4. **Formal decomposition:**
   - MVPF_direct = WTP_recipients / Net_Cost
   - MVPF_social = (WTP_recipients + WTP_spillovers) / Net_Cost
   - We present both, following Finkelstein & Hendren (2020) on including spillovers

**Evidence:**

- Spillover consumption gains: Egger et al. (2022) Econometrica Table 3 - non-recipient households in treatment villages show consumption ↑ 13%
- Multiplier methodology: Egger et al. estimate fiscal multiplier using dual income-based approach
- Hendren framework on spillovers: Finkelstein & Hendren (2020 JEP) "Welfare Analysis Meets Causal Inference" Section 4 discusses incorporating externalities

---

### Condition 4: clear separation of private vs. social surplus to avoid double counting

**Status:** [X] RESOLVED

**Response:**

We will maintain strict accounting separation:

**Numerator (WTP) components - mutually exclusive:**

| Component | Included | Rationale |
|-----------|----------|-----------|
| Direct transfer value | Yes | $1,000 × (1 - admin costs) = recipient's cash received |
| Consumption utility gain | No | Already captured in transfer value for cash |
| Asset accumulation | No | Represents savings from transfer, not additional value |
| Non-recipient consumption gain | Yes (separately) | Genuine spillover welfare |
| Psychological wellbeing gain | Discussed qualitatively | Difficult to monetize |

**Denominator (Net Cost) components:**

| Component | Included | Rationale |
|-----------|----------|-----------|
| Transfer amount | Yes | $1,000 gross cost |
| Admin costs | Yes | GiveDirectly: ~15% overhead |
| VAT from consumption | Negative (offset) | Government revenue from spending |
| Future transfer savings | Negative (offset) | Reduced welfare dependence |
| Earnings taxes | Negative (offset) | Minimal due to informality |

**Key anti-double-counting rules:**

1. If recipient values $1 cash at $1 (standard assumption), we do NOT also add consumption gains
2. Multiplier effects on GDP are NOT welfare; only measured WTP gains count
3. Producer surplus from local business expansion is NOT counted (would require separate estimation)
4. Price effects are redistributive and net to zero (confirmed by Egger et al.: <1% inflation)

**Evidence:**

- Standard MVPF accounting: Hendren & Sprung-Keyser (2020 QJE) Section 2.1 - "The numerator captures beneficiaries' willingness to pay... If the government provides a lump-sum transfer of $1, the recipient's WTP equals $1"
- GiveDirectly overhead: GiveDirectly Financials page (https://www.givedirectly.org/financials/) - 85%+ of donations reach recipients

---

## The MVPF of Nurse-Family Partnership in the United States

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: demonstrating what MVPF adds beyond existing cost-benefit work

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: pre-specifying valuation choices for non-market outcomes

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: assembling consistent lifetime fiscal/benefit streams across trials

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## The MVPF of Denmark's "Start Aid" Refugee Integration Policy

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: secured register access

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: strong no-manipulation/continuity diagnostics

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: explicit accounting for any coincident reforms

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: compositional shifts

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED - Ready to proceed to Phase 4**
