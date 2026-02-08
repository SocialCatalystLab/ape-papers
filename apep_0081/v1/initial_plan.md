# Initial Research Plan

**Paper:** Roads, Crashes, and Substances: A Geocoded Atlas of US Traffic Fatalities 2001-2023

**Date:** 2026-01-29

**Type:** Descriptive Data Paper

---

## Vision

Create a **data showcase paper** that demonstrates the research potential of integrating FARS crash data with OpenStreetMap road networks at unprecedented granularity. This is NOT a causal paper---it's a foundation paper that:

1. Creates a novel integrated dataset (FARS + OSM + marijuana/alcohol policy)
2. Demonstrates granularity with stunning visualizations
3. Documents patterns that future causal research can exploit
4. Provides replication code for the research community

---

## Geographic Focus: Western Marijuana States

### Core States (Legal Recreational)

| State | Rec Legal | Retail Open | Key Borders |
|-------|-----------|-------------|-------------|
| Colorado | Dec 2012 | Jan 2014 | WY, NE, KS, UT, NM |
| Washington | Dec 2012 | Jul 2014 | ID, OR |
| Oregon | Jul 2015 | Oct 2015 | ID, WA, CA, NV |
| Alaska | Feb 2015 | Oct 2016 | (isolated) |
| California | Jan 2018 | Jan 2018 | AZ, NV, OR |
| Nevada | Jan 2017 | Jul 2017 | CA, AZ, UT, ID, OR |

### Comparison States (Illegal During Key Period)

| State | Status | Borders With |
|-------|--------|--------------|
| Wyoming | Fully illegal | CO |
| Nebraska | Fully illegal | CO |
| Kansas | Fully illegal | CO |
| Idaho | Fully illegal | WA, OR, NV |
| Utah | Medical only (2018) | CO, NV |
| Arizona | Medical only -> Rec 2020 | CA, NV |

### Key Border Pairs for Analysis

1. **CO-WY**: Sharpest contrast, major I-25 corridor
2. **WA-ID**: I-90 corridor, significant cross-border traffic
3. **OR-ID**: Rural but important for agriculture/trucking
4. **CA-AZ**: I-10, I-8 corridors, high traffic
5. **NV-UT**: I-15 corridor, Las Vegas traffic

---

## Core Dataset to Build

| Component | Source | Granularity | Years |
|-----------|--------|-------------|-------|
| Fatal crashes | FARS (NHTSA) | Lat/lon (~1m) | 2001-2023 |
| Road network | OpenStreetMap | Road segment | Current + snapping |
| Drug/alcohol | FARS person file | Individual test results | 2001-2023 |
| Marijuana policy | Harvard Dataverse + manual | State-day | 1994-2023 |
| State borders | Census TIGER | Vector polygons | 2020 |

**Final integrated dataset:** ~200-300K crashes in Western states with road attributes, substance involvement, and policy exposure.

---

## Paper Structure (Target: 35-40 pages)

### 1. Introduction (3 pages)
- Motivation: Traffic fatalities are a leading cause of death; policy research needs better data
- Gap: Existing studies use aggregated data; geocoded potential is underexploited
- Contribution: First comprehensive integration of FARS + OSM + policy timing
- Roadmap for the paper

### 2. Data Sources and Integration (8 pages)

#### 2.1 FARS Overview
- Census of fatal crashes since 1975
- Geocoding quality by year (show precision improvement over time)
- Key variables: crash characteristics, person-level outcomes, substance tests

#### 2.2 OpenStreetMap Road Network
- Coverage and attributes (highway type, lanes, speed limits)
- Snapping methodology (osmnx, accuracy validation)
- What we can and cannot determine (direction of travel limitations)

#### 2.3 Policy Data
- Marijuana legalization timeline (state-level)
- Alcohol policy variation (BAC limits, serving hours)
- Border identification methodology

#### 2.4 Integration Pipeline
- Technical workflow diagram
- Matching crashes to road segments
- Assigning policy exposure based on crash location and date
- Data quality checks and validation

### 3. Descriptive Patterns: National Overview (6 pages)

#### 3.1 Temporal Trends
- Annual fatal crashes 2001-2023 (total, by substance involvement)
- THC-positive crash share over time (dramatic increase post-2012)
- Alcohol-positive crash share over time (secular decline)

#### 3.2 Geographic Distribution
- National heat map of crash density
- Crashes per capita by state
- Urban vs rural fatal crash rates

#### 3.3 Road Type Patterns
- Crashes by highway classification (Interstate, US Highway, State, Local)
- Speed limit distribution of fatal crashes
- Fatality rates by road type and lighting condition

### 4. Showcase: Zooming In (8 pages) --- THE MONEY SECTION

#### 4.1 State Border Zoom: Colorado-Wyoming
- Full page figure: CO-WY border region with every fatal crash 2014-2023
- Color by THC-positive (red) vs alcohol (blue) vs neither (gray)
- Inset: Timeline of THC-positive crashes by distance to border

#### 4.2 Highway Segment Zoom: I-25 Corridor
- 50-mile stretch of I-25 near Denver
- Individual crashes snapped to road segments
- Crash clustering at specific locations

#### 4.3 Urban Zoom: Denver Metro
- Denver area with crashes by time of day
- Road network detail showing arterials

#### 4.4 Rural Zoom: Eastern Oregon / Idaho Border
- Sparse rural area showing crash clustering on major roads
- Border region patterns

### 5. Substance Involvement Patterns (6 pages)

#### 5.1 Alcohol Trends
- BAC distribution among tested drivers
- Alcohol involvement by time of day, day of week
- Alcohol involvement trends by state

#### 5.2 Drug Trends
- THC-positive rate over time, by state legalization status
- Drug type distribution (THC, amphetamines, opioids, etc.)
- Poly-substance involvement (alcohol + THC)
- Testing rates and positivity rates by state

#### 5.3 The Substitution Question (Descriptive)
- Alcohol vs THC involvement in legal states over time
- Show raw patterns WITHOUT causal claims

### 6. Policy Border Patterns (5 pages)

#### 6.1 Marijuana Legalization Borders
- Crash density by distance to legal/illegal border
- THC-positive rate by distance to border

#### 6.2 Time Patterns at Borders
- Event study style plot showing THC-positive rates before/after legalization
- Purely descriptive - no causal language

### 7. Data Quality and Limitations (3 pages)

#### 7.1 Geocoding Quality
- Precision by year
- Validation against known locations
- Snapping accuracy assessment

#### 7.2 Substance Testing Limitations
- Document the ~65% missing rate for drug tests
- Testing varies by state, crash severity, driver survival
- Selection concerns for causal research

#### 7.3 Road Network Limitations
- OSM coverage gaps
- Direction of travel inference challenges
- Speed limit data coverage

### 8. Research Applications (2 pages)

#### 8.1 Spatial RDD Opportunities
- List border pairs with clean policy contrasts
- Sample size assessment by border

#### 8.2 Difference-in-Differences Opportunities
- Staggered adoption of marijuana legalization
- Within-state county variation

#### 8.3 Mechanism Analysis Potential
- THC vs alcohol substitution
- Time of day / day of week patterns
- Road type interactions

### 9. Conclusion (1 page)

### Appendix A: Technical Documentation (5 pages)
- Complete variable codebook
- R/Python code snippets for replication
- API access instructions

### Appendix B: Additional Maps and Figures (5 pages)

---

## Key Figures List (20+ figures)

| # | Description | Type | Purpose |
|---|-------------|------|---------|
| 1 | National crash density heatmap | Choropleth | Overview |
| 2 | Annual crashes time series | Line plot | Trends |
| 3 | THC-positive rate over time | Line plot | Drug trends |
| 4 | Alcohol-positive rate over time | Line plot | Comparison |
| 5 | **CO-WY border zoom** | Map | Granularity showcase |
| 6 | **I-25 corridor zoom** | Map | Road-level detail |
| 7 | **Denver metro zoom** | Map | Urban detail |
| 8 | **OR-ID border zoom** | Map | Rural detail |
| 9 | BAC distribution histogram | Histogram | Alcohol patterns |
| 10 | Crashes by hour of day | Bar chart | Temporal |
| 11 | Crashes by day of week | Bar chart | Temporal |
| 12 | Drug type breakdown | Stacked bar | Drug patterns |
| 13 | THC vs alcohol over time (legal states) | Dual line | Substitution |
| 14 | Crashes by road type | Bar chart | Infrastructure |
| 15 | Crash density vs distance to legal border | Line plot | Border patterns |
| 16 | THC-positive by distance to border | Line plot | Border patterns |
| 17 | Event study: THC rates around legalization | Event study | Timing |
| 18 | Testing rate by state | Choropleth | Data quality |
| 19 | Geocoding precision by year | Line plot | Data quality |
| 20 | OSM attribute coverage | Bar chart | Data quality |

---

## Code Structure

```
output/paper_108/code/
├── 00_packages.R          # Load libraries, set ggplot theme
├── 01_fetch_fars.R        # Download FARS 2001-2023
├── 02_fetch_osm.py        # OSM road network (Python)
├── 03_snap_crashes.py     # Snap to roads (Python)
├── 04_merge_policy.R      # Add policy variables
├── 05_build_analysis.R    # Final dataset
├── 06_national_figures.R  # Overview figures
├── 07_zoom_figures.R      # Granularity showcase
├── 08_substance_figures.R # Drug/alcohol patterns
├── 09_border_figures.R    # Policy border analysis
└── 10_tables.R            # Summary tables
```

---

## Risks & Mitigations

| Risk | Probability | Mitigation |
|------|-------------|------------|
| FARS lat/long missing pre-2000 | Medium | Focus on 2001-2023; note limitation |
| Few crashes near some borders | Medium | Pool across borders; report individual border estimates |
| Road distance computation slow | Low | Use efficient routing (sfnetworks, dodgr) |
| THC testing selection | High | Document thoroughly; flag for causal research |
| Null patterns at borders | Medium | Report honestly; descriptive is informative |

---

## Why This Paper Matters

1. **Novel contribution:** First comprehensive FARS + OSM integration
2. **Research enabler:** Provides foundation for dozens of causal studies
3. **Beautiful:** The zoom figures will be stunning and shareable
4. **Practical:** Replication code enables others to extend
5. **Timely:** Marijuana legalization research is hot; this enables better work
