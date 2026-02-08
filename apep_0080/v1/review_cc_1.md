# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-29
**Paper:** Click It or Ticket at the Border: A Spatial RDD Analysis

## Summary

This paper attempts a spatial regression discontinuity design examining primary vs secondary seatbelt enforcement at U.S. state borders. The paper is notable for its honest acknowledgment of design failures.

## Key Issues Identified

### 1. Running Variable Construction (Critical)
The running variable is computed as distance to the nearest opposite-type state *polygon*, not to actual treatment-changing border *segments*. This means some observations may be closest to a border that doesn't represent a treatment discontinuity for that crash. The paper acknowledges this limitation explicitly.

### 2. Validity Test Failures
- McCrary density test rejects (p < 0.001)
- Placebo cutoffs show significant effects away from true border
- Covariate balance fails for "persons per crash" (p = 0.03)

### 3. Pooled Border Design
Pooling across heterogeneous borders without border-segment conditioning violates single-cutoff RD structure.

## Strengths

1. Honest presentation of null findings and design failures
2. Comprehensive robustness checks (bandwidth, kernel, polynomial, donut)
3. Clear framing as methodological case study
4. Proper statistical inference throughout

## Format Check

- Length: ~22 pages main text (adequate)
- All coefficients have SEs
- Tables include N and confidence intervals
- Figures are publication quality
- Prose-based writing (no bullet points in main sections)

## Decision

The paper serves as a valuable methodological contribution by documenting why naive spatial RDD at multi-border settings fails. It should be published with its acknowledged limitations.

DECISION: MAJOR REVISION
