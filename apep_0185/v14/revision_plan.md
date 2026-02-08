# Revision Plan: apep_0205 → paper_190

## Summary

Polishing revision of apep_0205. The paper already passed advisor review (3/4 PASS) and external review (2 MINOR, 1 MAJOR). This revision focuses on the two new quality advisors:

1. **Exhibit Review (Stage A.5):** Visual inspection of all tables and figures — formatting, clarity, storytelling
2. **Prose Review (Stage A.6):** Writing quality in the Shleifer/Glaeser/Katz style — hooks, narrative arc, transitions

## Scope

- Fix any exhibits flagged as REVISE by the exhibit reviewer
- Polish prose based on prose reviewer feedback — focus on opening hook, results narration, transitions
- No substantive changes to methodology, data, or identification strategy
- No code changes unless exhibits need formatting fixes

## Execution Order

1. Copy parent workspace
2. Run exhibit review → fix flagged exhibits
3. Run prose review → polish prose
4. Recompile PDF
5. Run advisor review (should pass easily since parent already passed)
6. Run external review
7. Publish with --parent apep_0205

## Verification

- Advisor: 3/4 PASS minimum
- External: 3 reviews completed
- PDF compiles cleanly
- 25+ pages main text
