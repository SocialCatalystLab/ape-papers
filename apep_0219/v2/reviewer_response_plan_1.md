# Revision Plan — apep_0217 v1

## Overview

This revision addresses feedback from three external reviewers (GPT, Grok, Gemini), one exhibit review, and one prose review. The paper received one Major Revision (GPT) and two Minor Revisions (Grok, Gemini). The prose review rated the paper "top-journal ready." All changes are organized into three workstreams.

---

## Workstream 1: Must Do (Substantive Reviewer Concerns)

### 1.1 Clustering Clarification (GPT)
**Location:** Section 4.2 (Estimation)
**Action:** Add a paragraph explicitly stating that `rdrobust`'s `cluster` option is used with county FIPS codes as the clustering variable, producing cluster-robust bias-corrected standard errors. Cite Cameron, Gelbach, and Miller (2008) on cluster-robust inference.

### 1.2 Power/MDE Calculations (GPT)
**Location:** Section 5.2 (Main Results), after presenting null estimates
**Action:** Add a paragraph reporting minimum detectable effect sizes given the effective sample sizes and standard errors. Frame what effect sizes the design can rule out.

### 1.3 Additional References (GPT, Grok, Gemini)
**Action:** Add to bibliography and cite in text:
- Cameron, Gelbach, and Miller (2008) — cluster-robust bootstrap → Section 4.2
- Hahn, Todd, and Van der Klaauw (2001) — fuzzy RD foundations → Section 4.1
- Bartik (1991) — demand shocks/place-based policy → Section 6.1
- Austin, Glaeser, and Summers (2018) — distressed communities/Opportunity Zones → Section 6.1
- Papke (1994) — enterprise zones → Section 6.1

### 1.4 First-Stage Discussion (GPT, Grok, Gemini)
**Location:** Section 5.5 (Mechanisms: Small treatment intensity)
**Action:** Expand the subsection to explicitly acknowledge the absence of county-level grant utilization data. Discuss what this means for interpreting the null: we cannot distinguish between low take-up and ineffective spending. Note that this is a shared limitation with other place-based RDD studies.

### 1.5 BEA Personal Income Note (GPT)
**Location:** Section 4.4 (Threats to Validity — outcome-assignment overlap)
**Action:** Add explicit sentence noting that BEA-based personal income estimates (an outcome not mechanically linked to the CIV) yield consistent null results, strengthening the case that the null is genuine.

---

## Workstream 2: Should Do (Exhibit and Prose Improvements)

### 2.1 Kill Roadmap Paragraph (Prose Review)
**Location:** End of Section 1 (Introduction)
**Action:** Delete the "The remainder of the paper proceeds as follows..." paragraph entirely.

### 2.2 Improve Abstract (Prose Review)
**Action:** Tighten the abstract — make it more vivid and direct. Remove hedging language. Lead with the stakes.

### 2.3 Remove Filler Phrases (Prose Review)
**Action:** Sweep through paper for throat-clearing phrases ("It is worth noting that...", "In this section, I...", etc.) and remove or tighten them.

---

## Workstream 3: Nice to Have

### 3.1 Move Yearly Estimates and Bandwidth Sensitivity to Appendix
**Location:** Figures 4 and 5 in main text
**Action:** Move Figure 4 (yearly estimates) and Figure 5 (bandwidth sensitivity) from main text to the appendix. Keep textual discussion but reference appendix figures.

### 3.2 Reference Appalachian Map in Introduction
**Location:** Section 1 (Introduction)
**Action:** Add a sentence in the introduction referencing the map in the appendix (Appendix Figure) to orient readers geographically.

---

## Execution Order

1. Add new bibliography entries
2. Make substantive text edits (clustering, MDE, first-stage, BEA note, new citations)
3. Prose improvements (kill roadmap, tighten abstract, remove filler)
4. Move figures to appendix
5. Recompile PDF (two passes)
6. Write reply_to_reviewers_1.md
