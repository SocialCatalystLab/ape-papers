"""
03_main_analysis.py — Local projections: aggregate + heterogeneous IRFs
                      (by industry, goods/services, cyclicality)
"""

import os
import sys
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
import pandas as pd
import statsmodels.api as sm

DATA_DIR = pkg.DATA_DIR

# ============================================================
# Load data
# ============================================================
print("Loading analysis data...")
main_df = pd.read_csv(os.path.join(DATA_DIR, 'analysis_main.csv'), index_col='date', parse_dates=True)
jolts_df = pd.read_csv(os.path.join(DATA_DIR, 'analysis_jolts.csv'), index_col='date', parse_dates=True)
lags_df = pd.read_csv(os.path.join(DATA_DIR, 'control_lags.csv'), index_col='date', parse_dates=True)

with open(os.path.join(DATA_DIR, 'classifications.json')) as f:
    classifications = json.load(f)

# Merge lags into main
main_df = main_df.join(lags_df[[c for c in lags_df.columns if '_L' in c]], how='left')

# ============================================================
# Local Projection Helper Functions
# ============================================================

def run_lp(df, dep_var_prefix, shock_var, controls, horizons, nw_bandwidth_fn=None):
    """
    Run local projection for a single outcome variable.

    Parameters
    ----------
    df : DataFrame with all variables
    dep_var_prefix : str, prefix for forward difference columns (e.g., 'fwd_PAYEMS')
    shock_var : str, column name of the shock variable
    controls : list of str, control variable column names
    horizons : list of int, LP horizons
    nw_bandwidth_fn : callable, function of h returning NW bandwidth (default: 1.5*(h+1))

    Returns
    -------
    dict with keys: 'beta', 'se', 'ci_lo', 'ci_hi', 'ci68_lo', 'ci68_hi', 'pval', 'nobs', 'r2'
    """
    if nw_bandwidth_fn is None:
        nw_bandwidth_fn = lambda h: int(1.5 * (h + 1))

    results = {
        'horizons': horizons,
        'beta': [],
        'se': [],
        'ci90_lo': [],
        'ci90_hi': [],
        'ci68_lo': [],
        'ci68_hi': [],
        'pval': [],
        'nobs': [],
        'r2': [],
    }

    for h in horizons:
        dep_var = f'{dep_var_prefix}_h{h}'
        if dep_var not in df.columns:
            results['beta'].append(np.nan)
            results['se'].append(np.nan)
            results['ci90_lo'].append(np.nan)
            results['ci90_hi'].append(np.nan)
            results['ci68_lo'].append(np.nan)
            results['ci68_hi'].append(np.nan)
            results['pval'].append(np.nan)
            results['nobs'].append(0)
            results['r2'].append(np.nan)
            continue

        # Build regression data
        all_vars = [dep_var, shock_var] + controls
        reg_df = df[all_vars].dropna()

        if len(reg_df) < 30:
            results['beta'].append(np.nan)
            results['se'].append(np.nan)
            results['ci90_lo'].append(np.nan)
            results['ci90_hi'].append(np.nan)
            results['ci68_lo'].append(np.nan)
            results['ci68_hi'].append(np.nan)
            results['pval'].append(np.nan)
            results['nobs'].append(len(reg_df))
            results['r2'].append(np.nan)
            continue

        y = reg_df[dep_var]
        X = sm.add_constant(reg_df[[shock_var] + controls])

        # Newey-West HAC
        bw = nw_bandwidth_fn(h)
        try:
            model = sm.OLS(y, X).fit(cov_type='HAC', cov_kwds={'maxlags': bw})

            beta = model.params[shock_var]
            se = model.bse[shock_var]
            pval = model.pvalues[shock_var]

            # 90% CI (z = 1.645)
            ci90_lo = beta - 1.645 * se
            ci90_hi = beta + 1.645 * se

            # 68% CI (z = 1.0) — standard in macro LP papers
            ci68_lo = beta - 1.0 * se
            ci68_hi = beta + 1.0 * se

            results['beta'].append(beta)
            results['se'].append(se)
            results['ci90_lo'].append(ci90_lo)
            results['ci90_hi'].append(ci90_hi)
            results['ci68_lo'].append(ci68_lo)
            results['ci68_hi'].append(ci68_hi)
            results['pval'].append(pval)
            results['nobs'].append(model.nobs)
            results['r2'].append(model.rsquared)
        except Exception as e:
            print(f"    Warning: LP at h={h} failed: {e}")
            results['beta'].append(np.nan)
            results['se'].append(np.nan)
            results['ci90_lo'].append(np.nan)
            results['ci90_hi'].append(np.nan)
            results['ci68_lo'].append(np.nan)
            results['ci68_hi'].append(np.nan)
            results['pval'].append(np.nan)
            results['nobs'].append(0)
            results['r2'].append(np.nan)

    return results


def run_interaction_lp(df, dep_var_prefix, shock_var, interaction_var, controls, horizons):
    """
    Run LP with interaction: y_{t+h} = a + b*shock + c*(shock*X) + d*X + controls + e
    Returns coefficients on shock (beta) and interaction (delta).
    """
    nw_bandwidth_fn = lambda h: int(1.5 * (h + 1))

    results = {
        'horizons': horizons,
        'beta': [], 'beta_se': [], 'beta_pval': [],
        'delta': [], 'delta_se': [], 'delta_pval': [],
        'nobs': [], 'r2': [],
    }

    # Create interaction
    df = df.copy()
    df['shock_x_interact'] = df[shock_var] * df[interaction_var]

    for h in horizons:
        dep_var = f'{dep_var_prefix}_h{h}'
        if dep_var not in df.columns:
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                results[key].append(np.nan)
            results['nobs'].append(0)
            results['r2'].append(np.nan)
            continue

        all_vars = [dep_var, shock_var, 'shock_x_interact', interaction_var] + controls
        reg_df = df[all_vars].dropna()

        if len(reg_df) < 30:
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                results[key].append(np.nan)
            results['nobs'].append(len(reg_df))
            results['r2'].append(np.nan)
            continue

        y = reg_df[dep_var]
        X = sm.add_constant(reg_df[[shock_var, 'shock_x_interact', interaction_var] + controls])

        bw = nw_bandwidth_fn(h)
        try:
            model = sm.OLS(y, X).fit(cov_type='HAC', cov_kwds={'maxlags': bw})
            results['beta'].append(model.params[shock_var])
            results['beta_se'].append(model.bse[shock_var])
            results['beta_pval'].append(model.pvalues[shock_var])
            results['delta'].append(model.params['shock_x_interact'])
            results['delta_se'].append(model.bse['shock_x_interact'])
            results['delta_pval'].append(model.pvalues['shock_x_interact'])
            results['nobs'].append(model.nobs)
            results['r2'].append(model.rsquared)
        except Exception as e:
            print(f"    Warning: Interaction LP at h={h} failed: {e}")
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                results[key].append(np.nan)
            results['nobs'].append(0)
            results['r2'].append(np.nan)

    return results


# ============================================================
# Build control variable list
# ============================================================
# 12 lags of shock + current and lagged controls
lag_controls = []
for lag in range(1, 13):
    lag_col = f'mp_shock_L{lag}'
    if lag_col in main_df.columns:
        lag_controls.append(lag_col)

macro_controls = []
for var in ['FEDFUNDS', 'UNRATE', 'inflation', 'ip_growth']:
    for lag in range(1, 5):
        lag_col = f'{var}_L{lag}'
        if lag_col in main_df.columns:
            macro_controls.append(lag_col)

controls = lag_controls + macro_controls
print(f"\nUsing {len(controls)} control variables ({len(lag_controls)} shock lags + {len(macro_controls)} macro lags)")

# ============================================================
# 1. AGGREGATE LOCAL PROJECTIONS
# ============================================================
print("\n" + "=" * 60)
print("1. AGGREGATE LOCAL PROJECTIONS")
print("=" * 60)

agg_results = {}
for series in ['PAYEMS']:
    name = pkg.CES_SERIES.get(series, series)
    print(f"\n  Running LP for {name}...")
    res = run_lp(main_df, f'fwd_{series}', 'mp_shock', controls, pkg.LP_HORIZONS)
    agg_results[series] = res

    # Print key horizons
    for h_idx, h in enumerate(pkg.LP_HORIZONS):
        b = res['beta'][h_idx]
        se = res['se'][h_idx]
        p = res['pval'][h_idx]
        if not np.isnan(b):
            print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) p={p:.3f} {pkg.stars(p)} N={int(res['nobs'][h_idx])}")

# ============================================================
# 1b. CUMULATIVE EFFECTS
# ============================================================
print("\n" + "-" * 40)
print("Cumulative Effects (sum of betas)")
print("-" * 40)

cumulative_results = {}

for series, res in agg_results.items():
    horizons = res['horizons']
    betas = res['beta']
    ses = res['se']

    cum = {}
    for max_h in [12, 24]:
        # Sum betas for h=0 through h=max_h
        indices = [i for i, h in enumerate(horizons) if h <= max_h]
        sel_betas = [betas[i] for i in indices]
        sel_ses = [ses[i] for i in indices]

        if all(not np.isnan(b) for b in sel_betas) and len(sel_betas) > 0:
            cum_beta = sum(sel_betas)
            # Cumulative SE: sqrt(sum of se^2) — conservative (assumes independence across horizons)
            cum_se = np.sqrt(sum(s**2 for s in sel_ses))
            cum_ci95_lo = cum_beta - 1.96 * cum_se
            cum_ci95_hi = cum_beta + 1.96 * cum_se
            cum_pval = 2 * (1 - __import__('scipy').stats.norm.cdf(abs(cum_beta / cum_se)))

            cum[f'h0_to_{max_h}'] = {
                'sum_beta': cum_beta,
                'se': cum_se,
                'ci95_lo': cum_ci95_lo,
                'ci95_hi': cum_ci95_hi,
                'pval': cum_pval,
                'n_horizons': len(sel_betas),
                'horizons_included': [horizons[i] for i in indices],
            }
            print(f"  {series} h=0-{max_h}: cumulative={cum_beta:.4f} (se={cum_se:.4f}) "
                  f"95% CI=[{cum_ci95_lo:.4f}, {cum_ci95_hi:.4f}] {pkg.stars(cum_pval)}")
        else:
            cum[f'h0_to_{max_h}'] = {
                'sum_beta': np.nan, 'se': np.nan,
                'ci95_lo': np.nan, 'ci95_hi': np.nan,
                'pval': np.nan, 'n_horizons': 0,
                'horizons_included': [],
            }

    cumulative_results[series] = cum

# ============================================================
# 2. INDUSTRY-LEVEL LOCAL PROJECTIONS
# ============================================================
print("\n" + "=" * 60)
print("2. INDUSTRY-LEVEL LOCAL PROJECTIONS")
print("=" * 60)

industry_results = {}
industry_codes = [c for c in pkg.CES_SERIES.keys()
                  if c not in ['PAYEMS', 'CES0500000001']
                  and f'fwd_{c}_h0' in main_df.columns]

for series in industry_codes:
    name = pkg.CES_SERIES.get(series, series)
    print(f"\n  Running LP for {name}...")
    res = run_lp(main_df, f'fwd_{series}', 'mp_shock', controls, pkg.LP_HORIZONS)
    industry_results[series] = res

    # Print peak response
    betas = [b for b in res['beta'] if not np.isnan(b)]
    if betas:
        peak_idx = np.argmin(betas)
        peak_h = res['horizons'][peak_idx]
        peak_b = res['beta'][peak_idx]
        peak_se = res['se'][peak_idx]
        peak_p = res['pval'][peak_idx]
        print(f"    Peak at h={peak_h}: beta={peak_b:.4f} (se={peak_se:.4f}) {pkg.stars(peak_p)}")

# ============================================================
# 3. GOODS VS SERVICES INTERACTION
# ============================================================
print("\n" + "=" * 60)
print("3. GOODS VS SERVICES INTERACTION")
print("=" * 60)

# Create panel dataset for interaction LP
panel_rows = []
for series in industry_codes:
    is_goods = 1 if series in pkg.GOODS_INDUSTRIES else 0
    for date, row in main_df.iterrows():
        panel_row = {
            'date': date,
            'industry': series,
            'is_goods': is_goods,
            'mp_shock': row['mp_shock'],
        }
        # Add forward differences
        for h in pkg.LP_HORIZONS:
            fwd_col = f'fwd_{series}_h{h}'
            if fwd_col in row.index:
                panel_row[f'fwd_h{h}'] = row[fwd_col]
        # Add controls
        for c in controls:
            if c in row.index:
                panel_row[c] = row[c]
        panel_rows.append(panel_row)

panel_df = pd.DataFrame(panel_rows)
panel_df['shock_x_goods'] = panel_df['mp_shock'] * panel_df['is_goods']

print(f"  Panel: {len(panel_df)} obs ({len(industry_codes)} industries x {main_df.shape[0]} months)")

# Run interaction LP on panel
goods_interact_results = {
    'horizons': pkg.LP_HORIZONS,
    'beta': [], 'beta_se': [], 'beta_pval': [],
    'delta': [], 'delta_se': [], 'delta_pval': [],
    'nobs': [],
}

for h in pkg.LP_HORIZONS:
    dep_var = f'fwd_h{h}'
    if dep_var not in panel_df.columns:
        for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
            goods_interact_results[key].append(np.nan)
        goods_interact_results['nobs'].append(0)
        continue

    all_vars = [dep_var, 'mp_shock', 'shock_x_goods', 'is_goods', 'industry'] + controls
    reg_df = panel_df[all_vars].dropna()

    if len(reg_df) < 50:
        for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
            goods_interact_results[key].append(np.nan)
        goods_interact_results['nobs'].append(len(reg_df))
        continue

    y = reg_df[dep_var]
    X = sm.add_constant(reg_df[['mp_shock', 'shock_x_goods', 'is_goods'] + controls])

    try:
        # Cluster-robust SEs by industry (proper panel inference)
        model = sm.OLS(y, X).fit(cov_type='cluster', cov_kwds={'groups': reg_df['industry']})
        goods_interact_results['beta'].append(model.params['mp_shock'])
        goods_interact_results['beta_se'].append(model.bse['mp_shock'])
        goods_interact_results['beta_pval'].append(model.pvalues['mp_shock'])
        goods_interact_results['delta'].append(model.params['shock_x_goods'])
        goods_interact_results['delta_se'].append(model.bse['shock_x_goods'])
        goods_interact_results['delta_pval'].append(model.pvalues['shock_x_goods'])
        goods_interact_results['nobs'].append(model.nobs)
    except Exception as e:
        print(f"    Warning at h={h}: {e}")
        for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
            goods_interact_results[key].append(np.nan)
        goods_interact_results['nobs'].append(0)

print("\n  Goods interaction results:")
for h_idx, h in enumerate(pkg.LP_HORIZONS):
    d = goods_interact_results['delta'][h_idx]
    se = goods_interact_results['delta_se'][h_idx]
    p = goods_interact_results['delta_pval'][h_idx]
    if not np.isnan(d):
        print(f"    h={h:2d}: delta_goods={d:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 4. JOLTS FLOW DECOMPOSITION
# ============================================================
print("\n" + "=" * 60)
print("4. JOLTS FLOW DECOMPOSITION")
print("=" * 60)

# Build JOLTS controls (use same lag structure but only from 2001+)
jolts_controls = []
for lag in range(1, 13):
    lag_col = f'mp_shock_L{lag}'
    if lag_col in jolts_df.columns:
        jolts_controls.append(lag_col)
for var in ['FEDFUNDS', 'UNRATE', 'inflation', 'ip_growth']:
    for lag in range(1, 5):
        lag_col = f'{var}_L{lag}'
        if lag_col in jolts_df.columns:
            jolts_controls.append(lag_col)

# Merge lags into JOLTS dataset
jolts_lags = pd.read_csv(os.path.join(DATA_DIR, 'control_lags.csv'), index_col='date', parse_dates=True)
jolts_df = jolts_df.join(jolts_lags[[c for c in jolts_lags.columns if '_L' in c]], how='left', rsuffix='_dup')
# Remove duplicate columns
jolts_df = jolts_df[[c for c in jolts_df.columns if not c.endswith('_dup')]]

jolts_results = {}
for flow_code, flow_name in pkg.JOLTS_FLOWS.items():
    col = f'total_{flow_code}'
    if col not in jolts_df.columns:
        continue

    print(f"\n  Running LP for Total {flow_name}...")

    # Construct log forward differences for this JOLTS series (x100 for percentage)
    log_col = f'log_{col}'
    if log_col not in jolts_df.columns:
        jolts_df[log_col] = np.log(jolts_df[col].clip(lower=0.1)) * 100
    for h in pkg.LP_HORIZONS:
        fwd_col = f'fwd_{col}_h{h}'
        if fwd_col not in jolts_df.columns:
            jolts_df[fwd_col] = jolts_df[log_col].shift(-h) - jolts_df[log_col].shift(1)

    res = run_lp(jolts_df, f'fwd_{col}', 'mp_shock', jolts_controls, pkg.LP_HORIZONS)
    jolts_results[flow_code] = res

    for h_idx, h in enumerate(pkg.LP_HORIZONS):
        b = res['beta'][h_idx]
        se = res['se'][h_idx]
        p = res['pval'][h_idx]
        if not np.isnan(b):
            print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 5. CYCLICALITY INTERACTION
# ============================================================
print("\n" + "=" * 60)
print("5. CYCLICALITY INTERACTION")
print("=" * 60)

# Add cyclicality beta to panel
cyc_betas = classifications.get('cyclicality', {})
panel_df['cyclicality'] = panel_df['industry'].map(cyc_betas)

# Standardize cyclicality for interaction
if panel_df['cyclicality'].notna().sum() > 0:
    cyc_mean = panel_df['cyclicality'].mean()
    cyc_std = panel_df['cyclicality'].std()
    if cyc_std > 0:
        panel_df['cyclicality_std'] = (panel_df['cyclicality'] - cyc_mean) / cyc_std
    else:
        panel_df['cyclicality_std'] = 0
    panel_df['shock_x_cyc'] = panel_df['mp_shock'] * panel_df['cyclicality_std']

    cyc_interact_results = {
        'horizons': pkg.LP_HORIZONS,
        'beta': [], 'beta_se': [], 'beta_pval': [],
        'delta': [], 'delta_se': [], 'delta_pval': [],
        'nobs': [],
    }

    for h in pkg.LP_HORIZONS:
        dep_var = f'fwd_h{h}'
        if dep_var not in panel_df.columns:
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                cyc_interact_results[key].append(np.nan)
            cyc_interact_results['nobs'].append(0)
            continue

        all_vars = [dep_var, 'mp_shock', 'shock_x_cyc', 'cyclicality_std', 'industry'] + controls
        reg_df = panel_df[all_vars].dropna()

        if len(reg_df) < 50:
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                cyc_interact_results[key].append(np.nan)
            cyc_interact_results['nobs'].append(len(reg_df))
            continue

        y = reg_df[dep_var]
        X = sm.add_constant(reg_df[['mp_shock', 'shock_x_cyc', 'cyclicality_std'] + controls])

        try:
            model = sm.OLS(y, X).fit(cov_type='cluster', cov_kwds={'groups': reg_df['industry']})
            cyc_interact_results['beta'].append(model.params['mp_shock'])
            cyc_interact_results['beta_se'].append(model.bse['mp_shock'])
            cyc_interact_results['beta_pval'].append(model.pvalues['mp_shock'])
            cyc_interact_results['delta'].append(model.params['shock_x_cyc'])
            cyc_interact_results['delta_se'].append(model.bse['shock_x_cyc'])
            cyc_interact_results['delta_pval'].append(model.pvalues['shock_x_cyc'])
            cyc_interact_results['nobs'].append(model.nobs)
        except Exception as e:
            for key in ['beta', 'beta_se', 'beta_pval', 'delta', 'delta_se', 'delta_pval']:
                cyc_interact_results[key].append(np.nan)
            cyc_interact_results['nobs'].append(0)

    print("\n  Cyclicality interaction results:")
    for h_idx, h in enumerate(pkg.LP_HORIZONS):
        d = cyc_interact_results['delta'][h_idx]
        se = cyc_interact_results['delta_se'][h_idx]
        p = cyc_interact_results['delta_pval'][h_idx]
        if not np.isnan(d):
            print(f"    h={h:2d}: delta_cyc={d:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# Save all results
# ============================================================
print("\n" + "=" * 60)
print("SAVING RESULTS")
print("=" * 60)

# Convert numpy types for JSON serialization
def to_serializable(obj):
    if isinstance(obj, (np.integer,)):
        return int(obj)
    elif isinstance(obj, (np.floating,)):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    return obj

def clean_results(results_dict):
    return {k: [to_serializable(v) for v in vals] if isinstance(vals, list) else to_serializable(vals)
            for k, vals in results_dict.items()}

all_results = {
    'aggregate': {k: clean_results(v) for k, v in agg_results.items()},
    'industry': {k: clean_results(v) for k, v in industry_results.items()},
    'goods_interaction': clean_results(goods_interact_results),
    'jolts': {k: clean_results(v) for k, v in jolts_results.items()},
    'cumulative': {k: {hk: clean_results(hv) for hk, hv in v.items()}
                   for k, v in cumulative_results.items()},
}

if 'cyc_interact_results' in dir():
    all_results['cyclicality_interaction'] = clean_results(cyc_interact_results)

with open(os.path.join(DATA_DIR, 'lp_results.json'), 'w') as f:
    json.dump(all_results, f, indent=2, default=to_serializable)

print("Results saved to lp_results.json")
print("\nMain analysis complete.")
