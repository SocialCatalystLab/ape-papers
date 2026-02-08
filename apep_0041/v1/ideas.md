# Research Ideas - Paper 58

## Idea 1: State Paid Family Leave and Maternal Employment

**Policy:** State-level paid family leave (PFL) programs
- California: July 2004
- New Jersey: July 2009
- Rhode Island: January 2014
- New York: January 2018
- Washington: January 2020

**Outcome:** Maternal employment and labor force participation for women with young children (Census ACS PUMS)

**Identification:** Difference-in-differences comparing employment outcomes for women in states that adopted PFL vs. never-adopter states, using staggered adoption timing. Use modern heterogeneity-robust estimators (Callaway-Sant'Anna or Sun-Abraham).

**Why it's novel:**
- Most existing studies focus on California alone (Rossin-Slater, Baum & Ruhm)
- We can use the multi-state staggered rollout for heterogeneity-robust DiD
- Focus on employment rather than just leave-taking
- Use 2005-2022 ACS PUMS for comprehensive pre/post coverage

**Feasibility check:**
- ✓ Clear staggered adoption dates (5 states 2004-2020, many never-adopters)
- ✓ Census PUMS API accessible with ESR (employment), FER (recent birth), WAGP (wages)
- ✓ Sample: working-age women (25-44) who gave birth in last 12 months
- ✓ Modern DiD methods available (did, fixest packages)

---

## Idea 2: Recreational Cannabis Legalization and Employment

**Policy:** State recreational cannabis legalization with retail sales
- Colorado/Washington: January 2014
- Oregon: October 2015
- Alaska: October 2016
- Nevada: July 2017
- California: January 2018
- Massachusetts: November 2018

**Outcome:** Labor force participation and wages (Census ACS PUMS)

**Identification:** Staggered DiD comparing employment outcomes in states with legal recreational cannabis retail sales vs. non-legal states.

**Why it's novel:**
- Most cannabis studies focus on crime, traffic safety, or health
- Employment effects less studied, especially with modern DiD methods
- Use retail sales date (not ballot measure) as treatment timing

**Feasibility check:**
- ✓ Clear staggered adoption (6+ states 2014-2018)
- ✓ Census PUMS accessible for employment data
- ✓ Never-treated states available as controls
- ? Concern: Many confounders (other state policies, selection into legalization)

---

## Idea 3: Right-to-Work Laws and Union Membership

**Policy:** State right-to-work (RTW) law adoptions
- Indiana: February 2012
- Michigan: March 2013
- Wisconsin: March 2015
- West Virginia: July 2016
- Kentucky: January 2017

**Outcome:** Union membership rates, wages, employment (Census ACS PUMS or CPS)

**Identification:** Staggered DiD comparing labor outcomes in states that recently adopted RTW vs. non-RTW states and long-standing RTW states.

**Why it's novel:**
- Recent wave of RTW adoptions (2012-2017) provides fresh variation
- Most RTW literature uses older adoptions
- Can examine heterogeneity across industries with different union density

**Feasibility check:**
- ✓ Clear staggered adoption (5 states 2012-2017)
- ✓ ACS PUMS has union membership variable available
- ✓ Never-adopted states as controls
- ? Concern: Political selection into RTW adoption may violate parallel trends

---

## Recommendation

**Pursue Idea 1 (Paid Family Leave)** as the primary candidate because:
1. Clearest policy variation with explicit benefit start dates
2. Well-defined treatment population (women who recently gave birth)
3. Less selection concerns compared to cannabis/RTW (states adopted PFL for various political reasons)
4. Rich outcome variation (employment, hours, wages)
5. Novel contribution: multi-state DiD with modern methods, not just California

**Backup: Idea 2 (Cannabis)** if PFL parallel trends fail.
