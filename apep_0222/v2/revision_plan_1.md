# Revision Plan (Post-Review)

## Summary of Reviewer Feedback

All three external reviewers assessed the paper positively:
- **Gemini-3-Flash:** CONDITIONALLY ACCEPT
- **GPT-5-mini:** MINOR REVISION
- **Grok-4.1-Fast:** MINOR REVISION

### Common Themes Across Reviewers

1. **Multiple testing correction** for the turnover result (the only significant finding among 6 outcomes)
2. **Public vs. private school** decomposition (NAICS 6111 includes both; laws target public schools)
3. **Turnover decomposition** — deeper analysis of the one significant result
4. **Minor repetition** of the TWFE bias discussion (mentioned ~4 times)

### Reviewer-Specific Suggestions

- **Gemini:** Public/private ownership code (ownercode), mechanisms of turnover (hires vs. separations), Jackson (2013) citation
- **GPT:** Wild cluster bootstrap, leave-one-out checks, joint pre-trend test statistics, placebo treatment dates, covariate-augmented CS, Conley & Taber (2011) citation
- **Grok:** Turnover event study figure, quantify turnover costs, trim TWFE repetition, additional citations (Andrews & Oster 2019)

## Changes to Implement

### 1. Address multiple testing (all reviewers)
- Add a paragraph in the turnover discussion acknowledging that with 6 outcomes tested, the Bonferroni-corrected threshold is approximately 0.008, and the turnover p-value (~0.046) does not survive this correction
- Frame appropriately: the turnover result is suggestive but should be interpreted cautiously

### 2. Trim TWFE repetition (Grok, prose review)
- Reduce from ~4 explanations to 2: once in Results (Section 5.3) and once in Methodological Implications (Section 7.4)
- Remove redundant mentions in the Introduction and Conclusion

### 3. Add public vs. private discussion (Gemini, GPT)
- Add a paragraph in limitations noting that QWI ownercode=A05 (all owners) includes both public and private K-12 schools
- Note that ownercode restrictions at NAICS 6111 level would increase suppression substantially
- Add bounding calculation: if private = 10%, and the true ATT on public schools is X, then measured ATT ≈ 0.9X

### 4. Minor text improvements
- Fix the opening per prose review (already done)
- Acknowledge potential for migration-based spillover attenuation more explicitly
- Remove roadmap paragraph if present

These changes are text-only and do not require re-running R scripts or recompiling tables/figures.
