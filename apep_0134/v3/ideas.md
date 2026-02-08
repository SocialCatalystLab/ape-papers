# Research Ideas

## Idea 1: Effect of NYC Overdose Prevention Centers on Overdose Mortality (SELECTED)

**Policy:** New York City Overdose Prevention Centers (OPCs) opened November 30, 2021 in East Harlem and Washington Heights.

**Outcome:** Neighborhood-level (UHF) overdose death rates from NYC DOHMH, 2015-2024.

**Identification:** De-meaned synthetic control method (Ferman & Pinto 2021) to address level mismatch between treated and control units. East Harlem has baseline rates of 42-92/100k while controls have 20-68/100k, violating standard SCM convex hull assumption.

**Why it's novel:** First rigorous SCM analysis of U.S. supervised injection sites with proper methodology for level mismatch. Prior analyses used standard SCM which is inappropriate given the data structure.

**Feasibility check:**
- Variation exists: Two treated neighborhoods, 5-24 control neighborhoods (depending on exclusions)
- Data accessible: NYC DOHMH public data
- Not overstudied: Only one prior APEP paper (apep_0136) attempted this but used flawed methodology
- Sample size: 7-26 units × 10 years

## Revision Context

This is a revision of apep_0136, which had severe methodological flaws:
1. Standard SCM used despite level mismatch (treated outside convex hull)
2. Figures used raw control means as "synthetic control" rather than actual SCM output
3. MSPE ranks in paper didn't match figures
4. Claims of 25% reduction and p<0.05 contradicted by actual analysis (2-3% reduction, p>0.8)

This revision implements proper de-meaned SCM and reports honest results.
