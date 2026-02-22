# Revision Plan: apep_0439 → v2

## Context

**Paper:** "Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy"
**Current rating:** 25.6 μ, 18.7 conservative (top ~5 APEP)
**User directive:** "needs a lot of polishing" + "conceptually sharp, think AER"
**Parent:** `papers/apep_0439/v1/`
**New workspace:** `output/apep_0439/v2/`

**Core finding:** Sub-additive interaction between language and religion borders: Catholic heritage dampens the French progressive effect on gender voting by 7.3pp ($p < 0.001$).

**What's already good:** Interesting question, clean empirical setting, striking results, powerful falsification test, decent prose (graded A by reviewer).

**What's missing for AER:** No conceptual framework, no municipality controls, several text/table inconsistencies, some exhibit quality issues, framing is "three literatures" instead of one big idea.

---

## Workstreams (7 total, ordered by priority)

### WS1: Conceptual Framework (NEW SECTION — the biggest upgrade)

**Goal:** Add Section 3 "Conceptual Framework" between Background and Data. This is what "conceptually sharp" means — clear theoretical predictions *before* seeing data.

**Content:**

1. **The Modularity Assumption.** Standard cultural economics treats dimensions as independent additive shifters: $\theta_i = \alpha + \beta_L L_i + \beta_R R_i + \epsilon_i$. Cite Alesina & Giuliano (2015), Fernandez (2011), Tabellini (2010). Make explicit that this is a *maintained assumption* that has never been tested.

2. **Three Models of Cultural Combination:**
   - *Model A: Additive (Modular).* Each dimension shifts preferences independently. Predicted: $\gamma = 0$.
   - *Model B: Super-additive (Reinforcing).* Dimensions amplify each other. E.g., "double progressivism" of French-Protestant culture. Predicted: $\gamma > 0$.
   - *Model C: Sub-additive (Dampening).* Dimensions offset. Catholic institutions create friction against francophone progressive transmission. Predicted: $\gamma < 0$.

3. **Three Testable Predictions:**
   - **P1:** $\gamma < 0$ (sub-additivity in aggregate gender voting)
   - **P2:** $|\gamma|$ is larger for church-salient issues (abortion, 2002) than for secular gender issues (paternity leave, 2020) — because Catholic institutional influence is strongest where Church doctrine is most specific
   - **P3:** The dampening is specific to gender attitudes, not a generic feature of French-Catholic political behavior (falsification with non-gender referenda)

4. **Theoretical Underpinnings.** Brief discussion connecting to:
   - Bisin & Verdier (2001): Cultural transmission under cross-cutting identities
   - Akerlof & Kranton (2000): Identity and competing prescriptions
   - Crenshaw (1989): Intersectionality as non-additivity (bridge from sociology to economics)

**Files modified:** `paper.tex` (add ~2.5 pages)

---

### WS2: Rewrite Introduction for One Big Idea

**Goal:** The paper should be about ONE idea: *cultural dimensions are not modular*. Everything else supports this.

**Changes:**
- Keep the opening hook (Lausanne/Lucerne woman) — it's excellent
- Sharpen the framing: "The standard approach treats cultural dimensions as independent modules. We test this assumption."
- Kill the "three literatures" paragraph — weave contributions into the narrative instead
- Add paragraph connecting to P1-P3 predictions from the new framework
- Delete the roadmap paragraph ("The remainder of the paper proceeds as follows...")
- Active voice subsection titles throughout:
  - "5.1 The Röstigraben and Confessional Gaps" → "5.1 Language and Religion Both Predict Gender Voting"
  - "5.2 Catholicism Dampens Francophone Progressivism" → keep (already good)
  - "5.3 Culture Group Means and the Additivity Test" → "5.3 The Additivity Test Fails"
  - "5.5 The Dampening Persists Across Four Decades" → "5.5 The Dampening Is Persistent but Issue-Dependent"

**Files modified:** `paper.tex`

---

### WS3: Fix Code Bugs & Add Municipality Controls

**Goal:** Address the biggest identification concern (no covariates) and fix data quality issues.

**Bug fixes:**
1. **Solothurn classification:** Code says `"Catholic"` (line 126 of `01_fetch_data.R`) but paper says Mixed→Protestant. Fix code to match paper.
2. **Language heuristic:** Currently Bern defaults to all-German and Valais to all-French. Both are bilingual — need proper classification for Bernese Jura (French) and Upper Valais (German).

**New controls from BFS:**
- Use BFS API to fetch municipality-level: population, population density (proxy for urbanization), foreign-born share
- Add a "controlled" specification to the main results table (new column)
- This directly addresses GPT referee's concern about missing covariates

**Files modified:** `code/01_fetch_data.R`, `code/02_clean_data.R`, `code/03_main_analysis.R`

---

### WS4: Statistical Improvements

**Goal:** Bring inference up to top-journal standard.

**Changes:**
1. Report 95% CIs for all headline estimates in text and tables
2. Fix permutation p-value: "0.000" → "$p < 0.002$" (= 0/500)
3. Voter-weighted regression already exists in robustness; make it more prominent
4. Add SEs and significance stars to Table 6 (time-varying gaps) — currently reports point estimates only
5. Add a brief Oster (2019) omitted variable bias bound: how large would selection on unobservables need to be relative to observables to explain away the interaction?

**Files modified:** `code/03_main_analysis.R`, `code/04_robustness.R`, `code/06_tables.R`, `paper.tex`

---

### WS5: Exhibit Overhaul

**Goal:** AER-quality figures and tables.

**Changes:**
1. **NEW: Map of Switzerland** showing the 4 culture groups with language border and confessional boundary highlighted. This is critical for a spatial paper — readers need to see the geography.
2. **Fix Figure 1 (culture groups bar chart):** Remove any LOESS interpolation; use simple bars + 95% CI whiskers
3. **Improve Figure 3 (interaction plot):** Make this the "money figure" — cleaner, with CIs, clearly showing deviation from additive prediction
4. **Add SEs to Table 6** (time-varying gaps)
5. **Clean Table 1 headers:** Verify unit labels (pp vs proportion)
6. **Reorder appendix:** Move permutation histogram to appendix; promote distribution density plot to main text if space permits

**Files modified:** `code/05_figures.R`, `code/06_tables.R`, `paper.tex`

---

### WS6: Prose Polish

**Goal:** Every sentence earns its place. Shleifer clarity.

**Changes:**
1. Tighten Background section (~15% shorter) — remove redundant citations
2. Results section: translate coefficients into meaning ("Catholicism halves the French effect")
3. Discussion: cut mechanism discussion from 3 full paragraphs to 2 tighter ones
4. Conclusion: end on a strong sentence about the broader lesson, not a future-research laundry list
5. Vary sentence rhythm in Section 5.2 (currently monotonous)
6. Soften causal language on the interaction where appropriate ("is associated with" rather than "causes")
7. Add explicit connection back to predictions P1-P3 in results section

**Files modified:** `paper.tex`

---

### WS7: Fix Advisor FAIL Issues

**Goal:** Clear the GPT advisor's blocking concerns.

**Specific fixes:**
1. ~~Replace @CONTRIBUTOR_GITHUB placeholders~~ (verify these are actually present in current tex — the reply_to_reviewers claims they were fixed)
2. Fix turnout text/table mismatch — text claims "53-54% German" but Table 1 shows 47-50%
3. Fix SD inconsistency — Table 1 reports 0.052-0.104 but Table 3 reports 0.200-0.223. Clarify: Table 1 = within-group SD of municipality means; Table 3 = SD across municipality×referendum observations
4. Add clear unit labels (percentage points vs proportions) throughout

**Files modified:** `paper.tex`, `code/06_tables.R`

---

## Execution Order

1. **WS3 first** (code fixes → data changes cascade to everything)
2. **WS4** (statistical improvements — changes tables)
3. **WS5** (exhibits — depends on updated data/analysis)
4. **WS7** (fix advisor FAIL — depends on updated tables)
5. **WS1** (conceptual framework — pure writing, no code dependency)
6. **WS2** (intro rewrite — depends on WS1 existing)
7. **WS6** (prose polish — final pass after all content is settled)

## Key Files

- **Parent paper:** `papers/apep_0439/v1/paper.tex`
- **Parent code:** `papers/apep_0439/v1/code/` (8 R scripts)
- **Parent data:** `papers/apep_0439/v1/data/` (12 RDS files)
- **New workspace:** `output/apep_0439/v2/`
- **Review workflow:** `.claude/skills/paper/workflows/review.md`
- **Publish workflow:** `.claude/skills/paper/workflows/publish.md`

## Verification

1. All R scripts run end-to-end without error
2. `pdflatex` + `bibtex` compiles cleanly (no unresolved refs)
3. Page count ≥ 25 main text pages
4. All 4 advisors PASS
5. 3 fresh external reviews completed
6. Revision addresses all external review concerns
7. Publish with `--parent apep_0439`
8. Run tournament initialization + calibration matches
9. Push to leaderboard
