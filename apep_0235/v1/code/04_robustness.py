"""
04_robustness.py — Alternative shocks, subsamples, placebo tests, inference methods
"""

import os
import sys
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
analysis = import_module('03_main_analysis')
import numpy as np
import pandas as pd
import statsmodels.api as sm

DATA_DIR = pkg.DATA_DIR

# Load data
main_df = pd.read_csv(os.path.join(DATA_DIR, 'analysis_main.csv'), index_col='date', parse_dates=True)
lags_df = pd.read_csv(os.path.join(DATA_DIR, 'control_lags.csv'), index_col='date', parse_dates=True)
main_df = main_df.join(lags_df[[c for c in lags_df.columns if '_L' in c]], how='left')

controls = analysis.controls

robustness_results = {}

# ============================================================
# 1. SUBSAMPLE STABILITY
# ============================================================
print("=" * 60)
print("1. SUBSAMPLE STABILITY")
print("=" * 60)

subsamples = {
    'pre_gfc': ('1990-01-01', '2007-12-31'),
    'post_2001': ('2001-01-01', '2024-12-31'),
    'excl_zlb': None,  # Special handling
    'excl_covid': None,  # Special handling
}

for name, date_range in subsamples.items():
    print(f"\n  Subsample: {name}")

    if name == 'excl_zlb':
        # Exclude 2009-2015
        sub_df = main_df[(main_df.index < '2009-01-01') | (main_df.index > '2015-12-31')]
    elif name == 'excl_covid':
        # Exclude 2020-2021
        sub_df = main_df[(main_df.index < '2020-01-01') | (main_df.index > '2021-12-31')]
    else:
        sub_df = main_df.loc[date_range[0]:date_range[1]]

    print(f"    Observations: {len(sub_df)}")

    # Run aggregate LP
    res = analysis.run_lp(sub_df, 'fwd_PAYEMS', 'mp_shock', controls, pkg.LP_HORIZONS)
    robustness_results[f'subsample_{name}'] = res

    # Print key horizons
    for h_idx, h in enumerate([12, 24, 48]):
        if h in pkg.LP_HORIZONS:
            idx = pkg.LP_HORIZONS.index(h)
            b = res['beta'][idx]
            se = res['se'][idx]
            p = res['pval'][idx]
            if not np.isnan(b):
                print(f"    h={h}: beta={b:.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 2. ALTERNATIVE SHOCK MEASURES
# ============================================================
print("\n" + "=" * 60)
print("2. ALTERNATIVE SHOCK MEASURES")
print("=" * 60)

# 2a. Total JK shock (not decomposed)
jk_raw = pd.read_csv(os.path.join(DATA_DIR, 'jk_shocks_monthly.csv'))
date_col = jk_raw.columns[0]
shock_cols = [c for c in jk_raw.columns if c != date_col]

# Check if there's a total/raw shock column
if len(shock_cols) >= 2:
    # Use second column as alternative (typically 'cbi' or 'info')
    alt_col = shock_cols[1] if len(shock_cols) > 1 else shock_cols[0]
    print(f"  Alternative shock column: {alt_col}")

# 2b. Construct Bu-Rogers-Wu style shock (proxy: using raw FFR changes as crude alternative)
# Construct from FEDFUNDS changes around FOMC dates
print("\n  Constructing alternative shock: FEDFUNDS first difference (BRW-proxy)...")
main_df['ffr_change'] = main_df['FEDFUNDS'].diff()

# Create forward differences for this shock
for h in pkg.LP_HORIZONS:
    pass  # Forward differences are the same (they're on employment, not shock)

# Create lags for FFR change shock
for lag in range(1, 13):
    main_df[f'ffr_change_L{lag}'] = main_df['ffr_change'].shift(lag)

alt_controls = [f'ffr_change_L{lag}' for lag in range(1, 13) if f'ffr_change_L{lag}' in main_df.columns]
alt_controls += [c for c in controls if 'mp_shock' not in c]

res_alt = analysis.run_lp(main_df, 'fwd_PAYEMS', 'ffr_change', alt_controls, pkg.LP_HORIZONS)
robustness_results['alt_shock_ffr_change'] = res_alt

print("\n  FFR change shock results:")
for h_idx, h in enumerate(pkg.LP_HORIZONS):
    b = res_alt['beta'][h_idx]
    se = res_alt['se'][h_idx]
    p = res_alt['pval'][h_idx]
    if not np.isnan(b):
        print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 3. ADDITIONAL CONTROLS
# ============================================================
print("\n" + "=" * 60)
print("3. ADDITIONAL CONTROLS (OIL + VIX)")
print("=" * 60)

# Load macro data for oil and VIX
macro = pd.read_csv(os.path.join(DATA_DIR, 'macro_controls.csv'), index_col='date', parse_dates=True)
macro = macro.resample('MS').last()

if 'DCOILWTICO' in macro.columns:
    main_df['oil_change'] = macro['DCOILWTICO'].pct_change(1).reindex(main_df.index) * 100
    for lag in range(1, 5):
        main_df[f'oil_change_L{lag}'] = main_df['oil_change'].shift(lag)

if 'VIXCLS' in macro.columns:
    main_df['vix'] = macro['VIXCLS'].reindex(main_df.index)
    for lag in range(1, 5):
        main_df[f'vix_L{lag}'] = main_df['vix'].shift(lag)

extra_controls = controls.copy()
for var in ['oil_change', 'vix']:
    for lag in range(1, 5):
        col = f'{var}_L{lag}'
        if col in main_df.columns:
            extra_controls.append(col)

res_extra = analysis.run_lp(main_df, 'fwd_PAYEMS', 'mp_shock', extra_controls, pkg.LP_HORIZONS)
robustness_results['extra_controls'] = res_extra

print("  With oil + VIX controls:")
for h_idx, h in enumerate(pkg.LP_HORIZONS):
    b = res_extra['beta'][h_idx]
    se = res_extra['se'][h_idx]
    p = res_extra['pval'][h_idx]
    if not np.isnan(b):
        print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 4. EXCLUDING OUTLIER FOMC MEETINGS
# ============================================================
print("\n" + "=" * 60)
print("4. EXCLUDING OUTLIER SHOCKS (>2 SD)")
print("=" * 60)

shock_sd = main_df['mp_shock'].std()
shock_mean = main_df['mp_shock'].mean()
outlier_mask = (main_df['mp_shock'] - shock_mean).abs() <= 2 * shock_sd
trimmed_df = main_df[outlier_mask]
n_excluded = len(main_df) - len(trimmed_df)
print(f"  Excluded {n_excluded} months with |shock| > 2 SD ({shock_sd:.4f})")

res_trim = analysis.run_lp(trimmed_df, 'fwd_PAYEMS', 'mp_shock', controls, pkg.LP_HORIZONS)
robustness_results['excl_outliers'] = res_trim

print("  Trimmed sample results:")
for h_idx, h in enumerate(pkg.LP_HORIZONS):
    b = res_trim['beta'][h_idx]
    se = res_trim['se'][h_idx]
    p = res_trim['pval'][h_idx]
    if not np.isnan(b):
        print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# 5. PLACEBO TEST: PRE-FOMC EMPLOYMENT CHANGES
# ============================================================
print("\n" + "=" * 60)
print("5. PLACEBO: PRIOR EMPLOYMENT CHANGES")
print("=" * 60)

# If shocks are truly exogenous, they should NOT predict PAST employment changes
# Test: regress (y_{t-1} - y_{t-h-1}) on MP_t
placebo_horizons = [1, 3, 6, 12]
placebo_results = {'horizons': placebo_horizons, 'beta': [], 'se': [], 'pval': []}

for h in placebo_horizons:
    if 'log_PAYEMS' in main_df.columns:
        # Past change: y_{t-1} - y_{t-1-h}
        main_df[f'past_PAYEMS_h{h}'] = main_df['log_PAYEMS'].shift(1) - main_df['log_PAYEMS'].shift(1 + h)

        dep_var = f'past_PAYEMS_h{h}'
        all_vars = [dep_var, 'mp_shock']
        reg_df = main_df[all_vars].dropna()

        if len(reg_df) > 30:
            y = reg_df[dep_var]
            X = sm.add_constant(reg_df[['mp_shock']])
            model = sm.OLS(y, X).fit(cov_type='HAC', cov_kwds={'maxlags': int(1.5 * (h + 1))})
            placebo_results['beta'].append(model.params['mp_shock'])
            placebo_results['se'].append(model.bse['mp_shock'])
            placebo_results['pval'].append(model.pvalues['mp_shock'])
            print(f"  h={h}: beta={model.params['mp_shock']:.4f} (se={model.bse['mp_shock']:.4f}) p={model.pvalues['mp_shock']:.3f}")
        else:
            placebo_results['beta'].append(np.nan)
            placebo_results['se'].append(np.nan)
            placebo_results['pval'].append(np.nan)

robustness_results['placebo_pre_fomc'] = placebo_results

# ============================================================
# 6. ALTERNATIVE LAG STRUCTURE
# ============================================================
print("\n" + "=" * 60)
print("6. ALTERNATIVE LAG STRUCTURE (6 lags instead of 12)")
print("=" * 60)

short_controls = [c for c in controls if '_L' not in c or
                  (any(f'_L{i}' in c for i in range(1, 7)))]

res_short_lags = analysis.run_lp(main_df, 'fwd_PAYEMS', 'mp_shock', short_controls, pkg.LP_HORIZONS)
robustness_results['short_lags'] = res_short_lags

# ============================================================
# 7. AUGMENTED (RESIDUALIZED) SHOCK ROBUSTNESS
# ============================================================
print("\n" + "=" * 60)
print("7. AUGMENTED SHOCK (RESIDUALIZED ON MACRO LAGS)")
print("=" * 60)

# Regress JK shocks on 4 lags of employment growth, inflation, and IP growth
# Then use residuals as "cleaned" shocks and re-estimate aggregate LP

# Construct employment growth (log difference of PAYEMS * 100)
main_df['emp_growth'] = main_df['log_PAYEMS'].diff() * 100
for lag in range(1, 5):
    main_df[f'emp_growth_L{lag}'] = main_df['emp_growth'].shift(lag)

# Build the augmenting regressors: 4 lags of emp_growth, inflation, ip_growth
aug_regressors = []
for var in ['emp_growth', 'inflation', 'ip_growth']:
    for lag in range(1, 5):
        col = f'{var}_L{lag}'
        if col in main_df.columns:
            aug_regressors.append(col)

print(f"  Augmenting regressors: {len(aug_regressors)} variables")
print(f"  Variables: {aug_regressors}")

# Residualize the shock
aug_vars = ['mp_shock'] + aug_regressors
aug_df = main_df[aug_vars].dropna()
print(f"  Observations for first-stage regression: {len(aug_df)}")

y_shock = aug_df['mp_shock']
X_aug = sm.add_constant(aug_df[aug_regressors])
first_stage = sm.OLS(y_shock, X_aug).fit()
print(f"  First-stage R²: {first_stage.rsquared:.4f}")
print(f"  F-stat: {first_stage.fvalue:.2f} (p={first_stage.f_pvalue:.4f})")

# Store residuals back into main_df
main_df['mp_shock_clean'] = np.nan
main_df.loc[aug_df.index, 'mp_shock_clean'] = first_stage.resid

# Create lags of the cleaned shock for controls
for lag in range(1, 13):
    main_df[f'mp_shock_clean_L{lag}'] = main_df['mp_shock_clean'].shift(lag)

# Build controls for cleaned-shock LP (replace mp_shock lags with cleaned lags)
clean_controls = [f'mp_shock_clean_L{lag}' for lag in range(1, 13)
                  if f'mp_shock_clean_L{lag}' in main_df.columns]
clean_controls += [c for c in controls if 'mp_shock' not in c]

# Re-estimate aggregate LP with cleaned shocks
res_aug = analysis.run_lp(main_df, 'fwd_PAYEMS', 'mp_shock_clean', clean_controls, pkg.LP_HORIZONS)
robustness_results['augmented_shock'] = res_aug

print("\n  Augmented (residualized) shock results:")
for h_idx, h in enumerate(pkg.LP_HORIZONS):
    b = res_aug['beta'][h_idx]
    se = res_aug['se'][h_idx]
    p = res_aug['pval'][h_idx]
    if not np.isnan(b):
        print(f"    h={h:2d}: beta={b:8.4f} (se={se:.4f}) {pkg.stars(p)}")

# ============================================================
# Save robustness results
# ============================================================
print("\n" + "=" * 60)
print("SAVING ROBUSTNESS RESULTS")
print("=" * 60)

def to_serializable(obj):
    if isinstance(obj, (np.integer,)):
        return int(obj)
    elif isinstance(obj, (np.floating,)):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    return obj

def clean_results(d):
    return {k: [to_serializable(v) for v in vals] if isinstance(vals, list) else to_serializable(vals)
            for k, vals in d.items()}

rob_clean = {k: clean_results(v) for k, v in robustness_results.items()}

with open(os.path.join(DATA_DIR, 'robustness_results.json'), 'w') as f:
    json.dump(rob_clean, f, indent=2, default=to_serializable)

print("Robustness results saved to robustness_results.json")
print("\nRobustness analysis complete.")
