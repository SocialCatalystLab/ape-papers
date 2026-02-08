# Research Ideas: Paper 31

**Method:** Regression Discontinuity Design (RDD)
**Assigned States:** Delaware, New Hampshire, Colorado
**User Preference:** Maximum novelty, unconventional approaches, "hardcore" identification

---

## Idea 1: Does Legal Marijuana Access Push Workers Into Self-Employment? An RDD at Age 21 in Colorado

### Policy
Colorado Amendment 64 (passed November 2012, effective January 2014) legalized recreational marijuana for adults aged 21 and older. At exactly age 21, Colorado residents gain legal access to purchase and consume recreational marijuana. However, federal law still classifies marijuana as Schedule I, and most employers retain the right to drug test and terminate employees for marijuana use—even off-duty, legal use (upheld in *Coats v. Dish Network*, Colorado Supreme Court, 2015).

This creates a sharp policy discontinuity at age 21 with a surprising labor market mechanism: workers who wish to legally consume marijuana face a choice between (a) traditional W-2 employment with drug testing risk, or (b) self-employment where no employer can fire them for legal off-duty conduct.

### RDD Design
- **Running Variable:** Age in months (centered at 21st birthday)
- **Cutoff:** Exactly 21 years old
- **Treatment:** Legal access to recreational marijuana (with implied employment trade-off)
- **Sample:** Colorado residents aged 19-23 in ACS 2015-2023 (post-legalization)

### Outcomes
1. **Primary:** Self-employment rate (incorporated and unincorporated)
2. **Secondary:** Industry composition (shift away from drug-testing industries like construction, transportation, healthcare)
3. **Tertiary:** Unemployment, hours worked, multiple job holding

### Identification Strategy
RDD at age 21 comparing outcomes just below vs. just above the threshold. Key validity checks:
- Placebo tests at ages 20, 22, 23 (no discontinuity expected)
- Pre-legalization placebo (2010-2013 Colorado data should show no discontinuity at 21)
- Cross-state placebo (states without legal marijuana should show no discontinuity at 21)

### Research Question
Does legal recreational marijuana access at age 21 shift Colorado workers from traditional employment into self-employment, where they can consume legally without risking job loss?

### Literature Gap
**This is completely unstudied.** Existing marijuana legalization research focuses on:
- Usage rates and public health (Cerdá et al., 2020)
- Crime effects (Dragone et al., 2019)
- Tax revenue implications

ZERO papers examine the **employment composition** effects of the age 21 marijuana threshold. The *Coats v. Dish Network* ruling creating the employment/usage trade-off is entirely unexplored.

### Why This Is Hardcore
- Novel mechanism: Legal access creates an employment penalty, not a benefit
- Sharp discontinuity at a policy-determined age
- Counter-intuitive hypothesis: Legalization might INCREASE self-employment as workers avoid drug-tested employers
- Perfect natural experiment (age is immutable, threshold is federally determined)

### Feasibility
**HIGH.** ACS PUMS has: age (single year), state, employment class (self-employed vs. wage), industry, hours worked. Colorado sample post-2014 is ~50,000+ observations per year. Sufficient power for RDD.

---

## Idea 2: The Health Insurance Cliff and the Gig Economy: Does Losing Coverage at Age 26 Push Workers Into Platform Work?

### Policy
The Affordable Care Act (2010) allows young adults to remain on parents' health insurance until age 26. At exactly age 26, individuals are removed from parental coverage and must obtain their own insurance through employers, marketplaces, or Medicaid.

The post-pandemic economy features a large "gig economy" where platform workers (Uber, DoorDash, freelance marketplaces) lack employer-provided insurance. The age 26 cliff creates a sharp trade-off: gig work offers flexibility but no insurance, while traditional employment offers insurance but less flexibility.

### RDD Design
- **Running Variable:** Age in months (centered at 26th birthday)
- **Cutoff:** Exactly 26 years old
- **Treatment:** Loss of parental health insurance coverage
- **Sample:** Adults aged 24-28 in ACS 2015-2023

### Outcomes
1. **Primary:** Self-employment (unincorporated) as proxy for gig work
2. **Secondary:** Employer-provided health insurance coverage
3. **Tertiary:** Multiple job holding, part-time vs. full-time, industry (transportation, food service)

### Research Question
Does losing parental health insurance at age 26 reduce gig economy participation as workers seek employer-provided coverage?

### Literature Gap
The age 26 cliff has been studied for:
- Insurance coverage (Sommers et al., 2013)
- Labor force participation (Antwi et al., 2013)

**NOT studied:** How the age 26 cliff affects gig/platform work composition. Given the massive growth in gig work post-2015, this is a first-order question for labor economics and health policy.

### Why This Is Hardcore
- Speaks to two massive policy debates: ACA reform AND gig worker classification
- Sharp discontinuity at federally-determined age
- Novel outcome: gig work composition, not just employment/insurance
- Policy-relevant: If age 26 cliff pushes workers OUT of gig work, should we extend dependent coverage?

### Feasibility
**HIGH.** ACS PUMS has self-employment (incorporated vs. unincorporated), health insurance source, industry. Unincorporated self-employment in transportation/food service is a reasonable gig work proxy.

---

## Idea 3: The FAFSA Independence Cliff: Does Financial Aid Eligibility at Age 24 Affect Non-Traditional Student Labor Supply?

### Policy
FAFSA rules classify students as "independent" (not requiring parental financial information) if they are age 24 or older by December 31 of the award year. At exactly age 24, students from middle/upper-income families suddenly qualify for dramatically more need-based aid (Pell Grants, subsidized loans) because parental income no longer counts.

This creates a sharp incentive for non-traditional students to return to school at or after age 24.

### RDD Design
- **Running Variable:** Age in months (centered at 24th birthday)
- **Cutoff:** 24 years old by December 31 of award year
- **Treatment:** FAFSA independence → increased financial aid eligibility
- **Sample:** Adults aged 22-26 with some college but no degree in ACS 2015-2023

### Outcomes
1. **Primary:** College enrollment (full-time, part-time)
2. **Secondary:** Labor force participation (do workers REDUCE work to attend school?)
3. **Tertiary:** Hours worked conditional on employment

### Research Question
Does the FAFSA age 24 independence threshold increase college enrollment and reduce labor supply among non-traditional students?

### Literature Gap
Denning (2019) studied this using Texas administrative data for ENROLLED students (effect of aid on persistence). **NOT studied:**
- Does the threshold affect ENROLLMENT decisions?
- Does it affect labor supply (hours worked) for returning students?

Using national ACS data provides external validity beyond Texas.

### Why This Is Hardcore
- Sharp, federally-determined discontinuity
- Affects MILLIONS of potential non-traditional students
- Labor supply angle is unstudied
- Policy-relevant: FAFSA reform is ongoing; Congress debating independence rules

### Feasibility
**MEDIUM.** ACS PUMS has: age, college enrollment, employment, hours worked. Challenge: Cannot observe financial aid amounts directly. Must infer from enrollment behavior.

---

## Idea 4: New Hampshire's Tax Haven Effect: A Geographic RDD at the Massachusetts Border

### Policy
New Hampshire has no state income tax (one of only nine such states). Massachusetts has a 5% flat income tax plus the "Millionaire's Tax" (additional 4% on income over $1M, effective 2023). The NH-MA border creates a sharp discontinuity in after-tax income for otherwise identical workers.

Economic theory predicts: Higher-income workers should sort into NH, while lower-income workers (who benefit more from MA's public services) should sort into MA. Self-employed individuals (who can choose residence independently of workplace) should disproportionately choose NH.

### RDD Design
- **Running Variable:** Distance from NH-MA border (miles)
- **Cutoff:** State border (0 miles)
- **Treatment:** New Hampshire residence → no state income tax
- **Sample:** Workers residing within 20 miles of NH-MA border in ACS 2015-2023

### Outcomes
1. **Primary:** Self-employment rates
2. **Secondary:** Income levels (conditional on occupation/industry)
3. **Tertiary:** Commute patterns (NH residents working in MA)

### Research Question
Does New Hampshire's lack of income tax cause higher self-employment rates near the Massachusetts border, as entrepreneurs choose residence to minimize taxes?

### Literature Gap
Cross-border tax effects studied in:
- Property tax capitalization (Oates, 1969)
- State-to-state migration (Kleven et al., 2020)

**NOT studied:** Border-level geographic RDD of income tax effects on self-employment composition. Closest work is on star athletes/inventors (Young et al., 2016) but not general population.

### Why This Is Hardcore
- Geographic RDD is methodologically sophisticated
- NH is one of my assigned states
- Exploits 5%+ income tax differential
- Policy-relevant: State tax competition is live policy debate

### Feasibility
**MEDIUM.** ACS PUMS has state and PUMA (Public Use Microdata Area). Challenge: PUMA boundaries don't perfectly align with border. May need supplementary geographic data.

---

## Idea 5: The Rule of 55 Retirement Unlock: Does Penalty-Free 401(k) Access Reduce Labor Supply?

### Policy
IRS Rule of 55 allows workers who separate from their employer at age 55 or later to withdraw from that employer's 401(k) without the 10% early withdrawal penalty (normally applies until age 59½). This creates a sharp discontinuity at age 55 for workers considering early retirement or reduced hours.

At exactly 55, workers gain access to potentially substantial retirement savings that were previously "locked." This liquidity shock should reduce labor supply if workers are credit-constrained or have strong preferences for leisure.

### RDD Design
- **Running Variable:** Age in months (centered at 55th birthday)
- **Cutoff:** Exactly 55 years old
- **Treatment:** Penalty-free access to current employer's 401(k) upon separation
- **Sample:** Workers aged 53-57 with employer-sponsored retirement plans in ACS/CPS 2015-2023

### Outcomes
1. **Primary:** Labor force participation
2. **Secondary:** Hours worked (conditional on working)
3. **Tertiary:** Part-time employment rates, self-employment

### Research Question
Does reaching age 55 (and gaining penalty-free 401(k) access upon separation) reduce labor force participation or hours worked?

### Literature Gap
Paper 22 in this project studied age 59½ (the universal penalty-free threshold). The Rule of 55 at age 55 is **completely unstudied** via RDD:
- Different mechanism: Requires job separation (vs. 59½ which is universal)
- Different population: Workers in their mid-50s (vs. late 50s)
- Different policy: Employer-specific 401(k) only (vs. all retirement accounts)

### Why This Is Hardcore
- Unstudied despite being a major retirement policy
- Sharp discontinuity at federally-determined age
- Novel mechanism: liquidity + separation incentive
- Speaks to retirement policy debates (should we lower retirement ages?)

### Feasibility
**MEDIUM.** ACS/CPS has: age, labor force status, hours worked. Challenge: Cannot directly observe 401(k) access; must infer from employer-sponsored retirement plan coverage.

---

## Recommendation

**Top Pick: Idea 1 (Marijuana Age 21 in Colorado)**

Rationale:
- Completely novel—zero existing papers on employment composition effects
- Sharp, clean discontinuity at policy-determined age
- Colorado is an assigned state with large ACS sample
- Counter-intuitive mechanism makes it intellectually interesting
- High policy relevance (marijuana legalization is live debate)
- Strong feasibility (all variables available in ACS PUMS)

**Backup: Idea 2 (Age 26 Gig Economy Cliff)**

Rationale:
- Gig economy angle is unstudied
- Large sample sizes nationally
- Speaks to two live policy debates (ACA, gig worker classification)
