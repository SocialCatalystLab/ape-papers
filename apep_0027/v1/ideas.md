# Research Ideas - Paper 34

**Focus:** Historical school policies from the 1950s-1970s
**Identification Strategy:** Birth state × birth year variation in PUMS
**Assigned States:** Maine, Minnesota, New York

---

## Idea 1: The Long Shadow of the Paddle - Corporal Punishment Bans and Adult Outcomes

**Policy:** State-level bans on corporal punishment in public schools

**Timing Variation:**
- New Jersey: 1867 (very early adopter)
- Massachusetts: 1972
- Hawaii: 1973
- **Maine: 1975** (assigned state)
- Rhode Island, DC: 1977
- New Hampshire: 1983
- **New York:** 1985 (assigned state)
- California: 1986
- Nebraska, Wisconsin: 1988
- **Minnesota:** 1989 (assigned state)
- Many others through 1990s (still legal in 17 states today)

**Research Question:** Do individuals who attended school entirely after their state banned corporal punishment have better long-term educational and economic outcomes?

**Identification:** Difference-in-differences comparing cohorts born in early-ban vs late-ban states, before and after ban implementation. Exploit the fact that a child born in Maine in 1970 experienced corporal punishment during elementary school, while one born in 1975 did not.

**PUMS Variables:**
- Birth state (BPLD) + birth year → treatment assignment
- Outcomes: EDUC (educational attainment), INCWAGE (wages), INCTOT (total income), DIFFREM/DIFFPHYS (cognitive/physical disability as health proxy)

**Novelty:** Most economic research on corporal punishment is from India (see ERIC EJ1303175). U.S. causal inference studies exploiting the staggered state ban timing are essentially nonexistent. Psychology literature documents correlational effects but lacks clean identification.

**Data Quality:** Excellent. Clean timing variation, large sample sizes per state, long post-treatment observation period.

---

## Idea 2: The Breakfast Effect - School Breakfast Program Rollout and Long-Term Health

**Policy:** School Breakfast Program (SBP) - federal pilot (1966) → permanent (1975)

**Timing Variation:**
- 1966: Pilot launched in "nutritionally needy" areas
- 1968: Became federal program, state-administered
- 1971: Expanded to schools with low-income families and working parents
- 1975: Made permanent
- State-level rollout varied based on "severe need" designations

**Research Question:** Did early exposure to school breakfast programs during childhood improve long-term health and economic outcomes?

**Identification:** Exploit state-level variation in program rollout timing and intensity. Compare cohorts in states that adopted early (designated "severe need") vs late adopters.

**PUMS Variables:**
- Birth state + birth year → treatment intensity
- Outcomes: Health insurance (HCOVANY), disability status (DIFF*), labor force participation (EMPSTAT), poverty status (POVERTY)

**Novelty:** Existing SBP research focuses on short-term academic and BMI effects. Long-term adult outcomes using the 1966-1975 rollout timing are understudied.

**Data Quality:** Moderate. State-level rollout data would need to be collected from historical USDA records. Black Panthers' parallel program complicates urban identification.

---

## Idea 3: The Minnesota Miracle - School Finance Equalization and Intergenerational Mobility

**Policy:** Minnesota's 1971 school finance reform ("Minnesota Miracle")

**Background:**
- Ten-year effort culminating in 1971 legislation
- Shifted school funding from local property taxes to state equalization
- Dramatic reduction in per-pupil spending disparities between rich and poor districts
- Model for reforms in other states

**Research Question:** Did Minnesota's school finance equalization improve intergenerational mobility for children from low-income families born after 1971?

**Identification:**
- Compare Minnesota-born cohorts before (1960-1970) vs after (1972-1985) the reform
- Use other Midwestern states (Wisconsin, Iowa, Dakotas) as controls
- Triple-difference: pre/post × MN/control × family income quintile

**PUMS Variables:**
- Birth state + birth year → treatment
- Parent's education (proxy for childhood SES): POPLOC/MOMLOC linked
- Outcomes: EDUC, INCWAGE, occupational prestige

**Novelty:** While Jackson, Johnson & Persico (2016) study school finance reforms nationally, the Minnesota Miracle has unique features (simultaneous with other fiscal reforms, very large spending changes) that merit focused analysis.

**Data Quality:** Good. Clean single-state treatment with clear timing. Challenge: PUMS doesn't directly observe childhood family income.

---

## Idea 4: Open Classrooms, Open Minds? - The 1960s-70s Open Education Movement

**Policy:** Open classroom/informal education movement in American elementary schools

**Background:**
- British-inspired movement peaked in late 1960s-early 1970s
- Removed classroom walls, student-directed learning, learning stations
- By mid-1970s, faced backlash ("back to basics" movement)
- Some districts adopted extensively; others rejected entirely

**Research Question:** Did exposure to open education pedagogy during elementary school affect creativity, entrepreneurship, or unconventional career paths in adulthood?

**Identification:** Exploit district-level variation in adoption. Challenging because adoption was not systematic at state level.

**PUMS Variables:**
- Birth state + birth year (crude proxy)
- Outcomes: Self-employment (CLASSWKR), creative occupations (OCC codes for artists, designers, etc.)

**Novelty:** High - essentially unstudied in economics.

**Data Quality:** Poor. No systematic data on which districts adopted open classrooms. Would require archival research.

---

## Idea 5: When Schools Got Bigger - Rural School Consolidation Effects

**Policy:** Rural school district consolidation (peak: 1950s-1960s)

**Background:**
- Number of U.S. school districts fell from 127,000 (1930) to 15,000 (1990)
- Most dramatic consolidation occurred 1945-1970
- Students bused longer distances to larger, consolidated schools
- Debates about community loss vs educational quality gains

**Research Question:** Did rural school consolidation improve or harm long-term educational and economic outcomes for affected cohorts?

**Identification:**
- Use state-level consolidation intensity (change in number of districts)
- Compare cohorts in high-consolidation vs low-consolidation states

**PUMS Variables:**
- Birth state + birth year + rural/urban birth location (if available in historical PUMS)
- Outcomes: EDUC, INCWAGE, migration (current state vs birth state)

**Novelty:** Moderate. Some research exists (Berry & West 2010) but focuses on test scores, not long-term adult outcomes.

**Data Quality:** Moderate. State-level consolidation data available from NCES historical statistics. Challenge: PUMS may not identify rural birth locations precisely.

---

## Ranking Criteria

| Idea | Novelty | Data Quality | Clean ID | Relevance |
|------|---------|--------------|----------|-----------|
| 1. Corporal Punishment | ★★★★★ | ★★★★★ | ★★★★★ | ★★★★☆ |
| 2. School Breakfast | ★★★★☆ | ★★★☆☆ | ★★★☆☆ | ★★★★☆ |
| 3. Minnesota Miracle | ★★★☆☆ | ★★★★☆ | ★★★★☆ | ★★★★☆ |
| 4. Open Classrooms | ★★★★★ | ★☆☆☆☆ | ★☆☆☆☆ | ★★★☆☆ |
| 5. School Consolidation | ★★★☆☆ | ★★★☆☆ | ★★★☆☆ | ★★★☆☆ |

**Recommendation:** Idea 1 (Corporal Punishment Bans) offers the best combination of novelty, data quality, and clean identification. The staggered state-level timing provides excellent quasi-experimental variation, and PUMS birth state enables direct identification of treatment cohorts.
