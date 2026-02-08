# Research Ideas: San Francisco Migration and Multigenerational Trajectories

## Summary

This paper will be **descriptive and exploratory**, not standard causal inference. We leverage the IPUMS Multigenerational Longitudinal Panel (MLP) to study who migrated to San Francisco across multiple generations, what happened to them, and how selection into this frontier city shaped long-term outcomes. The approach is novel: **start from 1950, track backwards** through the genealogical links.

---

## Idea 1: "The Making of a City: Multigenerational Origins of San Francisco's 1950 Population"

**Core Question:** Where did San Francisco's 1950 population come from—not just geographically, but genealogically? By tracking backwards through linked census records, we can characterize the multi-generational origins of a modern American city.

**Approach:**
1. **Base sample:** All adults in 1950 census living in San Francisco County (STATEFIP=6, COUNTYFIP=75)
2. **Backward tracking:** Use HISTID links to trace individuals to 1940, 1930, 1920, 1910, 1900, 1880, 1870, 1860, 1850
3. **Family linking:** Use MOMLOC/POPLOC to identify parents' locations and characteristics at each census
4. **Analysis:** Map the geographic and socioeconomic "family trees" of SF's 1950 population

**Novel Descriptive Findings:**
- What fraction of 1950 SF residents can be traced to Gold Rush arrivals (1850-1860)?
- What fraction came from Eastern states vs. foreign-born lineages?
- How many generations has the "typical" SF family been in California?
- Are there distinct genealogical clusters (old SF families vs. recent arrivals)?

**Why Novel:**
- Previous studies of migration study *flows* (who moved when); we study *stocks* (the accumulated genealogical composition)
- This is a "reverse genealogy" at population scale—starting from endpoint, tracing origins
- No prior study has characterized a city's population by multigenerational migration history

**Data Feasibility:**
- 1950 SF County population: ~775,000 people
- MLP provides ~40-50% linking rate between adjacent censuses
- Backward tracking feasible through 6+ census waves

---

## Idea 2: "Selection into the Frontier: Comparing San Francisco Arrivals Across Eras (1850-1920)"

**Core Question:** Did the *type* of person who moved to San Francisco change as the city matured from frontier outpost to established metropolis? We test whether early pioneers were selected differently than later arrivals.

**Approach:**
1. **Sample construction:** Identify arrivals in each decade (people in SF who weren't there in prior census)
2. **Comparison groups:**
   - 1850s arrivals (Gold Rush era)
   - 1870s arrivals (post-transcontinental railroad)
   - 1890s arrivals (mature city, pre-earthquake)
   - 1910s arrivals (post-earthquake rebuilding)
3. **Characteristics:** Age, literacy, occupation before arrival, birthplace, family structure
4. **Outcomes:** Track subsequent occupational mobility, persistence in SF, family formation

**Testable Hypotheses:**
- H1: Gold Rush arrivals were younger, more male, less attached (fewer families)
- H2: Gold Rush arrivals had higher occupational mobility (less stratified society)
- H3: Later arrivals were more selected on human capital (literacy, prior occupation)
- H4: Arrival cohort predicted long-term family persistence in SF

**Why Novel:**
- Prior work on frontier selection is cross-sectional or aggregate
- MLP allows individual-level tracking of arrivals AND their subsequent trajectories
- Can compare selection patterns across different eras of city development

**Data Feasibility:**
- Identify arrivals by observing location change between censuses
- Track subset who remain in SF in subsequent censuses
- Use family links to characterize whether they brought families or formed them

---

## Idea 3: "Occupational Alchemy: Upward Mobility Among San Francisco Gold Rush Migrants"

**Core Question:** The Gold Rush promised social mobility—did it deliver? We track the occupational trajectories of men who arrived during the Gold Rush era (1850-1860) and compare to non-migrants and other destinations.

**Approach:**
1. **Treatment group:** Men observed in SF in 1860 who were elsewhere (or not born) in 1850
2. **Comparison groups:**
   - Men who stayed in Eastern cities
   - Men who moved to other Western destinations
   - Men who moved to SF in later decades
3. **Outcomes:** Occupational status (OCCSCORE, OCC1950), property ownership, family formation
4. **Tracking:** Follow through 1870, 1880, 1900

**Testable Hypotheses:**
- H1: SF arrivals 1850s had higher absolute occupational mobility than stayers
- H2: SF arrivals 1850s had higher mobility than arrivals in later decades (first-mover advantage)
- H3: Occupational origins mattered less for SF arrivals (weaker intergenerational persistence)
- H4: "Failure" rate (leaving SF, downward mobility) was also higher—high variance outcomes

**Why Novel:**
- Song et al. (2019) documented declining mobility but didn't test frontier effect directly
- No individual-level study has tracked Gold Rush migrants longitudinally
- We can test whether the frontier truly offered a "clean slate"

**Data Feasibility:**
- 1850-1860 linking has lower rates (~35%) but still yields large samples
- SF 1860 had ~57,000 people; even 35% linkage = ~20,000 trackable
- Compare to linked samples from NYC, Boston, Chicago

---

## Idea 4: "Roots and Routes: Intergenerational Mobility in San Francisco, 1880-1950"

**Core Question:** Did San Francisco offer better intergenerational mobility than other American cities? We compare father-son occupational mobility for SF residents vs. other major cities using linked census data.

**Approach:**
1. **Sample:** Father-son pairs where son observed in SF at working age
2. **Measure:** Father's occupation in prior census, son's occupation when aged 30-40
3. **Comparison:** Same analysis for NYC, Chicago, Boston, LA
4. **Periods:** 1880-1910, 1910-1940 (different eras of city development)

**Testable Hypotheses:**
- H1: SF had higher intergenerational mobility than Eastern cities in 1880-1910
- H2: SF mobility advantage diminished by 1910-1940 (maturation convergence)
- H3: SF foreign-born children had higher mobility than Eastern foreign-born
- H4: Mobility was highest for families that arrived earliest

**Why Novel:**
- Long & Ferrie (2013) compared US vs. UK; no city-level comparison
- Song et al. (2019) national trends; didn't isolate frontier cities
- We can directly test whether Western frontier cities offered mobility premium

**Data Feasibility:**
- MLP explicitly designed for intergenerational analysis
- MOMLOC/POPLOC link children to parents
- OCCSCORE provides standardized occupational ranking

---

## Idea 5: "The 1906 Shock: Individual-Level Migration Responses to the San Francisco Earthquake"

**Core Question:** The earthquake has been studied at aggregate level (Ager et al. 2019). We add *individual-level* analysis: who left, who stayed, and what happened to them?

**Approach:**
1. **Pre-shock sample:** All individuals in SF in 1900 census
2. **Post-shock observation:** Track to 1910, 1920, 1930 censuses
3. **Outcomes:** Location (stayed in SF, moved where?), occupation, property
4. **Heterogeneity:** By neighborhood (intensity), occupation, family structure, birthplace

**Testable Hypotheses:**
- H1: Higher SES individuals more likely to leave (could afford to)
- H2: Family-attached individuals more likely to stay (rebuilding vs. exit)
- H3: Foreign-born more likely to stay (less mobile)
- H4: Those who stayed had better outcomes (selection or rebuilding returns?)

**Why Novel:**
- Ager et al. used aggregate flows; we track individuals
- Can identify *who* responded to shock, not just *that* responses occurred
- Can decompose long-run effects into composition vs. selection channels

**Data Feasibility:**
- 1900 SF population: ~343,000; 1910 population: ~417,000
- MLP 1900-1910 link rate ~45-50%
- Adequate sample for heterogeneity analysis

---

## Recommended Approach: **Combine Ideas 1 + 2 + 3**

Given the preference for a descriptive paper and novel use of MLP, I recommend a unified paper:

**"From Gold Rush to Mid-Century: A Multigenerational Portrait of San Francisco's Making"**

This paper would:

1. **Characterize the 1950 SF population's genealogical composition** (Idea 1)
   - Track backward from 1950 through all available censuses
   - Map the "family trees" of a modern city

2. **Compare arrival cohorts across eras** (Idea 2)
   - Gold Rush (1850s), Railroad (1870s), Pre-earthquake (1890s), Post-earthquake (1910s)
   - Document changing selection patterns

3. **Test whether early arrival mattered for outcomes** (Idea 3)
   - Occupational mobility by arrival cohort
   - Persistence and family formation

**Why This is Novel:**
- Uses MLP for what it was designed for: multigenerational tracking
- "Reverse genealogy" at population scale is methodologically new
- SF as case study is culturally resonant but understudied with modern data
- Descriptive paper format allows rich characterization without forcing causal claims

**Data Strategy:**
- Start with 1950 SF full count (manageable: ~775K)
- Track backward through linked censuses
- Build outward to family connections
- Compare to control cities for benchmarking
