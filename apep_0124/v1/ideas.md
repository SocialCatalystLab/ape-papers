# Research Ideas

## Idea 1: Close Referendum Losses and Subsequent Voter Turnout (RDD)

**Policy:** Swiss federal referendum outcomes at the municipal level

**Outcome:** Voter turnout in subsequent referendums on thematically related topics

**Identification:** Regression Discontinuity Design (RDD) at the 50% vote share threshold
- **Running variable:** Municipal-level "Yes" vote share in referendum t
- **Treatment:** "Local loss" (municipality voted <50% Yes on proposal that passed nationally) vs "Local win" (>50% Yes)
- **Outcome:** Turnout in referendum t+1, t+2, etc. on related policy domains

**Data sources:**
- Municipal referendum results: Swiss Federal Statistical Office via voteinfo-app.ch JSON API
- Coverage: 2,100+ municipalities, hundreds of referendums since 1981
- Variables: Yes/No percentages, turnout, eligible voters at Gemeinde level

**Why it's novel:**
- The winner-loser gap literature documents attitude effects (losers become more skeptical of referendums)
- But **turnout effects** of close referendum outcomes are unstudied
- Tests whether democracy is self-reinforcing (winners participate more) or self-correcting (losers mobilize)
- First application of close-election RDD methodology to referendum turnout dynamics

**Theoretical contribution:**
- Policy feedback theory: Do "winning" experiences with democracy increase democratic participation?
- Sore loser hypothesis: Do narrow losses demobilize subsequent participation?
- Democratic resilience: Does direct democracy build or erode civic engagement over repeated votes?

**Feasibility check:**
- Data confirmed accessible: voteinfo-app.ch returns municipal-level results with turnout and vote shares
- ~2,100 municipalities × ~700 federal referendums = substantial sample size
- Can identify "close" municipalities (within ±5pp of 50%) and compare turnout trajectories
- Can match referendums by policy domain (health, environment, immigration, etc.) for related-topic analysis

**Key methodological challenges to address:**
- Selection: Municipalities with close votes may differ systematically from those with landslide results
- Solution: RDD compares only municipalities near the 50% threshold (local randomization)
- Municipal heterogeneity: Control for population, language region, urbanity
- Clustering: Municipalities within cantons share shocks → cluster SEs at canton level

**Research score:** 4/5 (Strong identification, novel question, confirmed data access)

---

## Idea 2: Compulsory Voting Abolition and Long-Run Civic Engagement (DiD)

**Policy:** Historical abolition of compulsory voting across Swiss cantons (1920s-1970s)

**Outcome:** Long-run turnout patterns, civic organization membership, trust in democracy

**Identification:** Difference-in-Differences using staggered cantonal abolition of compulsory voting
- 25 cantons abolished compulsory voting at different times (only Schaffhausen retains it)
- Compare turnout trends before/after abolition across cantons

**Data sources:**
- Historical cantonal voting requirements: Fedlex/cantonal archives
- Turnout data: BFS historical statistics
- Civic engagement: Gemeindemonitoring surveys (1988, 1994, 1998, 2005, 2009, 2017)

**Why it's novel:**
- Schaffhausen 2014 fine increase has been studied (Bechtel et al.)
- But the **long-run effects of abolishing compulsory voting** on civic culture remain unstudied
- Tests whether "forced" democratic participation creates lasting habits or resentment

**Feasibility check:**
- Historical timing data requires archival research — less immediately accessible than Idea 1
- Outcome data (civic engagement surveys) requires SWISSUbase registration — adds friction
- Pre-treatment periods for 1920s-1970s abolitions may lack consistent outcome measures

**Research score:** 3/5 (Novel question, but historical data access uncertain)

---

## Idea 3: Language Border Voting Information Asymmetry (Spatial RDD)

**Policy:** Swiss federal referendum campaigns conducted primarily in German vs French

**Outcome:** Turnout and vote shares at the Röstigraben language border

**Identification:** Spatial RDD at French-German language border
- Running variable: Distance to language border (Gemeinde centroid)
- Compare voting patterns in French vs German municipalities at the border
- Control for canton-level policy environment by focusing on within-canton language borders (e.g., Fribourg, Valais, Bern)

**Data sources:**
- Municipal voting results: swissdd R package / voteinfo API
- Language region classification: BFS
- Geographic boundaries: BFS base maps

**Why it's novel:**
- The Röstigraben political divide is well-documented descriptively
- But **causal effects of language-based information asymmetry** on voting are understudied
- Tests whether campaign information access (German media dominance) affects democratic outcomes

**Feasibility check:**
- apep_0071 already used Swiss canton border spatial RDD — similar design may feel derivative
- Language borders don't create sharp policy discontinuities — weaker treatment than policy borders
- Would need to identify referendums with asymmetric campaign intensity across languages

**Research score:** 2/5 (Interesting but weaker identification, similar to existing APEP work)

---

## Recommendation: Pursue Idea 1

Idea 1 (Close Referendum RDD) is the strongest candidate because:
1. **Novel:** No existing study applies close-election RDD to referendum turnout dynamics
2. **Rigorous identification:** RDD at 50% threshold provides quasi-random assignment
3. **Data confirmed:** Municipal-level voting data is accessible via public API
4. **Policy relevant:** Understanding how winning/losing affects future participation matters for democratic design
5. **Swiss-specific:** Leverages Switzerland's uniquely rich referendum data at municipal level

This idea combines methodological innovation (adapting election RDD to referendum context) with a theoretically important question (does democracy reinforce itself?) and confirmed data feasibility.
