# Initialization

## Session
- **Date**: 2026-02-06
- **Contributor**: @SocialCatalystLab
- **Mode**: Revision
- **Parent Paper**: apep_0197
- **Parent Workspace**: output/paper_181

## Revision Information
- **Parent**: apep_0197
- **Type**: Revision (3 targeted improvements)

## Revision Scope
Three targeted improvements to apep_0197:
1. Fix weight normalization bug in exposure construction (weights don't sum to 1 after NA filtering)
2. Re-incorporate QWI job flow variables (HirA, Sep, FrmJbC, FrmJbD) that were dropped during data processing
3. Make earnings a co-primary outcome alongside employment, add USD-denominated specifications for interpretable magnitudes
