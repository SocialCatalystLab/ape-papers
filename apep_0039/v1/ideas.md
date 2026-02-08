# Research Ideas - Paper 56

## Idea 1: Heat Illness Prevention Standards and Outdoor Worker Safety

**Policy:** State heat illness prevention standards for outdoor workers
- California: 2005 (outdoor), July 2024 (indoor)
- Minnesota: 1997 (indoor only)
- Oregon: June 2022 (indoor and outdoor)
- Colorado: 2022 (agriculture)
- Washington: 2023 (outdoor)
- Maryland: September 2024

**Outcome:** Workplace injuries/illnesses and employment in heat-exposed industries
- Data: BLS Survey of Occupational Injuries and Illnesses (SOII), state-industry-year
- Alternative: CDC WONDER heat-related mortality, workers' compensation claims

**Identification:** DiD comparing states that adopted heat standards to never-treated states, exploiting staggered timing (2005, 2022, 2023, 2024)

**Why it's novel:**
- No rigorous causal study of state heat standards on worker safety exists
- OSHA proposed federal rule in 2024 makes this policy-relevant
- Clean staggered adoption with recent variation
- Climate change increasing policy salience

**Feasibility check:**
- Variation: Clear state × year variation with 6 treated states vs ~44 controls
- Data: SOII publicly available at state-industry-year level
- Not overstudied: Zero papers in APEP database, limited academic research

---

## Idea 2: CROWN Act and Black Employment Outcomes

**Policy:** CROWN Act (Creating a Respectful and Open World for Natural Hair) - prohibits hair discrimination
- California: July 2019 (first)
- New York: July 2019
- New Jersey: December 2019
- 27 states adopted by 2024

**Outcome:** Employment and wages for Black workers
- Data: CPS microdata (employed, wages, occupation) by race and state
- Alternative: EEOC discrimination charges

**Identification:** DiD comparing states adopting CROWN Act to non-adopting states, with race × treatment interaction

**Why it's novel:**
- First causal study of anti-hair discrimination laws on labor market outcomes
- Growing policy momentum (federal CROWN Act passed House but not Senate)
- Clear staggered adoption 2019-2024

**Feasibility check:**
- Variation: 27 treated states, 23 never-treated as of 2024
- Data: CPS microdata available via IPUMS (API key confirmed)
- Not overstudied: No papers in APEP database, limited academic research

---

## Idea 3: State Auto-IRA Mandates and Retirement Savings

**Policy:** State-mandated automatic IRA enrollment for employers without retirement plans
- Oregon: 2017 (first mandate, phased by employer size)
- Illinois: 2018
- California: 2019
- Connecticut: 2020
- Maryland: 2022
- Virginia, Colorado: 2023
- New Jersey, Vermont: 2024

**Outcome:** Retirement savings participation and employer plan offerings
- Data: CPS ASEC supplements (pension coverage), ACS (retirement income)
- Alternative: State program administrative data, SIPP

**Identification:** DiD exploiting staggered state mandate adoption

**Why it's novel:**
- Some prior research on employer plan adoption (BC study), but effects on worker savings less studied
- Employment effects of mandates not studied
- Clean staggered rollout 2017-2024

**Feasibility check:**
- Variation: ~13 states with mandates vs ~37 without
- Data: CPS ASEC available via IPUMS
- Prior research exists but gaps remain (worker outcomes, employment effects)

---

## Idea 4: Captive Audience Meeting Bans and Union Organizing

**Policy:** Laws prohibiting mandatory employer meetings about unionization
- Oregon: July 2010 (first)
- Maine: 2023
- Minnesota: 2023
- Connecticut: 2023
- Vermont: 2024
- New York: 2024
- Washington: 2024

**Outcome:** Union election outcomes, organizing activity, employment
- Data: NLRB election data (petitions, wins), BLS union membership (CPS)

**Identification:** DiD comparing states banning captive audience meetings to control states

**Why it's novel:**
- Highly policy-relevant given renewed union organizing (Amazon, Starbucks)
- Recent wave of adoptions 2023-2024
- No causal studies exist

**Feasibility check:**
- Variation: 7 states with bans, 43+ controls
- Data: NLRB election data public; CPS union membership via IPUMS
- Very novel but limited pre-period for recent adopters

---

## Ranking and Recommendation

| Idea | Novelty | Data Quality | Identification | Policy Relevance | Recommended |
|------|---------|--------------|----------------|------------------|-------------|
| 1. Heat Standards | Very High | Good (SOII) | Strong | Very High | **YES** |
| 2. CROWN Act | High | Good (CPS) | Strong | High | YES |
| 3. Auto-IRA | Medium | Good (CPS) | Strong | High | Maybe |
| 4. Captive Audience | Very High | Good (NLRB) | Weak (short pre) | Very High | Maybe |

**Primary Recommendation: Idea 1 (Heat Illness Prevention Standards)**

Rationale:
- Most novel topic with zero existing causal research
- Clean staggered adoption (2005, 2022, 2023, 2024)
- OSHA federal rulemaking makes this immediately policy-relevant
- Worker safety is understudied in economics relative to wages/employment
- Data readily available at state-industry level
