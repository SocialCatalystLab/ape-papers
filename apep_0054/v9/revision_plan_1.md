# Revision Plan for apep_0167 → apep_0168

## Source
Based on referee feedback (2 MAJOR, 1 MINOR) and user guidance on theoretical framing.

## Core Changes

### 1. Theoretical Framework Restructure
- Kept Cullen et al. (2023) as foundation
- Section 3 already derives predictions ex ante from model
- Sections 3.5-3.6 explain conditions under which effects might be null
- User guidance: theory → predictions → conditions for null → evidence → interpretation

### 2. Convert Bullets to Prose (GPT/Grok Critical)
- Introduction: Converted results bullets to flowing prose
- Section 7.4: Converted border decomposition bullets to prose
- Section 7.5: Converted level/change bullets to prose

### 3. Fix Section 4.4 Inconsistency (Grok Critical)
- Original: "approximately 2% wage reduction 'buys' 1 percentage point reduction in the gender gap"
- Problem: Contradicts null findings
- Fix: Replaced with statement about null making trade-off question moot

### 4. Wild Cluster Bootstrap (All Reviewers)
- Added 04c_wild_bootstrap.R script
- Uses fwildclusterboot package with Webb (6-point) weights
- Addresses concern about 17 state clusters being too few for asymptotic inference

### 5. Industry Heterogeneity Analysis (User Priority + All Reviewers)
- Added 01b_fetch_qwi_industry.R to download industry-stratified QWI
- Added 04d_industry_heterogeneity.R for heterogeneity analysis
- Tests Cullen prediction P3: effects larger in high-bargaining industries
- Industries: Info, Finance, Professional Services, Management (high) vs Retail, Food, Healthcare (low)

### 6. New References
- Kessler et al. (2024) - salary posting bans
- Menzel (2023) - pay transparency meta-analysis
- Arnold (2022) - employer power

### 7. Language Variation
- Reduced "null" repetition
- Now uses: "no detectable effect", "statistically insignificant", "zero effect cannot be rejected"

## Implementation Status
All LaTeX changes implemented. R code for wild bootstrap and industry analysis written.
Paper recompiled and passed (42 pages).
