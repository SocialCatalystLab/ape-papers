"""
03_main_analysis.py — LP-IV estimation for hysteresis comparison
v4: implements pre-recession controls (log pop, pre-growth, region dummies),
    permutation inference, pre-trend estimation, subsample robustness
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

with open(DATA_DIR / "processed_data.json") as f:
    proc = json.load(f)

bartik_gr = proc['bartik_gr']
bartik_covid = proc['bartik_covid']
hpi_boom = proc['hpi_boom']
gr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_paths'].items()}
covid_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_paths'].items()}
gr_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_ur_paths'].items()}
gr_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_lfpr_paths'].items()}
covid_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_ur_paths'].items()}
covid_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_lfpr_paths'].items()}

# ──────────────────────────────────────────────────────────────
# Build pre-recession control vectors: X_s in Eq.(1)
# Controls: log(population), pre-recession employment growth,
#           3 region dummies (NE, MW, S; West = reference)
# ──────────────────────────────────────────────────────────────
print("Building pre-recession control matrices...")

panel = pd.read_csv(DATA_DIR / "state_panel.csv")
panel['date'] = pd.to_datetime(panel['date'])
summary_df = pd.DataFrame(proc['summary'])

CENSUS_REGIONS_CTRL = {
    'Northeast': ['CT','ME','MA','NH','RI','VT','NJ','NY','PA'],
    'Midwest': ['IL','IN','IA','KS','MI','MN','MO','NE','ND','OH','SD','WI'],
    'South': ['AL','AR','DE','FL','GA','KY','LA','MD','MS','NC','OK','SC','TN','TX','VA','WV'],
    'West': ['AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY'],
}
STATE_TO_REGION_CTRL = {}
for region, sts in CENSUS_REGIONS_CTRL.items():
    for st in sts:
        STATE_TO_REGION_CTRL[st] = region

def build_state_controls(states, emp_col, growth_start, growth_end):
    """Build state-level control dict: state -> np.array([log_pop, pre_growth, NE, MW, S])."""
    controls = {}
    for st in states:
        ctrl = []
        # 1. Log population (employment proxy at recession peak)
        row = summary_df[summary_df['state'] == st]
        emp = float(row[emp_col].values[0]) if len(row) > 0 else np.nan
        ctrl.append(np.log(emp) if emp > 0 and not np.isnan(emp) else 0.0)

        # 2. Pre-recession employment growth
        st_panel = panel[panel['state'] == st].set_index('date').sort_index()
        try:
            start_dt = pd.Timestamp(growth_start)
            end_dt = pd.Timestamp(growth_end)
            emp_s = st_panel.loc[st_panel.index.asof(start_dt), 'emp']
            emp_e = st_panel.loc[st_panel.index.asof(end_dt), 'emp']
            growth = np.log(emp_e / emp_s) if emp_s > 0 else 0.0
        except (KeyError, ValueError):
            growth = 0.0
        ctrl.append(growth)

        # 3. Region dummies (West = reference)
        region = STATE_TO_REGION_CTRL.get(st, 'West')
        ctrl.append(1.0 if region == 'Northeast' else 0.0)
        ctrl.append(1.0 if region == 'Midwest' else 0.0)
        ctrl.append(1.0 if region == 'South' else 0.0)

        controls[st] = np.array(ctrl)
    return controls

all_states = sorted(STATE_FIPS.keys())
gr_controls = build_state_controls(all_states, 'emp_2007', '2004-12-01', '2007-12-01')
covid_controls = build_state_controls(all_states, 'emp_2020', '2017-01-01', '2019-12-01')

print(f"  GR controls: {len(gr_controls)} states, {len(next(iter(gr_controls.values())))} variables")
print(f"  COVID controls: {len(covid_controls)} states, {len(next(iter(covid_controls.values())))} variables")

# ──────────────────────────────────────────────────────────────
# LP estimation functions
# ──────────────────────────────────────────────────────────────

def lp_ols(paths, instrument, horizons, controls=None, min_n=10):
    """
    Cross-sectional LP: Δy_{s,h} = α + β_h * Z_s + ε_{s,h}
    Returns: betas, ses, n_obs, r2s, pvals at each horizon
    """
    results = []
    for h in horizons:
        # Build cross-section
        y_list, x_list = [], []
        for st in sorted(paths.keys()):
            if st not in instrument:
                continue
            if h not in paths[st]:
                continue
            y_list.append(paths[st][h])
            x_list.append(instrument[st])

        y = np.array(y_list)
        x = np.array(x_list)

        if len(y) < min_n:
            results.append({'h': h, 'beta': np.nan, 'se': np.nan,
                           'n': len(y), 'r2': np.nan, 'pval': np.nan})
            continue

        # OLS with constant
        X = np.column_stack([np.ones(len(x)), x])
        if controls is not None:
            ctrl_rows = []
            for st in sorted(paths.keys()):
                if st in instrument and h in paths[st]:
                    cv = controls.get(st)
                    if cv is not None:
                        ctrl_rows.append(np.asarray(cv, dtype=float))
            if ctrl_rows:
                ctrl_matrix = np.array(ctrl_rows)
                if ctrl_matrix.ndim == 1:
                    ctrl_matrix = ctrl_matrix.reshape(-1, 1)
                X = np.column_stack([X, ctrl_matrix])

        try:
            beta_hat = np.linalg.lstsq(X, y, rcond=None)[0]
            resid = y - X @ beta_hat
            n = len(y)
            k = X.shape[1]
            sigma2 = np.sum(resid**2) / (n - k)

            # HC1 robust standard errors
            meat = np.zeros((k, k))
            for i in range(n):
                xi = X[i:i+1, :]
                meat += (resid[i]**2) * (xi.T @ xi)
            bread = np.linalg.inv(X.T @ X)
            V_hc1 = (n / (n - k)) * bread @ meat @ bread
            se = np.sqrt(np.diag(V_hc1))

            # R-squared
            ss_res = np.sum(resid**2)
            ss_tot = np.sum((y - np.mean(y))**2)
            r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 0

            tstat = beta_hat[1] / se[1] if se[1] > 0 else 0
            pval = 2 * (1 - stats.t.cdf(abs(tstat), n - k))

            results.append({
                'h': h, 'beta': float(beta_hat[1]), 'se': float(se[1]),
                'n': n, 'r2': float(r2), 'pval': float(pval),
                'intercept': float(beta_hat[0])
            })
        except np.linalg.LinAlgError:
            results.append({'h': h, 'beta': np.nan, 'se': np.nan,
                           'n': len(y), 'r2': np.nan, 'pval': np.nan})
    return results

# ──────────────────────────────────────────────────────────────
# Permutation inference
# ──────────────────────────────────────────────────────────────

def permutation_test(paths, instrument, horizons, n_perms=1000, seed=42, controls=None):
    """
    Permutation test: randomly reassign Z_s across states without replacement.
    Controls are held fixed (only the instrument is permuted).
    Returns dict: horizon -> permutation p-value (two-sided).
    """
    rng = np.random.RandomState(seed)

    # Get actual estimates (with controls)
    actual = lp_ols(paths, instrument, horizons, controls=controls)
    actual_betas = {r['h']: r['beta'] for r in actual}

    # Build aligned state list
    states = sorted([st for st in paths.keys() if st in instrument])
    z_vals = np.array([instrument[st] for st in states])

    perm_counts = {h: 0 for h in horizons}

    for _ in range(n_perms):
        z_perm = rng.permutation(z_vals)
        perm_instrument = {st: float(z_perm[i]) for i, st in enumerate(states)}
        perm_results = lp_ols(paths, perm_instrument, horizons, controls=controls)
        for r in perm_results:
            h = r['h']
            if h in actual_betas and not np.isnan(r['beta']) and not np.isnan(actual_betas[h]):
                if abs(r['beta']) >= abs(actual_betas[h]):
                    perm_counts[h] += 1

    perm_pvals = {h: perm_counts[h] / n_perms for h in horizons}
    return perm_pvals

# ──────────────────────────────────────────────────────────────
# Main LP estimates
# ──────────────────────────────────────────────────────────────
print("="*60)
print("LOCAL PROJECTION ESTIMATES: EMPLOYMENT")
print("="*60)

# Key horizons for tables
table_horizons = [0, 3, 6, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120]
covid_table_horizons = [0, 3, 6, 12, 24, 36, 48]

# Fine horizons for figures (every 3 months)
fig_horizons = list(range(0, 133, 3))
covid_fig_horizons = list(range(0, 49, 3))

# 1. Great Recession — Bartik instrument
print("\n--- Great Recession: Bartik Instrument ---")
gr_bartik_results = lp_ols(gr_paths, bartik_gr, fig_horizons, controls=gr_controls)
for r in gr_bartik_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 2. Great Recession — Housing price instrument
print("\n--- Great Recession: Housing Price Instrument ---")
gr_hpi_results = lp_ols(gr_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_hpi_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 3. COVID — Bartik instrument
print("\n--- COVID Recession: Bartik Instrument ---")
covid_bartik_results = lp_ols(covid_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
for r in covid_bartik_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# ──────────────────────────────────────────────────────────────
# Permutation inference (Change 1)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PERMUTATION INFERENCE (1,000 reassignments)")
print("="*60)

# Permutation p-values for table horizons
perm_horizons_gr = [3, 6, 12, 24, 36, 48, 60, 84, 120]
perm_horizons_covid = [3, 6, 12, 24, 36, 48]

print("\n--- Great Recession (HPI instrument) ---")
gr_perm_pvals = permutation_test(gr_paths, hpi_boom, perm_horizons_gr, n_perms=1000, controls=gr_controls)
for h in perm_horizons_gr:
    print(f"  h={h:3d}: perm p-value = {gr_perm_pvals[h]:.3f}")

print("\n--- COVID (Bartik instrument) ---")
covid_perm_pvals = permutation_test(covid_paths, bartik_covid, perm_horizons_covid, n_perms=1000, controls=covid_controls)
for h in perm_horizons_covid:
    print(f"  h={h:3d}: perm p-value = {covid_perm_pvals[h]:.3f}")

# ──────────────────────────────────────────────────────────────
# Pre-trend estimation (Change 2)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PRE-TREND EVENT STUDY")
print("="*60)

# Load panel for pre-trend computation
panel = pd.read_csv(DATA_DIR / "state_panel.csv")
panel['date'] = pd.to_datetime(panel['date'])

# GR: compute pre-period paths (h = -36, -24, -12 relative to Dec 2007)
gr_peak_dt = pd.Timestamp("2007-12-01")
pre_horizons_gr = [-36, -24, -12]
post_horizons_gr = [0, 6, 12, 24, 36, 48, 60, 84, 120]
all_event_horizons_gr = pre_horizons_gr + post_horizons_gr

gr_pretrend_paths = {}
for st in panel['state'].unique():
    st_data = panel[panel['state'] == st].set_index('date').sort_index()
    if 'log_emp' not in st_data.columns:
        continue
    peak_val = st_data.loc[st_data.index.asof(gr_peak_dt), 'log_emp'] if gr_peak_dt <= st_data.index.max() else np.nan
    if np.isnan(peak_val):
        continue
    path = {}
    for h in all_event_horizons_gr:
        target = gr_peak_dt + pd.DateOffset(months=h)
        candidates = st_data.index[(st_data.index >= target - pd.Timedelta(days=15)) &
                                    (st_data.index <= target + pd.Timedelta(days=15))]
        if len(candidates) > 0:
            path[h] = st_data.loc[candidates[0], 'log_emp'] - peak_val
    gr_pretrend_paths[st] = path

# COVID: pre-period (h = -36, -24, -12 relative to Feb 2020)
covid_peak_dt = pd.Timestamp("2020-02-01")
pre_horizons_covid = [-36, -24, -12]
post_horizons_covid = [0, 6, 12, 24, 36, 48]
all_event_horizons_covid = pre_horizons_covid + post_horizons_covid

covid_pretrend_paths = {}
for st in panel['state'].unique():
    st_data = panel[panel['state'] == st].set_index('date').sort_index()
    if 'log_emp' not in st_data.columns:
        continue
    peak_val = st_data.loc[st_data.index.asof(covid_peak_dt), 'log_emp'] if covid_peak_dt <= st_data.index.max() else np.nan
    if np.isnan(peak_val):
        continue
    path = {}
    for h in all_event_horizons_covid:
        target = covid_peak_dt + pd.DateOffset(months=h)
        candidates = st_data.index[(st_data.index >= target - pd.Timedelta(days=15)) &
                                    (st_data.index <= target + pd.Timedelta(days=15))]
        if len(candidates) > 0:
            path[h] = st_data.loc[candidates[0], 'log_emp'] - peak_val
    covid_pretrend_paths[st] = path

# Estimate event-study LP for both (with controls)
gr_event_results = lp_ols(gr_pretrend_paths, hpi_boom, all_event_horizons_gr, controls=gr_controls)
covid_event_results = lp_ols(covid_pretrend_paths, bartik_covid, all_event_horizons_covid, controls=covid_controls)

print("\n--- Great Recession pre-trends (HPI instrument) ---")
for r in gr_event_results:
    if r['h'] < 0:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:4d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  p={r['pval']:.3f}")

print("\n--- COVID pre-trends (Bartik instrument) ---")
for r in covid_event_results:
    if r['h'] < 0:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:4d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  p={r['pval']:.3f}")

# ──────────────────────────────────────────────────────────────
# Subsample robustness (Change 4)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("SUBSAMPLE ROBUSTNESS")
print("="*60)

# Census region mapping
CENSUS_REGIONS = {
    'Northeast': ['CT','ME','MA','NH','RI','VT','NJ','NY','PA'],
    'Midwest': ['IL','IN','IA','KS','MI','MN','MO','NE','ND','OH','SD','WI'],
    'South': ['AL','AR','DE','FL','GA','KY','LA','MD','MS','NC','OK','SC','TN','TX','VA','WV'],
    'West': ['AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY'],
}
STATE_TO_REGION = {}
for region, states in CENSUS_REGIONS.items():
    for st in states:
        STATE_TO_REGION[st] = region

# State population (use 2007 employment as proxy)
summary = pd.DataFrame(proc['summary'])
median_emp = summary['emp_2007'].median()

subsample_results = {}

# By Census region (skip region dummies within single-region subsample)
print("\n--- By Census Region (GR, HPI instrument, h=60) ---")
for region, region_states in CENSUS_REGIONS.items():
    region_paths = {st: p for st, p in gr_paths.items() if st in region_states}
    if len(region_paths) < 5:
        print(f"  {region}: too few states ({len(region_paths)})")
        subsample_results[f'region_{region}'] = {'beta_60': np.nan, 'se_60': np.nan, 'n': len(region_paths)}
        continue
    # Use only log(pop) and pre-growth as controls (region dummies meaningless within region)
    region_ctrl = {st: gr_controls[st][:2] for st in region_states if st in gr_controls}
    region_res = lp_ols(region_paths, hpi_boom, [60], min_n=5, controls=region_ctrl)
    if region_res and not np.isnan(region_res[0]['beta']):
        r = region_res[0]
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  {region:12s}: β_60={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}")
        subsample_results[f'region_{region}'] = {'beta_60': r['beta'], 'se_60': r['se'], 'n': r['n'], 'pval': r['pval']}
    else:
        print(f"  {region}: estimation failed")
        subsample_results[f'region_{region}'] = {'beta_60': np.nan, 'se_60': np.nan, 'n': 0}

# Above/below median population
print("\n--- By State Size (GR, HPI instrument, h=60) ---")
large_states = summary[summary['emp_2007'] >= median_emp]['state'].tolist()
small_states = summary[summary['emp_2007'] < median_emp]['state'].tolist()

for label, state_list in [('Large (above median)', large_states), ('Small (below median)', small_states)]:
    sub_paths = {st: p for st, p in gr_paths.items() if st in state_list}
    sub_res = lp_ols(sub_paths, hpi_boom, [60], controls=gr_controls)
    if sub_res and not np.isnan(sub_res[0]['beta']):
        r = sub_res[0]
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  {label:25s}: β_60={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}")
        subsample_results[label.lower().replace(' ', '_').replace('(', '').replace(')', '')] = {
            'beta_60': r['beta'], 'se_60': r['se'], 'n': r['n'], 'pval': r['pval']
        }

# ──────────────────────────────────────────────────────────────
# LP estimates for unemployment rate
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: UNEMPLOYMENT RATE")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_ur_results = lp_ols(gr_ur_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_ur_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_ur_results = lp_ols(covid_ur_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
for r in covid_ur_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

# ──────────────────────────────────────────────────────────────
# LP estimates for LFPR
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: LFPR")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_lfpr_results = lp_ols(gr_lfpr_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_lfpr_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_lfpr_results = lp_ols(covid_lfpr_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
for r in covid_lfpr_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

# ──────────────────────────────────────────────────────────────
# Half-life computation
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("HALF-LIFE ANALYSIS")
print("="*60)

def compute_half_life(results, negative=True):
    """Find the peak response and compute half-life (months to recover halfway)."""
    valid = [r for r in results if not np.isnan(r['beta'])]
    if not valid:
        return 0, 0.0, np.nan

    if negative:
        peak = min(valid, key=lambda r: r['beta'])
        if peak['beta'] >= 0:
            return peak['h'], peak['beta'], np.nan
        half_target = peak['beta'] / 2
        for r in sorted(valid, key=lambda x: x['h']):
            if r['h'] > peak['h'] and r['beta'] > half_target:
                return peak['h'], peak['beta'], r['h'] - peak['h']
        return peak['h'], peak['beta'], np.inf
    else:
        peak = max(valid, key=lambda r: r['beta'])
        if peak['beta'] <= 0:
            return peak['h'], peak['beta'], np.nan
        half_target = peak['beta'] / 2
        for r in sorted(valid, key=lambda x: x['h']):
            if r['h'] > peak['h'] and r['beta'] < half_target:
                return peak['h'], peak['beta'], r['h'] - peak['h']
        return peak['h'], peak['beta'], np.inf

gr_peak_h, gr_peak_beta, gr_half_life = compute_half_life(gr_hpi_results, negative=True)
covid_peak_h, covid_peak_beta, covid_half_life = compute_half_life(covid_bartik_results, negative=False)

print(f"  Great Recession (HPI): peak at h={gr_peak_h}, β={gr_peak_beta:.4f}, half-life={gr_half_life} months")
print(f"  COVID (Bartik): peak at h={covid_peak_h}, β={covid_peak_beta:.4f}, half-life={covid_half_life} months")

# Persistence ratio: β at h=48 / β at peak
gr_48 = next((r['beta'] for r in gr_hpi_results if r['h'] == 48), np.nan)
gr_peak_val = next((r['beta'] for r in gr_hpi_results if r['h'] == gr_peak_h), np.nan)
covid_48 = next((r['beta'] for r in covid_bartik_results if r['h'] == 48), np.nan)
covid_peak_val = next((r['beta'] for r in covid_bartik_results if r['h'] == covid_peak_h), np.nan)

if gr_peak_val != 0 and not np.isnan(gr_peak_val):
    gr_persist = gr_48 / gr_peak_val
else:
    gr_persist = np.nan
if covid_peak_val != 0 and not np.isnan(covid_peak_val):
    covid_persist = covid_48 / covid_peak_val
else:
    covid_persist = np.nan

print(f"  Persistence ratio (β_48/β_peak):")
print(f"    Great Recession: {gr_persist:.3f}")
print(f"    COVID: {covid_persist:.3f}")

# ──────────────────────────────────────────────────────────────
# Save all results
# ──────────────────────────────────────────────────────────────
lp_results = {
    'gr_bartik': gr_bartik_results,
    'gr_hpi': gr_hpi_results,
    'covid_bartik': covid_bartik_results,
    'gr_ur': gr_ur_results,
    'covid_ur': covid_ur_results,
    'gr_lfpr': gr_lfpr_results,
    'covid_lfpr': covid_lfpr_results,
    'half_lives': {
        'gr': {'peak_h': gr_peak_h, 'peak_beta': gr_peak_beta, 'half_life': gr_half_life,
               'beta_48': gr_48, 'persistence': gr_persist},
        'covid': {'peak_h': covid_peak_h, 'peak_beta': covid_peak_beta, 'half_life': covid_half_life,
                  'beta_48': covid_48, 'persistence': covid_persist}
    },
    'permutation_pvals': {
        'gr_hpi': {str(k): v for k, v in gr_perm_pvals.items()},
        'covid_bartik': {str(k): v for k, v in covid_perm_pvals.items()},
    },
    'event_study': {
        'gr': gr_event_results,
        'covid': covid_event_results,
    },
    'subsample': subsample_results,
}

with open(DATA_DIR / "lp_results.json", 'w') as f:
    json.dump(lp_results, f, indent=2, default=lambda x: None if (isinstance(x, float) and np.isnan(x)) else x)

print(f"\n✓ LP results saved to {DATA_DIR / 'lp_results.json'}")
