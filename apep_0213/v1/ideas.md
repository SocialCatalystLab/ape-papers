# Research Ideas

## Idea 1: Anti-Cyberbullying Laws and Youth Mental Health: Modern Causal Evidence from Staggered State Adoption

**Policy:** State anti-cyberbullying / electronic harassment laws adopted in staggered fashion from 2006–2015. All 50 states eventually enacted laws requiring schools to address cyberbullying, but adoption timing varied by 8+ years. Key sources: Hinduja & Patchin (2016), NCSL State Bullying Laws database. Laws vary in strength—some mandate school policies only, others include criminal penalties for electronic harassment.

**Outcome:** Youth Risk Behavior Surveillance System (YRBSS), CDC Socrata API (dataset `svam-8dhg`). State × year panel, biennial 2003–2017. Key outcome variables:
- H24: Electronic bullying victimization (2011–2017, first-stage test)
- H26: Considered suicide (1991–2017, primary outcome)
- H28: Attempted suicide (1991–2017, primary outcome)
- H25: Sad or hopeless / depression proxy (1991–2017, mechanism)
- H23: Bullying at school (2009–2017, spillover test)

**Identification:** Staggered difference-in-differences using Callaway-Sant'Anna (2021) estimator. Treatment = year state adopted anti-cyberbullying law. Never-treated and not-yet-treated states form the comparison group. ~20+ treatment cohorts spanning 2006–2015.

**Why it's novel:**
- Nikolaou (2017, JHE) used YRBS + bivariate probit with cyberbullying laws as instruments. Our contribution: (1) heterogeneity-robust CS-DiD instead of bivariate probit, (2) event study evidence on dynamic treatment effects, (3) law heterogeneity analysis (criminal vs. school-policy-only), (4) randomization inference for exact p-values, (5) spillover tests to traditional bullying, (6) extended outcome set including depression.
- The question of whether legislation can counter the social media mental health crisis is among the most policy-relevant in current public discourse.

**Feasibility check:**
- ✅ YRBS API tested and returns state-level data (40+ states per wave)
- ✅ Electronic bullying question available 2011–2017 (4 waves, 64–72 observations each)
- ✅ Suicide consideration available 1991–2017 (14 waves, up to 74 observations each)
- ✅ Staggered adoption across 48 states provides clean DiD variation
- ✅ Pre-treatment periods: 5+ for suicide outcomes, 0–3 for cyberbullying (varies by cohort)

---

## Idea 2: Does Criminalizing Revenge Porn Protect Women? Staggered Adoption of Non-Consensual Intimate Image Laws

**Policy:** State criminalization of non-consensual intimate image (NCII) distribution ("revenge porn"). California first in 2013; by 2019, 46+ states had adopted. Staggered adoption 2013–2019 across nearly all states. Source: Ballotpedia, EPIC state law tracker.

**Outcome:** Two possible outcome sources:
- CDC WONDER mortality data: female suicide rates ages 15–34 (state × year, 1999–2022)
- FBI UCR/NIBRS: harassment, stalking, and intimidation offenses (state × year)

**Identification:** Staggered DiD (CS estimator). Treatment = year state criminalized NCII distribution. Never-treated states (those without NCII laws before 2019) as comparison.

**Why it's novel:**
- No existing causal study of NCII laws on any outcome
- Novel theory: NCII as tool of intimate partner coercion; criminalization removes weapon from abusers
- Directly relevant to recent federal TAKE IT DOWN Act (2025)

**Feasibility check:**
- ✅ Policy variation confirmed: 46+ states, staggered 2013–2019
- ⚠️ Specific adoption dates need compilation from individual state statutes
- ⚠️ CDC WONDER API has location restrictions — may need web interface download
- ⚠️ Power concern: NCII-attributable suicides are a small fraction of all female suicides
- ⚠️ FBI UCR data has NIBRS transition measurement issues (2013–2021)

---

## Idea 3: Anti-Cyberbullying Laws and School Discipline: Unintended Consequences of Zero-Tolerance Digital Policies

**Policy:** Same anti-cyberbullying laws as Idea 1.

**Outcome:** Civil Rights Data Collection (CRDC), U.S. Department of Education. School-level data on suspensions, expulsions, bullying-related disciplinary actions. Available biennially: 2009, 2011, 2013, 2015, 2017.

**Identification:** Staggered DiD. School-level panel with state treatment.

**Why it's novel:**
- Asks whether anti-cyberbullying laws increased school discipline (suspensions/expulsions) — a potential unintended consequence
- Most literature focuses on bullying reduction, not disciplinary spillovers
- Could reveal that laws shifted schools toward zero-tolerance approaches with disparate racial impacts

**Feasibility check:**
- ✅ CRDC data publicly available from Department of Education
- ⚠️ Biennial data limits pre/post periods
- ⚠️ School-level data requires aggregation to state-year
- ✅ Policy variation same as Idea 1 (well-documented)

---

## Idea 4: State Sexting Diversion Laws and Juvenile Justice: Does Decriminalization Reduce Collateral Consequences?

**Policy:** State teen sexting diversion laws. ~25 states created specific, lesser penalties for teen sexting (misdemeanor/education programs) instead of prosecuting under child pornography statutes. Staggered adoption ~2009–2020.

**Outcome:** OJJDP (Office of Juvenile Justice and Delinquency Prevention) data on juvenile arrests and adjudications for sex offenses. State × year panel.

**Identification:** Staggered DiD on juvenile sex-offense processing rates.

**Why it's novel:**
- Tests whether diversion from sex-offender registry reduces juvenile recidivism
- Policy-relevant as sexting prevalence has increased dramatically
- Limited causal evidence exists

**Feasibility check:**
- ⚠️ OJJDP data availability and API access needs verification
- ⚠️ Only ~25 treated states — borderline for DiD feasibility
- ⚠️ Treatment dates require compilation from individual state statutes
- ❌ Not yet validated — higher risk

---

## Idea 5: State Data Breach Notification Law Amendments and Identity Theft

**Policy:** State data breach notification law amendments/expansions. Original laws adopted 2003–2018 (all 50 states). Many states subsequently strengthened notification requirements (shorter timelines, broader definitions, AG notification). Second wave of amendments ~2015–2021.

**Outcome:** FTC Consumer Sentinel identity theft complaints by state × year. Or CFPB consumer complaint data.

**Identification:** Staggered DiD using amendment dates (not original adoption, since all states adopted).

**Why it's novel:**
- Tests whether STRENGTHENING breach notification (not just having it) reduces identity theft
- Romanosky et al. (2011) studied original adoption; no study of amendments

**Feasibility check:**
- ⚠️ FTC Consumer Sentinel data access needs verification (may require data agreement)
- ⚠️ Amendment dates need compilation
- ⚠️ May be too far from "social media" for the requested topic
