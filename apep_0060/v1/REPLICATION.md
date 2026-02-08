# Replication Instructions: Paper 75

## "The Making of a City: A Multigenerational Portrait of San Francisco's Population, 1850-1950"

---

## Data Sources

This paper uses IPUMS USA full-count census microdata with MLP (Multigenerational Longitudinal Panel) linking.

### IPUMS Extracts Required

| Extract ID | Description | Samples | Est. Size |
|------------|-------------|---------|-----------|
| 142 | 1900-1910 earthquake analysis | us1900m, us1910m | ~15 GB |
| 143 | 1920-1940 tracking | us1920b, us1940b | ~20 GB |

### Variables Requested

**Core (all extracts):**
- HISTID, SERIAL, PERNUM, YEAR, STATEFIP, COUNTYICP

**Demographics:**
- AGE, SEX, RACE, MARST, BPL, NATIVITY

**Human Capital:**
- LIT, SCHOOL

**Labor/Economic:**
- LABFORCE, OCC1950, CLASSWKR, OCCSCORE

**Family Links:**
- MOMLOC, POPLOC, SPLOC, RELATE, NCHILD

---

## Reproducing the Data

### Step 1: Request IPUMS Access

1. Create account at https://usa.ipums.org
2. Apply for access to full-count data
3. Accept terms of use

### Step 2: Create Extracts

Use the IPUMS extract system to request:

**Extract 1: 1900-1910 Full-Count**
- Samples: us1900m, us1910m
- Variables: [list above]
- Format: CSV

**Extract 2: 1920-1940 Full-Count**
- Samples: us1920b, us1940b
- Variables: [list above]
- Format: CSV

### Step 3: Download and Process

```bash
# Set up environment
export IPUMS_API_KEY="your-api-key"

# Or via Python
python3 code/01_fetch_data.py
python3 code/02_check_status.py
```

### Step 4: Run Analysis

```bash
# R analysis pipeline
Rscript code/00_packages.R
Rscript code/03_process_data.R
Rscript code/04_main_analysis.R
Rscript code/05_figures.R
```

---

## Geographic Filters

After downloading, we filter to:

| City | STATEFIP | COUNTYICP |
|------|----------|-----------|
| San Francisco | 6 | 750 |
| Los Angeles | 6 | 370 |
| Seattle | 53 | 330 |

---

## Citations

IPUMS USA:
> Steven Ruggles, Sarah Flood, Matthew Sobek, Daniel Backman, Annie Chen, Grace Cooper, Stephanie Richards, Renae Rogers, and Megan Schouweiler. IPUMS USA: Version 15.0 [dataset]. Minneapolis, MN: IPUMS, 2024. https://doi.org/10.18128/D010.V15.0

MLP:
> IPUMS Multigenerational Longitudinal Panel. https://usa.ipums.org/usa/mlp/

---

## Notes

- Full-count extracts are 10-20 GB each
- Processing requires 16+ GB RAM
- Use data.table for memory efficiency
- Delete raw data files after analysis (see cleanup section in skill instructions)
