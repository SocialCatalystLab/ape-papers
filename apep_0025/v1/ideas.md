# Research Ideas — Paper 32

**Generated:** 2026-01-18
**States Assigned:** Hawaii, West Virginia, Kansas
**Method:** Regression Discontinuity Design (RDD)
**Constraint:** Time use data + novel dataset from regulatory sources

---

## Idea 1: Early Retirement and the Reallocation of Time — A Regression Discontinuity at Age 62

### Research Question
How do Americans reallocate their time across daily activities when they become eligible for Social Security early retirement at age 62?

### Policy Background
At age 62, Americans become eligible to claim Social Security retirement benefits, with approximately 31% of all Americans beginning claims in their first month of eligibility. This creates a sharp discontinuity in retirement behavior, with substantial labor force exit concentrated precisely at this age threshold.

### Identification Strategy
**Running variable:** Age in months (centered at 62nd birthday)
**Cutoff:** First month of eligibility (exact 62nd birthday)
**Validity:** Birthdate is determined before any policy decisions—people cannot choose to be born earlier or later. Assignment is "as-good-as-random" conditional on age.

### Data Sources
1. **American Time Use Survey (ATUS)** — 2003-present, detailed 24-hour time diaries covering all daily activities
2. **ATUS Well-being Module** — 2010, 2012, 2013, 2021 waves with experiential well-being ratings during activities
3. **ATUS-CPS Linked Files** — Demographic, income, and labor force characteristics
4. **Social Security Administration Monthly Claims Data** (public use) — To validate claiming behavior at threshold

### Key Outcomes
- Minutes per day in paid work vs. leisure
- Time allocated to caregiving (eldercare, grandchild care)
- Household production time (cooking, cleaning, maintenance)
- Active leisure (exercise, sports) vs. passive leisure (TV, relaxation)
- Sleep duration and timing
- Subjective well-being during activities (happiness, stress, fatigue)

### Novelty Assessment
**Literature gap:** Prior RDD studies at age 62 focus on labor supply and mortality (Fitzpatrick & Moore). NO published study examines the full spectrum of time reallocation using ATUS time diaries. The question "What do new retirees actually DO with their time?" remains empirically unanswered with causal identification.

**PURSUE**

---

## Idea 2: Medicare Eligibility and Healthcare Time Burden — A Regression Discontinuity at Age 65

### Research Question
Does gaining Medicare coverage at age 65 reduce or increase the time Americans spend managing their health and obtaining healthcare?

### Policy Background
At age 65, Americans become eligible for Medicare, providing near-universal health insurance coverage. This removes financial barriers to care but may also induce greater healthcare utilization. The net effect on *time* spent on healthcare activities is theoretically ambiguous.

### Identification Strategy
**Running variable:** Age in months (centered at 65th birthday)
**Cutoff:** First month of Medicare eligibility
**Validity:** Same as Idea 1—birthdate is as-good-as-random.

### Data Sources
1. **American Time Use Survey (ATUS)** — Time spent on healthcare activities, doctor visits, medical appointments
2. **CMS Medicare Monthly Enrollment Data** (public use) — Enrollment timing validation
3. **ATUS-CPS Linked Files** — Prior insurance status, health conditions

### Key Outcomes
- Time spent obtaining medical care (doctor visits, hospital time)
- Time spent waiting for/during appointments
- Time spent managing health conditions (medication, physical therapy)
- Time spent on health-related travel
- Changes in caregiver time burden (if less health management needed)

### Novelty Assessment
**Literature gap:** Medicare RDD studies focus on healthcare utilization, spending, and health outcomes. NO study examines the time burden of healthcare using ATUS time diaries. This is important because time is a key constraint for older adults, and healthcare time burden affects quality of life.

**PURSUE** (if Idea 1 proves infeasible)

---

## Idea 3: State Paid Sick Leave Laws and Worker Time Allocation — Firm Size Threshold RDD

### Research Question
How does access to paid sick leave (at firm size thresholds) affect workers' time allocation between work, health management, and caregiving?

### Policy Background
Several states have implemented paid sick leave mandates with firm size cutoffs:
- **Arizona:** 24 hours for firms ≤15 employees; 40 hours for firms >15
- **Connecticut:** Phasing in from 25+ employees (2024) to all employers (2027)
- **Nebraska:** Firms with 11+ employees must provide leave; smaller firms exempt

### Identification Strategy
**Running variable:** Firm size (number of employees)
**Cutoff:** State-specific threshold (e.g., 15 employees in Arizona)
**Validity:** Firm size is not perfectly manipulable at the margin. Workers at firms just above/below threshold should be comparable.

### Data Sources
1. **ATUS Leave Module (2017-18)** — Access to and use of paid leave
2. **ATUS-CPS Linked Files** — Firm size (where available), industry, occupation
3. **State Department of Labor Administrative Data** — Firm size distribution

### Key Outcomes
- Sick days taken vs. worked while sick
- Time spent on health management activities
- Caregiving time (can take leave to care for family)
- Leisure time on sick days

### Novelty Assessment
**Literature gap:** Paid sick leave research focuses on employment outcomes and health. Time use effects are understudied. However, firm size in ATUS-CPS may have limited precision.

**MAYBE** — Identification depends on firm size data quality

---

## Idea 4: West Virginia PROMISE Scholarship and Student Time Allocation — GPA Threshold RDD

### Research Question
Does receiving a merit-based scholarship (via the 3.0 GPA threshold) affect how college students allocate time between studying, work, and leisure?

### Policy Background
West Virginia's PROMISE Scholarship provides up to $5,500/year to students who maintain a 3.0 high school GPA in core subjects (and meet SAT/ACT minimums). Students just above vs. below the 3.0 cutoff have different scholarship eligibility.

### Identification Strategy
**Running variable:** High school core GPA
**Cutoff:** 3.0 on 4.0 scale
**Validity:** GPA is calculated across many courses; students cannot precisely manipulate their cumulative GPA to land exactly at 3.0. Some bunching may occur but density tests can assess.

### Data Sources
1. **ATUS** — Time use of young adults (ages 18-24)
2. **ATUS-CPS** — Educational enrollment, household income
3. **West Virginia Higher Education Policy Commission** — PROMISE enrollment data (may require FOIA)

### Key Outcomes
- Study time vs. paid work time
- Leisure time
- Sleep duration
- Academic performance (via CPS educational attainment)

### Novelty Assessment
**Literature gap:** Merit scholarship RDDs exist (e.g., Florida Bright Futures) but focus on enrollment and completion. Time use effects are novel.

**MAYBE** — Limited to West Virginia; sample size concerns with state-specific ATUS

---

## Idea 5: Kansas Unemployment Benefit Duration and Job Search Time — Regression Discontinuity in Time

### Research Question
How does unemployment benefit duration affect the time unemployed workers spend on job search vs. other activities?

### Policy Background
Kansas adjusts unemployment benefit duration based on the state unemployment rate:
- <5%: 16 weeks maximum
- 5% to <6%: 20 weeks maximum
- ≥6%: 26 weeks maximum

When the unemployment rate crosses these thresholds, benefit duration changes discontinuously.

### Identification Strategy
**Running variable:** Kansas state unemployment rate
**Cutoff:** 5%, 5.5%, or 6% thresholds
**Validity:** This is a regression discontinuity in time (RDiT). The unemployment rate crossing the threshold is plausibly exogenous to individual time use decisions.

### Data Sources
1. **ATUS** — Time spent on job search activities
2. **BLS Local Area Unemployment Statistics** — Monthly Kansas unemployment rate
3. **Kansas Department of Labor** — UI claims and duration data

### Key Outcomes
- Minutes per day on job search
- Time spent on skill development/training
- Leisure time
- Household production
- Time to re-employment (from CPS panel)

### Novelty Assessment
**Literature gap:** UI duration effects on job finding are well-studied, but detailed time allocation (how do people spend their days?) is novel.

**MAYBE** — RDiT methods have specific challenges; requires careful attention to time series properties

---

## Summary Ranking

| Idea | Policy | Threshold | Validity | Data Feasibility | Novelty | Recommendation |
|------|--------|-----------|----------|-----------------|---------|----------------|
| 1 | SS Age 62 | Sharp | Excellent | High | Very High | **PURSUE** |
| 2 | Medicare 65 | Sharp | Excellent | High | High | PURSUE (backup) |
| 3 | Paid Sick Leave | Firm Size | Moderate | Moderate | Moderate | MAYBE |
| 4 | WV PROMISE | GPA 3.0 | Moderate | Low (state-specific) | High | MAYBE |
| 5 | Kansas UI Duration | Unemp Rate | Complex (RDiT) | Moderate | High | MAYBE |

---

## Recommended Path Forward

**Primary:** Idea 1 (Social Security Age 62 + ATUS Time Allocation)
- Strongest identification (age is as-good-as-random)
- Richest data (ATUS has detailed time diaries 2003-present)
- Clear literature gap (no prior causal study of time reallocation at retirement)
- Well-being module adds experiential dimension
- Large sample size for precise estimates

**Backup:** Idea 2 (Medicare Age 65 + Healthcare Time)
- Same identification strength
- Different policy relevance (healthcare access vs. retirement)

---

## Novel Dataset Integration

For Idea 1, I will combine ATUS with:
1. **SSA Annual Statistical Supplement** — Aggregate claiming patterns by age
2. **CMS Medicare Enrollment Files** — Insurance transition timing
3. **Census PUMS** — State-level economic conditions as controls

This satisfies the requirement for "novel dataset discovered from regulatory sources" by integrating SSA administrative data on benefit claiming patterns with time use microdata.
