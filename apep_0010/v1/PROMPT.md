# Research Question

**Policy:** Preschool Fee Cap (Maxtaxa) 2002

January 2002: Introduction of maximum fee caps for childcare.
Reduced costs significantly for many families.

## Suggested Method: Difference-in-Differences (DiD)

This policy has simultaneous treatment timing. Classic 2x2 DiD is appropriate.

Key timing:
- Implementation: 2002-01-01
- Announcement: 2001

Treatment group: Families with children in preschool
Control group: Families without preschool-age children

Compare outcomes before vs after, treatment vs control.

**Key assumption:** Parallel trends - treatment and control groups would have
followed similar paths absent the treatment.

See `references/did_methodology.md` for validity checks and estimation guidance.


## Potential Outcomes

- Maternal labor supply
- Fertility
- Preschool enrollment
- Household consumption

## Data Sources

- Labor force participation: `SCB AM/AM0401`
- Fertility rates: `SCB BE/BE0101`
- Preschool enrollment: `Skolverket`

See `.claude/skills/research-paper/data_sources/sweden.md` for API patterns.

## Notes

Well-studied reform but room for new outcomes or mechanisms.
Compare high-fee vs low-fee municipalities for intensity variation.

## Instructions

1. Write `output/pre_analysis.md` with conceptual framework BEFORE analysis
2. Fetch and explore the data
3. Run the DiD analysis with appropriate validity checks
4. Write the paper following SKILL.md guidelines
5. Run external review (2-pass GPT cycle)
6. Mark this policy as evaluated after completion

**Policy ID:** `maxtaxa_2002`
