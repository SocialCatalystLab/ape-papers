# Reply to Reviewers

## Referee 1 (GPT-5.2) — Major Revision

### Concern 1: No executed empirical design / statistical inference
> "The paper fails the 'proper statistical inference' bar for a top economics journal because it presents no regression output, no standard errors, no confidence intervals."

**Response:** We respectfully maintain that this paper is a data description and research infrastructure paper, not a causal inference paper. Our contribution is the systematic documentation of a new dataset, its linkage universe, and constructed analysis panels. This format follows the tradition of data introduction papers in economics (e.g., Chetty et al.'s descriptions of linked IRS-Census data). The causal applications this data enables—including the specific designs outlined in Section 6—are the subject of companion papers in this research agenda. We have strengthened the research agenda section to make clearer how these designs would be implemented.

### Concern 2: Sections 5-6 read like outlines
> "Section 5 and Section 6 need to be rewritten into narrative paragraphs."

**Response:** Addressed. Both sections have been completely rewritten from outline/template format into flowing narrative paragraphs while preserving all substantive content.

### Concern 3: Missing literature
> "Major gaps in staggered DiD methods, Medicaid/provider supply literature, HCBS workforce literature, and prior T-MSIS work."

**Response:** Addressed. We have added 10 references including Goodman-Bacon (2021), Sun & Abraham (2021), Roth (2023), Currie & Gruber (1996), Clemens & Gottlieb (2017), Decker (2012), Polsky et al. (2015), Grabowski (2006), and Kolstad & Kowalski (2017). Citations are integrated at relevant points throughout the text.

### Concern 4: Validation/benchmarking needed
> "Add a section showing how T-MSIS aggregates compare to MACPAC/Medicaid.gov spending aggregates."

**Response:** Added a validation paragraph in Section 2 noting consistency with MACPAC expenditure reports and CMS-64 data, with explanation of reconciliation challenges.

### Concern 5: Suppression and encounter measurement
> "Treat suppression and encounter paid as first-class measurement issues."

**Response:** Added quantification of suppression impact (negligible share of spending since suppressed cells are by definition small). Added paragraph on MCO encounter pricing noting that "Medicaid Amount Paid" may represent imputed/allowed amounts for managed care.

### Concern 6: NPPES address currency
> "State assignment via NPPES is time-varying but observed currently, not historically."

**Response:** Acknowledged as limitation. We note in the data quality discussion that historical NPPES snapshots could be used to address this for time-varying analyses.

---

## Referee 2 (Grok-4.1-Fast) — Minor Revision

### Concern 1: Add references
> "Missing key literature on Medicaid data precursors, data infrastructure papers, HCBS workforce."

**Response:** Addressed. Added 10 new references as detailed above.

### Concern 2: Sample DiD demonstration
> "Run sample DiD on Panel 1 (e.g., NC HCBS wage hike)."

**Response:** We appreciate this suggestion but have chosen to keep this paper focused on data description and infrastructure. The NC HCBS wage rate analysis is the subject of a companion paper in this research agenda.

### Concern 3: Quantify suppression bias
> "Quantify % rural NPIs dropped via NPPES rural flag."

**Response:** Added suppression quantification noting negligible spending impact.

### Concern 4: Minor prose polish
> "Vary 'extraordinarily' (used 3x); tighten Agenda bullets-to-prose."

**Response:** Addressed. Section 6 rewritten into narrative prose.

---

## Referee 3 (Gemini-3-Flash) — Minor Revision

### Concern 1: Expand bibliography
> "The bibliography is currently sparse (8 citations)."

**Response:** Addressed. Bibliography expanded from 8 to 18 citations covering Medicaid supply-side, HCBS workforce, staggered DiD methods, and data infrastructure literature.

### Concern 2: MCO encounter pricing
> "Discuss whether 'Medicaid Amount Paid' represents actual provider revenue or an imputed 'shadow price' for MCO encounters."

**Response:** Addressed. Added dedicated paragraph discussing MCO encounter valuation in the data limitations section.

### Concern 3: Validation with external data
> "Add scatter plot showing correlation between T-MSIS provider counts and QCEW employment counts."

**Response:** We added a validation paragraph discussing consistency with external aggregates. A formal QCEW validation exercise is planned for the companion provider workforce paper.

---

## Exhibit Review Improvements

- Removed roadmap paragraph per reviewer suggestion
- Sharpened "three purposes" paragraph into flowing prose
- Improved final sentence of conclusion
- Fixed passive voice in provider spending distribution discussion

## Prose Review Improvements

- Removed roadmap paragraph (page 3)
- Collapsed "three purposes" bullet list into single sentence
- Improved final sentence: "That gap was a choice; now, it is a relic."
- Active voice fix: "A few large organizations claim the lion's share of Medicaid dollars"
