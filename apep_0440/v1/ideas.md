# Research Ideas

## Idea 1: Unlocking Better Jobs? Medicare Eligibility at 65 and Late-Career Underemployment

**Policy:** Medicare eligibility at age 65. Universal health insurance coverage eliminates dependence on employer-sponsored insurance, creating a sharp discontinuity in outside options for older workers.

**Outcome:** Underemployment measured three ways using ACS PUMS: (1) involuntary part-time work (works <35 hours but wants full-time), (2) overqualification (college degree holders working in occupations requiring less education, classified using O*NET Job Zone data), (3) occupational downgrading (working in occupation with lower median earnings than prior career trajectory would predict).

**Identification:** Sharp RDD at age 65. Running variable is age in integer years (Lee & Card 2008 framework for discrete running variables). ACS PUMS pooled 2014-2023 provides ~500,000 observations per age-year, giving massive statistical power even with coarse age measurement. McCrary density test not needed since age is non-manipulable. Cluster standard errors at age level.

**Why it's novel:** The entire Medicare-at-65 RDD literature studies the EXTENSIVE margin — whether people retire. Slavov (IZA DP 7785) found no job mobility effect; Card/Dobkin/Maestas study health outcomes. Nobody has studied the QUALITY of employment for those who remain working. The GAO (GAO-12-166R) explicitly identifies the mechanism — insurance lock "makes it harder to match workers to the most suitable jobs" — but no researcher has tested it causally. This paper fills that gap by studying how Medicare eligibility affects overqualification, involuntary part-time work, and occupational match quality among the ~60% of 65-year-olds who continue working.

**Feasibility check:** ACS PUMS confirmed accessible via tidycensus::get_pums() (download in progress). O*NET API confirmed available (key configured). Age variable (AGEP) available in integer years. Employment status (ESR), hours (WKHP), education (SCHL), occupation (OCCP) all available. Sample size: ~1.5M workers aged 55-75 across 10 years of ACS. No APEP papers on this specific topic.

---

## Idea 2: The Gainful Employment Cliff: Do Accountability Thresholds Reduce Credential Waste at For-Profit Colleges?

**Policy:** The Gainful Employment (GE) rule, reinstated 2023. Programs where graduates' annual debt payments exceed 8% of annual earnings (or 20% of discretionary earnings) face loss of federal student aid eligibility. First metrics published early 2025.

**Outcome:** Post-completion earnings relative to credential level as a measure of credential underutilization. Programs just above vs. below the GE threshold may differentially improve placement, alter curricula, or close — all affecting graduate underemployment. Measured via College Scorecard program-level earnings data.

**Identification:** Sharp RDD at the GE debt-to-earnings threshold. Running variable is the program-level D/E ratio. Programs just below 8% (pass) vs. just above (fail → face sanctions) provide a clean comparison. Use multiple years of Scorecard data to study how programs that were close to the margin in early cohorts changed outcomes for later cohorts.

**Why it's novel:** No published paper exploits the GE thresholds as an RDD (the literature search confirmed this gap). Cellini & Koedel studied enrollment effects; Deming, Goldin & Katz studied earnings. But nobody has examined whether GE accountability specifically reduces CREDENTIAL MISMATCH — the phenomenon where graduates work in jobs that don't require their credential. Career stage angle: compares short-term certificates (career changers) vs. associate's programs (early career).

**Feasibility check:** College Scorecard API confirmed available (SCORECARD key configured). Program-level fields include median debt, median earnings at 1 and 4 years, completion rates, by CIP code and credential level. Can compute D/E ratio. ~1,700 programs projected to fail at least one metric (large sample near threshold). Concern: D/E ratio denominator is partially the outcome (earnings). Must use LAGGED D/E from initial assessment to predict SUBSEQUENT cohort outcomes.

---

## Idea 3: From Constraint to Choice: Social Security Early Eligibility at 62 and the Voluntary Part-Time Transition

**Policy:** Social Security early retirement benefits at age 62. Workers become eligible for reduced SS benefits (70-75% of full benefit depending on birth cohort), creating a sharp income floor that changes the value of continued full-time employment.

**Outcome:** Transition from involuntary to voluntary part-time work. ACS PUMS distinguishes workers who want full-time work but can only find part-time (involuntary) from those who choose part-time (voluntary). This paper tests whether the SS income floor enables workers stuck in involuntary underemployment to either (a) exit to voluntary part-time in better-matched work, or (b) exit the labor force entirely.

**Identification:** Sharp RDD at age 62. Same framework as Idea 1 (ACS PUMS, integer-year age, Lee & Card 2008). The two thresholds (62 and 65) provide built-in replication: age 62 tests the INCOME channel (SS income floor) while age 65 tests the INSURANCE channel (Medicare). Comparing effect sizes across thresholds identifies which constraint — financial or insurance — is the bigger driver of late-career underemployment.

**Why it's novel:** Deshpande, Fadlon & Gray study retirement at 62; Gelber, Jones & Sacks study earnings test bunching. Nobody studies the involuntary-to-voluntary part-time transition. Novel contribution: distinguishing between workers who are underemployed because they MUST work full-time (insurance lock) vs. because they CANNOT find adequate hours (demand-side underemployment).

**Feasibility check:** Same data as Idea 1 (ACS PUMS). Key variable: WKHP (hours worked) combined with reason for part-time work. ACS has "usual hours worked" but may lack explicit involuntary/voluntary PT indicator — need to verify. CPS ASEC has this variable but is smaller sample. If ACS lacks it, fall back to CPS or construct proxy from hours + wanting full-time work indicators.

---

## Idea 4: Combined Design — Social Insurance Thresholds and the Quality of Late-Career Employment (RECOMMENDED)

**This is Ideas 1 + 3 combined into a single paper with two discontinuities.**

**Policy:** Two social insurance eligibility thresholds: SS at 62 (income support) and Medicare at 65 (health insurance). Each relaxes a different constraint that may trap older workers in suboptimal employment.

**Outcome:** Composite underemployment index combining: (1) involuntary part-time status, (2) overqualification (education-occupation mismatch via O*NET Job Zones), (3) occupational earnings gap (actual occupation vs. modal occupation for education level). Decompose effects by constraint type and worker characteristics.

**Identification:** Dual RDD exploiting both age thresholds in the same ACS PUMS sample. The two-threshold design provides:
- Built-in replication (effect should be positive at both cutoffs if underemployment story holds)
- Mechanism decomposition (SS=income, Medicare=insurance → relative magnitudes reveal binding constraint)
- Heterogeneity by health insurance source (workers with employer insurance should respond more at 65; workers without should respond more at 62)

**Why it's novel:** First paper to use DUAL age-based RDDs to study employment quality. First paper to study underemployment at either threshold. First paper to decompose income vs. insurance channels in late-career job match quality. Contributes to both the job-lock literature and the underemployment literature with a clean causal design.

**Feasibility check:** All data confirmed accessible. ACS PUMS via tidycensus (download tested). O*NET via API (key confirmed). Sample: ~1.5M workers aged 55-75. Key variables: AGEP, SCHL, OCCP, WKHP, ESR, HINS1-HINS2 (insurance type), PINCP (income). Two clear thresholds with massive power. No close substitutes in APEP or published literature.

**Risk:** Integer-year age creates a coarse running variable. Mitigation: (a) massive sample makes narrow bandwidths feasible, (b) Lee & Card (2008) methodology handles discrete running variables, (c) can use donut RDD excluding exact threshold age.
