# Research Ideas

Generated after exploration phase for assigned states: **Wyoming, New Hampshire, Alabama**

Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Wyoming Universal License Recognition - Effects on Licensed Worker In-Migration

**Policy:** Wyoming's SF 0018 (signed February 2021) requires state licensing boards to universally recognize occupational licenses obtained in other states. Workers who move to Wyoming with a valid out-of-state license can now practice immediately rather than repeating training or certification. Excludes attorneys and prescribers.

**Method:** DiD

**Research Question:** Did Wyoming's 2021 Universal License Recognition law increase in-migration of licensed workers relative to comparison states?

**Data:**
- Source: Census PUMS 2018-2023 (1-year files)
- Key variables: ST (state), MIG (migration status), MIGSP (migration state), OCCP (occupation), ESR (employment status), PWGTP (person weight), AGEP (age)
- Sample: Adults 18-64 in licensed occupations (cosmetology SOC 39-5012, barbers SOC 39-5011, real estate SOC 41-9022, and other licensed non-healthcare occupations)
- Sample size estimate: ~2,000-3,000 licensed workers in Wyoming per year; control states provide additional observations

**Hypotheses:**
- Primary: Wyoming will see increased in-migration of licensed workers post-2021 relative to control states
- Mechanism: Reduced relicensing costs (time, money, re-training) lower barriers to interstate mobility for licensed workers
- Heterogeneity: Effects should be strongest for occupations with higher training requirements (e.g., cosmetology at 1,600 hours) and for workers from states with different licensing standards

**Novelty:**
- Literature search: Found 1 rigorous NBER paper (Oh & Kleiner 2025, w34030) on universal license recognition, but it focuses exclusively on physicians/healthcare access. Goldwater Institute reports are descriptive (counting licenses issued), not causal estimates. One economics letter (ScienceDirect 2022) found ULR improves mobility in border counties.
- Gap: No causal study of ULR effects on non-healthcare licensed occupations (cosmetology, barbers, real estate, etc.)
- Contribution: First DiD estimates of ULR effects on migration for blue-collar/service licensed occupations using PUMS microdata

---

## Idea 2: Wyoming Universal License Recognition - Employment Effects for Resident Licensed Workers

**Policy:** Same as Idea 1 (SF 0018, February 2021). This idea focuses on labor market outcomes for licensed workers already in Wyoming.

**Method:** DiD

**Research Question:** Did Wyoming's Universal License Recognition law increase employment and labor force participation among licensed workers already residing in Wyoming?

**Data:**
- Source: Census PUMS 2018-2023 (1-year files)
- Key variables: ST, OCCP, ESR, WKHP (hours worked), WAGP (wages), PWGTP, POBP (birth state for long-term residents)
- Sample: Adults 18-64 residing in Wyoming in licensed occupations; compare to similar workers in control states
- Sample size estimate: ~15,000-20,000 per year in treatment + control groups

**Hypotheses:**
- Primary: ULR will increase labor force participation and employment rates among licensed workers in Wyoming
- Mechanism: Increased labor supply from in-migrants could increase competition but also increase demand for complementary workers; easier entry may also increase supply of licensed services overall
- Heterogeneity: Effects may differ by occupation depending on local labor market conditions and degree of previous licensing burden

**Novelty:**
- Literature search: NBER w34030 finds ULR increases healthcare utilization but no effect on physician interstate migration. No studies on employment effects for non-healthcare licensed workers.
- Gap: Unknown whether ULR affects incumbent workers' outcomes or only new entrants
- Contribution: First estimates of equilibrium employment effects of ULR on non-healthcare licensed workers

---

## Idea 3: Alabama Medicaid Non-Expansion - Effects on Health Insurance Coverage at the Eligibility Gap

**Policy:** Alabama has not expanded Medicaid under the ACA. Adults must earn less than 18% of FPL (~$4,650/year for family of 3) to qualify for Medicaid, compared to 138% FPL in expansion states. This creates a "coverage gap" for low-income adults above 18% FPL but below 100% FPL (ACA marketplace threshold).

**Method:** DiD

**Research Question:** How did Alabama's non-expansion of Medicaid affect health insurance coverage for low-income adults compared to similar Southern states that expanded?

**Data:**
- Source: Census PUMS 2012-2023 (spanning pre/post 2014 ACA implementation)
- Key variables: ST, HINS1-HINS7 (insurance types), HINSCAID (Medicaid), HICOV (any coverage), PINCP/POVPIP (income/poverty level), AGEP, PWGTP
- Sample: Adults 18-64 in Alabama (treatment) vs. expansion states (LA expanded 2016, KY expanded 2014) with income 0-138% FPL
- Sample size estimate: ~5,000-10,000 in coverage gap per year in AL; larger samples in control states

**Hypotheses:**
- Primary: Low-income adults in Alabama will have lower insurance coverage rates compared to similar adults in expansion states post-2014
- Mechanism: Adults in the coverage gap earn too much for Medicaid but too little for ACA subsidies, leaving them uninsured
- Heterogeneity: Effects concentrated among adults 100-138% FPL (those just above Medicaid threshold but eligible in expansion states)

**Novelty:**
- Literature search: Medicaid expansion has been extensively studied (100+ papers). Alabama specifically has been included in multi-state analyses but rarely as primary focus.
- Gap: Limited focus on Alabama specifically given its extremely low (18% FPL) pre-ACA Medicaid threshold for parents
- Contribution: Focused analysis on a state with extreme baseline eligibility restrictions; potential to compare to other non-expansion Southern states

---

## Idea 4: New Hampshire Paid Family and Medical Leave - Early Effects on Labor Force Participation

**Policy:** New Hampshire enacted a voluntary, state-sponsored paid family and medical leave program (HB2, June 2021) providing up to 60% wage replacement for 6 weeks. Coverage began January 2023 for state employees; private employers can opt in. First state with voluntary model.

**Method:** DiD

**Research Question:** Did New Hampshire's voluntary paid family leave program affect labor force participation, particularly among women of childbearing age?

**Data:**
- Source: Census PUMS 2020-2024 (once 2024 available)
- Key variables: ST, ESR, SEX, AGEP, FER (gave birth in past 12 months), PWGTP
- Sample: Women 20-44 in NH vs. neighboring states (VT, ME, MA) without new paid leave programs
- Sample size estimate: ~3,000-5,000 women in target age range per year in NH

**Hypotheses:**
- Primary: Limited or null effects expected due to voluntary nature and recent implementation
- Mechanism: Voluntary programs have low take-up; state employees may show effects but private sector effects likely small
- Heterogeneity: State employees vs. private sector; women with young children vs. without

**Novelty:**
- Literature search: California, NJ, NY mandatory programs studied extensively. No studies yet on NH's unique voluntary model (too recent).
- Gap: First voluntary state-sponsored paid leave program - unknown if voluntary model can achieve effects similar to mandatory
- Contribution: First evaluation of a voluntary state PFML model; policy-relevant for states considering non-mandate approaches

---

## Exploration Notes

**Search Strategy:**
- Received random state assignment: Wyoming, New Hampshire, Alabama
- Conducted domain-first searches (labor, licensing, health, education policy) in each state
- Verified policy details by fetching official sources (NCSL, state government sites)
- Checked NBER and Google Scholar for existing studies

**Ideas Considered and Rejected:**
1. **SNAP ABAWD Work Requirements (Age 49 RDD)**: Extensively studied - multiple NBER papers use this exact identification strategy (Pukelis et al., Census Bureau 2024). Not novel.
2. **Wyoming Property Tax Exemption at Age 65**: Age 65 is heavily polluted with other discontinuities (Medicare, Social Security). Hard to isolate property tax effect.
3. **Alabama Literacy Act (2019)**: Clean threshold (score 444) but educational outcomes poorly measured in PUMS.
4. **New Hampshire Minimum Wage**: No state minimum wage - defaults to federal $7.25. No policy variation to exploit.
5. **Alabama Prison Reform**: Criminal justice outcomes not measurable in PUMS.

**Why These 4 Ideas Rose to the Top:**
1. **Idea 1 (WY ULR Migration)** - Clear novelty gap (no studies on non-healthcare), clean DiD timing (Feb 2021), feasible with PUMS data
2. **Idea 2 (WY ULR Employment)** - Complementary to Idea 1, different outcome focus
3. **Idea 3 (AL Medicaid)** - Very well-studied topic BUT Alabama's extreme 18% FPL threshold is uniquely restrictive
4. **Idea 4 (NH PFML)** - Novel voluntary model but very recent implementation limits data availability

**Recommendation:** Ideas 1 and 2 on Wyoming's Universal License Recognition are most promising for novelty and feasibility. The non-healthcare angle differentiates from existing NBER work.
