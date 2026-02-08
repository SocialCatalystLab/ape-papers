# Research Ideas: Labor Market Policy Evaluation

**Paper 40** | Domain: Labor | Date: 2026-01-18

---

## Idea 1: State Auto-IRA Mandates and Worker Job Mobility (LEAD IDEA)

### Policy Background
Starting with Oregon in 2017, states have mandated that employers without retirement plans either offer one or automatically enroll workers in a state-run IRA program. As of 2026, 17+ states have implemented such programs:
- **Oregon** (OregonSaves): Pilot July 2017, phased rollout 2017-2020
- **Illinois** (Secure Choice): Phased in 2018-2020
- **California** (CalSavers): Pilot 2018, phased in 2019-2022
- **Maryland, Colorado, Connecticut, New Jersey, Virginia**, and others: 2020-2024

### Research Gap
Existing research (Bloomfield et al. 2024, NBER) focuses on **firm behavior** - whether mandates crowd in or crowd out private retirement plan adoption. **No rigorous empirical study** examines effects on **worker labor market outcomes**: job mobility, hours worked, labor force participation, or wages.

### Research Question
**Do state auto-IRA mandates affect worker job mobility and labor market attachment?**

### Theoretical Mechanisms
1. **Reduced job lock**: Traditional 401(k) plans create "job lock" as workers fear losing vested benefits. Portable auto-IRAs could increase job mobility by making retirement savings fully portable.
2. **Increased labor supply**: Access to retirement savings may encourage work at the extensive margin, particularly for older workers without prior access.
3. **Wage effects**: If workers value retirement benefits, equilibrium wages may adjust downward; alternatively, improved retention could increase wages.

### Identification Strategy
**Staggered Difference-in-Differences** exploiting:
- Cross-state variation in adoption timing (2017-2024)
- Within-state variation by employer size (mandates phase in by firm size)
- Cross-occupation variation (workers in firms with existing plans unaffected)

### Data Sources
- **IPUMS-CPS**: Monthly labor force data with job tenure, occupation, industry, state
- **SIPP**: Retirement plan coverage, job transitions, wealth
- **Quarterly Workforce Indicators (QWI)**: Job-to-job flows, earnings, turnover by state-industry-quarter

### Outcome Variables
- Job-to-job transition rates
- Separation rates (quits vs. layoffs)
- Labor force participation (especially ages 55-64)
- Hours worked
- Wages

### Feasibility Assessment
- **Clusters**: 17+ treated states, 33+ control states = ADEQUATE
- **Pre-treatment period**: Oregon 2017 → 6+ years pre-data in CPS = GOOD
- **Data access**: CPS/SIPP public; IPUMS API available = CONFIRMED
- **Power**: Large sample sizes from CPS monthly surveys = LIKELY ADEQUATE
- **Novelty**: HIGH - no existing papers on worker outcomes

### Potential Concerns
- COVID-19 shock (2020) coincides with many rollouts → need careful event study design
- Heterogeneous treatment intensity across states
- Selection into treatment (states choosing to adopt may differ)

**VERDICT: PURSUE** - Novel question, clean identification, feasible data

---

## Idea 2: Pay Transparency Laws and the Gender Wage Gap

### Policy Background
Since 2020, 14+ states have enacted pay disclosure/transparency laws requiring employers to post salary ranges in job listings:
- Colorado (Jan 2021)
- Connecticut (Oct 2021)
- Nevada (Oct 2021)
- California, Washington, Rhode Island (Jan 2023)
- New York (Sept 2023)
- Hawaii, DC (2024)
- Illinois, Minnesota, New Jersey, Vermont (2025)

### Research Gap
Existing research on salary history bans (related but distinct) shows wage increases for job changers. Pay transparency laws are newer and less studied. Most existing studies use simple DiD; opportunity for more rigorous identification.

### Research Question
**Do pay transparency laws reduce the gender wage gap?**

### Identification Strategy
Staggered DiD with state-level variation in adoption timing. Can compare job changers vs. stayers, new hires vs. incumbent workers.

### Data Sources
- ACS wages by gender, state, year
- CPS-ASEC income data
- Burning Glass/Lightcast job postings data (if accessible)

### Feasibility Assessment
- **Clusters**: 14+ treated states = MARGINAL (need wild bootstrap)
- **Pre-treatment period**: Colorado 2021 → limited pre-period = CONCERN
- **Novelty**: MODERATE - some related research exists

**VERDICT: BACKUP** - Good question but recency limits pre-period; some existing literature

---

## Idea 3: Universal License Recognition and Occupational Entry

### Policy Background
26 states have passed Universal License Recognition (ULR) reforms since 2013, with Arizona's landmark 2019 reform catalyzing a wave:
- Arizona (2019), Missouri (2018), Pennsylvania (2019)
- Montana, Idaho, Utah, Iowa (2019-2021)
- Major expansion through 2024

### Research Gap
Bae & Timmons (2023) found employment and migration effects. **Understudied**: effects on occupational entry, entrepreneurship, and demographic-specific outcomes (immigrants, military spouses).

### Research Question
**Do ULR laws increase occupational entry and entrepreneurship among licensed workers?**

### Data Sources
- ACS (occupation, self-employment, migration)
- IPUMS (occupation detail)
- State licensing board data (if accessible)

### Feasibility Assessment
- **Clusters**: 26 treated states = GOOD
- **Pre-treatment period**: Many adoptions 2019+ → some COVID overlap
- **Novelty**: MODERATE - employment effects studied; occupational entry angle less so

**VERDICT: BACKUP** - Feasible but existing literature reduces novelty

---

## Idea 4: State Mini-WARN Act Expansions and Worker Outcomes

### Policy Background
States have expanded beyond federal WARN Act (60 days notice for mass layoffs at 100+ employee firms):
- New Jersey strengthened 2023 (90 days notice, 50+ employees)
- Washington State adopted mini-WARN recently
- California, New York, Illinois have long-standing expansions

### Research Gap
Minimal empirical research on state mini-WARN effects. Federal WARN studied but state variation largely unexplored.

### Research Question
**Do expanded layoff notice requirements improve worker outcomes?**

### Data Sources
- WARN notice databases (public)
- Unemployment insurance claims by state
- CPS unemployment duration

### Feasibility Assessment
- **Clusters**: Limited recent variation (mostly pre-2015 adoptions)
- **Novelty**: HIGH but feasibility concerns
- **Challenge**: Most state expansions are old, limiting modern causal design

**VERDICT: SKIP** - Limited recent variation makes modern DiD difficult

---

## Idea 5: Non-Compete Ban Effects on Entrepreneurship

### Policy Background
- California: Long-standing ban (since 1872)
- Minnesota: Complete ban effective July 2023
- Massachusetts: Reformed 2018 (limits to 1 year, requires compensation)

### Research Gap
Minnesota ban too recent for outcome data. California ban is too old for modern DiD. Massachusetts 2018 reform offers best window but single-state limits inference.

### Feasibility Assessment
- **Clusters**: 1 recent state (Minnesota) = INSUFFICIENT
- **Pre-treatment period**: Minnesota 2023 → no post-data yet
- **Alternative**: Massachusetts 2018 → synthetic control possible but underpowered

**VERDICT: SKIP** - Insufficient treatment variation for credible identification

---

## Summary Ranking

| Rank | Idea | Novelty | Feasibility | Verdict |
|------|------|---------|-------------|---------|
| 1 | Auto-IRA and Job Mobility | HIGH | HIGH | **PURSUE** |
| 2 | Pay Transparency and Gender Gap | MODERATE | MODERATE | BACKUP |
| 3 | ULR and Occupational Entry | MODERATE | GOOD | BACKUP |
| 4 | Mini-WARN Expansions | HIGH | LOW | SKIP |
| 5 | Non-Compete Bans | HIGH | LOW | SKIP |

---

## Recommendation

**Proceed with Idea 1: State Auto-IRA Mandates and Worker Job Mobility**

This idea offers the best combination of:
1. **High novelty**: No existing papers on worker (vs. firm) outcomes
2. **Clean identification**: Staggered state adoption with variation in timing and firm size thresholds
3. **Strong data**: IPUMS CPS access confirmed; large sample sizes
4. **Adequate clusters**: 17+ treated states avoids small-cluster inference problems
5. **Clear mechanism**: Portable benefits should reduce job lock compared to 401(k)s

The main concern is COVID-19 overlap with some state rollouts (2020-2021), which requires careful research design (e.g., dropping 2020-2021, using only pre-COVID adopters like Oregon/Illinois, or explicitly modeling COVID heterogeneity).
