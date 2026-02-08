# Research Ideas: Swedish School Transport (Skolskjuts) and Educational Equity

## Idea 1: Distance Thresholds and School Choice: A Spatial RDD at the Skolskjuts Eligibility Boundary

**Policy:** Swedish skolskjuts (school transport) eligibility based on distance thresholds. Municipalities use sharp cutoffs (typically 2 km for grades F-3, 3 km for grades 4-6) to determine free transport eligibility. Students living just beyond the threshold receive free transport; those just below do not.

**Outcome:** School choice behavior measured as:
1. Attendance at non-assigned schools (especially friskolor/private schools)
2. Travel-to-school distance
3. Educational outcomes (meritvärde/merit points at grade 9)

**Identification:** Spatial Regression Discontinuity Design (Spatial RDD) at the 2 km and 3 km distance thresholds from assigned municipal schools.
- **Running variable:** Straight-line distance from home to assigned school
- **Cutoff:** Municipality-specific distance threshold (2km or 3km depending on grade)
- **Treatment:** Eligibility for free skolskjuts
- **Mechanism:** Transport subsidies reduce the effective "cost" of attending distant schools, potentially increasing school choice uptake

**Why it's novel:**
1. First spatial RDD exploiting skolskjuts eligibility thresholds as a natural experiment
2. Tests how transport subsidies affect school choice behavior—a key policy question given Sweden's quasi-market school system
3. Directly addresses equity concerns: do transport subsidies help disadvantaged families exercise school choice?

**Feasibility check:**
- **Variation:** Sharp distance thresholds exist across all 290 Swedish municipalities, with common cutoffs at 2-3 km
- **Data access:**
  - Kolada API: Municipality-level KPIs including merit points (N15504-N15568), school costs, student-teacher ratios
  - SCB Open API: DeSO-level neighborhood demographics (income, education, immigration status)
  - Skolenhetsregistret API: School unit locations and characteristics
  - OpenStreetMap: Geocoded school locations (more reliable than Skolverket coordinates)
- **Novelty:** No existing papers use spatial RDD on Swedish skolskjuts thresholds
- **Sample size:** 5,985 DeSO neighborhoods, ~290 municipalities, ~1 million grundskola students

**Key concern:** Student residential addresses are restricted microdata (MONA access required). Alternative approach uses neighborhood (DeSO) centroids as proxy for student location.

---

## Idea 2: Municipal Border Discontinuity in Skolskjuts Thresholds

**Policy:** Different Swedish municipalities set different skolskjuts distance thresholds. Some use 2 km for grades F-3, others use 3 km. This creates spatial discontinuities at municipal borders.

**Outcome:**
1. DeSO-level school enrollment patterns (share attending friskola vs municipal school)
2. DeSO-level average merit points
3. Segregation indices at municipal level

**Identification:** Geographic Regression Discontinuity at municipal borders where adjacent municipalities have different skolskjuts eligibility rules.
- Find border pairs where one side has 2 km threshold, other side has 3 km
- Compare DeSO neighborhoods on either side of border
- Use distance-to-border as running variable

**Why it's novel:**
1. Cross-municipal policy variation in Sweden rarely exploited for causal inference
2. Tests whether stricter (longer) distance requirements reduce school choice uptake
3. Addresses equity: are low-SES neighborhoods more affected by stricter thresholds?

**Feasibility check:**
- **Variation:** Must map which municipalities use 2 km vs 3 km thresholds (requires manual collection from municipal websites)
- **Data access:** DeSO boundaries from SCB geodata, municipal boundaries from Lantmäteriet
- **Novelty:** No existing cross-municipal border RDD studies on Swedish education
- **Challenge:** Heterogeneous treatment—need to find enough border pairs with threshold differences

**Key concern:** Mapping municipal thresholds requires scraping 290 municipality websites. May find limited variation (many use same rules).

---

## Idea 3: Transport Subsidy Generosity and Educational Equity: DiD with Municipal Policy Changes

**Policy:** Some Swedish municipalities have expanded or contracted skolskjuts eligibility over time (e.g., lowering distance thresholds, adding safety exemptions, extending to friskola students).

**Outcome:**
1. School choice uptake rates
2. Socioeconomic segregation across schools
3. Educational achievement gaps by family background

**Identification:** Difference-in-Differences comparing municipalities that changed skolskjuts policies to those that did not.

**Why it's novel:**
1. First systematic study of skolskjuts policy changes over time
2. Tests dynamic effects of transport subsidies on school segregation
3. Policy-relevant: informs whether transport subsidies are effective equity tools

**Feasibility check:**
- **Variation:** Requires documenting municipal policy changes over time (difficult—no central registry)
- **Data access:** Kolada has time series from 2010-2024, but policy timing is unknown
- **Challenge:** No existing database of when municipalities changed skolskjuts rules
- **Risk:** High—may not find enough variation or clear policy change dates

**Key concern:** This idea requires extensive archival research to document policy changes. SKIP unless we can find a natural experiment.

---

## Recommended Approach: Idea 1 (Primary) with Idea 2 as Robustness

**Rationale:**
- Idea 1 (distance threshold RDD) uses the cleanest identification with abundant variation
- Idea 2 (border discontinuity) provides a complementary identification strategy
- Both can be implemented with publicly available data

**Data Strategy:**
1. Use Kolada API for municipality-level outcomes (merit points, costs, teacher ratios)
2. Use SCB Open API for DeSO-level demographics and geography
3. Geocode schools using OpenStreetMap (more reliable than Skolverket)
4. Use municipal boundary shapefiles from Lantmäteriet/SCB

**Key Innovation:** Frame the paper around the **equity question**: Do transport subsidies help close the school choice gap between advantaged and disadvantaged families? The 2-3 km threshold creates a natural experiment where families just above vs. just below face different constraints on school choice.
