# Claude-4.5-Haiku Review

**Role:** External referee review
**Model:** anthropic/claude-haiku-4.5
**Paper:** paper.pdf
**Timestamp:** 2026-02-01T00:26:19.042800
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 49460 in / 8000 out
**Response SHA256:** 1f7fe49114004bed

---

# COMPREHENSIVE REVIEW

## 1. FORMAT CHECK

**Length**: The paper is approximately 35-40 pages excluding references and appendix (main text pp. 1-35). ✓ Acceptable.

**References**: The bibliography is comprehensive and well-curated, covering policy feedback theory (Pierson, Mettler, Campbell), federalism (Oates, Shipan & Volden), climate policy acceptance (Kallbekken & Sælen, Carattini et al.), and econometric methodology (Calonico et al., Keele & Titiunik, Callaway & Sant'Anna). ✓ Strong.

**Prose Structure**: The paper is written in full paragraphs throughout. Sections 1-7 and the appendix follow standard academic structure. ✓ Acceptable.

**Section Depth**: Each major section contains multiple substantive paragraphs:
- Introduction (1.1-1.2): 3 paragraphs
- Literature Review (Section 2): 4 subsections with 3-4 paragraphs each
- Institutional Background (Section 3): 3 subsections with 2-3 paragraphs each
- Results (Section 6): 9 subsections with detailed exposition
✓ Adequate depth.

**Figures**: All 20 figures display real data with properly labeled axes, legends, and confidence intervals. Maps (Figures 1-5) are publication-quality. RDD plots (Figures 7, 16) show binned means with local polynomial fits. ✓ Excellent.

**Tables**: All 18 tables contain real numbers with complete reporting of estimates, standard errors, confidence intervals, and sample sizes. No placeholders. ✓ Excellent.

---

## 2. STATISTICAL METHODOLOGY (CRITICAL)

### A. Standard Errors and Inference

**PASS**: Every coefficient throughout the paper includes standard errors in parentheses. Examples:
- Table 4 (OLS): All estimates report SEs clustered by canton
- Table 5 (RDD): All estimates include SEs and 95% CIs
- Table 9 (DiD): All estimates report SEs with clustering
- Table 17 (Callaway-Sant'Anna): All group-time ATTs include SEs and CIs

All main results include both p-values and confidence intervals. ✓ **Excellent.**

### B. Significance Testing

**PASS**: The paper conducts multiple inference approaches:
1. **Cluster-robust inference** (canton-level clustering): Table 4, all specifications
2. **Wild cluster bootstrap** (MacKinnon & Webb weights): Table 10, p-value = 0.058 for same-language RDD
3. **Randomization inference**: Figure 12, permutation test under sharp null, two-tailed p = 0.62
4. **Spatial RDD with bias-corrected inference**: Table 5, robust confidence intervals (Calonico et al. 2014)

The paper explicitly addresses the few-cluster problem (5 treated of 26 cantons) through multiple robustness approaches. ✓ **Exemplary.**

### C. Sample Sizes

**PASS**: Sample sizes reported for all specifications:
- OLS: N = 2,120 Gemeinden (Table 4)
- RDD (pooled): N = 1,278 within bandwidth (Table 5, Figure 8)
- RDD (same-language): N = 862 within bandwidth (Table 5)
- Panel (CSA): N = 100 canton-period observations (Table 17)
- All robustness checks report N (Tables 13-15)

✓ **Complete.**

### D. DiD with Staggered Adoption

**CRITICAL ISSUE - PARTIALLY ADDRESSED**:

The paper uses staggered treatment adoption (GR 2011, BE 2012, AG 2013, BL 2016, BS 2017) and implements the **Callaway & Sant'Anna (2021)** estimator (Table 17, Section 6.5), which is the correct approach for heterogeneous treatment effects with staggered timing. The paper explicitly acknowledges the bias in standard TWFE (p. 31): "Standard two-way fixed effects (TWFE) estimates from Equation (3) may suffer from negative weighting bias if treatment effects are heterogeneous (Goodman-Bacon, 2021)."

**However**, the main results are NOT from the panel specification. The primary causal evidence comes from the **cross-sectional spatial RDD** (Table 5), which compares municipalities at canton borders in a single referendum (May 2017). This avoids the staggered-adoption problem entirely by treating all treatment as occurring before the outcome referendum.

**Assessment**: The paper's primary identification strategy (spatial RDD on a single referendum) is not subject to staggered-adoption bias. The panel analysis (Callaway-Sant'Anna) is presented as a robustness check and correctly uses heterogeneity-robust methods. ✓ **Methodologically sound.**

### E. RDD Implementation

**PASS - with important caveats**:

**Bandwidth Selection**: MSE-optimal bandwidths selected using Calonico et al. (2014) procedure:
- Pooled: 3.7 km (Table 5)
- Same-language: 3.2 km (Table 5)
✓ Appropriate.

**McCrary Density Test**: Figure 8 shows no significant discontinuity in the density of Gemeinden at the border (test statistic = 0.97, p = 0.332). ✓ Supports validity.

**Covariate Balance**: Table 6 and Figure 9 show no significant discontinuities in log(population), urban share, or turnout at the border. All estimates centered near zero with confidence intervals including zero. ✓ Supports validity.

**Bandwidth Sensitivity**: Figure 10 shows estimates remain negative across bandwidth range (0.5 km to 15 km). ✓ Robust.

**Donut RDD**: Table 14 and Figure 11 exclude municipalities within 0.5-2 km of border. Estimates remain negative through 1.5 km exclusion radius. ✓ Robustness check.

**Placebo Tests**: Table 15 tests RDD on unrelated referendums (immigration, basic income, corporate tax). Results:
- Immigration (Feb 2016): +4.05 pp discontinuity (p < 0.001)
- Corporate Tax (Feb 2017): -3.27 pp discontinuity (p < 0.001)

**CRITICAL LIMITATION**: These placebo results suggest the border discontinuity may reflect **permanent political differences** between treated and control cantons rather than energy-policy-specific effects. The paper acknowledges this (p. 48): "This pattern suggests that the pooled border discontinuity captures pre-existing political differences between treated and control cantons rather than energy-policy-specific effects."

The authors' response is to restrict to **same-language borders** (German-German only), which eliminates the Röstigraben confound. This is sensible but reduces sample size and introduces a different confound: bilingual cantons (FR, VS) and linguistic minorities within cantons (French in Bern, Italian/Romansh in Graubünden).

**Assessment**: The RDD design is implemented correctly, but identification relies on the assumption that same-language borders are comparable. This assumption cannot be fully verified. The placebo results raise legitimate concerns about border comparability. ✓ **Methodologically sound but with important caveats acknowledged.**

### F. Overall Methodology Assessment

**VERDICT: PASS** - The paper employs rigorous econometric methods with appropriate inference for few clusters. The primary identification strategy (spatial RDD on same-language borders) is sound, though it relies on assumptions that cannot be fully verified. Robustness checks are extensive and mostly supportive. The placebo results are concerning but appropriately interpreted.

---

## 3. IDENTIFICATION STRATEGY

### A. Spatial RDD Design

**Strengths**:
1. **Geographic discontinuity**: Canton borders are centuries-old administrative boundaries that municipalities cannot manipulate. This is a genuine quasi-random assignment of treatment.
2. **Corrected sample construction** (Section B.1): The authors ensure each municipality's distance is computed to its own canton's treated-control border, not the union boundary. This is methodologically rigorous and addresses a potential source of bias.
3. **Same-language specification**: Restricting to German-German borders eliminates the Röstigraben language confound, the dominant source of variation in referendum support (15.5 pp difference, Table 2).
4. **Multiple robustness checks**: Bandwidth sensitivity, donut RDD, border-pair heterogeneity, covariate balance all support the design.

**Weaknesses**:
1. **Language assignment at canton level**: The paper assigns language at the canton level (BFS majority classification) rather than Gemeinde level. This creates imprecision for bilingual cantons (FR, VS) and cantons with linguistic minorities (French-speaking areas in BE; Italian/Romansh areas in GR). The authors acknowledge this limitation (p. 48).
2. **Same-language borders still contain linguistic minorities**: Some border segments between nominally German-speaking cantons may include locally French-speaking areas. The paper notes this (p. 27) but does not fully address it.
3. **Placebo tests suggest permanent border effects**: Table 15 shows significant discontinuities on unrelated referendums (immigration +4.05 pp, corporate tax -3.27 pp), suggesting the borders may reflect permanent political differences. The Difference-in-Discontinuities design (Table 9) partially addresses this by controlling for time-invariant border effects, yielding a smaller estimate (-2.5 pp vs. -5.9 pp), but this is still concerning.

**Assessment**: The identification strategy is sound but relies on assumptions that cannot be fully verified. The same-language RDD is the cleanest specification, but the placebo results suggest caution in causal interpretation. The DiD design provides a useful robustness check that nets out permanent border effects.

### B. Parallel Trends (Panel Analysis)

**Strengths**:
1. **Pre-treatment balance**: Table 7 and Figure 13 show treated and control cantons had similar voting patterns in 2000 and 2003 (pre-treatment gaps of 1.4 pp and 2.1 pp, respectively). This supports parallel trends.
2. **Callaway-Sant'Anna estimator**: The paper uses the correct heterogeneity-robust DiD estimator for staggered adoption (Table 17, Figure 14).
3. **Pre-treatment coefficients near zero**: Figure 14 shows pre-treatment dynamic effects close to zero, supporting parallel trends.

**Weaknesses**:
1. **Limited panel**: Only 4 referendums over 17 years on different topics (energy levy, nuclear moratorium, nuclear phase-out, comprehensive energy strategy). The parallel trends assumption is weaker when comparing different policy objects.
2. **Small number of treated units**: With 5 treated cantons, power is limited. The CSA aggregate ATT is -1.54 pp (SE = 0.37), smaller than the cross-sectional RDD estimate (-5.9 pp).
3. **Pooling across referendums**: The panel estimate pools across referendums with different voter coalitions and campaign dynamics. This reduces precision and may mask heterogeneity.

**Assessment**: The panel analysis supports the main findings but is less precise and relies on a weaker parallel trends assumption. It serves as a useful robustness check rather than a primary identification strategy.

### C. Mechanisms

The paper discusses three mechanisms (Section 7.1):
1. **Thermostatic opinion response** (Wlezien 1995): Voters who have already received policy output reduce demand for more.
2. **Cost salience**: Implementation makes visible the private costs of building retrofits and heat pump mandates.
3. **Federal overreach**: Voters in cantons with existing laws view national harmonization as unnecessary duplication.

**Assessment**: The thermostatic mechanism is most compelling and consistent with the evidence. However, the paper cannot definitively distinguish between mechanisms without individual-level survey data on policy awareness and implementation experience. The paper acknowledges this limitation (p. 49).

### D. Limitations Acknowledged

The paper explicitly discusses limitations (Section 7.2):
1. **Canton-level language assignment**: Imprecision for bilingual cantons and linguistic minorities
2. **Power analysis**: With 5 treated cantons, minimum detectable effect at 80% power is 6.5 pp (same-language RDD)
3. **Treatment measurement**: Binary canton-level treatment masks variation in individual exposure
4. **Spatial RDD pooling**: Borders differ in important ways (Röstigraben vs. within-German)
5. **External validity**: Switzerland's institutions (direct democracy, strong federalism) are unusual

**Assessment**: The limitations are appropriately acknowledged and do not invalidate the main findings. ✓ **Excellent.**

---

## 4. LITERATURE REVIEW

### A. Coverage Assessment

The paper cites foundational work in:
- **Policy feedback**: Pierson (1993), Mettler (2002, 2011), Campbell (2002, 2012), Soss (1999) ✓
- **Laboratory federalism**: Oates (1999), Rose (1993), Shipan & Volden (2008), Karch (2007) ✓
- **Climate policy acceptance**: Kallbekken & Sælen (2011), Carattini et al. (2018), Drews & van den Bergh (2016) ✓
- **Econometric methodology**: Calonico et al. (2014), Keele & Titiunik (2015), Cattaneo et al. (2020), Dell (2010), Black (1999) ✓
- **Few-cluster inference**: Cameron et al. (2008), MacKinnon & Webb (2017, 2020), Young (2019) ✓
- **Staggered adoption**: Goodman-Bacon (2021), Callaway & Sant'Anna (2021) ✓

### B. Missing Literature

**CRITICAL GAPS** that should be addressed:

1. **Electoral backlash literature**: The paper cites Stokes (2016) on renewable energy backlash but does not adequately engage with the broader literature on policy-induced electoral punishment:
   - **Missing**: Achen & Bartels (2016) on retrospective voting; Healy & Lenz (2014) on the electoral consequences of policy implementation
   - **Suggestion**: Add discussion of how cost salience generates electoral backlash against incumbent parties, not just federal policy
   - **BibTeX**:
     ```bibtex
     @book{AchenBartels2016,
       author = {Achen, Christopher H. and Bartels, Larry M.},
       title = {Democracy for Realists: Why Elections Do Not Produce Responsive Government},
       publisher = {Princeton University Press},
       year = {2016}
     }
     @article{HealyLenz2014,
       author = {Healy, Andrew and Lenz, Gabriel S.},
       title = {Substituting the End Result for the Whole Loaf: How Voters Forecast the Consequences of Reelecting the Incumbent},
       journal = {Journal of Politics},
       year = {2014},
       volume = {76},
       pages = {885--899}
     }
     ```

2. **Federalism and policy diffusion**: The paper cites Shipan & Volden (2008) on horizontal diffusion but underutilizes literature on **vertical diffusion** (state-to-federal):
   - **Missing**: Rabe (2004) on state climate policy and federal momentum; Karch (2007) on state policy diffusion mechanisms
   - **Note**: Rabe (2004) is cited but not deeply engaged. The paper should more explicitly discuss whether decentralized climate policy builds or erodes federal support.
   - **Suggestion**: Add section contrasting Rabe's optimistic view (state action builds federal momentum) with this paper's pessimistic finding

3. **Thermostatic model extensions**: The paper cites Wlezien (1995) and Soroka & Wlezien (2010) but misses recent work on:
   - **Missing**: Stimson (1991) on macro political mood; Enns & Kellstedt (2008) on policy responsiveness
   - **BibTeX**:
     ```bibtex
     @article{Stimson1991,
       author = {Stimson, James A.},
       title = {Public Opinion in America: Moods, Cycles, and Swings},
       journal = {Westview Press},
       year = {1991}
     }
     @article{EnnsKellstedt2008,
       author = {Enns, Peter K. and Kellstedt, Paul M.},
       title = {Policy Mood and Congressional Ideology: Public Opinion, Institutional Position, and the Diffusion of Ideas},
       journal = {American Journal of Political Science},
       year = {2008},
       volume = {52},
       pages = {786--802}
     }
     ```

4. **Swiss direct democracy literature**: The paper cites Kriesi (2005), Trechsel & Kriesi (2000), and Vatter (2018) but could better engage with:
   - **Missing**: Linder (2010) on Swiss federalism; Herrmann & Sciarini (2010) on the Röstigraben
   - **Note**: These are cited but not deeply discussed. The paper should more explicitly position the Röstigraben as a fundamental cleavage that shapes all policy preferences in Switzerland.

5. **Renewable energy policy and local opposition**: The paper cites Stokes (2016) but misses:
   - **Missing**: Sunstein (2009) on group polarization; Bollinger & Gillingham (2012) on peer effects in energy adoption
   - **Suggestion**: Add discussion of how local implementation of building efficiency mandates may trigger organized opposition from construction industry, property owners, etc.
   - **BibTeX**:
     ```bibtex
     @article{BollingerGillingham2012,
       author = {Bollinger, Bryan and Gillingham, Kenneth T.},
       title = {Peer Effects in the Diffusion of Solar Photovoltaic Panels},
       journal = {Marketing Science},
       year = {2012},
       volume = {31},
       pages = {900--912}
     }
     ```

### C. Positioning of Contribution

**STRENGTH**: The paper clearly positions its contribution as challenging the optimistic "bottom-up" theory of climate governance (p. 1): "Which dynamic prevails has profound implications for the 'bottom-up' theory of climate governance embodied in the Paris Agreement."

**WEAKNESS**: The paper could more explicitly contrast its findings with prior work on policy diffusion. For example:
- Shipan & Volden (2008) document horizontal diffusion across states; this paper shows vertical diffusion (state-to-federal) may not occur
- Rabe (2004) argues state climate policy creates momentum for federal action; this paper finds the opposite

**Suggestion**: Add a paragraph in the literature review (Section 2.2) explicitly stating: "Unlike Rabe (2004), who argues that state-level climate policy creates momentum for federal adoption, this paper finds evidence of negative feedback: voters in states with prior policy exposure show *reduced* support for federal harmonization."

### D. Overall Literature Assessment

**VERDICT: GOOD but with gaps** - The paper cites foundational work appropriately but misses some important literature on electoral backlash, vertical policy diffusion, and the thermostatic model. The gaps are not fatal but should be addressed in revision.

---

## 5. WRITING QUALITY (CRITICAL)

### A. Prose vs. Bullets

**PASS**: The paper is written entirely in full paragraphs. No bullet points appear in the Introduction, Literature Review, Results, or Discussion sections. The Data section (4.1-4.4) uses prose with embedded tables rather than bullet points. ✓ **Excellent.**

### B. Narrative Flow

**STRENGTHS**:
1. **Compelling opening**: The Introduction (p. 1) begins with a concrete question: "Does prior experience with sub-national climate policy increase or decrease citizens' willingness to support national climate action?" This is immediately engaging.
2. **Clear arc**: The paper follows a logical progression: motivation (policy feedback debate) → theory (thermostatic vs. positive feedback) → institutional setting (Swiss federalism) → empirical strategy (spatial RDD) → findings (negative feedback) → implications (caution on bottom-up climate governance).
3. **Transitions between sections**: Section 1.2 (Roadmap) clearly signals the structure. Transitions between major sections are explicit (e.g., "The remainder of the paper proceeds as follows...").

**WEAKNESSES**:
1. **Institutional background (Section 3) is dense**: Pages 8-11 contain extensive detail on Swiss federalism, MuKEn provisions, and the Energy Strategy 2050. While necessary, this section could be tightened. For example, Section 3.2 (MuKEn) provides granular detail on building standards that may not be essential for understanding the identification strategy.
   - **Suggestion**: Move some institutional detail to an appendix box and retain only the essential facts: (1) 5 cantons adopted comprehensive energy laws between 2011-2017, (2) these laws included building efficiency standards and renewable energy subsidies, (3) the May 2017 federal referendum proposed similar measures nationally.

2. **Results section (Section 6) is very long**: Pages 20-35 contain 9 subsections with extensive robustness checks. While thoroughness is good, the narrative could be tightened.
   - **Suggestion**: Consolidate some robustness checks into a single "Robustness" subsection rather than separate subsections for each check (6.3, 6.4, 6.6, 6.7, 6.8).

3. **Placebo results (Table 15) are buried**: The concerning placebo results (immigration +4.05 pp, corporate tax -3.27 pp) are presented in the appendix (p. 51) rather than in the main text. These results raise important questions about identification and deserve more prominent discussion.
   - **Suggestion**: Move Table 15 to the main text (after Table 5) and discuss the implications for identification. Explain why the same-language RDD specification addresses this concern.

### C. Sentence Quality

**STRENGTHS**:
1. **Varied sentence structure**: The paper uses a mix of short, punchy sentences and longer, complex sentences. Example (p. 1): "Achieving global decarbonization requires sustained public support for climate mitigation policy. A central question for climate policy strategy is whether implementing climate policy at one level of government builds or erodes support for further action."
2. **Active voice**: Most sentences use active voice. Example (p. 5): "I exploit variation in the timing of cantonal energy law adoption in Switzerland to examine whether exposure to local climate policy shaped voting behavior..."
3. **Concrete examples**: The paper provides specific examples rather than abstract claims. Example (p. 8): "Graubünden was the first, adopting its Energiegesetz in 2010 (in force January 2011) with comprehensive building standards and strong enforcement."

**WEAKNESSES**:
1. **Some sentences are overly long and complex**: Example (p. 2): "While identification relies on assumptions about border comparability that cannot be fully verified, the evidence is consistent with the 'thermostatic' model of public opinion: sub-national policy implementation may reduce rather than increase demand for federal action, though the effect size is modest relative to the magnitude of the Röstigraben language divide." This sentence contains three clauses and is difficult to parse on first reading.
   - **Suggestion**: Break into two sentences: "While identification relies on assumptions about border comparability that cannot be fully verified, the evidence is consistent with the 'thermostatic' model of public opinion. Sub-national policy implementation may reduce rather than increase demand for federal action, though the effect size is modest relative to the magnitude of the Röstigraben language divide."

2. **Passive voice in some key passages**: Example (p. 20): "Treatment is binary and measured at the canton level, but actual policy exposure varied within cantons." Better: "I measure treatment as a binary variable at the canton level, but actual policy exposure varied within cantons."

### D. Accessibility

**STRENGTHS**:
1. **Technical terms explained**: The paper explains econometric terms on first use. Example (p. 15): "Local linear regression with triangular kernel weights and MSE-optimal bandwidth selection" is explained with citations to Calonico et al. (2014).
2. **Intuition provided**: The paper provides intuition for econometric choices. Example (p. 15): "The intuition is that municipalities on opposite sides of a border are similar in most respects except for cantonal jurisdiction—and thus cantonal policy exposure."
3. **Magnitudes contextualized**: The paper contextualizes effect sizes. Example (p. 22): "The effect size is substantial: nearly 6 percentage points of reduced support, equivalent to closing roughly one-third of the gap between the lowest-voting (Ticino, 41%) and highest-voting (Geneva, 73%) cantons."

**WEAKNESSES**:
1. **Swiss institutional details may confuse non-Swiss readers**: The paper assumes familiarity with Swiss federalism, cantons, and direct democracy. While explained, the level of detail may be overwhelming for readers unfamiliar with Switzerland.
   - **Suggestion**: Add a brief sidebar or appendix box explaining Swiss federalism for non-Swiss readers. Example: "Switzerland consists of 26 cantons (states) with substantial legislative autonomy. Citizens vote on federal referendums 3-4 times per year, deciding on constitutional amendments and legislation challenged by petition."

2. **Röstigraben explained late**: The paper introduces the Röstigraben (language divide) on page 9 but does not fully explain its political significance until later. The Röstigraben is the dominant source of variation in referendum support (15.5 pp difference) and should be introduced earlier.
   - **Suggestion**: Add a sentence in the Introduction: "Switzerland's political landscape is shaped by the 'Röstigraben' (rösti divide), a language-based cleavage where French-speaking voters consistently support more federal environmental policy than German-speaking voters."

### E. Figures and Tables

**STRENGTHS**:
1. **Maps are publication-quality**: Figures 1-5 are beautifully rendered and clearly show the geographic variation in treatment, language, and outcomes.
2. **RDD plots are informative**: Figure 7 shows binned means with confidence intervals and local polynomial fits, making the discontinuity visually apparent.
3. **Comprehensive robustness**: Figures 10-11 and Table 14 show bandwidth sensitivity and donut RDD specifications, providing transparency about robustness.

**WEAKNESSES**:
1. **Too many figures**: The paper contains 20 figures, which may be excessive for a journal submission. Some figures could be moved to the appendix.
   - **Suggestion**: Keep Figures 1-7 and 12-14 in the main text (core results and diagnostics). Move Figures 8-11 and 15-20 to the appendix.

2. **Figure 6 is redundant**: Figure 6 shows RDD specifications using the "pre-correction sample" (distance to union boundary), but the main results use the "corrected sample" (distance to own canton border). The figure is confusing and could be removed.
   - **Suggestion**: Delete Figure 6 and replace with a single figure showing the corrected-sample RDD estimates (Table 5, row 2).

3. **Some table notes are incomplete**: Table 5 notes that the sample is "restricted to municipalities in cantons that directly share a treated-control border" but does not explain why Basel-Stadt is excluded. The note should clarify: "Basel-Stadt is excluded because it is completely surrounded by treated Basel-Landschaft and thus has no treated-control canton border."

### F. Overall Writing Assessment

**VERDICT: GOOD** - The paper is well-written with clear prose, logical flow, and appropriate technical exposition. The main weaknesses are (1) overly dense institutional background (Section 3), (2) very long results section (Section 6), and (3) placebo results buried in appendix. These are fixable issues that do not prevent publication but would improve the paper.

---

## 6. CONSTRUCTIVE SUGGESTIONS FOR IMPACT

### A. Strengthen the Causal Claim

**Current approach**: The paper uses spatial RDD on same-language borders to isolate the causal effect of cantonal energy laws on federal referendum support.

**Suggestion**: Conduct a **survey experiment** to directly test the thermostatic mechanism. Design a survey where respondents in treated and control cantons are randomly assigned to:
- **Control**: No information about their canton's energy law
- **Treatment**: Information about their canton's energy law (e.g., "Your canton adopted building efficiency standards in 2012, requiring homeowners to retrofit buildings")

**Hypothesis**: Respondents who are reminded of their canton's existing policy should show *lower* support for federal energy policy (thermostatic response).

**Why this matters**: The current paper cannot definitively distinguish between thermostatic response, cost salience, and federal overreach. A survey experiment could isolate the thermostatic mechanism and strengthen the causal interpretation.

### B. Extend to Other Policy Domains

**Current scope**: The paper examines energy policy in Switzerland.

**Suggestion**: Test whether negative policy feedback generalizes to other regulatory policies (environmental protection, labor standards, consumer protection). Do voters in states with stricter environmental regulations show lower support for federal environmental policy?

**Why this matters**: The thermostatic model should apply broadly to regulatory policies where costs are salient. Testing this would strengthen the theoretical contribution.

### C. Individual-Level Heterogeneity

**Current approach**: The paper examines heterogeneity by urbanity (Table 8) but finds no significant differences.

**Suggestion**: Conduct individual-level analysis using survey data or administrative records to examine heterogeneity by:
- **Homeownership**: Do homeowners who faced building retrofit costs show stronger negative feedback than renters?
- **Income**: Do lower-income voters (who bear higher relative costs) show stronger negative feedback?
- **Policy awareness**: Do voters aware of their canton's energy law show stronger negative feedback than unaware voters?

**Why this matters**: Understanding which voters show thermostatic response would refine the mechanism and inform policy design.

### D. Reframe the Policy Implications

**Current framing** (p. 50): "Advocates should not assume that laboratory federalism automatically builds national coalitions. Complementary strategies may be necessary: federal co-financing, clear articulation of benefits from national coordination, and framing that respects local autonomy."

**Suggestion**: Go further and discuss implications for climate policy strategy:
1. **Bottom-up vs. top-down**: If local policy experience reduces demand for federal action, climate advocates should prioritize federal action *before* decentralized implementation, not after.
2. **Policy sequencing**: Consider whether the order of policy adoption (federal first vs. local first) affects public support differently.
3. **Framing**: How should federal policy be framed to avoid triggering thermostatic response? (E.g., "complementary" rather than "harmonizing"?)

**Why this matters**: This would make the paper more actionable for policymakers and advocates.

### E. Examine Mechanism Through Administrative Data

**Current approach**: The paper infers mechanisms (thermostatic response, cost salience, federal overreach) but cannot directly test them.

**Suggestion**: Examine administrative data on:
- **Building permits and retrofits**: Did municipalities in treated cantons see increased building activity after the energy law? (If so, voters may have direct experience with costs)
- **Turnout by demographic group**: Did turnout patterns differ between treated and control cantons? (Could indicate differential mobilization)
- **Vote share by municipality type**: Did rural municipalities show stronger negative feedback than urban municipalities? (Could indicate cost salience)

**Why this matters**: Administrative data could provide indirect evidence about which mechanisms are most important.

---

## 7. OVERALL ASSESSMENT

### Key Strengths

1. **Novel empirical finding**: The paper provides evidence of negative policy feedback—a surprising result that challenges the optimistic "bottom-up" theory of climate governance. This is a genuine contribution to the policy feedback and climate policy literatures.

2. **Rigorous methodology**: The spatial RDD design is well-executed with appropriate inference for few clusters. The corrected sample construction (distance to own canton border) is methodologically sophisticated. The multiple robustness checks (bandwidth sensitivity, donut RDD, covariate balance, placebo tests, DiD) are comprehensive.

3. **Transparent about limitations**: The paper explicitly acknowledges limitations (language assignment at canton level, few treated units, external validity concerns) and discusses how they affect interpretation. This transparency is admirable.

4. **Beautiful presentation**: The maps (Figures 1-5) are publication-quality and effectively communicate the geographic variation in treatment and outcomes. The RDD plots (Figures 7, 16) clearly show the discontinuity.

5. **Appropriate use of econometric methods**: The paper uses Callaway & Sant'Anna (2021) for staggered adoption (correct approach), wild cluster bootstrap for few-cluster inference (appropriate), and randomization inference (useful sensitivity check).

### Critical Weaknesses

1. **Identification relies on unverifiable assumptions**: The spatial RDD assumes municipalities on opposite sides of a canton border are comparable except for policy exposure. The placebo results (Table 15) suggest this assumption may be violated—the borders show significant discontinuities on