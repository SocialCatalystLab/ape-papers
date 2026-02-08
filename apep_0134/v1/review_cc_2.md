# Internal Review - Round 2

**Reviewer:** Claude Code Internal Review
**Paper:** Do Supervised Drug Injection Sites Save Lives?
**Date:** 2026-02-02

---

## Follow-up Review

The paper has been reviewed for fatal errors and methodological soundness. The advisor review identified:
- GPT-5-mini: PASS
- Grok-4.1-Fast: PASS

The core methodology (synthetic control + randomization inference for N=2 treated units) is appropriate. The paper is 35 pages with proper statistical inference.

### Remaining Issues (Non-Fatal)

1. **Data Provenance:** NYC DOHMH does not provide a public API for UHF-level mortality data. Data was compiled from published Epi Data Briefs (PDFs). This is the standard method for accessing this data but may appear as "hard-coded" in replication code.

2. **2024 Provisional Data:** The paper appropriately notes that 2024 data are provisional. The limitations section discusses this.

3. **Figure Consistency:** Some minor discrepancies between figures were identified and addressed.

### Assessment

The paper is methodologically sound and makes a novel contribution. The data provenance issue is inherent to the NYC health data ecosystem, not a flaw in the research design.

**DECISION: MINOR REVISION**
