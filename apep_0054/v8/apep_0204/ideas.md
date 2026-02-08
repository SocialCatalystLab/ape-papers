# Research Ideas

## Revision of APEP-0159 (Salary Transparency Laws, v5)

This is a code-scan-fix revision of apep_0159. No new research ideas -- the revision addresses two HIGH-severity code scan findings:

1. **DATA_PROVENANCE_MISSING**: Unused intermediate file load in 07_tables.R
2. **SUSPICIOUS_TRANSFORMS**: Hard-coded incomplete border state list in 05_robustness.R

### Changes Made
- Added input/output provenance headers to all scripts (00-07)
- Removed unused `desc_stats` load in 07_tables.R
- Replaced ad-hoc border state list with complete US Census Bureau adjacency matrix
- Added symmetric border-exclusion robustness check
- Added file existence checks to downstream scripts
