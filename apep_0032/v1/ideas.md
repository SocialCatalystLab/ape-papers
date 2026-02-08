# Paper 42: Research Ideas

**Focus:** Permanent Income Hypothesis (PIH) + Gender + IPUMS Full Count Census

**Constraint:** Must use historical policies (1850-1940) where we can test whether individuals respond to expected permanent income changes differently by gender.

---

## Idea 1: Compulsory Schooling Laws and Mother's Labor Supply

### Policy
States mandated school attendance at different times:
- Massachusetts (1852) - first state
- New York (1853)
- Connecticut (1872)
- Spread across states through 1918 (Mississippi last)

Child labor laws similarly restricted child employment by age (varied by state, 12-16 age cutoffs).

### PIH Mechanism
**This is a clean PIH test.** When child labor laws take effect:
- Household permanent income DROPS (child can no longer contribute earnings)
- If household believes this is permanent, consumption adjusts downward
- If believed temporary, household may borrow or increase other labor supply

**Mother's labor supply response reveals PIH:**
- If mothers enter workforce **temporarily** → treating the shock as transitory
- If mothers enter workforce **permanently** → treating the shock as permanent income loss
- Compare to households where child dies (clearly permanent shock)

### Gender Heterogeneity
- Do mothers vs. fathers respond differently?
- Are effects stronger for single mothers vs. married?
- Does mother's labor supply depend on father's occupation (income insurance)?

### Data
- **IPUMS Full Count:** 1880, 1900, 1910, 1920, 1930
- **Outcomes:** Mother's labor force participation (OCC1950), occupation type, household composition
- **Treatment:** State × year compulsory schooling age × child ages
- **Link:** Match mothers to children in households

### Identification
Difference-in-differences: Compare labor supply of mothers whose children are just below vs. just above compulsory schooling age, in states before vs. after law adoption.

### Feasibility Assessment
- **Data:** Full count census has household structure, mother's occupation
- **State variation:** 50+ years of staggered adoption (1852-1918)
- **Clusters:** All 48 states
- **Pre-treatment:** Multiple census years before treatment for most states
- **Prior research:** Aizer (2004) studied children's outcomes; less focus on mother's labor supply response
- **Concerns:**
  - Mothers' occupation underreported in census (Goldin correction needed)
  - Need to properly link mothers to children in household structure
  - Compulsory schooling and child labor laws often passed together

### Verdict: **PURSUE** (strong PIH test, novel gender angle, good data fit)

---

## Idea 2: Civil War Widow Pensions and Female Labor Supply

### Policy
Federal pensions for Union widows expanded over time:
- 1862: Widows of soldiers who died in service
- 1890: **Major expansion** - widows of ANY honorably discharged veteran who died (not just service-related)
- 1901: Widows who remarried and became widowed again could claim
- 1916: All widows of honorably discharged veterans eligible

Confederate states had separate pension systems:
- Georgia (1879), Alabama (1886), Virginia (1888), etc.
- Much more limited benefits

### PIH Mechanism
**The 1890 expansion is a quasi-experimental income shock.** Pre-1890, only widows of soldiers who died from service-related causes received pensions. After 1890, any widow whose veteran husband died (from any cause) became eligible.

- This is a **permanent income shock** (pension continues until death/remarriage)
- PIH predicts: consumption should increase, labor supply should decrease
- Can compare widows who became eligible in 1890 to non-eligible widows

### Gender Focus
- Pensions directly targeted women (widows)
- Tests how women respond to permanent income when not mediated through marriage
- Can compare Union states (pension available) vs. Confederate states (limited pensions)

### Data
- **IPUMS Full Count:** 1880, 1900, 1910
- **Outcomes:** Widow labor force participation, occupation type, household composition, property ownership
- **Treatment:** Post-1890 × Union state × widowed status
- **Challenge:** Cannot directly identify veteran widows vs. non-veteran widows

### Identification
Triple-difference:
1. Widows vs. non-widows
2. Union states vs. Confederate states
3. Pre-1890 (1880) vs. post-1890 (1900, 1910)

### Feasibility Assessment
- **Data:** Census has marital status (MARST), occupation, state
- **Challenges:**
  - Cannot identify veteran widows specifically (pension records not in census)
  - Could use county-level veteran population from 1890 Veterans Census as proxy
  - Missing 1890 census limits timing precision
- **Prior research:** Salisbury (2015) studied remarriage; labor supply less explored
- **Novelty:** Labor supply response to widows' pensions underexplored

### Verdict: **CONDITIONAL PURSUE** (need to solve veteran widow identification)

---

## Idea 3: Women's Suffrage and Female Human Capital Investment

### Policy
States granted women voting rights at different times:
- Wyoming Territory (1869) - first
- Colorado (1893)
- Utah, Idaho (1896)
- Washington (1910), California (1911)
- Many states 1912-1918
- 19th Amendment (1920) - federal

### PIH Mechanism
**Suffrage changes expected permanent income through multiple channels:**
1. Political power → more government spending on issues women care about
2. Economic opportunities → reduced discrimination
3. Bargaining power within marriage → better claim on household resources

**If women anticipate these changes, PIH predicts forward-looking investment:**
- More education (human capital)
- Higher-earning occupations
- Property accumulation

### Gender Focus
- Central to the research design: compare women (treated) to men (placebo)
- Can also compare single vs. married women
- Test whether effects are driven by single women (direct political power) vs. married women (household bargaining)

### Data
- **IPUMS Full Count:** 1900, 1910, 1920, 1930
- **Outcomes:** Female literacy (LIT), school attendance (SCHOOL), occupational income (OCCSCORE), occupation type, property (REALPROP - limited years)
- **Treatment:** State × year suffrage adoption × gender

### Identification
Difference-in-differences-in-differences:
- Female vs. male (gender placebo)
- Suffrage states vs. non-suffrage states
- Pre vs. post suffrage

### Feasibility Assessment
- **Data:** Strong variable availability, literacy and occupation in all years
- **State variation:** 50+ years of staggered adoption (1869-1920)
- **Clusters:** All 48 states, plus territories
- **Prior research:**
  - Miller (2008) studied child mortality (government responsiveness)
  - Less focus on human capital investment and occupational outcomes
- **Concerns:**
  - Suffrage may be endogenous to women's economic status
  - Many states adopted suffrage close together (1910-1920)
  - Federal adoption (1920) limits post-period for late adopters

### Verdict: **PURSUE** (clear PIH + gender design, good data, some novelty in outcomes)

---

## Idea 4: Married Women's Property Acts and Black Women's Economic Outcomes

### Policy
Same as described in Paper 41: States passed MWPAs 1839-1900.

### Why This Angle is Novel
Prior research found: *"the effects of change in married women's property legislation on married women's labor force participation was trivially small and negative for white women. For black women, initial results suggest that the property laws could have had an effect."*

**Black women faced different constraints:**
- Already high labor force participation (often not voluntary)
- Wealth accumulation nearly impossible under slavery, limited after
- MWPAs may have enabled protection of meager earnings from husbands' creditors
- Full count census now enables sufficient sample size for Black subgroup analysis

### PIH Mechanism
- MWPAs increased Black women's expected return to labor (could keep earnings)
- Should lead to occupational upgrading (higher-earning jobs) even if participation unchanged
- Property accumulation should increase (now protected)

### Gender + Race Intersection
- Compare Black women to Black men (gender effect)
- Compare Black women to white women (race heterogeneity)
- Focus on Southern states post-1865 (when Black women could accumulate property)

### Data
- **IPUMS Full Count:** 1870, 1880, 1900, 1910
- **Outcomes:** Occupation type, occupational income score (OCCSCORE), property (REALPROP 1870 only)
- **Treatment:** State × year MWPA adoption × race × gender

### Identification
Quadruple-difference:
- Black vs. white
- Female vs. male
- MWPA states vs. non-MWPA states
- Pre vs. post MWPA

### Feasibility Assessment
- **Data:** Full count has race, gender, occupation
- **Challenges:**
  - Most MWPAs passed before 1870, limiting pre-treatment for post-war analysis
  - Some Southern states passed MWPAs during Reconstruction (1865-1877)
  - REALPROP only available 1870 (one cross-section for post-war)
- **Novelty:** Black women's response to MWPAs largely unstudied

### Verdict: **CONDITIONAL PURSUE** (need to verify sufficient Southern MWPA variation post-1865)

---

## Idea 5: Homestead Acts and Female Land Ownership

### Policy
Homestead Act of 1862 allowed:
- Any adult citizen (or intending citizen) who was head of household or over 21
- **Single women and widows qualified** (married women did not, as husbands were heads)
- To claim 160 acres of public land
- After 5 years of residence and improvement, land became theirs

Later amendments:
- Enlarged Homestead Act (1909) - 320 acres in dry regions
- Stock-Raising Homestead Act (1916) - 640 acres

### PIH Mechanism
**Land ownership is a permanent wealth/income shock:**
- Free land = increase in expected permanent income
- Should affect marriage decisions, labor supply, fertility
- Single women faced unique choice: claim land (requires 5 years unmarried) vs. marry

### Gender Focus
- Single/widowed women could claim; married women could not
- Creates natural comparison: single women in homestead vs. non-homestead areas
- Can study marriage delay, occupational choice, wealth accumulation

### Data
- **IPUMS Full Count:** 1880, 1900, 1910, 1920
- **Outcomes:** Marital status (MARST), age at marriage, occupation, property ownership, fertility
- **Treatment:** Residence in homestead-eligible territory/state × single woman status
- **Geographic:** Focus on Great Plains, Mountain West

### Identification
Difference-in-differences:
- Homestead-eligible areas vs. non-eligible (Eastern states)
- Single women vs. married women
- Pre-Homestead Act (1860) vs. post (1880+)

### Feasibility Assessment
- **Data:** Census has residence, marital status, age
- **Challenges:**
  - Cannot identify actual homesteaders in census (no land claim records)
  - Selection: women who moved West may be different
  - Confounded with frontier vs. settled area differences
- **Prior research:** H. Elaine Lindgren studied female homesteaders, less focus on economic outcomes
- **Novelty:** Individual-level analysis of female homesteaders

### Verdict: **SKIP** (identification too weak - can't identify actual homesteaders, selection concerns)

---

## Summary and Ranking

| Idea | Policy | PIH Mechanism | Gender Focus | Data Fit | Identification | Verdict |
|------|--------|---------------|--------------|----------|----------------|---------|
| 1 | Compulsory Schooling | Strong (income shock) | Mother vs. father | GOOD | Strong DiD | **PURSUE** |
| 2 | Widow Pensions | Strong (permanent income) | Widows directly | MEDIUM | Triple-diff | CONDITIONAL |
| 3 | Women's Suffrage | Medium (expected income) | Female vs. male | GOOD | Triple-diff | **PURSUE** |
| 4 | MWPAs + Black Women | Medium (earnings rights) | Race × gender | MEDIUM | Quadruple-diff | CONDITIONAL |
| 5 | Homestead Acts | Strong (wealth shock) | Single women | POOR | Weak selection | SKIP |

**Recommended Priority:**

1. **Compulsory Schooling and Mother's Labor Supply** - Cleanest PIH test, novel outcome, good data
2. **Women's Suffrage and Human Capital Investment** - Strong gender design, PIH-consistent prediction
3. **Civil War Widow Pensions** - If veteran widow identification can be solved
4. **MWPAs + Black Women** - Backup, fills literature gap but data constraints

---

## Sources

- [IPUMS Full Count Data](https://usa.ipums.org/usa/full_count.shtml)
- [IPUMS Linked Data Samples](https://usa.ipums.org/usa/linked_data_samples.shtml)
- [Were Compulsory Attendance and Child Labor Laws Effective?](https://www.journals.uchicago.edu/doi/10.1086/340393) - Aizer (2004)
- [Women's Suffrage, Political Responsiveness, and Child Survival](https://academic.oup.com/qje/article-abstract/123/3/1287/1928181) - Miller (2008)
- [Women's Income and Marriage Markets: Civil War Pension](https://www.cambridge.org/core/journals/journal-of-economic-history/article/womens-income-and-marriage-markets-in-the-united-states-evidence-from-the-civil-war-pension/B60892B048CE7EB23CC3EAB2FF511535) - Salisbury (2015)
- [Married Women's Property Laws and Labor Force Participation](https://users.pop.umn.edu/~eroberts/eha2006.pdf) - Roberts et al.
- [Child Labor Reform Movement](https://www.bls.gov/opub/mlr/2017/article/history-of-child-labor-in-the-united-states-part-2-the-reform-movement.htm) - BLS
