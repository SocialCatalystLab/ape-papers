# Reply to Reviewers - Round 1

We thank the reviewers for their thorough and constructive feedback. We acknowledge their core concern: this paper does not implement formal statistical inference or causal designs, which is required for publication in top general-interest economics journals.

---

## Response to All Reviewers: Paper Positioning

Our paper is explicitly positioned as a **data infrastructure and descriptive atlas** contribution (stated on p. 2: "methodological and descriptive rather than causal"). We believe this framing is appropriate because:

1. **Novel data integration**: The FARS + OSM + policy timing integration has not been done at this granularity before
2. **Research enablement**: The dataset enables spatial RDD and other designs that we document and motivate
3. **Transparent limitations**: We extensively document drug testing selection, THC impairment interpretation, and geocoding quality issues

We acknowledge that AER/QJE/JPE/ReStud/Ecta/AEJ:EP require formal inference. We will consider alternative venues (Scientific Data, JRSS-A, JPAM, domain journals) that accept data/methods contributions.

---

## Reviewer 1

### On statistical inference
> "No regressions, no SEs/CIs/tests anywhere"

**Response**: Acknowledged. This paper is descriptive by design. We have added clear language emphasizing this is not a causal study.

### On missing years (2006-2015)
> "Fatal to any serious policy evaluation"

**Response**: We acknowledge this limitation in Section 7 and note that extending the pipeline is future work.

### On literature gaps
> "Missing foundational RDD, DiD, and marijuana/traffic safety references"

**Response**: We have added the suggested citations to references.bib but note that implementing the full RDD/DiD methodology is beyond our current scope.

---

## Reviewer 2

### On Table 2 labeling
> "Panel D appears before Panel C"

**Response**: Fixed. Panel ordering is now consistent.

### On policy coding
> "CA and NV grouped as 'Legal' even in 2016 pre-legalization"

**Response**: We clarify in Table 2 notes that this grouping uses eventual legalization status for descriptive consistency, not crash-date policy status.

---

## Reviewer 3

### On selection into drug reporting
> "Conditioning on 'crashes with any drug record' is not innocuous"

**Response**: We extensively document this in Sections 2.1 and 7.2. We acknowledge this is a first-order limitation for causal interpretation and recommend selection modeling in future work.

### On contribution statement
> "'We provide replication code' is not enough"

**Response**: Our contribution is the integrated dataset construction and documentation, not a single new causal estimate. We believe this is valuable for the research community even without causal claims.

---

## Summary of Changes Made

1. Fixed Table 2 internal consistency issues
2. Corrected poly-substance text (swapped percentages)
3. Updated figure terminology throughout
4. Added suggested literature citations
5. Clarified descriptive vs causal framing

## What We Did Not Change

1. Did not implement full RDD/DiD - beyond paper scope
2. Did not fill missing years - data constraint
3. Did not add formal selection modeling - beyond paper scope

We accept the REJECT AND RESUBMIT decision and will consider targeting a more appropriate venue for a data/methods contribution.
