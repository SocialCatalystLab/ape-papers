"""
02_clean_data.py — Construct panel dataset, Bartik instruments, Saiz IV,
emp/pop paths, and industry shares matrix for apep_0238 v6
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

# ──────────────────────────────────────────────────────────────
# Load raw data
# ──────────────────────────────────────────────────────────────
with open(DATA_DIR / "raw_fred_data.json") as f:
    raw = json.load(f)

def dict_to_series(d, name="val"):
    dates = pd.to_datetime(list(d.keys()))
    vals = [float(v) for v in d.values()]
    return pd.Series(vals, index=dates, name=name).sort_index()

# ──────────────────────────────────────────────────────────────
# 1. Build state-level panel
# ──────────────────────────────────────────────────────────────
print("Building state-level panel...")

# Employment panel (monthly, thousands)
emp_frames = []
for st, d in raw['state_emp'].items():
    s = dict_to_series(d, 'emp')
    s = s.to_frame()
    s['state'] = st
    s.index.name = 'date'
    emp_frames.append(s.reset_index())

emp_panel = pd.concat(emp_frames, ignore_index=True)
emp_panel['date'] = pd.to_datetime(emp_panel['date'])
emp_panel = emp_panel.sort_values(['state', 'date']).reset_index(drop=True)

# UR panel
ur_frames = []
for st, d in raw['state_ur'].items():
    s = dict_to_series(d, 'ur')
    s = s.to_frame()
    s['state'] = st
    s.index.name = 'date'
    ur_frames.append(s.reset_index())
ur_panel = pd.concat(ur_frames, ignore_index=True)
ur_panel['date'] = pd.to_datetime(ur_panel['date'])

# LFPR panel
lfpr_frames = []
for st, d in raw['state_lfpr'].items():
    s = dict_to_series(d, 'lfpr')
    s = s.to_frame()
    s['state'] = st
    s.index.name = 'date'
    lfpr_frames.append(s.reset_index())
lfpr_panel = pd.concat(lfpr_frames, ignore_index=True)
lfpr_panel['date'] = pd.to_datetime(lfpr_panel['date'])

# Merge
panel = emp_panel.merge(ur_panel, on=['state', 'date'], how='left')
panel = panel.merge(lfpr_panel, on=['state', 'date'], how='left')

# Log employment
panel['log_emp'] = np.log(panel['emp'])

# ──────────────────────────────────────────────────────────────
# 1b. State population — interpolate annual to monthly (WS3)
# ──────────────────────────────────────────────────────────────
print("Processing state population data...")
state_pop_monthly = {}
for st, d in raw.get('state_pop', {}).items():
    s = dict_to_series(d, 'pop')
    if len(s) < 2:
        continue
    # Resample annual to monthly via linear interpolation
    s_monthly = s.resample('MS').interpolate(method='linear')
    state_pop_monthly[st] = s_monthly
print(f"  Interpolated population: {len(state_pop_monthly)} states")

# Add population to panel and compute emp/pop ratio
pop_frames = []
for st, s in state_pop_monthly.items():
    df = s.to_frame('pop')
    df['state'] = st
    df.index.name = 'date'
    pop_frames.append(df.reset_index())

if pop_frames:
    pop_panel = pd.concat(pop_frames, ignore_index=True)
    pop_panel['date'] = pd.to_datetime(pop_panel['date'])
    panel = panel.merge(pop_panel, on=['state', 'date'], how='left')
    # emp/pop ratio (employment in thousands, population in thousands)
    panel['emp_pop'] = panel['emp'] / panel['pop']
    panel['log_emp_pop'] = np.log(panel['emp_pop'].clip(lower=0.001))
    print(f"  Panel with population: {panel['pop'].notna().sum()} obs have pop data")

print(f"  Panel: {len(panel)} obs, {panel['state'].nunique()} states, "
      f"{panel['date'].min().strftime('%Y-%m')} to {panel['date'].max().strftime('%Y-%m')}")

# ──────────────────────────────────────────────────────────────
# 2. Construct Bartik instruments
# ──────────────────────────────────────────────────────────────
print("\nConstructing Bartik instruments...")

# National industry employment (for "shifts")
nat_ind = {}
ind_name_map = {
    'MANEMP': 'MFG', 'USCONS': 'CONS', 'USFIRE': 'FIRE',
    'USLAH': 'LEIH', 'USEHS': 'EDUH', 'USGOVT': 'GOVT',
    'USINFO': 'INFO', 'USTRADE': 'TRAD', 'USMINE': 'MINE',
    'USPBS': 'PROF'
}
for sid, d in raw['nat_ind'].items():
    short = ind_name_map.get(sid, sid)
    nat_ind[short] = dict_to_series(d, short)

# State industry employment (for "shares")
state_ind = defaultdict(dict)
for st, industries in raw['state_ind_emp'].items():
    for ind_code, d in industries.items():
        state_ind[st][ind_code] = dict_to_series(d, ind_code)

# Compute Bartik for each recession (leave-one-out)
def compute_bartik(base_date, shock_start, shock_end, states, state_ind, nat_ind):
    """
    Bartik = sum_j (share_{s,j,base} * delta_E_{-s,j,shock})
    Returns dict: state -> bartik_value, shifts dict, and shares matrix
    """
    bartik = {}
    base_dt = pd.Timestamp(base_date)
    shock_start_dt = pd.Timestamp(shock_start)
    shock_end_dt = pd.Timestamp(shock_end)

    nat_levels = {}
    for ind_code, s in nat_ind.items():
        s_monthly = s.resample('MS').first().dropna()
        try:
            e_start = s_monthly.loc[s_monthly.index.asof(shock_start_dt)]
            e_end = s_monthly.loc[s_monthly.index.asof(shock_end_dt)]
            if e_start > 0:
                nat_levels[ind_code] = (e_start, e_end)
        except (KeyError, ValueError):
            pass

    state_levels = {}
    for st in states:
        if st not in state_ind:
            continue
        state_levels[st] = {}
        for ind_code, s in state_ind[st].items():
            if ind_code not in nat_levels:
                continue
            s_monthly = s.resample('MS').first().dropna()
            try:
                e_start = s_monthly.loc[s_monthly.index.asof(shock_start_dt)]
                e_end = s_monthly.loc[s_monthly.index.asof(shock_end_dt)]
                state_levels[st][ind_code] = (e_start, e_end)
            except (KeyError, ValueError):
                pass

    shifts = {}
    for ind_code, (e_start, e_end) in nat_levels.items():
        shifts[ind_code] = np.log(e_end / e_start)

    # Also collect shares matrix for AKM SEs
    ind_codes_sorted = sorted(nat_levels.keys())
    shares_matrix = {}  # state -> {industry: share}

    for st in states:
        if st not in state_ind:
            continue
        total_emp = 0
        weighted_shift = 0
        ind_emp = {}
        for ind_code, s in state_ind[st].items():
            if ind_code not in nat_levels:
                continue
            s_monthly = s.resample('MS').first().dropna()
            try:
                e_base = s_monthly.loc[s_monthly.index.asof(base_dt)]
            except (KeyError, ValueError):
                continue

            nat_start, nat_end = nat_levels[ind_code]
            st_start, st_end = state_levels.get(st, {}).get(ind_code, (0, 0))
            loo_start = nat_start - st_start
            loo_end = nat_end - st_end

            if loo_start > 0:
                loo_shift = np.log(loo_end / loo_start)
                total_emp += e_base
                weighted_shift += e_base * loo_shift
                ind_emp[ind_code] = e_base

        if total_emp > 0:
            bartik[st] = weighted_shift / total_emp
            shares_matrix[st] = {ind: ind_emp.get(ind, 0) / total_emp
                                 for ind in ind_codes_sorted}

    return bartik, shifts, shares_matrix

# Great Recession Bartik (base: 2006, shock: Dec 2007 - Jun 2009)
bartik_gr, shifts_gr, shares_gr = compute_bartik("2006-12-01", "2007-12-01", "2009-06-01",
                                                  list(STATE_FIPS.keys()), state_ind, nat_ind)

# COVID Bartik (base: 2019, shock: Feb 2020 - Apr 2020)
bartik_covid, shifts_covid, shares_covid = compute_bartik("2019-12-01", "2020-02-01", "2020-04-01",
                                                           list(STATE_FIPS.keys()), state_ind, nat_ind)

print(f"  Great Recession Bartik: {len(bartik_gr)} states")
print(f"    Mean: {np.mean(list(bartik_gr.values())):.4f}, "
      f"Std: {np.std(list(bartik_gr.values())):.4f}")
print(f"    Industry shifts: {shifts_gr}")
print(f"  COVID Bartik: {len(bartik_covid)} states")
print(f"    Mean: {np.mean(list(bartik_covid.values())):.4f}, "
      f"Std: {np.std(list(bartik_covid.values())):.4f}")
print(f"  Shares matrix: GR={len(shares_gr)} states, COVID={len(shares_covid)} states")

# ──────────────────────────────────────────────────────────────
# 3. Housing price instrument (for Great Recession)
# ──────────────────────────────────────────────────────────────
print("\nConstructing housing price instrument...")
hpi_boom = {}
for st, d in raw['state_hpi'].items():
    s = dict_to_series(d, 'hpi')
    s = s.resample('QS').first().dropna()
    try:
        h2003 = s.loc[s.index.asof(pd.Timestamp("2003-01-01"))]
        h2006 = s.loc[s.index.asof(pd.Timestamp("2006-10-01"))]
        if h2003 > 0:
            hpi_boom[st] = np.log(h2006 / h2003)
    except (KeyError, ValueError):
        pass
print(f"  Housing boom (log change 2003-2006): {len(hpi_boom)} states")
print(f"    Mean: {np.mean(list(hpi_boom.values())):.4f}, "
      f"Std: {np.std(list(hpi_boom.values())):.4f}")

# ──────────────────────────────────────────────────────────────
# 3b. Saiz (2010) supply elasticity instrument (WS1)
# ──────────────────────────────────────────────────────────────
print("\nLoading Saiz supply elasticity instrument...")
saiz_elasticity = raw.get('saiz_elasticity', {})
# Invert: low elasticity → constrained supply → bigger housing boom → more scarring
# Use negative elasticity as instrument (low supply = high exposure)
saiz_instrument = {st: -val for st, val in saiz_elasticity.items()}
print(f"  Saiz instrument (negated elasticity): {len(saiz_instrument)} states")
saiz_vals = list(saiz_instrument.values())
print(f"    Mean: {np.mean(saiz_vals):.2f}, Std: {np.std(saiz_vals):.2f}")

# ──────────────────────────────────────────────────────────────
# 4. Compute outcome paths relative to recession peak
# ──────────────────────────────────────────────────────────────
print("\nComputing recovery paths...")

horizons = list(range(0, 133, 1))  # 0 to 132 months (11 years)

def compute_recovery_paths(panel, peak_date, horizons):
    """Compute log employment change relative to peak for each state at each horizon."""
    peak_dt = pd.Timestamp(peak_date)
    paths = {}
    for st in panel['state'].unique():
        st_data = panel[panel['state'] == st].set_index('date').sort_index()
        if peak_dt not in st_data.index:
            diffs = abs(st_data.index - peak_dt)
            peak_idx = diffs.argmin()
            peak_val = st_data.iloc[peak_idx]['log_emp']
        else:
            peak_val = st_data.loc[peak_dt, 'log_emp']

        path = {}
        for h in horizons:
            target_date = peak_dt + pd.DateOffset(months=h)
            if target_date in st_data.index:
                path[h] = st_data.loc[target_date, 'log_emp'] - peak_val
            else:
                candidates = st_data.index[(st_data.index >= target_date - pd.Timedelta(days=15)) &
                                           (st_data.index <= target_date + pd.Timedelta(days=15))]
                if len(candidates) > 0:
                    path[h] = st_data.loc[candidates[0], 'log_emp'] - peak_val
        paths[st] = path
    return paths

# Great Recession paths
gr_paths = compute_recovery_paths(panel, GR_PEAK, horizons)
# COVID paths (shorter horizon since more recent)
covid_horizons = list(range(0, 49, 1))
covid_paths = compute_recovery_paths(panel, COVID_PEAK, covid_horizons)

# Also compute UR and LFPR paths
def compute_level_paths(panel, peak_date, horizons, var='ur'):
    peak_dt = pd.Timestamp(peak_date)
    paths = {}
    for st in panel['state'].unique():
        st_data = panel[panel['state'] == st].set_index('date').sort_index()
        if var not in st_data.columns or st_data[var].isna().all():
            continue
        try:
            peak_val = st_data.loc[st_data.index.asof(peak_dt), var]
        except (KeyError, ValueError):
            continue
        path = {}
        for h in horizons:
            target_date = peak_dt + pd.DateOffset(months=h)
            candidates = st_data.index[(st_data.index >= target_date - pd.Timedelta(days=15)) &
                                       (st_data.index <= target_date + pd.Timedelta(days=15))]
            if len(candidates) > 0:
                path[h] = st_data.loc[candidates[0], var] - peak_val
        paths[st] = path
    return paths

gr_ur_paths = compute_level_paths(panel, GR_PEAK, horizons, 'ur')
gr_lfpr_paths = compute_level_paths(panel, GR_PEAK, horizons, 'lfpr')
covid_ur_paths = compute_level_paths(panel, COVID_PEAK, covid_horizons, 'ur')
covid_lfpr_paths = compute_level_paths(panel, COVID_PEAK, covid_horizons, 'lfpr')

# ──────────────────────────────────────────────────────────────
# 4b. Emp/pop ratio paths (WS3 — migration decomposition)
# ──────────────────────────────────────────────────────────────
print("Computing emp/pop ratio paths...")

def compute_emppop_paths(panel, peak_date, horizons):
    """Compute log(emp/pop) change relative to peak."""
    peak_dt = pd.Timestamp(peak_date)
    paths = {}
    for st in panel['state'].unique():
        st_data = panel[panel['state'] == st].set_index('date').sort_index()
        if 'log_emp_pop' not in st_data.columns or st_data['log_emp_pop'].isna().all():
            continue
        try:
            peak_val = st_data.loc[st_data.index.asof(peak_dt), 'log_emp_pop']
        except (KeyError, ValueError):
            continue
        if np.isnan(peak_val):
            continue
        path = {}
        for h in horizons:
            target_date = peak_dt + pd.DateOffset(months=h)
            candidates = st_data.index[(st_data.index >= target_date - pd.Timedelta(days=15)) &
                                       (st_data.index <= target_date + pd.Timedelta(days=15))]
            if len(candidates) > 0:
                val = st_data.loc[candidates[0], 'log_emp_pop']
                if not np.isnan(val):
                    path[h] = val - peak_val
        if path:
            paths[st] = path
    return paths

gr_emppop_paths = compute_emppop_paths(panel, GR_PEAK, horizons)
covid_emppop_paths = compute_emppop_paths(panel, COVID_PEAK, covid_horizons)
print(f"  GR emp/pop paths: {len(gr_emppop_paths)} states")
print(f"  COVID emp/pop paths: {len(covid_emppop_paths)} states")

print(f"  GR paths: {len(gr_paths)} states, max horizon {max(horizons)} months")
print(f"  COVID paths: {len(covid_paths)} states, max horizon {max(covid_horizons)} months")

# ──────────────────────────────────────────────────────────────
# 5. Save processed data
# ──────────────────────────────────────────────────────────────
processed = {
    'bartik_gr': bartik_gr,
    'bartik_covid': bartik_covid,
    'hpi_boom': hpi_boom,
    'saiz_instrument': saiz_instrument,
    'shifts_gr': shifts_gr,
    'shifts_covid': shifts_covid,
    'shares_gr': shares_gr,
    'shares_covid': shares_covid,
    'gr_paths': {st: {str(k): v for k, v in p.items()} for st, p in gr_paths.items()},
    'covid_paths': {st: {str(k): v for k, v in p.items()} for st, p in covid_paths.items()},
    'gr_ur_paths': {st: {str(k): v for k, v in p.items()} for st, p in gr_ur_paths.items()},
    'gr_lfpr_paths': {st: {str(k): v for k, v in p.items()} for st, p in gr_lfpr_paths.items()},
    'covid_ur_paths': {st: {str(k): v for k, v in p.items()} for st, p in covid_ur_paths.items()},
    'covid_lfpr_paths': {st: {str(k): v for k, v in p.items()} for st, p in covid_lfpr_paths.items()},
    'gr_emppop_paths': {st: {str(k): v for k, v in p.items()} for st, p in gr_emppop_paths.items()},
    'covid_emppop_paths': {st: {str(k): v for k, v in p.items()} for st, p in covid_emppop_paths.items()},
    'horizons': horizons,
    'covid_horizons': covid_horizons,
}

# Summary stats
summary_rows = []
for st in sorted(STATE_FIPS.keys()):
    st_data = panel[panel['state'] == st]
    row = {
        'state': st,
        'state_name': STATE_NAMES.get(st, st),
        'emp_2007': float(st_data[st_data['date'] == '2007-12-01']['emp'].values[0]) if len(st_data[st_data['date'] == '2007-12-01']) > 0 else np.nan,
        'emp_2020': float(st_data[st_data['date'] == '2020-02-01']['emp'].values[0]) if len(st_data[st_data['date'] == '2020-02-01']) > 0 else np.nan,
        'bartik_gr': bartik_gr.get(st, np.nan),
        'bartik_covid': bartik_covid.get(st, np.nan),
        'hpi_boom': hpi_boom.get(st, np.nan),
        'saiz': saiz_elasticity.get(st, np.nan),
    }
    if st in gr_paths:
        trough_months = range(0, 25)
        trough_vals = [gr_paths[st].get(h, 0) for h in trough_months]
        row['gr_trough'] = min(trough_vals) if trough_vals else np.nan
    if st in covid_paths:
        trough_months = range(0, 7)
        trough_vals = [covid_paths[st].get(h, 0) for h in trough_months]
        row['covid_trough'] = min(trough_vals) if trough_vals else np.nan
    if st in gr_paths:
        row['gr_recovery_48'] = gr_paths[st].get(48, np.nan)
    if st in covid_paths:
        row['covid_recovery_48'] = covid_paths[st].get(48, np.nan)
    summary_rows.append(row)

summary_df = pd.DataFrame(summary_rows)
processed['summary'] = summary_df.to_dict('records')

with open(DATA_DIR / "processed_data.json", 'w') as f:
    json.dump(processed, f, indent=2, default=str)

# Also save panel as CSV for reference
panel.to_csv(DATA_DIR / "state_panel.csv", index=False)
summary_df.to_csv(DATA_DIR / "state_summary.csv", index=False)

print(f"\n✓ Processed data saved")
print(f"  Panel CSV: {len(panel)} obs")
print(f"  Summary: {len(summary_df)} states")
print(f"\n  Great Recession severity (log emp change, peak to trough):")
print(f"    Mean: {summary_df['gr_trough'].mean():.4f}")
print(f"    Worst: {summary_df.loc[summary_df['gr_trough'].idxmin(), 'state']} = {summary_df['gr_trough'].min():.4f}")
print(f"    Least: {summary_df.loc[summary_df['gr_trough'].idxmax(), 'state']} = {summary_df['gr_trough'].max():.4f}")
print(f"\n  COVID severity (log emp change, peak to trough):")
print(f"    Mean: {summary_df['covid_trough'].mean():.4f}")
print(f"    Worst: {summary_df.loc[summary_df['covid_trough'].idxmin(), 'state']} = {summary_df['covid_trough'].min():.4f}")
print(f"    Least: {summary_df.loc[summary_df['covid_trough'].idxmax(), 'state']} = {summary_df['covid_trough'].max():.4f}")
