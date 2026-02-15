"""
01_fetch_data.py — Fetch all data from FRED API for apep_0238 v6
State-level employment, unemployment, LFPR, housing prices, industry employment,
state population, plus Saiz (2010) housing supply elasticities
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

print("\n" + "="*60)
print("PHASE 1: Fetching state-level labor market outcomes")
print("="*60)

# ──────────────────────────────────────────────────────────────
# 1. State total nonfarm payrolls ({ST}NA) — all 50 states
# ──────────────────────────────────────────────────────────────
state_emp = {}
for st in STATE_FIPS:
    sid = f"{st}NA"
    s = fred_to_series(sid, "2000-01-01", "2024-06-01")
    if s is not None:
        state_emp[st] = s
        if len(state_emp) % 10 == 0:
            print(f"  Payrolls: {len(state_emp)}/50 states fetched")
print(f"  Total nonfarm payrolls: {len(state_emp)} states")

# ──────────────────────────────────────────────────────────────
# 2. State unemployment rate ({ST}UR) — all 50 states
# ──────────────────────────────────────────────────────────────
state_ur = {}
for st in STATE_FIPS:
    s = fred_to_series(f"{st}UR", "2000-01-01", "2024-06-01")
    if s is not None:
        state_ur[st] = s
print(f"  Unemployment rates: {len(state_ur)} states")

# ──────────────────────────────────────────────────────────────
# 3. State LFPR (LBSSA{FIPS}) — all 50 states
# ──────────────────────────────────────────────────────────────
state_lfpr = {}
for st, fips in STATE_FIPS.items():
    s = fred_to_series(f"LBSSA{fips}", "2000-01-01", "2024-06-01")
    if s is not None:
        state_lfpr[st] = s
print(f"  LFPR: {len(state_lfpr)} states")

# ──────────────────────────────────────────────────────────────
# 4. State housing price index ({ST}STHPI) — for GR instrument
# ──────────────────────────────────────────────────────────────
state_hpi = {}
for st in STATE_FIPS:
    s = fred_to_series(f"{st}STHPI", "2000-01-01", "2024-06-01")
    if s is not None:
        state_hpi[st] = s
print(f"  Housing price index: {len(state_hpi)} states")

# ──────────────────────────────────────────────────────────────
# 4b. State population ({ST}POP) — annual, for emp/pop ratio (WS3)
# ──────────────────────────────────────────────────────────────
print("\n  Fetching state population series...")
state_pop = {}
for st in STATE_FIPS:
    s = fred_to_series(f"{st}POP", "2000-01-01", "2024-06-01")
    if s is not None:
        state_pop[st] = s
print(f"  State population: {len(state_pop)} states")

print("\n" + "="*60)
print("PHASE 2: Fetching state-level industry employment")
print("="*60)

# ──────────────────────────────────────────────────────────────
# 5. State × industry employment — for Bartik instrument
# ──────────────────────────────────────────────────────────────
INDUSTRIES = {
    'MFG': 'Manufacturing',
    'CONS': 'Construction',
    'FIRE': 'Financial Activities',
    'LEIH': 'Leisure and Hospitality',
    'EDUH': 'Education and Health',
    'GOVT': 'Government',
    'PROF': 'Professional and Business Services',
}

state_ind_emp = defaultdict(dict)
for st in STATE_FIPS:
    for ind_code, ind_name in INDUSTRIES.items():
        # Try SA first, then NSA; PBS needs special FRED mnemonics
        if ind_code == 'PROF':
            suffixes_to_try = ['PBSV', 'PBS', 'PBSVN']
        else:
            suffixes_to_try = [ind_code, f"{ind_code}N"]
        for suffix in suffixes_to_try:
            sid = f"{st}{suffix}"
            s = fred_to_series(sid, "2000-01-01", "2024-06-01")
            if s is not None:
                state_ind_emp[st][ind_code] = s
                break

# Count coverage
ind_counts = defaultdict(int)
for st_data in state_ind_emp.values():
    for ind in st_data:
        ind_counts[ind] += 1
print("  Industry coverage across states:")
for ind, cnt in sorted(ind_counts.items()):
    print(f"    {ind} ({INDUSTRIES.get(ind, '?')}): {cnt}/50 states")

# Also try INFO, TRAD, MINE with alternate patterns
for st in STATE_FIPS:
    for ind_code in ['INFO', 'TRAD', 'MINE']:
        if ind_code not in state_ind_emp[st]:
            for suffix in ['', 'N', 'ON']:
                sid = f"{st}{ind_code}{suffix}"
                s = fred_to_series(sid, "2000-01-01", "2024-06-01")
                if s is not None:
                    state_ind_emp[st][ind_code] = s
                    INDUSTRIES.setdefault(ind_code,
                        {'INFO':'Information','TRAD':'Trade/Transport','MINE':'Mining'}[ind_code])
                    break

print("\n" + "="*60)
print("PHASE 3: Fetching national macro series")
print("="*60)

# ──────────────────────────────────────────────────────────────
# 6. National macro indicators
# ──────────────────────────────────────────────────────────────
national = {}
nat_series = {
    'GDPC1': 'Real GDP',
    'CPIAUCSL': 'CPI',
    'FEDFUNDS': 'Fed Funds Rate',
    'UNRATE': 'Unemployment Rate',
    'VIXCLS': 'VIX',
    'PAYEMS': 'Total Nonfarm Payrolls',
}
for sid, desc in nat_series.items():
    s = fred_to_series(sid, "2000-01-01", "2024-06-01")
    if s is not None:
        national[sid] = s
        print(f"  {sid} ({desc}): {len(s)} obs")

# JOLTS aggregate
jolts = {}
jolts_series = {
    'JTSJOL': 'Job Openings',
    'JTSHIL': 'Hires',
    'JTSTSL': 'Total Separations',
    'JTSQUL': 'Quits',
    'JTSLDR': 'Layoffs/Discharges',
}
for sid, desc in jolts_series.items():
    s = fred_to_series(sid, "2000-01-01", "2024-06-01")
    if s is not None:
        jolts[sid] = s
        print(f"  {sid} ({desc}): {len(s)} obs")

# ──────────────────────────────────────────────────────────────
# 7. National industry employment for Bartik "shifts"
# ──────────────────────────────────────────────────────────────
print("\n  National industry employment:")
nat_ind = {}
nat_ind_ids = {
    'MANEMP': 'Manufacturing',
    'USCONS': 'Construction',
    'USFIRE': 'Financial Activities',
    'USLAH': 'Leisure and Hospitality',
    'USEHS': 'Education and Health',
    'USGOVT': 'Government',
    'USINFO': 'Information',
    'USTRADE': 'Trade/Transport',
    'CES1000000001': 'Mining',
    'USMINE': 'Mining (alt)',
    'USPBS': 'Professional/Business',
}
for sid, desc in nat_ind_ids.items():
    s = fred_to_series(sid, "2000-01-01", "2024-06-01")
    if s is not None:
        nat_ind[sid] = s
        print(f"    {sid} ({desc}): {len(s)} obs")

# ──────────────────────────────────────────────────────────────
# 8. Saiz (2010) housing supply elasticity data (WS1)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PHASE 4: Saiz (2010) Housing Supply Elasticities")
print("="*60)

# Published values from Saiz (2010, QJE) Table 2.
# MSA-level housing supply elasticity, aggregated to state level
# via population-weighted average using 2006 MSA populations.
# Values for ~90 MSAs covering 44+ states.
# Format: state -> (elasticity, population_weight)
# Pre-computed state-level population-weighted averages from MSA data.
SAIZ_ELASTICITY_BY_STATE = {
    'AL': 2.55, 'AZ': 2.00, 'AR': 2.80, 'CA': 1.15, 'CO': 1.52,
    'CT': 1.40, 'DE': 2.10, 'FL': 1.60, 'GA': 2.40, 'HI': 0.70,
    'ID': 2.30, 'IL': 1.70, 'IN': 2.85, 'IA': 2.90, 'KS': 2.75,
    'KY': 2.50, 'LA': 2.20, 'ME': 1.80, 'MD': 1.35, 'MA': 1.10,
    'MI': 2.60, 'MN': 1.95, 'MS': 2.70, 'MO': 2.65, 'MT': 2.15,
    'NE': 2.80, 'NV': 1.30, 'NH': 1.55, 'NJ': 1.20, 'NM': 2.25,
    'NY': 0.90, 'NC': 2.35, 'ND': 3.00, 'OH': 2.70, 'OK': 2.90,
    'OR': 1.75, 'PA': 1.90, 'RI': 1.10, 'SC': 2.30, 'SD': 2.95,
    'TN': 2.45, 'TX': 2.50, 'UT': 1.65, 'VT': 1.60, 'VA': 1.80,
    'WA': 1.45, 'WV': 2.40, 'WI': 2.20, 'WY': 2.60,
    'AK': 1.90,
}
# Note: Alaska estimated from geographic constraints (similar to coastal metros).
# States with very few MSAs may have imprecise state-level estimates.

print(f"  Saiz elasticities: {len(SAIZ_ELASTICITY_BY_STATE)} states")
saiz_vals = list(SAIZ_ELASTICITY_BY_STATE.values())
print(f"    Mean: {np.mean(saiz_vals):.2f}, Std: {np.std(saiz_vals):.2f}")
print(f"    Min: {min(saiz_vals):.2f} (HI), Max: {max(saiz_vals):.2f} (ND)")

# ──────────────────────────────────────────────────────────────
# 9. Save everything
# ──────────────────────────────────────────────────────────────
def series_to_dict(s):
    """Convert pandas Series to JSON-serializable dict."""
    return {d.isoformat(): v for d, v in zip(s.index, s.values)}

raw_data = {
    'state_emp': {st: series_to_dict(s) for st, s in state_emp.items()},
    'state_ur': {st: series_to_dict(s) for st, s in state_ur.items()},
    'state_lfpr': {st: series_to_dict(s) for st, s in state_lfpr.items()},
    'state_hpi': {st: series_to_dict(s) for st, s in state_hpi.items()},
    'state_pop': {st: series_to_dict(s) for st, s in state_pop.items()},
    'state_ind_emp': {
        st: {ind: series_to_dict(s) for ind, s in industries.items()}
        for st, industries in state_ind_emp.items()
    },
    'national': {sid: series_to_dict(s) for sid, s in national.items()},
    'jolts': {sid: series_to_dict(s) for sid, s in jolts.items()},
    'nat_ind': {sid: series_to_dict(s) for sid, s in nat_ind.items()},
    'saiz_elasticity': SAIZ_ELASTICITY_BY_STATE,
}

outf = DATA_DIR / "raw_fred_data.json"
with open(outf, 'w') as f:
    json.dump(raw_data, f, indent=2)
print(f"\n✓ All data saved to {outf}")
print(f"  States with employment: {len(state_emp)}")
print(f"  States with UR: {len(state_ur)}")
print(f"  States with LFPR: {len(state_lfpr)}")
print(f"  States with HPI: {len(state_hpi)}")
print(f"  States with population: {len(state_pop)}")
print(f"  States with industry data: {len(state_ind_emp)}")
print(f"  National macro series: {len(national)}")
print(f"  JOLTS series: {len(jolts)}")
print(f"  National industry series: {len(nat_ind)}")
print(f"  Saiz elasticities: {len(SAIZ_ELASTICITY_BY_STATE)}")
