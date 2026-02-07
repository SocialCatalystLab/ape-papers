# Revision Plan: apep_0204 -> Pay Transparency + QWI

## Summary

Add QWI (Quarterly Workforce Indicators) administrative data as a second independent dataset to complement the CPS ASEC analysis. Reframe the paper around labor market dynamics under salary transparency -- not just wages and gender gaps, but separations, hiring, job creation/destruction, and turnover. Restructure for AER-level narrative with explicit conceptual framework.

## Workstreams

### WS1: QWI Data Pipeline
- Fetch state-level QWI data from Census API (state x quarter x sex x industry, 2012-2024)
- Variables: Emp, EarnS, HirA, Sep, FrmJbC, FrmJbLs, Payroll, TurnOvrS
- Clean and construct analysis panel with quarterly treatment indicators

### WS2: QWI Analysis
- Earnings DiD (triangulates CPS null aggregate effect)
- Gender gap DiD (independent test with admin data)
- Labor market dynamism DiD (separations, hiring, turnover, job flows)
- Quarterly event studies (sharper temporal identification)
- Industry heterogeneity (Finance/Professional vs Retail/Accommodation)

### WS3: Paper Restructuring
- New title: "Making Wages Visible: Labor Market Dynamics Under Salary Transparency"
- New conceptual framework with predictions table
- Integrate QWI results as central contribution
- Compress CPS robustness to appendix
- AER-style prose and narrative arc

### WS4: Review and Publish
- Full review cycle (advisor + exhibit + external)
- Publish with --parent apep_0204
