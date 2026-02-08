# Research Idea Ranking

**Generated:** 2026-01-19T00:17:37.293108
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5736
**OpenAI Response ID:** resp_0aa4cf856dce798300696d69e2e9a881938e3fa11298340348

---

### Rankings

**#1: Compulsory Schooling Laws and Mother's Labor Supply**
- **Score: 73/100**
- **Strengths:** The age-based exposure to compulsory schooling/child labor restrictions creates a plausible, policy-driven earnings shock to households with children near the cutoff, and the full-count census provides large samples to examine heterogeneity by marital status and household structure. The PIH angle (temporary vs permanent maternal labor supply response) is conceptually tight and testable.
- **Concerns:** Identification hinges on clean timing and separability from other contemporaneous reforms (child labor, schooling finance, factory regulation) and on credible “no differential pre-trends” for mothers with slightly younger vs older children. Maternal work is underreported/mismeasured in historical census data, and endogenous migration across states could contaminate exposure.
- **Novelty Assessment:** **Moderately novel.** Compulsory schooling/child labor laws are heavily studied, but *maternal labor supply as a PIH test* is much less saturated than child outcomes; still, it’s adjacent to existing literatures and will need clear differentiation.
- **Recommendation:** **PURSUE**

---

**#2: Women’s Suffrage and Female Human Capital Investment**
- **Score: 66/100**
- **Strengths:** A clean gender-based placebo structure (women vs men) combined with staggered adoption is a strong design template, and the outcomes (schooling/literacy/occupation-based earnings proxies) are well measured in census data. Policy relevance is high given ongoing interest in political rights and economic opportunity.
- **Concerns:** Suffrage adoption is plausibly endogenous to pre-existing female human capital and progressive institutions, so DDD will not automatically rescue causal interpretation; you’ll need strong pre-trend/event-study evidence and perhaps instruments or border-pair designs. The 1910–1920 clustering plus the 19th Amendment compresses treatment variation and complicates modern staggered DiD inference.
- **Novelty Assessment:** **Somewhat studied.** Suffrage has a large empirical literature (especially on public spending and child outcomes), and there is nontrivial work on longer-run female outcomes; focusing tightly on “forward-looking human capital investment” helps, but it’s not wide open.
- **Recommendation:** **CONSIDER** (good project if you can make the endogeneity story and staggered timing inference truly convincing)

---

**#3: Married Women’s Property Acts (MWPAs) and Black Women’s Economic Outcomes**
- **Score: 64/100**
- **Strengths:** The race × gender focus is genuinely valuable and underexplored, and full-count census data meaningfully improves feasibility for Black subgroup analysis relative to older work. If you can isolate usable post-emancipation legal variation, this could speak to how legal property rights translate into economic outcomes under severe constraints.
- **Concerns:** The biggest risk is *lack of usable identifying variation in the relevant period*: many MWPAs pre-date 1870, while Black women’s meaningful access to property/contracting changes discontinuously with emancipation and Reconstruction—making “pre vs post MWPA” comparisons fragile. Wealth/property outcomes are thin in the census (REALPROP limited), so you may be forced into occupational proxies that are easier to confound with local labor market shifts and racial violence/disenfranchisement.
- **Novelty Assessment:** **High novelty.** Black women’s responses to MWPAs are not well mapped in the literature, and this is exactly where full-count data can add new knowledge.
- **Recommendation:** **CONSIDER** (conditional on demonstrating sufficient post-1865 MWPA variation and a credible strategy to separate MWPA effects from Reconstruction-era shocks)

---

**#4: Civil War Widow Pensions and Female Labor Supply**
- **Score: 52/100**
- **Strengths:** The pension expansion is a conceptually strong permanent-income shock aimed directly at women, making the PIH test intuitive and policy-relevant. There is a clear treatment “event” (1890) with meaningful benefit changes.
- **Concerns:** In census data you generally cannot identify *eligible* Union veteran widows vs other widows, so the proposed triple-diff risks being a diffuse intent-to-treat with severe measurement error and differential composition across regions. The missing 1890 census is not just an inconvenience—it weakens timing precision exactly when you most need to pin down dynamics and parallel trends.
- **Novelty Assessment:** **Moderately studied.** Civil War pensions have a substantial literature (health, remarriage, fertility, selection), and while labor supply is less central than remarriage, it is not an untouched area; without eligibility identification, the marginal contribution may be limited.
- **Recommendation:** **SKIP** unless you can credibly link to pension/veteran records (or another way to directly identify eligible widows at the individual level)

---

**#5: Homestead Acts and Female Land Ownership**
- **Score: 37/100**
- **Strengths:** The question is intrinsically interesting and potentially important for understanding wealth formation and gendered access to assets on the frontier. The PIH mechanism (asset windfall affecting marriage/fertility/labor) is clear.
- **Concerns:** The core treatment—actual homestead claiming/land receipt—is not observed in the census, making selection (who moved West, who stayed single, who chose frontier counties) overwhelming and hard to bound. “Eligible territory” comparisons confound the policy with frontier development, migration, and local labor markets, yielding weak causal identification.
- **Novelty Assessment:** **Mixed.** Female homesteading is less studied than many major policies, but homesteading/frontier settlement is extensively researched and the missing individual treatment measure makes incremental credible contribution unlikely.
- **Recommendation:** **SKIP**

---

### Summary
This is a solid batch in terms of historically grounded policy variation matched to full-count census scale, but only one idea (compulsory schooling/child labor exposure and maternal labor supply) looks close to “institute-ready” on identification and feasibility. I would prioritize **Idea 1** first, keep **Idea 3** as the next-best option if you can sharpen identification/endogeneity concerns, and treat **Idea 4** (MWPAs × Black women) as a high-upside but higher-risk project contingent on demonstrating usable post-1865 variation and credible outcomes.