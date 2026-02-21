# Reply to Reviewers

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### "Sharp RDD" terminology
> The design is not sharp in treatment... arguably not even sharp in eligibility.

**Response:** We agree this language was imprecise. We have removed "sharp" throughout and now describe the design as a "reduced-form regression discontinuity design." The estimand is the reduced-form discontinuity in employment outcomes at the 500-person village population threshold — the policy-relevant parameter for village-level targeting.

### First-stage concern
> Without showing a discontinuity in road connectivity at the village level, estimates cannot be interpreted as causal.

**Response:** We acknowledge this concern and have strengthened the discussion in Section 5.3 ("Interpretation: Intent-to-Treat at the Village Level"). The estimand is the reduced-form effect of crossing the threshold — not a LATE or treatment effect of roads. OMMAS data is not publicly available in geocoded form to construct a village-level first stage. We note that the null reduced form is informative regardless: even without quantifying attenuation, the finding that village-level employment shows no discontinuity at 500 constrains the possible magnitude of road effects on gendered structural transformation.

### Missing 95% CIs
> Main tables should report 95% CIs, especially for null results.

**Response:** Added 95% CIs to Table 3 (main results).

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Overall assessment
> Methodology is gold-standard for RDD. No threats unaddressed.

**Response:** Thank you. We have added the suggested references (Imbens & Lemieux 2008, Lee & Lemieux 2010 — both were already cited).

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### OMMAS data suggestion
> Provide descriptive evidence of road completion rates using OMMAS data.

**Response:** OMMAS data is not publicly available in geocoded form that can be linked to Census villages. We acknowledge this limitation in Section 7.3.

### Literature additions
> Add Field et al. (2010), Bernhardt et al. (2018).

**Response:** Added Bernhardt et al. (2018) to the discussion of why roads may fail to benefit women.

## Exhibit Review (Gemini)

- Moved covariate balance figure to appendix (reducing main-text redundancy)
- Kept bandwidth sensitivity figure in main text (visual is essential for the null-result narrative)

## Prose Review (Gemini)

- Shortened roadmap paragraph
- Maintained Data section structure (lists are appropriate for variable definitions)
