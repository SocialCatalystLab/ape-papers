# Research Ideas

## Summary

These four ideas evaluate recent (post-2010) U.S. labor market policies using difference-in-differences. Each has been vetted for: (1) clean state-level variation in adoption timing, (2) accessible outcome data via public APIs, and (3) novelty relative to existing literature and APEP papers.

---

## Idea 1: Pay Transparency Laws and the Gender Wage Gap

**Policy:** State laws requiring employers to post salary ranges in job advertisements

**Adoption Timeline (Staggered):**
- Colorado: January 2021 (first state)
- Connecticut: October 2021 (upon request only)
- Washington: January 2023
- California: January 2023 (15+ employees)
- New York: September 2023 (4+ employees)
- Hawaii: January 2024 (50+ employees)
- Maryland: October 2024
- Illinois: January 2025

**Identification:** Staggered DiD comparing states that adopted salary range posting requirements vs. non-adopting states. Clean treatment timing with 30+ never-treated control states.

**Outcome Data:**
- Census QWI: Quarterly earnings by state, sex, industry, firm characteristics
- ACS PUMS: Individual wages, hours, occupation (no API key required)
- Both accessible via public Census API

**Why It's Novel:**
- One main paper exists (Arnold et al. NBER #34480) focusing on posted wages and average earnings
- Unexplored angles: effects on within-firm wage compression, gender wage gap specifically, differential effects by occupation/industry, effects on job-to-job transitions
- Very recent policy expansion (2023-2024) provides fresh variation not yet studied

**Feasibility Check:**
- Variation: Yes, clean staggered adoption 2021-2024
- Data: Confirmed - QWI and ACS PUMS APIs functional
- Not overstudied: One main paper, substantial room for contribution

---

## Idea 2: State EITC Expansions and Labor Force Participation

**Policy:** New state Earned Income Tax Credits or major expansions of existing credits

**Recent Adoptions/Expansions (2021-2023):**
- Washington: 2021 (first state without income tax to adopt EITC)
- Missouri: 2023 (new credit)
- Utah: 2023 (new credit)
- Hawaii: 2023 (made refundable)
- Michigan: 2023 (increased from 6% to 30% of federal)
- Connecticut: 2023 (increased to 40% of federal)
- Maryland: 2023 (increased to 45% of federal)

**Identification:** Staggered DiD exploiting variation in state EITC adoption and generosity changes. Compare labor supply outcomes in newly-adopting/expanding states vs. states with no EITC or constant EITC.

**Outcome Data:**
- ACS PUMS: Labor force participation, employment status, hours worked
- QWI: Employment counts, earnings
- All accessible via Census API (no key required)

**Why It's Novel:**
- Classic EITC literature (Meyer, Eissa-Liebman) studied federal expansions in 1990s
- Kleven (2024) challenged DiD identification for older reforms
- These 2021-2023 state-level changes have NOT been studied
- Can apply modern DiD methods (Callaway-Sant'Anna) to fresh policy variation

**Feasibility Check:**
- Variation: Yes, multiple states adopted/expanded 2021-2023
- Data: Confirmed - ACS PUMS API functional
- Novel: These specific recent expansions unstudied

---

## Idea 3: Noncompete Agreement Restrictions and Worker Mobility

**Policy:** State laws restricting or banning noncompete agreements

**Recent Policy Changes (2021-2023):**
- Minnesota: July 2023 (FULL BAN - first new full ban since Oklahoma in 1890)
- Oregon: 2021 (limited to 12 months, income threshold $100,533)
- Illinois: 2022 (banned for workers earning <$75,000)
- Colorado: 2022 (criminal penalties for improper noncompetes)
- D.C.: April 2022 (near-complete ban with income threshold $150k+)
- Nevada: 2021 (banned for hourly workers, penalty enforcement)

**Identification:** Staggered DiD comparing states that restricted noncompetes vs. states with no restrictions. Minnesota's 2023 full ban provides clean treatment; income threshold states provide additional variation.

**Outcome Data:**
- QWI: Job-to-job flows, earnings changes for job changers
- ACS PUMS: Occupation changes, self-employment
- BEA/Census: Business formation rates

**Why It's Novel:**
- Existing literature (Marx, Starr, Bishara) focused on California's longstanding ban or cross-sectional variation
- Minnesota's 2023 ban is the first new full ban in 130+ years - completely unstudied
- Recent income threshold laws (2021-2022) provide fresh quasi-experimental variation

**Feasibility Check:**
- Variation: Yes, Minnesota full ban + income threshold changes
- Data: Confirmed - QWI API functional
- Novel: Minnesota 2023 ban completely unstudied

---

## Idea 4: Tipped Minimum Wage Elimination and Service Sector Employment

**Policy:** State elimination of subminimum tipped wage (requiring full minimum wage for tipped workers)

**Current Landscape:**
- 7 states never allowed tip credit: AK, CA, MN, MT, NV, OR, WA
- Michigan: 2024 court ruling reinstated gradual elimination (then partially rolled back 2025)
- D.C.: Gradual elimination underway

**Identification:** DiD comparing employment and wages in states with vs. without subminimum tipped wage. Use the existing cross-state variation plus recent policy turbulence in Michigan.

**Outcome Data:**
- QWI: Restaurant/hospitality sector employment, earnings
- ACS PUMS: Wages for food service workers, hours worked
- BLS: Industry-specific employment

**Why It's Novel:**
- Most minimum wage research ignores tipped sector specifically
- Michigan's 2024 legal battle creates quasi-experimental variation
- Seven states have NEVER had subminimum wage - long-run comparison possible

**Feasibility Check:**
- Variation: Yes, 7 states vs. 43 states, plus Michigan changes
- Data: Confirmed - QWI has industry detail
- Concern: Michigan policy instability (court ruling then legislative rollback) may complicate identification

---

## Recommendation

**Pursue Idea 1 (Pay Transparency) or Idea 3 (Noncompete Restrictions)** as primary candidates.

- Both have recent, clean staggered adoption (2021-2024)
- Both are understudied relative to their policy importance
- Both have strong outcome data via public Census APIs
- Pay transparency has ONE main paper (room for contribution); noncompete has NO papers on Minnesota 2023 ban

**Idea 2 (State EITC)** is a strong backup but faces the Kleven critique on DiD identification for EITC effects.

**Idea 4 (Tipped Minimum Wage)** is interesting but Michigan's policy instability makes clean identification difficult.
