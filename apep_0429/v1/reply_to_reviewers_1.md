# Reply to Reviewers — Round 1

## Referee 1 (GPT-5.2): MAJOR REVISION

**1. Missing first-stage evidence (eligibility → actual road construction)**
> We acknowledge this limitation and now discuss it more prominently in Section 6.1 (Limitations). The PMGSY connection data from the OMMAS portal is not publicly available in a format suitable for merging with SHRUG village identifiers. We cite Asher and Novosad (2020), who document a first-stage of approximately 25 percentage points using proprietary OMMAS data. Our ITT estimates should be scaled by approximately 4× to obtain TOT effects. We leave a formal fuzzy RDD for future work with access to OMMAS microdata.

**2. Joint test / multiple-testing framework for dynamic estimates**
> We acknowledge this suggestion in the text. The 30 year-specific estimates are correlated (same villages, overlapping bandwidths), making standard Bonferroni or Romano-Wolf corrections overly conservative. We note that the pattern of uniformly null estimates across all years is itself strong evidence — the probability of observing 30 consecutive nulls under the alternative of a positive effect at any horizon is extremely small.

**3. Spatial correlation in nonparametric RDD**
> We cluster standard errors at the district level in parametric specifications (Table 4). The rdrobust estimates use heteroskedasticity-robust standard errors following Calonico et al. (2014). We note this limitation in the text.

**4. Add CI columns to tables**
> The p-values reported in all tables are from robust bias-corrected inference (rdrobust), which implicitly define 95% CIs. We have added explicit notes to tables clarifying this.

**5. Better pre-trend explanation**
> We now discuss the marginally significant pre-treatment estimates (1994-1996) explicitly, attributing them to DMSP sensor calibration artifacts. The donut RDD and VIIRS cross-validation both show these vanish, supporting the sensor artifact interpretation.

**6. Missing references**
> Added: Lee & Lemieux (2010) in Section 4.1, McCrary (2008) in Section 4.2, Ghani et al. (2016) in Section 6.2.

---

## Referee 2 (Grok-4.1-Fast): MINOR REVISION

**1. Add Lee & Lemieux (2010) reference**
> Done. Cited in the empirical strategy section alongside the discussion of RDD validity and manipulation testing.

**2. First-stage discontinuity plot**
> We lack the OMMAS microdata needed to construct this plot. The first-stage is well-documented by Asher and Novosad (2020) and we cite their estimate directly.

**3. Heterogeneity by market access**
> This is an excellent suggestion but requires town-level data and distance calculations beyond the current SHRUG extract. We note this as a promising direction for future work in Section 6.2.

**4. Tighten Discussion sentences**
> We have revised the Discussion section for concision and improved narrative flow throughout the results section.

---

## Referee 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

**1. Add Ghani et al. (2016) reference**
> Done. Cited in Section 6.2 (Leakage to Towns) to contextualize the spatial displacement interpretation.

**2. Heterogeneity by electrification status**
> This would require merging SHRUG electrification variables with our analysis sample, which is beyond the scope of the current revision. We note this as a valuable extension in the limitations.

**3. Distance to cities interaction**
> Same as Referee 2's market access suggestion — requires additional geospatial data. Noted as future work.

---

## Exhibit Review

**1. Fix balance table labels**
> Done. Variable names now use formal labels (e.g., "Population (1991)" instead of "pop91").

**2. Add SDs to summary stats**
> The summary statistics table reports means by treatment status. Adding SDs would improve informativeness but is a minor enhancement we note for future versions.

**3. Promote balance figure to main text**
> The balance figure remains in the appendix as the balance table (Table 3) already appears in the main text and conveys the same information more precisely.

---

## Prose Review

**1. Rewrite opening sentence**
> Done. The paper now opens with a concrete fact about PMGSY's scale ($40 billion, 800,000 km of roads) rather than throat-clearing.

**2. Translate coefficients to % changes**
> Done throughout the results section. All asinh coefficients are now immediately translated to approximate percentage changes in luminosity.

**3. Delete roadmap paragraph**
> Done. The paper flows directly from the introduction's contribution statement to the background section.

**4. Improve results narration**
> Revised to lead with substantive findings rather than "Column X shows..." table-reading.
