# Research Ideas

## Idea 1: Minimum Wage Increases and Teen Time Allocation: Direct and Spillover Effects

**Policy:** State minimum wage increases above the federal floor, staggered across states 2003-2023. Over 30 states have raised MW above $7.25, with substantial variation in timing and magnitude. Clean state×time variation for DiD identification.

**Data sources:**
- ATUS (American Time Use Survey) via IPUMS: Individual-level time diaries for ~10,000 respondents/year, 2003-2023. Includes state identifiers (STATEFIP), detailed activity codes (400+ categories), age, employment status, industry, household composition.
- DOL Historical Minimum Wage Database: State×year MW levels going back to 1968.

**Outcome variables:**
- Minutes per day in: work, job search, school attendance, homework, leisure/socializing, household chores, sleep
- Employment status (working vs. not working)
- School enrollment status

**Identification:** Difference-in-differences exploiting staggered state MW adoption. Treatment = state raises MW above federal floor. Compare teens in treated states (before/after) to teens in control states (never-treated or not-yet-treated). Use Callaway-Sant'Anna (2021) estimator to handle staggered adoption and heterogeneous treatment effects.

**Population of interest:**
1. **Direct effects:** Working teens (16-19) in MW-sensitive industries (retail, food service, leisure/hospitality)
2. **Spillover effects (novel):** Non-working teens in treated states. Hypothesis: MW increases tighten labor market → teens substitute toward schooling or face fewer job opportunities → changes in time allocation even without direct employment effect.

**Why it's novel:**
- Extensive literature on MW and teen *employment* (Neumark, Dube, Cengiz) but almost nothing on detailed *time use*.
- One 2023 paper (Raissian & Su, Review of Economics of the Household) studies MW effects on *parents'* time with children. No paper studies effects on *youth themselves*.
- The spillover to non-working teens is completely unstudied. This is a genuinely novel mechanism.

**Mechanisms to explore:**
1. Substitution from work to school (MW raises productivity bar → teens invest in human capital)
2. Displacement from work to leisure (MW reduces opportunities → involuntary non-work)
3. Household labor reallocation (if siblings get MW jobs, other teens may reduce household chores)
4. Social activities (peer effects if friends' employment status changes)

**Feasibility check:**
- ✓ ATUS available via IPUMS with state identifiers and detailed activity codes
- ✓ MW data available from DOL historical database
- ✓ 20+ years of data (2003-2023) with substantial policy variation
- ✓ ~25,000 teen observations in ATUS over period (rough estimate: 10k/year × 0.12 teen share × 20 years)
- ✓ Clean DiD identification with staggered adoption
- ✓ Not overstudied - this specific angle is genuinely new

**DiD Early Feasibility Screen:**
| Criterion | Assessment | Score |
|-----------|------------|-------|
| Pre-treatment periods | 2003-2013 for most states → ≥5 years | Strong |
| Selection into treatment | MW increases driven by politics, not teen time use trends | Strong |
| Comparison group | Never-treated states (federal MW only) + not-yet-treated | Strong |
| Treatment clusters | 30+ states raised MW | Strong |
| Concurrent policies | Some overlap with ACA (2014), need controls | Marginal |
| Outcome timing | Time use measured same period as treatment | Strong |
| Outcome-Policy Alignment | Time use directly captures behavior change | Strong |

---

## Idea 2: Minimum Wage and Teen School-Work Trade-offs by Family Income

**Policy:** Same as Idea 1.

**Data:** Same as Idea 1, but focus on heterogeneity by family income (available in ATUS via CPS link).

**Identification:** Same DiD design, with triple-diff by family income tercile.

**Hypothesis:** Low-income teens may respond to MW increases by reducing school time (opportunity cost of schooling rises with higher wages), while high-income teens may increase school time (MW jobs less attractive relative to human capital investment).

**Why it's novel:** Tests competing theoretical predictions about MW effects on human capital investment by income. Literature finds low-SES teens less likely to drop out when MW rises (Neumark & Wascher), but mechanism through time allocation is unstudied.

**Feasibility check:**
- ✓ Family income available via CPS link (FAMINC)
- ✓ Same data source and policy variation as Idea 1
- ⚠ Sample size concern: splitting by income tercile reduces power

---

## Idea 3: Minimum Wage Spillovers Within Households

**Policy:** Same as Idea 1.

**Data:** Same ATUS data, but exploit household structure. ATUS samples one person per household but collects employment status for all household members.

**Identification:** Within treated states, compare time use of teens whose siblings/parents work in MW-sensitive industries vs. those without such household members. This identifies spillover through household channels rather than aggregate labor market channels.

**Why it's novel:** Tests specific spillover mechanism (household labor reallocation) rather than just aggregate effects.

**Feasibility check:**
- ⚠ Limited power: only one time diary per household, so we observe teen's time use but not sibling's
- ⚠ Endogeneity: household members' industry choice may be endogenous
- May be better as a robustness check for Idea 1 rather than standalone paper
