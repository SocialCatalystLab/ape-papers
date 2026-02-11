# Reply to Reviewers — apep_0219 v3

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**1. Missing first stage / fuzzy RDD**
> "Make every reasonable effort to obtain county-level ARC grant receipts..."

We explored USAspending.gov (CFDA 23.002) and found county-level ARC obligation data for FY2008-2015, but coverage is incomplete (missing FY2007, FY2016-2017) and the data do not reliably distinguish Distressed-targeted grants from general ARC allocations. We added this exploration to Section 5.6 and strengthened the ITT framing throughout. A formal first stage with incomplete data would risk introducing more bias than it resolves. The limitation remains the paper's primary acknowledged weakness.

**2. Pooling across years with moving cutoff**
> "Show year-specific thresholds... confirm pooling validity"

Year-specific thresholds range from 158 (FY2015-2016) to 172 (FY2010-2011), already reported in Section 2.4 and the Data Appendix. Year-by-year estimates in Appendix Table 6 confirm that results are consistent across years, validating the pooled approach. The panel specification with year fixed effects absorbs cross-year heterogeneity.

**3. Clustering / inference robustness**
> "Consider wild cluster bootstrap..."

With 369 clusters, conventional cluster-robust SEs are reliable (Cameron et al. 2008). The effective sample sizes within bandwidth (648-1,028) are well above conventional thresholds. We note this is a potential robustness extension for future work.

**4. Heterogeneity by capacity**
> "Construct proxies for administrative capacity..."

The Central Appalachia subgroup analysis (Section 5.3) already captures much of the capacity/coal-dependence variation. County-level measures of grant absorption capacity are not readily available for the sample period.

**5. Additional RDD citations**
> "Add Lee & Lemieux 2010, Cattaneo, Frandsen & Titiunik 2015..."

Added: Lee (2008), Lee & Lemieux (2010), and Eggers et al. (2018) are now cited in Section 4.1 (Empirical Strategy). All were already in references.bib.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**1. Missing foundational RDD citations**
> "No Lee 2008; Imbens/Lemieux 2008..."

Fixed. Lee (2008), Imbens & Lemieux (2008), Lee & Lemieux (2010), and Eggers et al. (2018) now cited in Section 4.1. All were present in the bibliography but not referenced in text.

**2. First stage via FOIA**
> "FOIA ARC grants data..."

We attempted the publicly available route (USAspending.gov CFDA 23.002) and documented the partial results. A FOIA request to ARC for internal grant databases is noted as a direction for future research.

**3. Extensions (event-study dynamics, longer horizon, spillovers)**
> "Lead/lag RD, extend to 2022, spatial RD..."

These are valuable suggestions that exceed the scope of the current revision. Noted in the Conclusion as directions for future research.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**1. Grant utilization data**
> "Scrape USAspending.gov for a subset of years..."

Done. We explored USAspending.gov and documented the findings. The partial coverage (8 of 11 years) and data quality issues preclude a formal first-stage analysis but are now reported in Section 5.6.

**2. Spatial spillovers**
> "Could the Distressed designation in one county affect the At-Risk neighbor?"

Interesting concern. The RDD identifies effects at the CIV threshold, not geographic boundaries, so spatial spillovers would need to operate through the CIV distribution rather than physical proximity. Noted as a direction for future research.

**3. Heterogeneity by industry**
> "Does the null hold for coal-dependent vs diversified counties?"

The Central Appalachia subgroup (Section 5.3) — which includes the coal-dependent Kentucky, West Virginia, and Virginia counties — shows null results consistent with the full sample, suggesting the null is not driven by industry composition.

---

## Internal Review (Claude Code R1/R2): MINOR REVISION

**1. County-switching statistics**
Added paragraph in Section 3.4: 83/369 counties (22%) switch between Distressed and non-Distressed status during the panel, 42 are always Distressed, 244 are never Distressed.

**2. Explicit ITT framing**
Added sentence before Table 3 clarifying estimates are intent-to-treat effects of the designation, not documented spending increases.

**3. Eggers et al. (2018) citation in text**
Now cited in Section 4.1 alongside Lee (2008) and Lee & Lemieux (2010).
