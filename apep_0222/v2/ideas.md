# Research Ideas

## Idea 1: Educational Content Restriction ("Divisive Concepts") Laws and Teacher Labor Markets

**Policy:** State laws restricting instruction on race, gender, and "divisive concepts" in K-12 schools, adopted by 20+ states between 2021-2023. Key examples: Idaho HB 377 (July 2021), Oklahoma HB 1775 (May 2021), Tennessee SB 623 (May 2021), Texas HB 3979 (Sept 2021), Iowa (June 2021), New Hampshire HB 2 (Nov 2021), Florida HB 7 (July 2022), Georgia HB 1084 (April 2022), South Carolina budget proviso (June 2021), Arkansas SB 627 (2021).

**Outcome:** Census Quarterly Workforce Indicators (QWI) — state-quarter level employment, earnings, hires, separations, and turnover for NAICS 61 (Educational Services). Secondary: NAICS 62 (Healthcare) and 00 (All Industries) as control sectors.

**Identification:** Staggered DiD using Callaway-Sant'Anna (2021) estimator exploiting variation in adoption timing across 20+ states from 2021-2023. Triple-difference comparing education sector (treated) vs. healthcare (control) within the same state-quarter. Pre-treatment period: 2015-2020 (6 years = 24 quarters). Post-treatment: 2021-2024 (variable by cohort). Robustness via Synthetic DiD (Arkhangelsky et al. 2021), Goodman-Bacon decomposition, Rambachan-Roth honest confidence intervals.

**Why it's novel:** (1) No rigorous causal study of how classroom content restrictions affect teacher labor supply — the existing literature is qualitative surveys and anecdotes. (2) Triple-diff design (education vs. healthcare within state) provides unusually clean identification by differencing out state-level confounds like COVID recovery, remote work trends, and inflation. (3) Counter-intuitive potential: the laws may NOT cause net teacher attrition if most teachers weren't teaching "divisive" content anyway — or the effect may operate through COMPOSITION (who teaches) rather than QUANTITY (how many teach). (4) Tests the "regulatory chill" hypothesis from free speech law in a labor market context.

**Feasibility check:** CONFIRMED. QWI API returns data for NAICS 61 for all 51 state-equivalents, 2015-2024. Treatment coding from PEN America Index of Educational Gag Orders identifies 20+ states with enacted laws. Pre-treatment period (2015-2020) provides 24 quarters of data. Post-treatment data available through 2024.

## Idea 2: State Noncompete Agreement Bans and Business Dynamism

**Policy:** State laws banning or restricting noncompete agreements for workers. Colorado HB 22-1317 (Aug 2022, comprehensive ban), Minnesota SF 3079 (July 2023, comprehensive ban), Washington (Jan 2020), Illinois Freedom to Work Act (Jan 2022), Maine (Sept 2019), Maryland (Oct 2019), Massachusetts (Oct 2018), Nevada (Oct 2021), New Hampshire (Sept 2019), Virginia (July 2020), Rhode Island (Jan 2020), Oregon (Jan 2022 strengthening), DC (Oct 2022).

**Outcome:** Census QWI (state-quarter level hires, separations, job-to-job flows, firm job creation/destruction). Census Business Dynamics Statistics (BDS) for establishment births/deaths.

**Identification:** Staggered DiD with treatment intensity variation (full ban vs. low-wage worker only vs. narrower restrictions). CS estimator with state and quarter FE.

**Why it's novel:** While Starr et al. (2019) and others study noncompetes using cross-sectional variation, the 2018-2023 wave of state bans provides a modern staggered DiD opportunity with clean policy changes. Novel angle: distinguish between "ban for all" states vs. "ban for low-wage only" as treatment intensity.

**Feasibility check:** PARTIALLY CONFIRMED. QWI data available. ~13-15 states with enacted bans (below 20 threshold). California, Oklahoma, and North Dakota have always banned noncompetes (always-treated, excluded from DiD). Treatment group may be borderline small.

## Idea 3: State Anti-ESG Legislation and Public Sector Financial Outcomes

**Policy:** State laws restricting ESG (Environmental, Social, Governance) criteria in state investments and government contracting. Texas SB 13 (Sept 2021), West Virginia (March 2022), Kentucky (April 2022), Oklahoma (May 2022), Florida SB 302 (May 2023), plus 15+ states in 2022-2023.

**Outcome:** NAICS 52 (Finance and Insurance) employment/earnings from QWI. FRED state-level financial indicators. Census Annual Survey of State and Local Government Finances (interest expenditures).

**Identification:** Staggered DiD with 20+ treated states, primarily adopted 2022-2023.

**Why it's novel:** Only one study (Garrett & Ivanov 2023) examined fiscal costs in Texas alone. Multi-state DiD with financial sector labor market outcomes would be a significant extension.

**Feasibility check:** PARTIALLY CONFIRMED. QWI data available for NAICS 52. Treatment coding requires careful legal research — the scope and stringency of anti-ESG laws vary substantially. State government finance data has 2-3 year publication lag, limiting post-treatment outcomes. 20+ states adopted but most in 2022-2023, giving limited post-treatment data.
