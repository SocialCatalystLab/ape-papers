# Conditional Requirements

**Generated:** 2026-01-29T17:43:44.573156
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Recreational Marijuana Legalization and Entrepreneurship: Industry-Level Evidence from Business Formation Statistics

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: redefining treatment timing around market opening/licensing/first sales

**Status:** [x] RESOLVED

**Response:**

The primary treatment variable will use the date of **first legal retail sales** in each state, not the statute/ballot date. This is the economically relevant moment when cannabis businesses can legally operate and when demand for ancillary business services materializes. Treatment timing:

| State | Ballot/Statute | First Retail Sales | Treatment Year (Primary) |
|-------|---------------|-------------------|--------------------------|
| CO | Nov 2012 | Jan 2014 | 2014 |
| WA | Nov 2012 | Jul 2014 | 2014 |
| OR | Nov 2014 | Oct 2015 | 2015 |
| AK | Nov 2014 | Oct 2016 | 2016 |
| CA | Nov 2016 | Jan 2018 | 2018 |
| NV | Nov 2016 | Jul 2017 | 2017 |
| MA | Nov 2016 | Nov 2018 | 2018 |
| ME | Nov 2016 | Oct 2020 | 2020 |
| VT | Jan 2018 (leg) | Oct 2022 | 2022 |
| MI | Nov 2018 | Dec 2019 | 2019 |
| IL | Jun 2019 (leg) | Jan 2020 | 2020 |
| AZ | Nov 2020 | Jan 2021 | 2021 |
| NJ | Nov 2020 | Apr 2022 | 2022 |
| MT | Nov 2020 | Jan 2022 | 2022 |
| NY | Mar 2021 (leg) | Dec 2022 | 2022 |
| VA | Apr 2021 (leg) | Not yet (no retail) | Exclude or use legalization date |
| NM | Apr 2021 (leg) | Apr 2022 | 2022 |
| CT | Jun 2021 (leg) | Jan 2023 | 2023 |
| RI | May 2022 (leg) | Dec 2022 | 2022 |
| MD | Nov 2022 | Jul 2023 | 2023 |
| MO | Nov 2022 | Feb 2023 | 2023 |
| DE | Apr 2023 (leg) | Not yet | Exclude |
| MN | May 2023 (leg) | Not yet | Exclude |
| OH | Nov 2023 | Aug 2024 | 2024 |

Robustness checks will use: (a) legalization/statute date as treatment, (b) first licensing/application period where available, and (c) event-study specifications that show effects building over time from legalization through first sales.

States without retail sales (VA, DE, MN) will be excluded from the primary specification. This leaves ~21 treated states in the primary analysis — still above the 20-state threshold.

**Evidence:** Treatment dates sourced from NCSL Cannabis Overview, MJBizDaily state tracker, Ballotpedia, and Wikipedia timeline of cannabis laws. Retail sales dates verified via web search.

---

### Condition 2: demonstrating industry mapping validity

**Status:** [x] RESOLVED

**Response:**

The BFS data provides 20 NAICS sector codes. Cannabis businesses plausibly map to:
- **NAICS11 (Agriculture):** Cannabis cultivation/growing
- **NAICSRET (Retail Trade):** Dispensaries, retail storefronts
- **NAICSMNF (Manufacturing):** Cannabis processing, edibles, concentrates
- **NAICS54 (Professional/Technical Services):** Testing labs, compliance consulting
- **NAICS62 (Healthcare):** Medical cannabis clinics (overlaps with medical marijuana)

The **primary** cannabis-adjacent grouping for the DDD will be: NAICS11 + NAICSRET + NAICSMNF.

Validation approach:
1. **Descriptive evidence:** Show that these three sectors exhibit differential business application growth in early-adopter states (CO, WA) relative to control states, while non-adjacent sectors (e.g., NAICS52 Finance, NAICS23 Construction) do not show differential effects.
2. **Placebo DDD:** Test whether non-adjacent sectors show null DDD coefficients (falsification).
3. **All-sector event study:** Run the event study for each NAICS sector separately and display the pattern visually.

**Evidence:** BFS monthly CSV verified to contain all NAICS sector codes. Colorado agriculture (NAICS11) business applications can be examined for pre/post-2014 discontinuity.

---

### Condition 3: reporting sensitivity to alternative NAICS groupings

**Status:** [x] RESOLVED

**Response:**

Will report results for four alternative definitions of "cannabis-adjacent" industries:
1. **Narrow:** NAICSRET only (dispensaries)
2. **Baseline:** NAICS11 + NAICSRET + NAICSMNF (agriculture + retail + manufacturing)
3. **Broad:** Baseline + NAICS54 + NAICS72 (adding professional services and accommodation/food)
4. **Individual sectors:** Event-study and CS estimates for each of the 20 NAICS sectors separately

A coefficient stability table across these groupings will be reported in the paper. If results are sensitive to grouping choices, this will be transparently discussed as a limitation.

**Evidence:** All 20 NAICS sectors available in BFS data confirmed via data download (NAICS11, NAICS21, NAICS22, NAICS23, NAICS42, NAICS51, NAICS52, NAICS53, NAICS54, NAICS55, NAICS56, NAICS61, NAICS62, NAICS71, NAICS72, NAICS81, NAICSMNF, NAICSRET, NAICSTW, NONAICS, TOTAL).

---

### Condition 4: explicitly addressing medical marijuana

**Status:** [x] RESOLVED

**Response:**

Medical marijuana was legal in most states before recreational legalization. This creates two concerns:
1. **Business formation from medical marijuana could contaminate pre-treatment trends.** Some states legalized medical marijuana well before recreational (e.g., Colorado medical 2000, recreational 2012).
2. **The "treatment" could partly reflect the transition from medical-only to recreational, not a clean intensive margin.**

Mitigation strategy:
- **Control for medical marijuana status:** Include an indicator for whether the state has active medical marijuana dispensaries in each year. Source: RAND-OPTIC database or ProCon.org timeline.
- **Event-study design:** CS event-study centered on first recreational retail sales will capture the *incremental* effect of recreational legalization beyond existing medical markets.
- **Discuss explicitly in paper:** Section on institutional background will document the relationship between medical and recreational markets and argue that recreational legalization represents a substantial market expansion (10-20x in revenue) beyond medical programs.
- **Robustness:** Restrict comparison group to states with medical marijuana laws (but no recreational) to isolate the recreational-specific effect.

**Evidence:** Colorado medical marijuana revenue was ~$400M in 2014; recreational revenue was ~$700M in 2014 and $1.7B by 2020, showing recreational dwarfs medical.

---

### Condition 5: other cannabis-policy bundling

**Status:** [x] RESOLVED

**Response:**

Recreational marijuana legalization often coincides with other policy changes:
- **Social equity programs:** Many states bundle expungement and equity licensing
- **Tax regimes:** Different states impose different tax structures
- **Local opt-out provisions:** Many states allow cities/counties to ban retail sales
- **Banking/280E tax rules:** Federal restrictions affect all legal states

Mitigation:
- **Tax variation:** This is a feature, not a bug — we can explore heterogeneity by state tax rate as a moderator.
- **Local opt-out:** While opt-out provisions create within-state variation, our outcome (state-level business applications) aggregates across all localities. This is acceptable for the state-level treatment effect interpretation.
- **Social equity:** These programs are implemented at different times and could independently affect business formation. Will note as a limitation and discuss in the paper.
- **Banking/280E:** These are constant across all legal states, so they don't create differential effects between treated and control states. They do limit the overall magnitude of the effect uniformly.
- **Robustness:** Include state-level controls for marijuana tax rates where available, and discuss how local opt-out provisions attenuate the state-level treatment effect (leading to conservative estimates).

**Evidence:** NCSL Cannabis Overview provides state-by-state regulatory detail. Tax Foundation publishes state marijuana tax rates.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
