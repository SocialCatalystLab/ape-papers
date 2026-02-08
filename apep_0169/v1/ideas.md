# Research Ideas

**Method:** Doubly Robust (DR) - selection on observables, not policy variation

Note: DR studies examine individual choices/behaviors rather than policy shocks with specific adoption dates. The "treatment" is an individual-level choice, and identification comes from rich covariates enabling conditional independence.

---

## Idea 1: The Insurance Value of Secondary Employment: Does Gig Work Enable Primary Job Mobility?

**Policy:** Individual choice to hold secondary employment (gig work, part-time second job, freelance work). Treatment is at the individual level, not a policy intervention. Analysis period: 2015-2024.

**Outcome:** Primary job transitions measured via CPS longitudinal panels: voluntary quits, job-to-job moves, wage changes, unemployment spells. Secondary outcomes: job tenure, industry switches, occupational upgrades.

**Identification:** Doubly Robust estimation (AIPW with cross-fitting) exploiting rich CPS covariates to achieve conditional independence. Selection into multiple job holding is controlled via demographics, education, occupation, industry, financial indicators, and family structure. Heterogeneous effects by credit constraint proxies test the "insurance" mechanism directly.

**Why it's novel:**
1. First causal estimate of secondary employment → primary job mobility
2. Tests competing theoretical mechanisms (insurance vs. lock-in) with falsifiable predictions
3. Heterogeneity analysis distinguishes insurance (benefits credit-constrained) from lock-in (hurts all)
4. Challenges "precarious work" narrative if gig work enables upward mobility

**Feasibility check:**
- CPS MULTJOB/NUMJOB available 1994-2024 ✓
- Longitudinal CPSIDP linking confirmed ✓
- ~150k workers/year, ~20% MJH rate = adequate power ✓
- Not studied causally in APEP or economics literature ✓
- Rich covariates support unconfoundedness ✓

---

## Idea 2: Who Benefits from Remote Work? Testing the Compensating Differentials Theory

**Policy:** Individual choice of remote/hybrid work arrangement vs. on-site. Treatment is post-pandemic sorting into flexible work (2022-2024). Analysis exploits variation in occupation-level teleworkability.

**Outcome:** Wage levels and wage growth, quit rates (revealed job satisfaction), hours worked, commuting time, residential location choices.

**Identification:** Doubly Robust with O*NET teleworkability scores as continuous moderator. Controls for occupation, industry, firm size, education, experience, metro area. Tests whether workers accept wage penalties for remote work (compensating differentials).

**Why it's novel:**
1. First DR estimate of remote work wage penalty/premium controlling for selection
2. Heterogeneity by family status tests "who values flexibility"
3. O*NET integration enables occupation-level ability vs. individual choice separation
4. Timely: post-pandemic return-to-office debates lack causal evidence

**Feasibility check:**
- CPS telework questions post-2020 ✓
- O*NET teleworkability scores available ✓
- Selection concerns substantial ⚠️ (strong unobservable sorting)

---

## Idea 3: Does Health Insurance Portability Enable Entrepreneurship? Spousal Coverage and Business Formation

**Policy:** Having a spouse with employer-sponsored health insurance (ESI) vs. own ESI vs. marketplace coverage. Treatment is family insurance arrangement. Analysis period: 2014-2024 (post-ACA for marketplace comparison).

**Outcome:** Self-employment entry, transition from wage work to self-employment, business income, hours in self-employment, business incorporation.

**Identification:** Doubly Robust comparing workers by spousal insurance status. Controls include both spouses' education, occupation, industry, income, age, state. Key test: does ACA marketplace reduce spousal coverage importance?

**Why it's novel:**
1. Spousal coverage less studied than own coverage in job lock literature
2. Can test insurance VALUE vs. insurance SOURCE distinction
3. Natural experiment within DR: pre/post ACA marketplace availability
4. Tests whether "job lock" operates through risk aversion or liquidity

**Feasibility check:**
- CPS ASEC has detailed insurance source including spousal ✓
- Can identify marketplace vs. ESI ✓
- Literature exists but mechanism testing is novel ✓

---

## Recommendation: Pursue Idea 1

**Rationale:**
1. **Most novel**: No causal estimates exist for gig work → primary job mobility
2. **Strongest theory**: Competing mechanisms (insurance vs. lock-in) with clear empirical tests
3. **Best DR fit**: Individual choice with rich observable determinants
4. **Counter-intuitive potential**: May challenge "precarious work" narrative
5. **Clean data**: CPS design ideal for this question
6. **Timely**: Post-pandemic gig economy expansion makes this policy-relevant

**Key risk:** Selection on unobservables (risk preferences, entrepreneurial ability)
**Mitigation:** E-value sensitivity, calibrated sensitivity analysis, negative control outcomes
