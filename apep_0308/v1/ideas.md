# Research Ideas

## Idea 1: The Geography of Medicaid's Invisible Workforce — A ZIP-Level Portrait of New York State

**Policy:** New York's Consumer Directed Personal Assistance Program (CDPAP) and Managed Long-Term Care (MLTC) system — the largest home- and community-based services market in the nation.

**Outcome:** T-MSIS Medicaid Provider Spending (2018–2024) linked to NPPES for ZIP-level geography, entity type, and taxonomy classification. Supplemented with Census ACS demographics by ZCTA.

**Identification:** Descriptive — spatial analysis of provider supply, spending concentration, and service mix variation within New York State. No causal claims. Uses ZIP/ZCTA-level choropleth maps, Lorenz curves, HHI measures, and decomposition analysis.

**Why it's novel:**
1. **First ZIP-level portrait of Medicaid provider supply** for any state using the newly released T-MSIS data.
2. **Stunning empirical fact**: A single procedure code (T1019 — personal care aides) accounts for 51.5% of all NY Medicaid provider-level spending ($74.6B out of $144.8B), compared to just 11.2% nationally. NY is 4.6x overweight.
3. **Extreme spatial concentration**: The top 20 ZIP codes account for 45% of statewide spending. Brooklyn neighborhoods (Brighton Beach, Borough Park, Sunset Park) and Queens (Flushing) drive billions in personal care spending.
4. **NYC vs Upstate structural divide**: NYC has 54% of providers but 72% of spending. The service mix is fundamentally different — NYC is 65% T-codes vs 37% Upstate.
5. **Connects to CDPAP fraud investigations** and policy debates about home care spending growth.

**Feasibility check:**
- Variation confirmed: 1,194 unique ZIPs with Medicaid providers in NY; extreme geographic variation verified.
- Data accessible: T-MSIS parquet (4.1 GB) and NPPES extract already downloaded. Census ACS ZCTA data available via API.
- Not overstudied: No prior academic paper maps ZIP-level Medicaid provider spending — the data was only released 6 days ago.
- Sufficient observations: 59,321 unique billing NPIs in NY, 16.2M T-MSIS rows, 84 months.

**Research agenda positioning:** This is Paper 2 in the Medicaid Provider Spending agenda (after the overview paper apep_0294). The overview described the national dataset; this paper demonstrates what a single-state deep dive reveals. It serves as a template for state-level analysis while documenting NY's unique HCBS concentration.

---

## Idea 2: Market Concentration in Medicaid Home Care — Evidence from New York's T-MSIS Data

**Policy:** NY MLTC/CDPAP home care market structure — organizational concentration, entry/exit, market power.

**Outcome:** Same T-MSIS + NPPES data, but focused on HHI computation by ZIP/county/ZCTA market for T1019 providers. Compute market concentration indices and relate to spending patterns.

**Identification:** Descriptive market structure analysis using standard IO tools (HHI, market shares, firm size distributions). Potentially combine with entry/exit dynamics.

**Why it's novel:** No prior measurement of Medicaid home care market concentration at fine geographic scales. The organizational structure (912 billing NPIs generating $74.6B in T1019 spending) implies extreme concentration.

**Feasibility check:** Data available and sufficient. But this is narrower than Idea 1 — it could be a section within the broader geographic portrait rather than a standalone paper.

---

## Idea 3: The Behavioral Health Gap — Why New York Routes Mental Health Outside T-MSIS

**Policy:** NY's behavioral health carve-out and transition to managed care for behavioral health services (phased 2015–2019). NY shows dramatically lower H-code spending (4% vs 13.6% nationally).

**Outcome:** H-code spending patterns in NY vs other states, by HCPCS code and provider taxonomy.

**Identification:** Descriptive comparison of NY's behavioral health spending structure vs national averages. Would need to investigate whether NY's gap reflects (a) genuine lower spending, (b) different coding (billing through managed care not captured in T-MSIS), or (c) institutional routing through different systems (OMH, OASAS).

**Feasibility check:** Interesting but probably requires state-level administrative data from NYS OMH/OASAS to fully explain the gap. Could be one section of a broader paper.
