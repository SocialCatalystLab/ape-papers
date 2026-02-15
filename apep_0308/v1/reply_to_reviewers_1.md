# Reply to Reviewers — apep_0296 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: No uncertainty quantification
> "The absence of any formal uncertainty/sensitivity quantification is a major weakness"

**Response:** We appreciate this concern. However, because our analysis uses population-level administrative data (not a sample), sampling uncertainty is not the relevant inferential framework. The key measurement concerns — address mismeasurement, managed care encounter valuation, and suppression — are systematic, not stochastic. We address these through:
- New Appendix A.3 showing robustness to non-spending measures (claims counts, organizational shares)
- Existing Appendix A.1 showing geographic stability (Spearman ρ=0.957)
- Explicit caveat in Section 2.3 about administrative vs. clinical geography

### Concern 2: Literature positioning incomplete
> "Bibliography is thin for HCBS/consumer-directed care and geographic variation methods"

**Response:** We have added 5 references:
- Carlson et al. (2007) on consumer-directed care (Cash and Counseling)
- Duggan (2004) on Medicaid managed care efficiency
- Stone & Wiener (2001) on long-term care workforce crisis
- Wennberg (2010) on geographic variation measurement
- DOJ/FTC (2010) Horizontal Merger Guidelines

### Concern 3: HHI/market power language overinterpretation
> "High HHI in billing does not necessarily imply local consumer harm or pricing power"

**Response:** Agreed. We have revised Section 4.3 to explicitly distinguish "billing concentration" (what we measure) from "service-market concentration" (what antitrust analysis targets). We note that a fiscal intermediary with dominant billing share may employ hundreds of independent aides, and that our HHI measures structural leverage in the billing layer, not necessarily market power in care delivery.

### Concern 4: Non-spending measures
> "Replicate core facts using claim counts, unique beneficiaries"

**Response:** New Appendix A.3 ("Robustness to Non-Spending Measures") shows T1019 dominance persists in claims (29.8% of all claims), geographic rankings are nearly identical (ρ=0.98 between spending and claims at ZIP level), and organizational dominance is even more extreme in claims (97.3%).

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing HCBS/CDPAP references
> "Literature light on HCBS/CDPAP specifics"

**Response:** Added 5 new references as detailed above. Citations placed in Introduction literature review, Discussion Section 6.2 (CDPAP), and Discussion Section 6.3 (workforce).

### Concern 2: ACS correlates for demand decomposition
> "Correlate ZIP spending with ACS Medicaid proxies"

**Response:** We note this as a direction for future work. The current paper focuses on documenting supply-side patterns; demand decomposition requires beneficiary-level data (available in restricted T-MSIS files) that we do not have access to.

---

## Reviewer 3 (Gemini-3-Flash): REJECT AND RESUBMIT

### Concern 1: Paper lacks formal hypothesis testing / regression analysis
> "To meet top general interest journal standards, the authors need to move beyond Three Facts and test a specific economic hypothesis"

**Response:** We respectfully disagree that a descriptive data paper requires hypothesis testing to merit publication. Our paper follows the tradition of Finkelstein, Gentzkow, and Williams (2016, QJE), which made its contribution through measurement and decomposition rather than causal estimation. The T-MSIS data release opens an entirely new window into Medicaid's supply side; documenting what these data reveal — with appropriate caveats about measurement — is a genuine contribution. Causal analysis of specific policy changes (ARPA, unwinding, CDPAP reform) is a natural next step that requires separate identification strategies and is better addressed in focused follow-up papers.

### Concern 2: Thin bibliography
> "Bibliography (10 entries) is somewhat thin"

**Response:** We have expanded the bibliography from 18 to 23 entries, adding references on consumer-directed care, Medicaid managed care, long-term care workforce, geographic variation measurement, and antitrust guidelines.

### Concern 3: HHI sensitivity to market definition
> "Does HHI change if you define the market at ZCTA or HRR level?"

**Response:** We acknowledge this concern in the revised Section 4.3, noting that county-level billing HHI is not identical to service-market concentration. Alternative market definitions (commuting zones, HRRs) are a direction for future work; our county-level HHI provides a conservative first estimate of billing concentration.

---

## Exhibit Review Feedback

- **Table 3 truncation:** Fixed by reducing font size and shortening column headers.
- **Table 4 siunitx formatting:** Provider and organization counts now properly wrapped in braces.
- **Figure 2 NYC inset:** Noted as desirable but not implemented in this round; Figure 4 already provides the NYC zoom-in.

## Prose Review Feedback

- Writing quality rated "Top-journal ready" with minor suggestions.
- "Med. Months" column in Table 3 now explicitly defined in notes.
