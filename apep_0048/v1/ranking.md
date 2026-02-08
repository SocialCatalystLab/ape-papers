# Research Idea Ranking

**Generated:** 2026-01-21T19:56:58.481942
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 3247
**OpenAI Response ID:** resp_0c01ee3209041c4d006971215d125881909713fa9861b30c47

---

### Rankings

**#1: City Votes, Country Voices: Urban-Rural Heterogeneity in the Labor Market Effects of Women's Suffrage (Angle 1)**
- **Score:** 68/100  
- **Strengths:** Clear, testable mechanism distinction (policy channel more likely to “bite” in urban wage labor markets vs norm changes potentially stronger in rural areas). Data are straightforward (URBAN, LABFORCE) and sample sizes are enormous, making heterogeneity feasible even for smaller early-adopting states.  
- **Concerns:** This is still fundamentally a state-level staggered-adoption DiD with limited pre-periods (1880/1900/1910 depending on state), so **parallel trends and compositional change** (urbanization, sectoral shifts) are big threats. The “Urban” indicator is not fully stable across censuses and can itself respond to suffrage-era growth, complicating interpretation of the triple interaction.  
- **Novelty Assessment:** **Medium.** Women’s suffrage → female LFP has been studied heavily; however, a clean, census-based **urban/rural heterogeneity** focus is less saturated than baseline DiD estimates and is plausibly additive if executed carefully.  
- **Recommendation:** **CONSIDER** (worth doing if you can convincingly address pre-trends and urbanization/composition issues; otherwise it risks being “one more suffrage DiD.”)

---

**#2: From Farm to Factory: Women’s Suffrage and Occupational Mobility in Urban America (Angle 2)**
- **Score:** 60/100  
- **Strengths:** More conceptually novel than LFP because it targets the **intensive margin** (occupation quality/skill), which is closer to “opportunity” than simple participation. If credible, results could speak directly to mechanisms like anti-discrimination/professional access and not just labor supply.  
- **Concerns:** Identification is weaker than Angle 1 because occupational upgrading is highly sensitive to **structural transformation** (industrialization, clerical expansion, education, compulsory schooling) that differs across states and is correlated with progressive-era reforms (including suffrage). Conditioning on “working women” introduces selection that may change with suffrage, and early occupational coding can be noisy—small classification changes can look like “upgrading.”  
- **Novelty Assessment:** **Medium-high.** There’s a large literature on occupational change for women in this period, and some work on suffrage impacts broadly, but **suffrage → occupational upgrading (especially with urban focus)** is less “standard” than LFP and could add real value if executed well.  
- **Recommendation:** **CONSIDER** (good follow-on or companion paper, but only if you have a strong plan to separate suffrage from concurrent modernization and to handle selection into employment.)

---

**#3: Voting with Their Feet: Did Suffrage Affect Women’s Internal Migration to Cities? (Angle 3)**
- **Score:** 44/100  
- **Strengths:** If feasible, this is arguably the most “general equilibrium” and behaviorally revealing angle—migration responses would be a strong signal of perceived opportunity changes and could connect political rights to spatial reallocation.  
- **Concerns:** The core outcome is hard to measure well in this period: birthplace ≠ residence is a very noisy proxy for migration timing and direction, and linking-based measures shrink sample size and can create selection bias. Even with full counts, mover identification and origin/destination treatment coding will be error-prone, making causal interpretation fragile.  
- **Novelty Assessment:** **High (but mostly because it’s hard).** There is migration work for the era, but suffrage-driven female internal migration is not heavily studied—largely because the data don’t cleanly support it.  
- **Recommendation:** **SKIP** (too measurement-limited for a policy institute deliverable unless you have unusually strong linked microdata and a pre-registered strategy to handle the noise.)

---

### Summary

This is a coherent batch centered on a well-known reform (women’s suffrage) but trying to extract new mechanism-relevant variation. Angle 1 is the most feasible and policy-relevant extension, though it needs unusually careful handling of urbanization/compositional trends to be credible. Angle 2 is potentially more novel but harder to identify cleanly; Angle 3 is the most fragile due to outcome measurement.