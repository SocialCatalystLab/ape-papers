# Paper 49 Initialization

## Human Q&A Record

**Date:** 2026-01-21
**Branch:** suffrage-branch

### User Selections

1. **Outcome Focus:** Gender-related outcomes (user specified: "something on gender")
2. **Heterogeneity Focus:** Urban/rural
3. **IPUMS API Key Configured:** Yes
4. **External Review:** Yes (GPT 5.2)

### User Requirements (Exact Quote)

> The first draft before you send to any external reviewer MUST BE:
> 1) at least 30 pages of polished writing, text in paragraphs like a real econ paper;
> 2) at least 5 figures, polished and journal submission ready;
> 3) at least 5 tables, professionally formatted;
> 4) The introduction should be at least four pages, and extremely well motivated research, with at least 20 papers you cite and how this is contributing to those papers;
> 5) Use too much data instead of too little, in order to overwhelm external referees with impressive work.

### Quality Checklist (from user requirements)

- [ ] 30+ pages of polished prose (no bullet points)
- [ ] 5+ publication-ready figures
- [ ] 5+ professionally formatted tables
- [ ] 4+ page Introduction with 20+ citations
- [ ] Full-count census data (overwhelming data)
- [ ] LaTeX subfiles structure (one file per section)
- [ ] Exhibits in separate folder

### Existing Suffrage Papers (to avoid duplication)

| Paper | Outcome | Heterogeneity | Notes |
|-------|---------|---------------|-------|
| apep_0043 | Female labor force participation | Marital status, age | Main effect |
| apep_0044 | Children's education | Gender (boys vs girls) | Triple-diff |

### Proposed Novel Angle

**Focus:** Urban/rural heterogeneity in the effects of women's suffrage on female labor supply and economic empowerment.

**Why novel:**
1. apep_0043 examines female LFP but does NOT examine urban/rural heterogeneity
2. Urban and rural labor markets operated very differently in 1880-1920
3. Political economy of suffrage may have operated differently in cities vs countryside
4. Urban areas had more wage labor opportunities; rural areas more family farms

**Conceptual hook:** Did suffrage's political voice translate differently into economic opportunity depending on local labor market structure?

### Setup Verification

- [x] Output directory created: `output/paper_52/`
- [x] Subdirectories: `code/`, `data/`, `figures/`, `tables/`, `sections/`
- [x] IPUMS API key confirmed
- [x] Existing papers reviewed

---

*This file is locked after creation. Do not modify.*
