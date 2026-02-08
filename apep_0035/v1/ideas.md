# Paper 47: Research Ideas

**Focus:** Historical MLP (1850-1950) | **Priority:** Feasibility

---

## Idea 1: Women's Suffrage and Female Labor Force Participation ⭐ RECOMMENDED

### Research Question
Did state-level women's suffrage (1893-1918) increase women's labor force participation?

### Policy Variation
- **Treated states (13):** WY (1869), UT (1870), CO (1893), ID (1896), WA (1910), CA (1911), OR (1912), KS (1912), AZ (1912), MT (1914), NV (1914), NY (1917), MI (1918)
- **Never-treated (33):** All other states (until 19th Amendment, 1920)
- **Adoption period:** Staggered 1869-1918 with concentration in 1910-1918

### Outcome
- Women's labor force participation (LABFORCE in IPUMS)
- Secondary: occupational status (OCC1950), self-employment

### Identification
- **Method:** Callaway-Sant'Anna DiD with never-treated controls
- **Pre-periods:** 1880, 1900, 1910 (2-3 pre-treatment censuses for most treated states)
- **Post-periods:** 1910, 1920 (depending on treatment timing)
- **Individual FE:** HISTID links same woman across censuses

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Data availability | ✅ IPUMS Full Count with HISTID |
| Pre-treatment periods | ✅ 2+ for states adopting 1910+ |
| Control states | ✅ 33 never-treated (excellent) |
| Clustering | ✅ 13 treated states (acceptable) |
| Outcome measurement | ✅ LABFORCE directly available |
| Novelty | ✅ Labor outcomes not studied (Miller 2008 did public spending) |

### Mechanism
Suffrage → political representation → labor-friendly policies (protective legislation, equal pay norms) → reduced discrimination → higher female LFP

### Risks
- Early adopters (WY 1869, UT 1870) have no pre-treatment census data
- Western states may differ on unobservables (frontier culture)
- Selection into treatment correlated with progressive attitudes

**FEASIBILITY: HIGH**

---

## Idea 2: State Prohibition and Male Labor Market Outcomes

### Research Question
Did state prohibition laws (1880-1919) affect male labor force participation and occupational stability?

### Policy Variation
- **Treated states (30):** ME (1851), KS (1880), ND (1889), GA (1907), OK (1907), MS (1908), NC (1908), TN (1909), WV (1912), and 21 more by 1919
- **Never-treated (16):** States that didn't adopt before 18th Amendment (1919)
- **Adoption period:** Very staggered (1851-1919), with main wave 1907-1919

### Outcome
- Male labor force participation (LABFORCE)
- Weeks worked (if available)
- Occupational mobility (OCC1950 changes across censuses)

### Identification
- **Method:** Callaway-Sant'Anna DiD
- **Pre-periods:** 1880, 1900, 1910 for states adopting 1907+
- **Post-periods:** 1910, 1920
- **Individual FE:** HISTID panel

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Data availability | ✅ IPUMS Full Count with HISTID |
| Pre-treatment periods | ✅ 2+ for states adopting 1907+ |
| Control states | ✅ 16 never-treated (good) |
| Clustering | ✅ 30 treated states (excellent) |
| Outcome measurement | ✅ LABFORCE, OCC available |
| Novelty | ✅ Labor outcomes not main focus of lit |

### Mechanism
Prohibition → reduced alcohol consumption → improved health/productivity → higher LFP, occupational upgrading

OR

Prohibition → alcohol industry job losses → lower LFP in some regions

### Risks
- ME (1851), KS (1880) have limited/no pre-treatment data
- Enforcement varied widely across states
- Coincident with WWI mobilization (1917-1918)

**FEASIBILITY: MEDIUM-HIGH**

---

## Idea 3: Workers' Compensation and Occupational Risk-Taking

### Research Question
Did workers' compensation laws (1910-1948) shift workers toward riskier, higher-wage occupations?

### Policy Variation
- **Treated states (48):** All states eventually adopt
- **Early adopters (1910-1915):** WI, NJ, WA, CA, IL, KS, MA, NH, NV, NY, OH, AZ, MI, RI, MD, CT, IA, MN, NE, OR, TX, WV, LA, IN, OK, CO, ME, MT, PA, UT, VT, WY (32 states)
- **Late adopters (1916-1948):** KY (1916), SD (1917), AL (1919), DE (1917), ID (1917), ND (1919), NM (1917), TN (1919), VA (1918), GA (1920), MO (1926), NC (1929), FL (1935), SC (1935), AR (1939), MS (1948)

### Outcome
- Occupation riskiness score (construct from OCC1950)
- Log income/wages (if available)
- Industry sector (manufacturing vs. agriculture)

### Identification
- **Method:** DiD using late adopters as controls
- **Pre-periods:** 1900, 1910 for early adopters
- **Post-periods:** 1920, 1930
- **Challenge:** No never-treated states → must use timing variation

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Data availability | ✅ IPUMS Full Count |
| Pre-treatment periods | ✅ 2+ for early adopters |
| Control states | ⚠️ Late adopters only (weaker) |
| Clustering | ✅ Many states (good) |
| Outcome measurement | ⚠️ Need to construct risk score |
| Novelty | ✅ Occupational choice not main focus |

### Mechanism
WC → reduced worker exposure to injury costs → willingness to take riskier jobs → shift to manufacturing/hazardous occupations

### Risks
- No never-treated states makes C-S harder
- Occupation risk scoring is subjective
- Coincident with industrialization trends

**FEASIBILITY: MEDIUM** (identification weaker)

---

## Idea 4: Compulsory Schooling and Child Labor Force Participation (RDD)

### Research Question
Did compulsory schooling laws reduce child labor at the age threshold?

### Policy Variation
- Use age-based RDD within states that have compulsory schooling
- Running variable: age relative to compulsory attendance threshold
- Cutoff varies by state (typically ages 8-14 for starting, 14-16 for ending)

### Outcome
- Child in labor force (LABFORCE for ages 10-18)
- Child in school (SCHOOL)

### Identification
- **Method:** RDD at age thresholds
- **Sample:** Children ages 10-18 in states with CSL
- **Running variable:** Age relative to minimum working age or maximum schooling age

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Data availability | ✅ IPUMS Full Count |
| Running variable | ⚠️ Age in years (coarse) |
| Outcome measurement | ✅ LABFORCE, SCHOOL available |
| Novelty | ⚠️ Similar to Angrist & Krueger approach |
| Sharpness | ⚠️ Age thresholds may not be binding |

### Risks
- Age reported in years only (coarse running variable)
- Enforcement varied by state
- Similar to existing literature (Angrist & Krueger 1991)

**FEASIBILITY: LOW-MEDIUM** (not novel enough)

---

## Recommendation

**Proceed with Idea 1: Women's Suffrage and Female LFP**

Rationale:
1. Best identification: 33 never-treated states provide excellent controls
2. High data availability: LABFORCE directly measured in census
3. Novelty: Miller (2008) studied public health spending, not labor outcomes
4. MLP advantage: Individual FE via HISTID strengthens identification
5. Clear mechanism: Political voice → labor market access
6. Sufficient pre-periods: 2+ censuses before treatment for 1910+ adopters

**Alternative: Idea 2 (Prohibition)** if suffrage has issues during execution.

---

## Next Steps

1. Verify suffrage dates against primary sources
2. Check IPUMS sample sizes for women in labor force
3. Pilot MLP extraction (0.1% sample) to validate design
4. Check pre-trends in pilot data before full extraction
