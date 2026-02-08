# Revision Plan 1

## Summary of Reviewer Feedback

All three reviewers (GPT, Grok, Gemini) provided MAJOR REVISION decisions. Key concerns addressed in this revision (relative to parent APEP-0189):

### Issues Addressed in This Revision

1. **Prose Quality**: Converted all bullet points to narrative paragraphs throughout Introduction, Theory, Results, and Discussion sections per reviewer requests for AER-quality prose.

2. **Visual Evidence**: Added 7 publication-quality figures including:
   - Choropleth maps of exposure variation (Figures 1-3)
   - First-stage binscatter (Figure 4)
   - Event study plot with 95% CIs (Figure 5)
   - Balance trends by IV quartile (Figure 6)
   - Census division heterogeneity (Figure 7)

3. **Confidence Intervals**: Added 95% CIs to all regression tables per reviewer request.

4. **Literature**: Added Goldsmith-Pinkham et al. (2020), Borusyak et al. (2022), Rambachan-Roth (2023) on shift-share identification.

5. **Identification Discussion**: Expanded discussion of parallel trends vs levels, clarified time-invariant weights, added clustering details.

6. **Heterogeneity Analysis**: Added new section with geographic, temporal, urban-rural, and wage-level heterogeneity.

7. **Institutional Background**: Added section on minimum wage policy variation and Fight for $15 movement.

### Remaining Concerns Noted by Referees

Some reviewers raised additional concerns about effect magnitude interpretation and further robustness checks. These are acknowledged in the Discussion section. The paper provides clear LATE interpretation and contextualizes the magnitude relative to variation in the data.

## Actions Taken

- Complete prose rewrite of 4 major sections
- Created 7 new figures with R code
- Updated all tables with CIs
- Expanded literature review
- Added institutional background section
- Added heterogeneity analysis section
- Improved clarity of sample construction documentation
