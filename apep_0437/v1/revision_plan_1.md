# Reviewer Response Plan (Round 1)

## Summary of Reviews
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Key Issues (grouped across reviewers)

### 1. Covariate-adjusted RDD (All three reviewers)
All reviewers flag that population and SC share imbalance should be addressed by running covariate-adjusted rdrobust. **Fix:** Add covariate-adjusted specification to robustness table.

### 2. RI Section (GPT critical, Grok mild)
GPT correctly notes that permuting vote margins is not standard RI for RD. **Fix:** Reframe as a diagnostic rather than inferential complement, and tone down the discussion.

### 3. Missing References (GPT, Grok)
Add Lee & Lemieux (2010), Caughey & Sekhon (2011). **Fix:** Add to .bib and cite in text.

### 4. Outcome Timing (GPT)
GPT raises the VIIRS starting in 2012 issue as a first-order concern. **Fix:** Already addressed in paper text (clarified varying exposure), but add a robustness check restricting to elections with complete post-windows (2012+).

### 5. Double Alignment Interaction (GPT)
GPT notes the interaction is not cleanly identified. **Fix:** Reframe as correlational/suggestive rather than causal RD, and acknowledge the limitation.

### 6. Power Analysis Emphasis (Gemini)
Better frame the MDE. **Fix:** Emphasize we rule out large Asher-sized effects.

## Revision Plan
1. Add covariate-adjusted RDD to robustness (code + paper)
2. Reframe RI as diagnostic
3. Add references (Lee & Lemieux 2010)
4. Add complete-window robustness specification
5. Tone down double-alignment claims
6. Sharpen power discussion
