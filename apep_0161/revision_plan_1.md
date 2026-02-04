# Revision Plan - Paper 145

## Reviews Received
- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MAJOR REVISION

## Changes to Make

### 1. Writing: Convert bullets to prose (Gemini)
- Convert "Predictions" bullets in Conceptual Framework to paragraph form
- Convert causal chain numbered list to flowing paragraphs
- Consolidate Discussion subsections for better flow
- Trim "Summary for Policymakers" or integrate into conclusion

### 2. References: Add missing citations (GPT, Grok)
- Bertrand, Duflo & Mullainathan (2004) - clustering in DiD
- Cameron, Gelbach & Miller (2008) - wild cluster bootstrap
- Finkelstein et al (2019) - Medicaid mortality null
- Doyle et al (2019) - cost-sharing and health

### 3. Reporting: Add exact N and cluster counts (GPT)
- Ensure all main tables show N and number of clusters
- Add treated-state count and post-treatment obs count
- Report exact pre-trend test statistics (Wald stat, df, p-value)

### 4. Framing: Tighten null interpretation (GPT, Grok, Gemini)
- Emphasize 1-4 year horizon limitation more prominently
- Acknowledge pandemic confounding more explicitly
- Caveat "precisely estimated null" claims

### 5. Suggestions acknowledged but not implemented
- Synthetic control (would require new code/data - mention as future work)
- Triple-diff with ERISA shares (no state-level ERISA data available - mention)
- Bayesian imputation for suppressed counts (methodological overkill for a revision - mention as limitation)
- DKA hospitalization data (not available at state-year level - mention)
