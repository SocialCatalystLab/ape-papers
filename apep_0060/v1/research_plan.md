# Initial Research Plan: Paper 75

## Title

**"The Making of a City: A Multigenerational Portrait of San Francisco's Population, 1850-1950"**

## Research Question

How did San Francisco's population form across a century of American history? Using novel individual-level longitudinal data, we trace the genealogical composition of a city's residents—asking where they came from, how selection patterns changed across eras, and how the 1906 earthquake reshaped who stayed and who left.

## Type of Paper

**Descriptive/Exploratory** — not standard causal inference. The paper characterizes patterns and documents new facts using a novel data approach (population-scale "reverse genealogy" and individual-level disaster response tracking).

## Data Source

**IPUMS Multigenerational Longitudinal Panel (MLP)**
- Full-count census microdata: 1850, 1860, 1870, 1880, 1900, 1910, 1920, 1930, 1940, 1950
- HISTID links enable tracking individuals across censuses
- Family links (MOMLOC, POPLOC) enable multigenerational tracking
- ~40-50% linkage rate between adjacent censuses; ~2.1% Type I error rate

## Analytical Framework

### Part I: The 1950 Stock — Reverse Genealogy

**Starting point:** All residents of San Francisco County in 1950 census (STATEFIP=6, COUNTY=75)

**Method:** Track backwards through linked censuses to characterize ancestral origins:
- First appearance in any census (earliest observation)
- Location at first observation (origin state/country)
- Parent characteristics (via MOMLOC/POPLOC links)
- Number of generations in California

**Key outputs:**
- Distribution of "depth" (how many generations traced back)
- Geographic origins map (where SF 1950 families came from)
- Arrival cohort composition (Gold Rush era vs. later arrivals)

### Part II: Arrival Cohorts — Selection Across Eras

**Sample:** Individuals arriving in San Francisco in each decade (present in SF census t, not present in SF at t-10)

**Comparison periods:**
- 1850s arrivals (Gold Rush)
- 1870s arrivals (post-transcontinental railroad)
- 1890s arrivals (established city, pre-earthquake)
- 1910s arrivals (post-earthquake rebuilding)

**Characteristics to compare:**
- Demographics: Age, sex ratio, marital status
- Human capital: Literacy, occupation before arrival
- Origins: Birthplace (domestic vs. foreign, East vs. West)
- Family structure: Arrived with family vs. solo

**Key hypotheses:**
- H1: Gold Rush arrivals younger, more male, less family-attached
- H2: Later arrivals more selected on human capital
- H3: Post-earthquake arrivals had different composition (rebuilding attracted specific occupations)

### Part III: The 1906 Shock — Individual Migration Responses

**Natural experiment:** 1906 earthquake and fire destroyed 80% of the city

**Sample:** All individuals in SF in 1900 census, tracked to 1910

**Outcomes:**
- Stayed in SF (found in SF in 1910)
- Left SF (found elsewhere in 1910)
- Not linked (death, emigration, or linkage failure)

**Heterogeneity analysis:**
- By damage zone (fire zone vs. outside)
- By SES (occupation, literacy)
- By family structure (with family vs. solo)
- By nativity (native vs. foreign-born)

**Comparison cities:** Los Angeles (same state, no shock), Seattle (Western, no shock)

**Key questions:**
- Who left after the earthquake? (selection on observables)
- Where did they go? (destination analysis)
- What happened to those who stayed? (subsequent trajectories)

## Data Strategy

### Sampling Approach (Memory-Conscious)

Given the massive size of MLP full-count data, we will:

1. **Start small:** Extract only SF County records, not all of California
2. **Use sample versions first:** Test pipeline on 1% samples before full-count
3. **Track backwards from 1950:** Start with 1950 SF sample, then request linked ancestors
4. **Chunk by decade:** Don't request all censuses at once

### IPUMS Extract Specifications

**Extract 1: 1950 SF County Base Sample**
```
Collection: USA
Samples: us1950b (full count)
Variables: HISTID, SERIAL, PERNUM, YEAR, STATEFIP, COUNTY, AGE, SEX, RACE,
           MARST, BPL, NATIVITY, LIT, SCHOOL, EDUC, OCC1950, IND1950,
           LABFORCE, CLASSWKR, MOMLOC, POPLOC, SPLOC, RELATE
Case selection: STATEFIP=6, COUNTY=75
```

**Extract 2: 1900-1910 SF + Comparison Cities (for Part III)**
```
Collection: USA
Samples: us1900m, us1910m (full count)
Variables: [same as above]
Case selection:
  - San Francisco: STATEFIP=6, COUNTY=75
  - Los Angeles: STATEFIP=6, COUNTY=37
  - Seattle: STATEFIP=53, COUNTY=33
```

**Extract 3: Historical Backward Links (for Parts I-II)**
```
Collection: USA
Samples: us1850c, us1860c, us1870c, us1880e, us1900m, us1910m, us1920c, us1930d, us1940b
Variables: [same as above]
Case selection: Linked to 1950 SF sample via HISTID
```

## Expected Outputs

### Tables

1. **Table 1:** 1950 SF Population Composition — by origin era (Gold Rush era lineages, post-1880 arrivals, 20th century arrivals)
2. **Table 2:** Arrival Cohort Characteristics — demographics, human capital, origins across eras
3. **Table 3:** 1906 Earthquake Response — persistence rates by characteristics
4. **Table 4:** Destination Analysis — where 1906 leavers went
5. **Table 5:** Comparison City Benchmarks — SF vs. LA vs. Seattle patterns

### Figures

1. **Figure 1:** Map of SF 1950 residents' ancestral origins (US state or country of origin)
2. **Figure 2:** Distribution of "genealogical depth" (generations traced back)
3. **Figure 3:** Arrival cohort characteristics over time (line plots)
4. **Figure 4:** 1900-1910 migration flows from SF (Sankey diagram)
5. **Figure 5:** Persistence rates by damage zone and characteristics

## Contribution

1. **Methodological innovation:** First "reverse genealogy" of an American city at population scale
2. **New facts:** Documents the multigenerational composition of SF's population
3. **Historical insight:** Individual-level view of how a major city formed through migration
4. **1906 earthquake:** Micro-level complement to existing aggregate studies

## Robustness Considerations

1. **Linkage selection:** Report characteristics of linked vs. unlinked, reweight if needed
2. **Survivorship bias:** We observe who was in SF in 1950, not all who ever came
3. **Damage zone assignment:** Sensitivity to geographic classification
4. **Comparison city validity:** Check pre-trends in comparison cities

## Timeline

1. Phase 4a: Submit initial IPUMS extract (1950 SF base)
2. Phase 4b: Build backward-linking pipeline
3. Phase 4c: Analyze 1900-1910 earthquake sample
4. Phase 4d: Compile full analysis and paper
5. Phase 5: Internal and external review
6. Phase 6: Publish

---

**Locked:** This plan was created before any data was fetched. Changes are permitted only in research_plan.md.
