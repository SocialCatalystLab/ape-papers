# Research Ideas — Paper 37

**Domain:** Criminal Justice  
**Geographic Focus:** Iowa, Florida, Colorado  
**Created:** 2026-01-18

---

## Idea 1: The Price of the Franchise — Florida's Fines and Fees Barrier to Re-enfranchisement

### Policy Background
Florida Amendment 4 (November 2018, effective January 8, 2019) restored voting rights to ~1.4 million people with felony convictions—the largest expansion of voting rights in the U.S. since the Voting Rights Act. However, SB 7066 (June 28, 2019) required full payment of all court-ordered fines, fees, and restitution before voting eligibility. An estimated 730,000 Floridians remain disenfranchised due to unpaid financial obligations.

### Research Question
Does the fines/fees requirement under SB 7066 create a wealth-based barrier to voting that disproportionately disenfranchises low-income individuals with felony convictions?

### Identification Strategy
**Method:** Regression Discontinuity Design  
- Exploit the threshold of "fines/fees fully paid" vs. "fines/fees outstanding"
- Compare voter registration and turnout rates for individuals just above vs. below the payment threshold
- Alternative: DiD comparing Florida registration/turnout trends pre/post SB 7066 (June 2019) among eligible population

### Data Sources
- **Florida Division of Elections voter files** (public records, updated monthly)
- **Court records on fines/fees** (may require FOIA)
- **Census PUMS** for demographic controls by county

### Feasibility Assessment
| Criterion | Rating | Notes |
|-----------|--------|-------|
| Policy variation | ★★★★★ | Clear date (June 2019), clear threshold |
| Data availability | ★★★☆☆ | Voter files public; fines data requires work |
| Parallel trends | ★★★★☆ | Can compare to other states |
| Novelty | ★★★☆☆ | Some academic attention, but specific fines RDD is novel |
| Avoids top10 mistakes | ★★★★☆ | Individual-level data avoids aggregation mismatch |

### Concerns
- Fines/fees threshold is individual-specific and may not be publicly available
- Need to link voter files to court records
- Complex eligibility rules (murder/sex offenses excluded)

---

## Idea 2: Decriminalize, Then Recriminalize — Colorado's Fentanyl Policy Reversal

### Policy Background
Colorado HB 19-1263 (2019) reduced possession of <4 grams of most controlled substances, including fentanyl, from a felony to a misdemeanor. Following a surge in fentanyl deaths (520 in 2020 → 803 in 2021), HB 22-1326 (May 2022) re-criminalized possession of >1 gram of fentanyl as a felony. This creates a rare natural experiment of decriminalization followed by partial recriminalization.

### Research Question
Did Colorado's 2019 fentanyl decriminalization increase overdose deaths, and did the 2022 recriminalization reverse this trend?

### Identification Strategy
**Method:** Difference-in-Differences with Event Study  
- Compare Colorado to synthetic control states (similar demographics, drug markets, but no policy change)
- Pre-period: 2016-2018 (pre-decriminalization)
- Treatment 1: 2019 (decriminalization)
- Treatment 2: May 2022 (recriminalization)
- Post-period: 2023-2024

### Data Sources
- **CDPHE State Unintentional Drug Overdose Reporting System (SUDORS)** — county-level overdose deaths 2015-2024
- **CDC WONDER** — mortality data for synthetic control construction
- **Colorado Division of Criminal Justice** — jail population, arrests by charge type

### Feasibility Assessment
| Criterion | Rating | Notes |
|-----------|--------|-------|
| Policy variation | ★★★★★ | Unique reversal creates two policy shocks |
| Data availability | ★★★★★ | CDPHE has excellent public dashboards |
| Parallel trends | ★★★☆☆ | COVID confounds 2020-2021 |
| Novelty | ★★★★★ | First study of policy reversal |
| Avoids top10 mistakes | ★★★☆☆ | ~64 counties; need to check cluster count |

### Concerns
- COVID-19 pandemic confounds the entire treatment period
- Difficult to separate policy effect from supply-side changes (fentanyl flooding the market nationally)
- Parallel trends may be violated due to different states' drug markets

---

## Idea 3: The 48-Hour Rule — Colorado's Bond Hearing Mandate

### Policy Background
Colorado HB 21-1280 (2021) requires bond hearings within 48 hours of arrest. Prior to this, individuals could languish in jail for days without a hearing. The law aimed to reduce pretrial detention for low-risk individuals.

### Research Question
Did Colorado's 48-hour bond hearing mandate reduce pretrial detention length and jail populations without increasing failure-to-appear rates?

### Identification Strategy
**Method:** Difference-in-Differences  
- Compare Colorado to neighboring states (Wyoming, Nebraska, Kansas, Utah, New Mexico) without the mandate
- Pre-period: 2018-2020
- Post-period: 2022-2024

### Data Sources
- **Colorado Division of Criminal Justice** — quarterly jail population data (HB 19-1297 mandates reporting)
- **Court Administrative Office of the Courts** — may have FTA data
- **Census PUMS** — demographic controls

### Feasibility Assessment
| Criterion | Rating | Notes |
|-----------|--------|-------|
| Policy variation | ★★★★☆ | Clear date, statewide mandate |
| Data availability | ★★★★☆ | Jail population data is quarterly and public |
| Parallel trends | ★★★☆☆ | COVID confounds; jail populations fell everywhere |
| Novelty | ★★★★☆ | Bond reform is hot topic; specific 48-hour rule less studied |
| Avoids top10 mistakes | ★★★☆☆ | Limited clusters (Colorado vs. 5-6 comparison states) |

### Concerns
- COVID-19 caused massive jail population declines everywhere—hard to isolate policy effect
- Only 6-7 units for DiD (Colorado + comparison states)—may be underpowered

---

## Idea 4: Automatic Expungement — Colorado's Clean Slate Law

### Policy Background
Colorado's automatic record sealing law requires the state court administrator to compile a list of eligible drug convictions by February 1, 2024, with records sealed by July 1, 2024. This removes barriers to employment and housing for individuals with old, minor convictions.

### Research Question
Does automatic record sealing improve employment outcomes for individuals with sealed drug convictions?

### Identification Strategy
**Method:** Regression Discontinuity Design  
- Exploit eligibility cutoffs: 7 years for misdemeanors, 10 years for felonies
- Compare employment outcomes for individuals just above vs. below the time threshold

### Data Sources
- **Census PUMS / ACS** — employment status by state
- **Colorado court records** — may track sealed records counts
- **BLS LAUS** — unemployment rates

### Feasibility Assessment
| Criterion | Rating | Notes |
|-----------|--------|-------|
| Policy variation | ★★★★☆ | Clear cutoffs (7 years, 10 years) |
| Data availability | ★★☆☆☆ | Cannot identify sealed individuals in Census |
| Parallel trends | N/A | RDD doesn't require parallel trends |
| Novelty | ★★★★☆ | Clean slate laws are new; limited research |
| Avoids top10 mistakes | ★★☆☆☆ | Can't observe who has sealed records |

### Concerns
- **Critical flaw:** Cannot identify individuals with sealed records in public data
- Would need court administrative data showing who was sealed
- Policy is very recent (July 2024)—insufficient post-period

---

## Idea 5: Iowa's Last Stand — The Final State to End Permanent Disenfranchisement

### Policy Background
Iowa was the last U.S. state to permanently disenfranchise all people with felony convictions. On August 5, 2020, Gov. Reynolds issued Executive Order 7, automatically restoring voting rights to most Iowans who completed their sentences (excluding homicide). This affected tens of thousands of citizens.

### Research Question
Did Iowa's automatic voting rights restoration increase voter turnout among formerly incarcerated individuals?

### Identification Strategy
**Method:** Difference-in-Differences  
- Compare Iowa to similar Midwestern states (Nebraska, Kansas, Missouri, South Dakota)
- Pre-period: 2016, 2018 elections
- Post-period: 2020, 2022, 2024 elections

### Data Sources
- **Iowa Secretary of State** — county-level turnout data
- **Census PUMS** — demographic controls
- **Prison Policy Initiative** — estimates of disenfranchised population

### Feasibility Assessment
| Criterion | Rating | Notes |
|-----------|--------|-------|
| Policy variation | ★★★★★ | Clear date, dramatic policy change |
| Data availability | ★★★★☆ | Turnout data is public |
| Parallel trends | ★★★★☆ | 2016, 2018 provide good pre-period |
| Novelty | ★★☆☆☆ | Georgetown study already found null effects |
| Avoids top10 mistakes | ★★★☆☆ | Aggregate county data may mask individual effects |

### Concerns
- **Already studied:** Georgetown researchers conducted RCTs finding "precise nulls"—no effect on turnout
- Ex-felons register and vote at very low rates nationally—hard to detect effects
- Limited novelty

---

## Summary Ranking

| Idea | Policy | Feasibility | Novelty | Recommendation |
|------|--------|-------------|---------|----------------|
| **#2** | Colorado Fentanyl Reversal | ★★★★☆ | ★★★★★ | **PURSUE** |
| **#1** | Florida Fines/Fees Barrier | ★★★☆☆ | ★★★☆☆ | MAYBE — data access unclear |
| **#3** | Colorado 48-Hour Bond Rule | ★★★☆☆ | ★★★★☆ | MAYBE — COVID confounding |
| **#4** | Colorado Clean Slate | ★★☆☆☆ | ★★★★☆ | SKIP — cannot identify treated |
| **#5** | Iowa Voting Rights | ★★★★☆ | ★★☆☆☆ | SKIP — already studied, null effects |

---

## Recommended Path Forward

**Primary:** Idea #2 (Colorado Fentanyl Policy Reversal)
- Unique natural experiment of decriminalization followed by recriminalization
- Excellent data availability from CDPHE
- Policy-relevant during ongoing fentanyl crisis
- Key challenge: Address COVID confounding through careful synthetic control construction

**Backup:** Idea #1 (Florida Fines/Fees)
- Pursue only if we can access court records linking fines to voter files
- Otherwise, limited to aggregate DiD which is less compelling
