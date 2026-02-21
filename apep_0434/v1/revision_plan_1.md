# Reviewer Response Plan — Round 1

**Paper:** apep_0434_v1 — Guaranteed Employment and the Geography of Structural Transformation
**Reviews:** GPT (Major Rev), Grok (Minor Rev), Gemini (Major Rev)
**Date:** 2026-02-21

---

## Workstream 1: Identification Strengthening (Restricted Nightlights, Causal Language)

**Reviewer concern:** All three reviewers flag that nightlight results suffer from (a) significant pre-trends (p<0.001) and (b) contaminated controls post-2008, undermining causal claims.

**Actions:**
1. **Add restricted nightlights analysis (2000–2007 only, clean controls).** New robustness result: ATT = +0.1746 (SE: 0.0173), positive and significant even when restricted to the window where Phase III districts are genuinely untreated. Report in Robustness section.
2. **Soften causal language for nightlights throughout.** The 27% headline result should be framed as "suggestive" or "descriptive," not causal. Revise intro paragraph (line 95), nightlight results section (line 301), and conclusion (line 469) to use hedged language ("is associated with," "suggests," "consistent with").
3. **Strengthen existing caveats.** The paper already notes pre-trends and contamination (lines 257, 307–319) but the introduction and abstract treat the 27% as more established than warranted. Align framing.

**Status:** Partially addressed in current draft (caveats exist); needs language tightening and restricted NL result added.

---

## Workstream 2: Inference (State-Level Clustering)

**Reviewer concern:** All three reviewers note that clustering at the state level (the level at which treatment assignment arguably varies) renders the main non-farm result insignificant (SE rises from 0.0022 to 0.0028, p > 0.10). This is already reported in the robustness table but deserves more prominent discussion.

**Actions:**
1. **Expand discussion in Robustness section** (currently ~3 sentences at line 411). Add explicit acknowledgment that with ~35 clusters, state-level inference is inherently conservative and that the result is fragile to this choice. Note that wild cluster bootstrap (WCB) was not feasible (fwildclusterboot unavailable) but would be the ideal next step.
2. **Acknowledge in Limitations section** that the small number of state-level clusters is a genuine constraint on inference for the main result, while the gender results (which are an order of magnitude larger) survive any reasonable clustering.

**Status:** Partially addressed; needs expansion in both Robustness and Limitations.

---

## Workstream 3: Composition / Migration Mechanism

**Reviewer concern:** GPT and Gemini flag that the population growth placebo (+1.5pp, p=0.014) suggests migration/composition effects may drive worker share changes. This is noted but not sufficiently engaged with as a competing mechanism.

**Actions:**
1. **Add a dedicated paragraph in Limitations** (after current ¶3, line 459) explicitly framing migration/composition as an important alternative mechanism that the data cannot fully adjudicate. Discuss the direction of bias: if MGNREGA attracted agricultural laborers or retained them, worker share changes partly reflect who is in the village rather than what existing residents do.
2. **Note in Discussion** that the "comfortable trap" interpretation applies to both channels (retention of agricultural workers who would have migrated out, and occupational stickiness among residents), but the welfare implications differ.

**Status:** Partially addressed (lines 279–281, 415); needs a more substantive engagement.

---

## Workstream 4: Exhibits (Table Labels)

**Reviewer concern:** Exhibit review flagged table formatting and label clarity.

**Actions:**
1. Table labels already improved in prior pass.

**Status:** Complete.

---

## Workstream 5: Prose Improvements (Opening Hook)

**Reviewer concern:** Prose review flagged opening hook and general readability.

**Actions:**
1. Opening hook already revised in prior pass.

**Status:** Complete.

---

## Summary of Edits to paper.tex

| Location | Edit |
|----------|------|
| Abstract (line 84) | Hedge nightlight claim: "associated with" not "experienced" |
| Intro ¶1 (line 95) | Soften "The satellites show it worked" |
| Intro ¶5 (line 107) | Hedge "Taken at face value, this suggests" → already hedged, add "suggestive" |
| NL results (line 301) | Frame 27% ATT as "suggestive of increased activity" |
| Robustness (after line 411) | Add restricted nightlights (2000–2007) paragraph |
| Robustness (line 411) | Expand state-clustering discussion, note WCB infeasibility |
| Limitations (after line 459) | Add migration/composition paragraph |
| Conclusion (line 469) | Soften "experienced increased aggregate economic activity" |
