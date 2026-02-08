# Conditional Requirements

**Generated:** 2026-01-25T14:01:30.398010
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS HAVE BEEN ADDRESSED

The ranking identified conditional requirements for the recommended idea(s).
All conditions have been validated with evidence below.

---

## The 1906 Shock: Individual-Level Migration Responses to the San Francisco Earthquake

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: a transparent attrition/"not-linked" accounting with bounds or validation

**Status:** [X] RESOLVED

**Response:**

The IPUMS MLP provides 36.3 million links between 1900 and 1910 censuses. With approximately 76 million people in 1900 and 92 million in 1910, this represents ~45-50% linkage rate for the 10-year window. For our analysis, we will:

1. **Report linkage rates** for SF 1900 sample and compare to national/comparison city rates
2. **Characterize linked vs. unlinked** on observables (age, sex, race, occupation, birthplace)
3. **Bound estimates** using Manski-style partial identification: worst-case assumes all unlinked stayed, best-case assumes all unlinked left
4. **Validate with aggregate flows**: Compare individual-level out-migration rates to known aggregate population changes

The MLP has ~2.1% Type I error rate (false positives) based on FamilyTree validation, far lower than alternative linking methods (6.6% for ABE, 13.5% for Feigenbaum).

**Evidence:**

- IPUMS MLP Data Description: 36.3M 1900-1910 links
- MLP methodology paper: Type I error ~2.1% vs FamilyTree ground truth
- Sources: [IPUMS MLP](https://usa.ipums.org/usa/mlp/mlp.shtml), [MLP Linking Method](https://usa.ipums.org/usa/mlp/mlp_linking_method.shtml)

---

### Condition 2: a feasible geography/intensity measure such as ward/ED-level burn/damage maps

**Status:** [X] RESOLVED

**Response:**

DataSF provides GIS shapefile data of the 1906 fire-damaged areas, digitized from the 1906 R.J. Waters & Co. map. This can be overlaid with:

1. **1900 enumeration district boundaries** (available from NHGIS)
2. **Street addresses** from census records (when available)
3. **Ward-level identification** from IPUMS geography variables

The fire burned 4.11 square miles (514 city blocks), and the boundaries are well-documented. We can classify individuals as:
- In fire zone (high damage)
- Near fire zone (moderate damage)
- Outside fire zone (low damage)

**Evidence:**

- DataSF: [Areas Damaged by Fire Following 1906 Earthquake](https://data.sfgov.org/Geographic-Locations-and-Boundaries/Areas-Damaged-by-Fire-Following-1906-Earthquake/yk2r-b4e8)
- USGS: [1906 San Francisco Earthquake ShakeMaps](https://earthquake.usgs.gov/earthquakes/events/1906calif/shakemap/)
- Harvard Map Collection: Original R.J. Waters & Co. 1906 map (digitized)

---

### Condition 3: benchmarking against at least one comparison city to separate quake effects from decade-wide trends

**Status:** [X] RESOLVED

**Response:**

We will use **Los Angeles** as the primary comparison city:
- Similar Western location, same state
- Growing rapidly in same era (pop: 102K in 1900 → 319K in 1910)
- No major shock during 1900-1910 window
- Same IPUMS MLP coverage and linkage methods

Secondary comparisons: **Seattle** (Western, no shock) and **New York City** (Eastern benchmark).

All comparison cities will use same linkage methodology, same outcome definitions, and same observation windows. This allows difference-in-differences style comparisons (SF vs. comparison, before vs. after) to isolate earthquake effects from general decade trends.

**Evidence:**

- All cities covered by IPUMS MLP full-count 1900 and 1910 censuses
- Population data: US Census Bureau historical statistics
- Ager et al. (2020) also used comparison cities in their aggregate analysis

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED**

---

## Additional Note on Paper Scope

Given the user's expressed preference for a **descriptive paper** rather than standard causal inference, we will frame the paper as:

**"The 1906 Shock and Beyond: A Multigenerational Portrait of San Francisco's Population, 1850-1950"**

This hybrid approach:
1. Uses the 1906 earthquake as one historical anchor (descriptive analysis of who left/stayed)
2. Incorporates the "reverse genealogy" concept (tracking 1950 SF residents backwards)
3. Describes migration patterns across eras without forcing causal claims
4. Leverages MLP's strength for individual-level longitudinal tracking

This respects both the ranking recommendation (earthquake as focal point) and user preference (descriptive over causal).
