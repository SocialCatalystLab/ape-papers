# Internal Review (Round 1)

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** Legal Status vs. Physical Access: Testing the Cannabis-Alcohol Substitution Hypothesis at State Borders

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** The paper is approximately 52 pages including appendix, with main text ending at ~25-26 pages before appendix. Meets length requirement.
- **References:** Bibliography covers relevant literature including Anderson & Rees (2021), Lovenheim (2008), Knight & Schiff (2012), methodology papers (Calonico et al., Cattaneo & Titiunik). Adequate.
- **Prose:** Major sections written in paragraph form. Introduction, Results, Discussion all in proper prose.
- **Section depth:** Sections have substantive paragraphs. Introduction ~7 paragraphs, Conceptual Framework ~15 paragraphs.
- **Figures:** Figures show visible data with proper axes. Figure 1-4 all present real visualizations.
- **Tables:** Tables have real numbers with standard errors in parentheses.

FORMAT: **PASS**

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All coefficients have SEs in parentheses. Table 1 (main results), Table 2 (robustness), Tables 9-10 all report SEs. **PASS**

b) **Significance Testing:** P-values reported throughout. Main result p=0.127, driver residency p=0.179, single-vehicle p=0.649. **PASS**

c) **Confidence Intervals:** 95% CIs reported for main specifications. Table 1 shows [-0.02, 0.21]. **PASS**

d) **Sample Sizes:** N reported (29,350 total, effective N varies by bandwidth). Table reports Effective N for each specification. **PASS**

e) **RDD Methodology:**
   - McCrary manipulation test: Reported (significant at 2-5km, acknowledged)
   - Bandwidth sensitivity: Table 2 shows three bandwidth choices (20km, 35.6km optimal, 50km)
   - Polynomial sensitivity: Linear and quadratic reported
   - **PASS**

METHODOLOGY: **PASS**

### 3. IDENTIFICATION STRATEGY

**Strengths:**
- Clear RDD design with geographic distance as running variable
- Balance checks on covariates (Table 3)
- Falsification tests on predetermined outcomes (Table 4)
- Multiple robustness specifications

**Concerns:**
1. **Significant McCrary test:** The manipulation test is significant at 2-5km from border, suggesting population sorting. The paper acknowledges this but proceeds anyway. The donut RDD is the appropriate response, but the 2km donut yields a **significant positive** result (0.237, p<0.05) that contradicts the "null" interpretation.

2. **Weak first stage acknowledged but not quantified:** The paper correctly identifies that physical access doesn't change sharply at borders, but doesn't formally test a first stage (e.g., cannabis use discontinuity). Without a first stage, we cannot determine if the null reflects "no substitution effect" or "no effective treatment contrast."

3. **Specification sensitivity:** The 2km donut yields a significant result in the opposite direction of substitution (higher alcohol involvement in legal states). The paper acknowledges this but somewhat dismisses it as "sample composition." This result actually suggests that among crashes 2-35km from the border, there IS a significant positive effect. The interpretation should be more cautious.

4. **Single-vehicle, in-state specification is preferred but underpowered:** The cleanest specification (N_effective=512) has SE=11.4pp, giving MDE ≈ 32pp at 80% power. This is extremely large—we cannot rule out effects of 25pp or smaller.

### 4. LITERATURE

Generally adequate but missing some relevant work:

**Missing citations:**
- Wen, Hockenberry, & Cummings (2015) on medical marijuana and traffic fatalities (important precursor)
- Lane et al. (2019) on cannabis legalization and crash outcomes in Colorado/Washington

Suggested BibTeX:
```bibtex
@article{WenHockenberryCummings2015,
  author = {Wen, Hefei and Hockenberry, Jason M. and Cummings, Janet R.},
  title = {The Effect of Medical Marijuana Laws on Adolescent and Adult Use of Marijuana, Alcohol, and Other Substances},
  journal = {Journal of Health Economics},
  year = {2015},
  volume = {42},
  pages = {64--80}
}
```

### 5. WRITING QUALITY

**Strengths:**
- Compelling opening hook (Trinidad, Colorado)
- Clear narrative arc from motivation to findings
- Technical material explained accessibly
- Active voice throughout

**Minor issues:**
- Some repetition in the Discussion section restating results
- The specification sensitivity discussion could be more integrated rather than appearing as an afterthought

WRITING: **PASS**

### 6. CONSTRUCTIVE SUGGESTIONS

1. **Strengthen the 2km donut interpretation:** Rather than dismissing it as "sample composition," investigate what drives this result. Which border segments contribute? Is it a particular state pair? This could be informative about heterogeneity.

2. **Power analysis more prominent:** The MDE discussion is buried. Given the null results, readers need to understand what effects the study CAN rule out. A power curve would help.

3. **Formal first stage:** If possible, show that cannabis use (from survey data like BRFSS or NSDUH) does/doesn't change at the border. This would directly address the weak first stage critique.

---

## PART 2: OVERALL ASSESSMENT

**Key strengths:**
- Novel spatial RDD design
- Careful attention to driver residency/unit-of-analysis issues
- Transparent reporting of specification sensitivity
- Well-written with clear exposition

**Critical weaknesses:**
- Significant 2km donut result somewhat undermines "null across specifications" framing
- Very low power in cleanest specification (single-vehicle, in-state)
- No formal first stage validation

**Specific suggestions:**
1. Revise abstract/conclusion to more prominently flag specification sensitivity
2. Add power analysis with MDE calculations
3. Investigate the 2km donut result more thoroughly

---

## DECISION

The paper is methodologically sound, addresses identification concerns thoughtfully, and presents transparent results. The specification sensitivity is concerning but appropriately acknowledged. The main weakness is statistical power in the cleanest specification.

DECISION: MINOR REVISION
