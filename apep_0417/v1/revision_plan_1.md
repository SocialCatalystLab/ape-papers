# Revision Plan — Stage C

## Summary of Referee Feedback

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5.2 | MAJOR REVISION | T-MSIS suppression/measurement, missing DiD refs, MDE calculation, CIs in tables, temper reimbursement language |
| Grok-4.1-Fast | MINOR REVISION | Missing DiD refs (Goodman-Bacon, CS, dCdH), fix table notes, reimbursement heterogeneity |
| Gemini-3-Flash | MINOR REVISION | Add Clemens/Gottlieb & Finkelstein refs, composition analysis, border county suggestion |

## Planned Changes

### 1. Add Missing References (All 3 reviewers)
- Goodman-Bacon (2021) - TWFE decomposition
- Callaway & Sant'Anna (2021) - group-time ATTs
- de Chaisemartin & D'Haultfoeuille (2020) - heterogeneous TE
- Roth et al. (2023) - pre-trends synthesis
- Cameron, Gelbach & Miller (2008) - wild bootstrap
- Clemens & Gottlieb (2014) - physician price response
- Finkelstein (2007) - insurance market GE effects
- Guagliardo (2004) - spatial accessibility

### 2. Add MDE Calculation (GPT)
- Formal minimum detectable effect for pooled and by-specialty
- Place in Section 6.1 after presenting the null

### 3. Add 95% CIs to Regression Tables (GPT)
- Add CI columns to Table 4 (by-specialty) and Table 5 (robustness)

### 4. Temper Reimbursement Language (GPT)
- Change "The binding constraint... is the price (reimbursement)" to suggestive language
- Add caveat that reimbursement hypothesis is consistent but not directly tested

### 5. Expand T-MSIS Suppression Discussion (GPT)
- Clarify that suppression is at billing×servicing×HCPCS×month level
- Note that provider-quarter aggregation mitigates some suppression
- Add caveat about measurement error and attenuation

### 6. Fix Table Notes (Grok)
- Ensure all tables have complete, non-empty notes

### 7. Cite DiD References in Text (All)
- Integrate citations into staggered DiD discussion (Section 5)
- Reference Goodman-Bacon decomposition results alongside Sun-Abraham

### NOT Addressed (Deferred)
- Border-county design (requires substantial new analysis)
- Market concentration heterogeneity (need hospital market data)
- Composition analysis of remaining enrollees (need beneficiary-level data)
- Wild cluster bootstrap (fwildclusterboot unavailable on this system)
- Alternative outcomes (payments/beneficiaries - not in current data extract)
