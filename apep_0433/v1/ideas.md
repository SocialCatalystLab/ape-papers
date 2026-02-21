# Research Ideas

## Idea 1: Does Female Political Representation Cause Female Economic Empowerment? Evidence from French Municipal Gender Parity

**Policy:** France's gender parity law for municipal elections. Since 2014, communes with 1,000+ inhabitants must use proportional list voting with strict "zipper" alternation between male and female candidates. Communes below 1,000 use majority voting with no parity requirement. The threshold was previously 3,500 (2001, 2008 elections).

**Outcome:** Female economic participation at the commune level — specifically:
- Female employment rate (INSEE census)
- Female labor force participation rate (INSEE census)
- Female share of local public sector employment (INSEE census)
- Business creation rates (INSEE démographie des entreprises)

**Identification:** Sharp RDD at the 1,000-inhabitant threshold. Running variable: legal population from INSEE. Treatment: proportional voting with mandatory gender parity. First stage: share of female municipal councilors (verified from election data on data.gouv.fr).

**Why it's novel:** The existing literature (Bagues & Campa 2020, European Journal of Political Economy) uses this threshold to study political selection — who gets elected and their quality. NO study has examined downstream economic effects. The causal evidence on female political representation → economic outcomes exists only from developing countries (Chattopadhyay & Duflo 2004; Beaman et al. 2012 on India). This paper would provide the first causal evidence from a developed economy, bridging political economy and labor economics.

**Feasibility check:**
- Variation: Sharp threshold at 1,000 inhabitants; ~35,000 communes, many near cutoff
- Data: All publicly available — INSEE census (commune-level employment by gender), data.gouv.fr (election results with candidate gender), INSEE populations légales
- Novelty: No existing study links French parity threshold to economic outcomes
- Sample size: ~5,000-10,000 communes within typical RDD bandwidth of the 1,000 cutoff
- API tested: INSEE data downloadable as CSV; election data on data.gouv.fr as CSV

---

## Idea 2: Mandatory Safety Committees and Workplace Injuries: RDD Evidence from France's 50-Employee Threshold

**Policy:** At the 50-employee threshold, French firms must establish a Comité d'Hygiène, de Sécurité et des Conditions de Travail (CHSCT) — a workplace health and safety committee with employee representatives and resources. Below 50, worker safety is handled by employee delegates without a dedicated committee.

**Outcome:** Workplace accident rates, occupational injury frequency, days lost to workplace injuries. Data from DARES (Direction de l'Animation de la Recherche, des Études et des Statistiques) or Caisse nationale de l'Assurance Maladie (CNAM).

**Identification:** RDD at the 50-employee threshold. Well-documented bunching effect (Garicano, Lelarge, Van Reenen 2016 AER).

**Why it's novel:** The 50-employee threshold has been extensively studied for firm growth, productivity, and employment distortions. No study has examined whether the mandated safety committee actually improves worker safety.

**Feasibility check:**
- Variation: Sharp threshold, well-documented bunching
- Data: UNCERTAIN — accident rates by firm size may require restricted DARES/CNAM data
- Novelty: Novel outcome for well-studied threshold
- RISK: Publicly available workplace accident data may not be at the firm level
- Known challenge: Bunching at 49 means compositional bias — firms at 50+ are systematically different

---

## Idea 3: The Price of Exclusion: Welfare Eligibility at Age 25 and Youth Self-Employment in France

**Policy:** France's RSA (Revenu de Solidarité Active) income support has a sharp age-25 eligibility threshold. Childless individuals under 25 are effectively excluded from the safety net (the "RSA jeunes" requires 2 years of work in last 3 years — very restrictive). At 25, they gain access to ~565€/month.

**Outcome:** Self-employment rates, micro-enterprise creation (auto-entrepreneur status), employment status transitions around age 25. From Enquête Emploi (French LFS) via Eurostat.

**Identification:** RDD at age 25. Running variable: age in months.

**Why it's novel:** Bargain & Doorley (2011) and Bargain & Vicard (2014) studied labor supply effects. A 2023 study examined homelessness. No study has examined whether welfare exclusion pushes youth into self-employment/informal work as a survival strategy, or whether welfare access at 25 enables transitions to more stable employment.

**Feasibility check:**
- Variation: Sharp age cutoff, well-documented
- Data: Eurostat LFS microdata (free, but need to apply; may take time) OR INSEE's published employment statistics by age
- Novelty: Novel outcome (self-employment, platform work)
- RISK: Eurostat microdata access may require application; published age-level data may lack sufficient granularity around age 25

---

## Idea 4: Urban Enterprise Zones and Local Employment: Spatial RDD Evidence from France's ZFU Program

**Policy:** Zones Franches Urbaines (ZFU) provide tax exemptions (corporate tax, payroll tax, property tax) to firms located in designated disadvantaged urban neighborhoods. First wave: 44 zones in 1997. Second wave: 41 additional zones in 2004. Third wave: 15 more in 2006.

**Outcome:** Local employment rates, establishment creation, sectoral composition at the IRIS level (sub-commune statistical units).

**Identification:** Spatial RDD at ZFU boundaries — comparing neighborhoods just inside vs. just outside the zone boundary.

**Why it's novel:** Mayer et al. (2015) studied ZFU effects using DiD comparing treated to eligible-but-not-treated areas. A spatial RDD at the boundary would provide sharper identification and avoid selection bias in zone designation.

**Feasibility check:**
- Variation: Clear geographic boundaries (available from data.gouv.fr as shapefiles)
- Data: IRIS-level census data from INSEE; ZFU boundaries from sig.ville.gouv.fr
- Novelty: Spatial RDD approach is novel for French enterprise zones
- RISK: IRIS boundaries may not align well with ZFU boundaries; geographic data manipulation in R requires careful handling
- RISK: Spillover effects across zone boundaries could bias RDD estimates
