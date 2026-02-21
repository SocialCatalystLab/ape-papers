# Code Advisor Review - Codex-Mini

**Role:** Code reviewer for academic publication standards
**Model:** openai/gpt-5.1-codex-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T18:33:27.972649
**Route:** OpenRouter + code bundle
**Files reviewed:** 00_packages.R, 01_fetch_data.R, 02_clean_data.R, 03_main_analysis.R, 04_robustness.R, 05_figures.R, 06_tables.R
**Tokens:** 23976 in / 1852 out
**Response SHA256:** 83b1fb7d6dc062fb

---

1. **File:** `03_main_analysis.R`  
   **Line(s):** 48-62, 77-188 (TWFE and pre-trend models); 140-149 (Sun-Abraham); 166-170 (gender TWFE)  
   **Code:** 
   ```r
   twfe_nonfarm <- feols(nonfarm_share ~ early_post | dist_id + year,
                         data = census_13, cluster = ~pc11_state_id)
   ...
   twfe_all_nonfarm <- feols(..., cluster = ~pc11_state_id)
   ...
   pt_nonfarm <- feols(..., cluster = ~pc11_state_id)
   ...
   sa_nl <- feols(..., cluster = ~pc11_state_id)
   ...
   twfe_nonfarm_f <- feols(..., cluster = ~pc11_state_id)
   ```
   **Issue:** All DiD/Sun-Abraham/TWFE specifications cluster standard errors at the *state* level. The treatment varies at the *district* level (district-phase roll out), so the appropriate clustering level is the district/treatment unit. Clustering at the higher state level is overly coarse and violates the requirement to cluster at the treatment unit, which can severely misstate inference.  
   **Fix:** Cluster at the district level (e.g., `cluster = ~dist_id` or `cluster = ~dist_num`) so that the standard errors reflect the treatment assignment unit.

2. **File:** `04_robustness.R`  
   **Line(s):** 22-90, 42-69, 63-104, 85-105, 101-105 (robustness regressions)  
   **Code:**
   ```r
   rob_nonfarm_12 <- feols(..., cluster = ~pc11_state_id)
   dose_resp <- feols(..., cluster = ~pc11_state_id)
   het_high <- feols(..., cluster = ~pc11_state_id)
   het_low <- feols(..., cluster = ~pc11_state_id)
   het_scst_high <- feols(..., cluster = ~pc11_state_id)
   het_scst_low <- feols(..., cluster = ~pc11_state_id)
   twfe_nl <- feols(..., cluster = ~pc11_state_id)
   ```
   **Issue:** The robustness checks, which re-estimate DiD/TWFE specifications at the district level, continue to cluster at the higher state level rather than the treatment unit (district). This violates the requirement to cluster standard errors at the treatment unit and undermines the validity of inference.  
   **Fix:** Switch the `cluster` argument to the district identifier (e.g., `cluster = ~dist_id` or `cluster = ~dist_num`) for all robustness regressions so that clustering matches the treatment unit.

**CODE ADVISOR VERDICT: FAIL**