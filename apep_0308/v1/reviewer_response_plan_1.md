# Reviewer Response Plan — apep_0296 v1

## Review Summary
- **GPT-5.2:** MAJOR REVISION — wants uncertainty quantification, expanded literature, HHI interpretation tightening
- **Grok-4.1-Fast:** MINOR REVISION — wants 4 additional references, minor enhancements
- **Gemini-3-Flash:** REJECT AND RESUBMIT — wants formal hypothesis testing, regression analysis

## Triage: What to Address

### Priority 1: Literature (All 3 reviewers)
- Add references on HCBS/consumer-directed care (Carlson 2007, Foster 2003)
- Add Medicaid managed care reference (Duggan 2004)
- Add home care workforce references (Stone & Wiener 2001)
- Add DOJ/FTC Merger Guidelines reference
- Add Wennberg 2010 on geographic variation measurement
- Cite these in appropriate text locations

### Priority 2: HHI Language Tightening (GPT, Gemini)
- Distinguish "billing concentration" from "market power"
- Add caveat that county-level billing HHI does not directly measure service-market concentration
- Note that intermediary role means HHI in billing ≠ HHI in care provision

### Priority 3: Non-Spending Measures (GPT)
- Add appendix paragraph showing T1019 dominance persists in claims counts (not just spending)
- Reference the companion paper's claims-based analysis

### Priority 4: Prose Polish from Exhibit/Prose Reviews
- Address any remaining constructive feedback

### What We Will NOT Do (and why)
- **Full regression analysis / hypothesis testing** (Gemini): This paper is explicitly a descriptive data portrait. Adding causal analysis would change its fundamental nature and is inappropriate without a credible identification strategy for the questions raised. We note this is a descriptive contribution in the tradition of Finkelstein et al. (2016).
- **Bootstrap CIs** (GPT): With population-level administrative data, sampling uncertainty is not the relevant concern. We add discussion of measurement sensitivity instead.
- **Multi-state comparison** (Grok, GPT): Outside scope for a state-level deep dive; the companion paper (APEP-0294) provides national context.
- **Interactive maps** (Grok): Not feasible in a journal submission format.

## Execution Order
1. Add new BibTeX entries to references.bib
2. Add citations in text (Introduction lit review, Discussion)
3. Tighten HHI/market power language (Section 4.3, Discussion)
4. Add claims-based robustness paragraph to Appendix
5. Recompile PDF
