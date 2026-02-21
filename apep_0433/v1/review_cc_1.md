# Internal Review — Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Parity Without Payoff: Gender Quotas in French Local Government and the Null Effect on Women's Economic Participation
**Date:** 2026-02-21

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** 32 pages total, approximately 28 pages of main text before `\label{apep_main_text_end}`. PASS.
- **References:** 26 citations covering the core RDD methodology (Lee & Lemieux, Cattaneo et al., McCrary), gender quotas (Chattopadhyay & Duflo, Beaman et al., Bagues & Campa, Bertrand et al.), and general labor economics (Goldin, Blau & Kahn). Adequate.
- **Prose:** All sections written in full paragraphs. No bullet-point lists in main text. PASS.
- **Section depth:** Each section has 3+ substantive paragraphs. PASS.
- **Figures:** 7 figures, all with visible data and proper axes. PASS.
- **Tables:** 5 tables with real data. PASS.

### 2. Statistical Methodology

- **Standard errors:** All coefficients have SEs in parentheses. PASS.
- **Significance testing:** p-values reported for all main results. Significance stars in Table 2. PASS.
- **Confidence intervals:** 95% CIs reported in Table 4 (bandwidth sensitivity) and Figure 4 (multi-outcome). Robust bias-corrected CIs from rdrobust used. PASS.
- **Sample sizes:** N reported in Tables 2 and 3 (after revision). PASS.
- **RDD specifics:** McCrary test (p=0.86), bandwidth sensitivity (100-800), multiple kernel and polynomial specifications. PASS.

### 3. Identification Strategy

**Strengths:**
- Clean institutional setting with sharp threshold
- Population determined by INSEE census — cannot be manipulated
- McCrary test confirms no bunching
- Comprehensive covariate balance (5 pre-determined variables, all smooth)
- Pre-treatment placebo (2011 outcomes) shows no discontinuity
- Placebo cutoffs at non-threshold populations show no effects

**Concerns:**
- The compound treatment issue (proportional + parity) is acknowledged but cannot be separated. This is a limitation, not a fatal flaw.
- The first stage of 2.7pp at narrow bandwidth vs 4.9pp at BW=500 raises questions about first-stage stability, though both are strongly significant.
- The paper frames this as a sharp RDD on the gender parity mandate, but the outcome is an intent-to-treat effect of crossing the threshold (which also changes the voting system).

### 4. Literature

The literature is well-positioned. Could benefit from:
- Brollo & Troiano (2016) on Brazilian mayors and gender
- Casas-Arce & Saiz (2015) on Spanish quotas
- Baltrunaite et al. (2014) on Italian gender quotas and politician quality

### 5. Writing Quality

The prose is excellent — clear, compelling, and well-structured. The introduction hooks effectively with the India-France contrast. The mechanisms section is particularly strong, providing economic intuition for the null.

Minor issues:
- "It is worth noting" on page 11 — delete filler phrase
- Some passive constructions could be tightened
- The conclusion could end with a punchier final sentence

### 6. Constructive Suggestions

1. **Consolidate Figures 2 and 3** into a two-panel figure (Panel A: Employment, Panel B: LFPR) to save space and enable direct comparison.
2. **Move Table 4 to appendix** since Figure 6 conveys the same information more effectively.
3. **Add a power calculation** explicitly in the text — the MDE discussion in Section 8.2 is good but could be more formal.
4. **Consider difference-in-discontinuity** using 2011 vs 2022 outcomes to strengthen the causal claim.

### 7. Overall Assessment

**Key strengths:**
- Clean identification with comprehensive validity tests
- Honest and well-framed null result
- Excellent writing quality
- Strong institutional knowledge

**Critical weaknesses:**
- None that are fatal. The compound treatment is acknowledged.

**Specific suggestions:**
- Tighten prose per suggestions above
- Consider panel figure consolidation
- Add 2-3 additional literature citations

DECISION: MINOR REVISION
