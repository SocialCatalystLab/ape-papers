# Revision Plan - Round 1

Based on internal review feedback.

## Changes to Make

1. **COVID Death Rate coefficient display (Table 3):** The coefficient shows as 0.000** due to scaling. This is a modelsummary formatting issue where the COVID death rate variable is in raw counts, making the per-unit effect tiny. Will note in table footnotes that the variable is in deaths per 100,000 at state level, and the small coefficient reflects the scale.

2. **Table numbering verification:** Ensure text references match displayed table numbers after removing double-wrapped table environments.

## Changes NOT Making

- MDE calculation: While useful, the paper already discusses power limitations extensively in the Discussion section. Adding a formal MDE calculation would require additional assumptions about the intra-cluster correlation that may not be well-identified.
- Additional literature: The bibliography is adequate for current purposes.
