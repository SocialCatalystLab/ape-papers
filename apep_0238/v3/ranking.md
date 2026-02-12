# Research Idea Ranking

**Generated:** 2026-02-12T11:47:07.665896
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 4600

---

### Rankings

**#1: Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets**
- **Score: 72/100**
- **Strengths:** Clever cross-episode design that uses rich monthly state panels and an established Bartik/shift-share style instrument to study persistence/hysteresis. High policy value if you can convincingly show that “shock type” (demand vs supply/temporary separations) predicts scarring in employment/LFPR.
- **Concerns:** The “demand vs supply recession” contrast risks being more narrative than identified: COVID combined supply constraints, massive fiscal/monetary support, and heterogeneous state NPIs—so differences in persistence may reflect policy and measurement differences, not shock structure. Also, **COVID doesn’t have 10-year horizons** (data through 2023 gives ~3–4 years), so the advertised \(h=120\) month LP comparison is only feasible for the Great Recession.
- **Novelty Assessment:** **Moderately high.** Hysteresis and state Bartik recovery paths are studied, but a *direct, unified cross-recession comparison (GR vs COVID) framed as demand- vs supply-driven scarring* is less saturated than standard Great Recession hysteresis papers—provided you execute it carefully and transparently.
- **Recommendation:** **PURSUE (conditional on: (i) redefining horizons to what COVID can support—e.g., 0–36/48 months; (ii) explicitly modeling/controlling for COVID-era policy heterogeneity (NPIs, UI expansions, sectoral shutdown intensity) or showing robustness; (iii) addressing modern shift-share validity concerns—leave-one-out construction, exposure exogeneity discussion, and inference robust to spatial correlation).**

---

**#2: Geographic Labor Mobility as a Shock Absorber: Migration Responses to Regional Recessions**
- **Score: 63/100**
- **Strengths:** Uses administrative IRS county-to-county flows—an unusually direct measure of migration responses—paired with plausibly exogenous Bartik labor-demand shocks. Strong policy relevance for place-based policy, UI design, and regional stabilization (whether people “vote with their feet” vs remain trapped).
- **Concerns:** Annual migration flows are a real limitation for business-cycle dynamics and make timing/anticipation hard (migration may respond with lags and be confounded by housing market lock-in). Identification hinges on shift-share assumptions and could be contaminated by correlated local shocks (housing prices, amenities, local policy) that both affect industry mix and migration.
- **Novelty Assessment:** **Moderate.** The adjustment mechanism (Blanchard–Katz) is classic and heavily cited, but **county-to-county flow evidence with modern Bartik practice** is less crowded than the stock-based literature; still, not “wide open.”
- **Recommendation:** **CONSIDER (upgrade to PURSUE if you: (i) pre-register a tight timing/event-study design around recessions; (ii) incorporate housing market/credit constraints explicitly; (iii) use robustness to alternative shock measures and show results by demographic/income group to reduce aggregation bias).**

---

**#3: The Fiscal Multiplier Through the Labor Market Lens: Evidence from ARRA**
- **Score: 58/100**
- **Strengths:** ARRA state allocation IV is among the cleanest and most policy-relevant state fiscal shock designs; policymakers still care about multipliers and *how* employment adjusts (hiring vs separations). If you can credibly decompose job creation vs job destruction, that’s a meaningful contribution.
- **Concerns:** **Novelty is low**: the ARRA multiplier design is extremely well-trodden (Wilson; Chodorow-Reich; many follow-ons), so incremental contributions need to be very clearly differentiated. Data feasibility is a serious risk: Recovery.gov compilation is nontrivial, and the proposal’s “JOLTS-style flow data at the state level” is not obviously available at consistent state coverage/quality (JOLTS is traditionally national/region/industry; state-level flows are limited/experimental—if unavailable, the core novelty claim collapses).
- **Novelty Assessment:** **Low.** The base question and identification are canonical; only the flow decomposition could lift it, and only if the data are genuinely strong and new.
- **Recommendation:** **CONSIDER (conditional on: (i) verifying a high-quality state-level hires/layoffs dataset—e.g., QWI/LEHD, UI records, or a defensible proxy; (ii) demonstrating that your decomposition is not already done in close substitutes; (iii) automating/validating ARRA spending measures with replicable code and clear documentation).**

---

**#4: Skill Mismatch and the Slow Recovery: Occupational Reallocation After the Great Recession**
- **Score: 45/100**
- **Strengths:** Important question with a natural mechanism (reallocation frictions/mismatch) and feasible microdata access via IPUMS CPS. Matched CPS panels can be powerful if executed carefully.
- **Concerns:** Identification is comparatively weak as described: “exposure to housing bust × reemployment patterns” risks being an elaborated correlation unless the exposure is clearly exogenous and not proxying for many other regional shocks (credit, local demand collapse, construction-heavy demographics). The mismatch literature is also crowded, and CPS matching plus occupation-code discontinuities can create fragile results if not handled rigorously.
- **Novelty Assessment:** **Low to moderate.** Occupational mismatch after the Great Recession has many influential predecessors (e.g., Şahin et al. and a large follow-on literature). “Longer follow-up” alone is typically not enough to clear the novelty bar.
- **Recommendation:** **SKIP (unless you can articulate a substantially sharper identification strategy—e.g., a compelling instrument or discontinuity, cleaner administrative data on job transitions, or a design that isolates mismatch from local demand/credit channels).**

---

### Summary

This is a solid batch conceptually, but only **Idea 1** clearly stands out on *novel framing plus feasible high-frequency data*—with the important caveat that the COVID horizon and policy confounding must be handled head-on. **Idea 3** is promising if you lean into what IRS flow data uniquely enables, while **Idea 2** is credible but heavily mined and only worth doing if the labor-flow decomposition is truly data-supported. **Idea 4** is the weakest: the space is crowded and the proposed identification risks collapsing into descriptive patterns rather than credible causal inference.