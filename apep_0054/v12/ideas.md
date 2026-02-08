# Research Ideas

Generated: 2026-01-21

---

## Idea 1: State Automatic IRA Mandates and Retirement Savings Participation

**Policy:** State-mandated automatic IRA programs requiring employers without retirement plans to enroll employees in state-facilitated retirement savings accounts.

**Adoption Timeline:**
| State | Program Launch | Full Mandate Effective |
|-------|---------------|----------------------|
| Oregon | July 2017 | July 2023 (all employers) |
| Illinois | November 2018 | November 2023 (all employers) |
| California | July 2019 | December 2025 (1+ employees) |
| Connecticut | March 2021 | April 2022 |
| Maryland | September 2022 | 2024 (phased) |
| Colorado | March 2023 | 2025 (phased) |
| Virginia | July 2023 | 2025 (phased) |
| Maine | 2024 | 2025 |
| Delaware | 2024 | 2025 |
| New Jersey | 2024 | 2026 |

**Outcome:** Retirement savings plan participation rates among private-sector workers

**Data Source:** Current Population Survey Annual Social and Economic Supplement (CPS ASEC), which includes questions on retirement plan coverage and participation. IPUMS-CPS provides individual-level microdata from 2000-present.

**Identification Strategy:** Difference-in-differences exploiting staggered adoption of state auto-IRA mandates across states. Compare retirement plan participation for workers in states that adopted mandates vs. states without mandates, before and after policy implementation.

**Why Novel:** Most existing research on auto-enrollment focuses on 401(k) plans within firms. The labor market and savings effects of mandatory state-facilitated IRA programs for workers at small employers without existing plans is understudied. This fills a gap as the first wave of state programs (OR, IL, CA, CT) now have sufficient post-treatment data.

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | CPS ASEC available 2000-present; first treatment (OR) in 2017 gives 17+ pre-periods | **Strong** |
| **Selection into treatment** | Political/legislative process; states with low employer-sponsored coverage more likely to adopt, but not responding to immediate retirement savings trends | **Marginal** |
| **Comparison group quality** | ~35 states without mandates, demographically diverse; some may be considering legislation | **Strong** |
| **Treatment clusters** | 11 treated states by 2024, with more coming; ~40+ never-treated | **Strong** |
| **Concurrent policies** | SECURE Act 2019 (federal) expanded retirement credits but applies uniformly; state tax incentives vary | **Marginal** |

**Feasibility Check:**
- Data accessible via IPUMS-CPS (API key available)
- Geographic variation confirmed across diverse states
- Outcome measure directly available in CPS ASEC (PENSION variable)
- Not in APEP avoid list

---

## Idea 2: State Paid Family Leave and Self-Employment Entry

**Policy:** State-mandated paid family and medical leave insurance programs providing wage replacement during leave.

**Adoption Timeline:**
| State | Benefits Began |
|-------|---------------|
| California | July 2004 |
| New Jersey | July 2009 |
| Rhode Island | January 2014 |
| New York | January 2018 |
| Washington | January 2020 |
| Massachusetts | January 2021 |
| Connecticut | January 2022 |
| Oregon | September 2023 |
| Colorado | January 2024 |

**Outcome:** Self-employment entry rates, particularly among workers of childbearing age

**Data Source:** CPS microdata (IPUMS-CPS) provides monthly self-employment status. Can identify transitions from wage employment to self-employment.

**Identification Strategy:** Difference-in-differences comparing self-employment transitions in states with vs. without PFL, before and after policy implementation. Focus on workers 25-45 (childbearing age) who may value the insurance provided by PFL for entrepreneurial risk-taking.

**Why Novel:** Existing PFL literature focuses on labor force participation, wages, and leave-taking. The entrepreneurship channel—that PFL provides insurance enabling risk-taking—is theoretically motivated but empirically unexplored. If PFL makes self-employment less risky (through continued benefit access), it could increase business formation.

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | First treatment (CA) in 2004; CPS available from 1976; extensive pre-period | **Strong** |
| **Selection into treatment** | States with strong labor movements/progressive politics adopted; not responding to self-employment trends | **Strong** |
| **Comparison group quality** | ~40 states without PFL; can match on demographics and industry mix | **Strong** |
| **Treatment clusters** | 9 treated states as of 2024, ~40 never-treated | **Marginal** (9 treated is borderline) |
| **Concurrent policies** | ACA (2014) affected self-employment through insurance; minimum wage increases vary; need controls | **Marginal** |

**Feasibility Check:**
- IPUMS-CPS data accessible
- Self-employment status clearly identified (CLASS OF WORKER variable)
- Long pre-period allows robust parallel trends testing
- APEP studied paid *sick* leave (paper 2), not paid family leave—distinct policy

---

## Idea 3: State Data Privacy Laws and Tech Sector Employment

**Policy:** Comprehensive state consumer data privacy laws modeled on CCPA/GDPR, requiring businesses to provide consumer rights over personal data.

**Adoption Timeline:**
| State | Effective Date |
|-------|---------------|
| California (CCPA) | January 1, 2020 |
| Virginia (VCDPA) | January 1, 2023 |
| Colorado (CPA) | July 1, 2023 |
| Connecticut (CTDPA) | July 1, 2023 |
| Utah (UCPA) | December 31, 2023 |
| Texas (TDPSA) | July 1, 2024 |
| Oregon (OCPA) | July 1, 2024 |
| Montana (MCDPA) | October 1, 2024 |

**Outcome:** Employment in data-intensive industries, particularly tech sector and digital marketing

**Data Source:** Quarterly Census of Employment and Wages (QCEW) from BLS provides county-level employment by detailed industry (NAICS). Can identify tech/data-intensive sectors.

**Identification Strategy:** Difference-in-differences using staggered adoption of privacy laws. Compare employment growth in data-intensive industries (NAICS 518 Data Processing, 5415 Computer Systems Design, 5416 Management/Scientific Consulting) across states with and without privacy laws.

**Why Novel:** Most privacy law research focuses on consumer outcomes (data breaches, privacy attitudes). The labor market effects—compliance costs potentially reducing employment vs. new privacy-tech jobs—is understudied.

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | QCEW available quarterly from 1990; CA law effective 2020 gives only ~3 years pre if starting from 2017 | **Marginal** |
| **Selection into treatment** | Large/tech-heavy states adopted first (CA); adoption may correlate with existing tech concentration | **Weak** |
| **Comparison group quality** | Most states lack privacy laws; but tech employment concentrated in treated states | **Marginal** |
| **Treatment clusters** | 8 states by end 2024, more coming in 2025; limited treatment variation so far | **Marginal** |
| **Concurrent policies** | COVID-19 (2020) dramatically affected tech employment; remote work shifts | **Weak** |

**Feasibility Check:**
- QCEW data publicly accessible
- Industry-level detail available
- However, CA effective date (2020) coincides with COVID → severe confounding concern
- Limited pre-treatment period for California specifically

**CONCERN:** COVID-19 confounding is severe for this design. California's law took effect January 2020, making pre-trends difficult to interpret.

---

## Idea 4: State Surprise Billing Laws and Personal Bankruptcy Filings

**Policy:** State laws protecting consumers from surprise out-of-network medical bills, implemented before the federal No Surprises Act (January 2022).

**Adoption Timeline (Comprehensive Laws):**
| State | Effective Date |
|-------|---------------|
| New York | March 2015 |
| Connecticut | January 2016 |
| Florida | July 2016 |
| California | July 2017 |
| Maryland | January 2018 |
| New Jersey | August 2018 |
| Colorado | January 2020 |
| Texas | January 2020 |
| Ohio | January 2021 |

**Outcome:** Personal bankruptcy filings, specifically those with medical debt as a contributing factor

**Data Source:** Administrative Office of US Courts provides bankruptcy filing data by district. Survey of Income and Program Participation (SIPP) includes medical debt questions.

**Identification Strategy:** Difference-in-differences comparing bankruptcy filing rates in states that adopted surprise billing laws vs. states without such laws, before the federal NSA took effect in 2022.

**Why Novel:** Most surprise billing research examines prices and billing amounts. The downstream financial distress effects—whether banning surprise bills reduces bankruptcies—connects healthcare policy to household financial health literature.

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | NY law in 2015; bankruptcy data available continuously; 10+ years pre-period | **Strong** |
| **Selection into treatment** | States with high insurance market concerns adopted; may correlate with healthcare cost trends | **Marginal** |
| **Comparison group quality** | ~20 states without comprehensive laws before 2022; federal law in 2022 ends experiment | **Strong** |
| **Treatment clusters** | ~18 states with comprehensive laws by 2021; good variation | **Strong** |
| **Concurrent policies** | ACA Medicaid expansion (2014+), short-term health plan regulations vary | **Marginal** |

**Feasibility Check:**
- Bankruptcy data publicly available
- State-level variation sufficient
- Federal law in January 2022 creates natural endpoint
- Post-period ends 2022 for clean identification

---

## Idea 5: Certificate of Need Repeal and Hospital Market Entry

**Policy:** Repeal of Certificate of Need (CON) laws that restrict new hospital/facility construction.

**Recent Repeal Timeline:**
| State | CON Repeal Date |
|-------|----------------|
| Indiana | 1999 (full by 2019) |
| New Hampshire | 2016 |
| Montana | 2021 |
| Florida | 2019 (partial) |
| South Carolina | 2023 |
| North Carolina | 2023-2025 (phased) |

**Historical Repeals (1980s-1990s):**
Arizona (1985), California (1987), Colorado (1987), Idaho (1983), Kansas, Minnesota, New Mexico, North Dakota, Pennsylvania, South Dakota, Texas, Utah

**Outcome:** Hospital market entry, facility expansion, healthcare employment

**Data Source:** American Hospital Association (AHA) Annual Survey provides hospital counts, beds, services. CMS Provider of Services file is free alternative.

**Identification Strategy:** Difference-in-differences comparing hospital market outcomes in states that repealed CON vs. states that maintained CON laws.

**Why Novel:** Recent CON repeals (NH 2016, MT 2021, FL 2019, SC 2023) provide fresh variation for modern analysis. Most CON research uses older 1980s-90s repeals. New repeals allow studying effects in contemporary healthcare markets.

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | NH repeal 2016, MT 2021, FL 2019—can use hospital data from 2010+ | **Strong** |
| **Selection into treatment** | States with rural hospital concerns and conservative legislatures repealed; political | **Marginal** |
| **Comparison group quality** | 35 states maintain CON laws; good comparison pool | **Strong** |
| **Treatment clusters** | Only 3-4 recent repeals with post-data; historical repeals are old | **Weak** |
| **Concurrent policies** | Medicaid expansion, hospital closure trends vary | **Marginal** |

**Feasibility Check:**
- AHA data requires subscription; CMS data is free
- Limited recent treatment variation (NH 2016, FL 2019, MT 2021)
- Historical repeals (1980s-90s) have very long post-periods but may not be relevant to modern markets

**CONCERN:** Only 3-4 recent repeals with sufficient post-period data. May not have enough treatment clusters for reliable inference.

---

## Summary and Recommendation

| Idea | Policy | DiD Feasibility | Data Access | Novelty | Recommend |
|------|--------|-----------------|-------------|---------|-----------|
| 1 | Auto-IRA Mandates | Strong | CPS ASEC via IPUMS | High | **PURSUE** |
| 2 | PFL & Self-Employment | Strong | CPS via IPUMS | Medium-High | **CONSIDER** |
| 3 | Data Privacy & Tech Employment | Weak (COVID confound) | QCEW (public) | Medium | SKIP |
| 4 | Surprise Billing & Bankruptcy | Strong | Courts data (public) | Medium | CONSIDER |
| 5 | CON Repeal | Weak (few clusters) | AHA/CMS | Medium | SKIP |

**Primary Recommendation:** Idea 1 (State Automatic IRA Mandates) offers the strongest combination of novel policy, clean identification, and data availability. The first wave of state programs (OR 2017, IL 2018, CA 2019, CT 2021) now have 3-7 years of post-treatment data, enabling credible DiD analysis of effects on retirement savings participation.

**Secondary Recommendation:** Idea 2 (PFL & Self-Employment) is also strong but has been more adjacent to existing PFL literature. The self-employment angle is novel but may require careful framing to distinguish from existing work.
