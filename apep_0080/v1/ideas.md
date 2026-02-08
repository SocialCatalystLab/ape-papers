# Research Ideas

## Idea 1: Click It or Ticket at the Border: A Spatial Regression Discontinuity Analysis of Primary Seatbelt Enforcement Laws

**Policy:** Primary seatbelt enforcement laws, which allow police to stop and cite drivers solely for not wearing a seatbelt (vs. secondary enforcement, which requires another violation first). Staggered adoption across 35 states from 1993 (California) through 2023 (North Dakota), creating dozens of policy borders at different times.

Key adoption dates:
- CA (1993), LA (1995), GA (1996), OK/MD/DC (1997), IN (1998), AL (1999), MI/NJ (2000), WA (2002), DE/IL (2003), TN (2004), SC (2005), AK/KY/NC (2006), ME (2007), AR/FL/MN/WI (2009), KS (2010), RI (2011), WV (2013), UT (2015), ND (2023)

Still secondary: AZ, CO, ID, MA, MO, MT, NE, NV, NH, SD, VT, VA, WY

**Outcome:** Fatal crash data from NHTSA's Fatality Analysis Reporting System (FARS), 1990-2020. FARS includes exact latitude/longitude coordinates for each fatal crash, enabling precise distance-to-border calculations.

**Identification:** Spatial regression discontinuity design (Spatial RDD) comparing fatal crashes on either side of state borders where one state has primary enforcement and the other has secondary enforcement.

Running variable: Road network distance from crash location to the nearest primary/secondary enforcement border (not Euclidean distance—using the actual road the crash occurred on).

This creates a multi-cutoff RDD with:
- Cross-sectional variation: 15+ active primary vs. secondary borders
- Temporal variation: Borders "turn on" as states adopt primary enforcement
- Placebo power: Pre-adoption years serve as placebo RDDs (no treatment effect expected)

**Economic Model:**

*Behavioral mechanism:* Primary enforcement increases the expected cost of not wearing a seatbelt by:
1. Raising detection probability (police can stop you for seatbelt alone)
2. Increasing salience (dedicated enforcement campaigns like "Click It or Ticket")

This higher expected cost → higher seatbelt compliance → conditional on crash occurring, lower probability of fatal injury.

*Testable predictions:*
- Effect should be on fatality rate conditional on crash, NOT on crash rate itself (seatbelts don't prevent crashes)
- Larger effects for ejection deaths (seatbelts prevent ejection)
- No effect on pedestrian/cyclist fatalities (placebo)
- Single-vehicle crashes may show larger effects (pure driver behavior)
- Effects should persist at distance from border (not just border crossing behavior)

**Why it's novel:**
- Existing literature (Cohen & Einav 2003, NHTSA studies) uses state-year panel DiD
- NO existing spatial RDD at state borders for seatbelt laws
- Our design addresses unobserved state-level heterogeneity by comparing similar locations near borders
- Staggered adoption + geographic variation = powerful identification

**Feasibility check:**
- FARS data confirmed available 1975-2020 with lat/long (API for 2010+, FTP for earlier)
- Census TIGER provides state boundary shapefiles
- OpenStreetMap/TIGER provides road network for network distance
- 35 states adopted primary = many borders, many years
- Not overstudied: Google Scholar shows ~50 papers on seatbelt laws, NONE using spatial RDD

**Visual elements (high impact):**
1. National map showing primary (green) vs secondary (red) states with border crash density
2. Individual RDD plots for each major border (CO-KS, VA-NC, etc.)
3. Pooled multi-cutoff RDD plot
4. Before/after maps showing effect emergence at treatment borders
5. Road network distance distribution histogram
6. Event study at border counties around adoption dates
7. Mechanism decomposition: fatality by crash type (ejection, rollover, frontal impact)
8. Placebo: pedestrian fatality RDD (should show null)

---

## Idea 2: Texting While Dying: A Spatial RDD of Distracted Driving Laws

**Policy:** Primary enforcement texting-while-driving bans. Staggered adoption from Washington (2008) through ~2015 for most states. 49 states now have bans, but enforcement type (primary vs secondary) varies.

**Outcome:** FARS geocoded crash data, focusing on:
- Total fatalities
- Single-vehicle crashes (most likely distraction-caused)
- Daytime crashes (when texting more common)

**Identification:** Spatial RDD at borders between primary-ban and secondary-ban (or no-ban) states.

**Economic Model:**
- Primary enforcement → higher expected fine for texting → reduced texting while driving → fewer distraction-caused crashes
- Unlike seatbelts, this affects CRASH RATE, not just fatality|crash
- Mechanism test: Should see effects on single-vehicle, daytime, run-off-road crashes (typical distraction profile)

**Why it's novel:**
- Existing literature uses state-year DiD (Abouk & Adams 2013, Lim & Chi 2017)
- No spatial RDD at borders
- Cleaner mechanism than seatbelts (affects crashes, not just survivability)

**Feasibility check:**
- FARS confirmed with lat/long
- State adoption dates well-documented (GHSA, IIHS)
- Multiple borders exist
- Slightly less variation than seatbelt laws (more compressed adoption period)

**Concerns:**
- Shorter pre-period (texting wasn't common pre-2005)
- Technology evolution (smartphone adoption) is confound
- Harder to isolate mechanism (distraction vs other factors)

---

## Idea 3: Slower Neighbors, Safer Roads? Speed Limit Differentials and Border Crashes

**Policy:** State maximum speed limit increases (from 65/70 to 75/80 mph) on rural interstates. Staggered adoption 2010-2020: WY (2014), ID (2014), SD (2015), MT (2015), NV (2017), etc.

**Outcome:** FARS crashes on rural interstates, geocoded. Focus on:
- Fatal crash rate per VMT
- Crash severity (fatalities per crash)
- Speed-related crashes (single vehicle, rollover)

**Identification:** Spatial RDD at borders between high-limit and low-limit states, specifically on interstate highways that cross the border.

**Economic Model:**
- Higher speed limits → faster actual speeds → more kinetic energy → more severe crashes
- Effect is mechanical (physics), not behavioral deterrence
- Running variable: Road distance along the specific interstate to the border

**Why it's novel:**
- Classic speed limit literature (Ashenfelter & Greenstone 2004) uses time-series/cross-section
- Spatial RDD at speed limit borders is unexplored
- Clean mechanism: physics of impact

**Feasibility check:**
- FARS available
- Speed limits well-documented (IIHS)
- Fewer borders than seatbelt (only ~10 states raised to 75-80)
- Need to restrict to rural interstates (where limits differ)

**Concerns:**
- Limited number of borders
- Speed limits often change at state line anyway (signage)
- VMT data may be coarse

---

## Idea 4: High Times at the Border: Recreational Marijuana and Traffic Safety

**Policy:** Recreational marijuana legalization. Staggered: CO/WA (2012), OR/AK (2014), CA/NV/MA (2016), etc. Now 24 states.

**Outcome:** FARS crashes geocoded, especially:
- Drug-involved crashes (FARS has drug test indicators)
- Nighttime/weekend crashes
- Single-vehicle crashes

**Identification:** Spatial RDD at legalization borders.

**Economic Model:**
- Legal access → increased cannabis consumption → impaired driving → more crashes
- BUT: Substitution from alcohol (which is worse for driving) → fewer crashes
- Net effect is empirical question

**Concerns (why NOT top choice):**
- Heavy prior literature including some spatial work (Dragone et al. on WA-OR border for crime)
- Spillover problem: People cross border to buy, consume, then crash going home
- Treatment assignment unclear (residence vs purchase vs consumption location)

---

## Ranking

1. **Idea 1 (Primary Seatbelt Laws)** - PURSUE
   - Most borders (35 states adopted)
   - Longest time series (1993-2020)
   - Cleanest mechanism (compliance → survival|crash)
   - Zero spatial RDD papers exist
   - Excellent for impressive visuals (many border maps)

2. **Idea 2 (Texting Bans)** - CONSIDER
   - Good variation but compressed timeline
   - Mechanism affects crash rate (harder to isolate)
   - Smartphone adoption is confound

3. **Idea 3 (Speed Limits)** - CONSIDER
   - Very clean mechanism (physics)
   - Limited borders (only ~10 states)
   - May not have enough power

4. **Idea 4 (Marijuana)** - SKIP
   - Prior spatial work exists
   - Spillover/sorting concerns
   - Not novel enough
