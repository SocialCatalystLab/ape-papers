"""
02_clean_data.py — Merge shocks + employment, construct forward differences for LP,
                   create industry classifications
"""

import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
import pandas as pd

DATA_DIR = pkg.DATA_DIR

# ============================================================
# 1. Load raw data
# ============================================================
print("Loading raw data...")

# JK shocks
jk = pd.read_csv(os.path.join(DATA_DIR, 'jk_shocks_monthly.csv'))
print(f"  JK shocks columns: {list(jk.columns)}")

# Parse JK date: file has separate 'year' and 'month' columns
if 'year' in jk.columns and 'month' in jk.columns:
    jk['date'] = pd.to_datetime(jk['year'].astype(str) + '-' + jk['month'].astype(str).str.zfill(2) + '-01')
else:
    date_col = jk.columns[0]
    if jk[date_col].dtype == 'int64' or jk[date_col].astype(str).str.len().median() == 6:
        jk['date'] = pd.to_datetime(jk[date_col].astype(str), format='%Y%m')
    else:
        jk['date'] = pd.to_datetime(jk[date_col])

# Identify shock columns
non_date_cols = [c for c in jk.columns if c not in ['year', 'month', 'date']]
print(f"  Shock columns: {non_date_cols}")

# Use MP_median as the primary monetary policy shock (Jarocinski-Karadi posterior median)
mp_col = None
for candidate in ['MP_median', 'MP_pm', 'mp', 'MP', 'mp_shock']:
    if candidate in non_date_cols:
        mp_col = candidate
        break
if mp_col is None:
    mp_col = non_date_cols[0]

print(f"  Using '{mp_col}' as monetary policy shock")

jk_clean = jk[['date', mp_col]].copy()
jk_clean.columns = ['date', 'mp_shock']
jk_clean = jk_clean.set_index('date').resample('MS').sum()  # Ensure monthly start frequency
jk_clean = jk_clean.sort_index()

# CES employment
ces = pd.read_csv(os.path.join(DATA_DIR, 'ces_employment.csv'), index_col='date', parse_dates=True)
ces = ces.resample('MS').last()  # Ensure monthly start frequency

# JOLTS
jolts = pd.read_csv(os.path.join(DATA_DIR, 'jolts_flows.csv'), index_col='date', parse_dates=True)
jolts = jolts.resample('MS').last()

# Macro
macro = pd.read_csv(os.path.join(DATA_DIR, 'macro_controls.csv'), index_col='date', parse_dates=True)

# ============================================================
# 2. Construct macro controls
# ============================================================
print("\nConstructing macro controls...")

# IMPORTANT: Resample to monthly FIRST (raw macro has daily data for VIX/oil)
macro_monthly = macro.resample('MS').last()

# CPI inflation (12-month percentage change, now on monthly data)
if 'CPIAUCSL' in macro_monthly.columns:
    macro_monthly['inflation'] = macro_monthly['CPIAUCSL'].pct_change(12) * 100

# Industrial production growth (12-month)
if 'INDPRO' in macro_monthly.columns:
    macro_monthly['ip_growth'] = macro_monthly['INDPRO'].pct_change(12) * 100

# GDP growth (quarterly → monthly via forward fill)
if 'GDPC1' in macro_monthly.columns:
    gdp_m = macro_monthly['GDPC1'].dropna()
    # For quarterly data resampled to monthly, compute 4-observation growth
    # But since GDPC1 is quarterly and was forward-filled, we need to handle carefully
    gdp_growth = gdp_m.pct_change(12) * 100  # 12-month change on monthly-resampled quarterly
    macro_monthly['gdp_growth'] = gdp_growth

# Oil price changes
if 'DCOILWTICO' in macro_monthly.columns:
    macro_monthly['oil_change'] = macro_monthly['DCOILWTICO'].pct_change(1) * 100

# Spread
if 'GS10' in macro_monthly.columns and 'FEDFUNDS' in macro_monthly.columns:
    macro_monthly['term_spread'] = macro_monthly['GS10'] - macro_monthly['FEDFUNDS']

controls = macro_monthly[['FEDFUNDS', 'UNRATE', 'inflation', 'ip_growth']].copy()
controls = controls.dropna()
print(f"  Controls: {controls.shape[0]} months, first: {controls.index[0]}, last: {controls.index[-1]}")

# ============================================================
# 3. Merge all datasets
# ============================================================
print("\nMerging datasets...")
print(f"  JK shape: {jk_clean.shape}, index type: {type(jk_clean.index).__name__}, first: {jk_clean.index[0] if len(jk_clean) > 0 else 'empty'}")
print(f"  CES shape: {ces.shape}, index type: {type(ces.index).__name__}, first: {ces.index[0] if len(ces) > 0 else 'empty'}")
print(f"  Controls shape: {controls.shape}, index type: {type(controls.index).__name__}, first: {controls.index[0] if len(controls) > 0 else 'empty'}")

# Main analysis dataset: shocks + employment + controls
step1 = jk_clean.join(ces, how='inner')
print(f"  After JK+CES join: {step1.shape}")
main_df = step1.join(controls, how='inner')
print(f"  After controls join: {main_df.shape}")

print(f"  Main dataset: {main_df.shape[0]} months, {main_df.shape[1]} columns")
print(f"  Date range: {main_df.index[0].strftime('%Y-%m')} to {main_df.index[-1].strftime('%Y-%m')}")

# JOLTS dataset: shocks + JOLTS flows + controls (starts 2001)
jolts_df = jk_clean.join(jolts, how='inner')
jolts_df = jolts_df.join(controls, how='inner')
jolts_df = jolts_df.loc['2001-01-01':]

print(f"  JOLTS dataset: {jolts_df.shape[0]} months, {jolts_df.shape[1]} columns")

# ============================================================
# 4. Construct log employment and forward differences
# ============================================================
print("\nConstructing log employment and forward differences...")

# Log employment for each CES series
industry_codes = [c for c in ces.columns if c in main_df.columns]
for col in industry_codes:
    main_df[f'log_{col}'] = np.log(main_df[col]) * 100  # Multiply by 100 for percentage interpretation

# Forward differences for LP: y_{t+h} - y_{t-1}
for h in pkg.LP_HORIZONS:
    for col in industry_codes:
        log_col = f'log_{col}'
        if log_col in main_df.columns:
            main_df[f'fwd_{col}_h{h}'] = main_df[log_col].shift(-h) - main_df[log_col].shift(1)

# JOLTS forward differences (levels, not logs — rates are already in levels)
jolts_flow_cols = [c for c in jolts.columns if c in jolts_df.columns]
for h in pkg.LP_HORIZONS:
    for col in jolts_flow_cols:
        jolts_df[f'fwd_{col}_h{h}'] = jolts_df[col].shift(-h) - jolts_df[col].shift(1)

# ============================================================
# 5. Construct industry classifications
# ============================================================
print("\nConstructing industry classifications...")

# Goods vs Services
industry_type = {}
for code in industry_codes:
    if code in ['PAYEMS', 'CES0500000001', 'USGOVT']:
        industry_type[code] = 'aggregate'
    elif code in pkg.GOODS_INDUSTRIES:
        industry_type[code] = 'goods'
    elif code in pkg.SERVICES_INDUSTRIES:
        industry_type[code] = 'services'
    else:
        industry_type[code] = 'other'

# Cyclical sensitivity (beta relative to GDP)
# Using pre-period 1990-2000 data
pre_period = main_df.loc['1990-01-01':'2000-12-31']
cyclicality = {}
if 'ip_growth' in pre_period.columns:
    ip_var = pre_period['ip_growth'].var()
    for col in industry_codes:
        if col in ['PAYEMS', 'CES0500000001']:
            continue
        emp_growth = pre_period[col].pct_change(12) * 100
        cov = emp_growth.cov(pre_period['ip_growth'])
        beta = cov / ip_var if ip_var > 0 else 0
        cyclicality[col] = beta

# Classify into terciles
if cyclicality:
    betas = pd.Series(cyclicality)
    terciles = pd.qcut(betas, 3, labels=['low', 'medium', 'high'])
    cyclicality_class = terciles.to_dict()
else:
    cyclicality_class = {}

# ============================================================
# 6. Save cleaned datasets
# ============================================================
print("\nSaving cleaned datasets...")

main_df.to_csv(os.path.join(DATA_DIR, 'analysis_main.csv'))
jolts_df.to_csv(os.path.join(DATA_DIR, 'analysis_jolts.csv'))

# Save classifications
classifications = {
    'industry_type': industry_type,
    'cyclicality': {k: float(v) for k, v in cyclicality.items()},
    'cyclicality_class': {k: str(v) for k, v in cyclicality_class.items()},
    'goods_industries': pkg.GOODS_INDUSTRIES,
    'services_industries': pkg.SERVICES_INDUSTRIES,
}

import json
with open(os.path.join(DATA_DIR, 'classifications.json'), 'w') as f:
    json.dump(classifications, f, indent=2)

# Save control variable lags for LP
# Create 12 lags of shock + controls
lags_df = main_df[['mp_shock', 'FEDFUNDS', 'UNRATE', 'inflation', 'ip_growth']].copy()
for lag in range(1, 13):
    for col in ['mp_shock', 'FEDFUNDS', 'UNRATE', 'inflation', 'ip_growth']:
        lags_df[f'{col}_L{lag}'] = lags_df[col].shift(lag)
lags_df.to_csv(os.path.join(DATA_DIR, 'control_lags.csv'))

print(f"\nFiles saved to {DATA_DIR}:")
for f in sorted(os.listdir(DATA_DIR)):
    size = os.path.getsize(os.path.join(DATA_DIR, f)) / 1024
    print(f"  {f}: {size:.1f} KB")

# Print summary statistics
print("\n" + "=" * 60)
print("SUMMARY STATISTICS")
print("=" * 60)
print(f"\nMonetary Policy Shock:")
print(f"  Mean: {main_df['mp_shock'].mean():.4f}")
print(f"  Std:  {main_df['mp_shock'].std():.4f}")
print(f"  Min:  {main_df['mp_shock'].min():.4f}")
print(f"  Max:  {main_df['mp_shock'].max():.4f}")
print(f"  N:    {main_df['mp_shock'].notna().sum()}")

print(f"\nEmployment (Total Nonfarm, thousands):")
if 'PAYEMS' in main_df.columns:
    print(f"  Mean: {main_df['PAYEMS'].mean():.0f}")
    print(f"  Std:  {main_df['PAYEMS'].std():.0f}")
    print(f"  Min:  {main_df['PAYEMS'].min():.0f}")
    print(f"  Max:  {main_df['PAYEMS'].max():.0f}")

print(f"\nIndustry type counts:")
for itype in ['goods', 'services', 'aggregate']:
    count = sum(1 for v in industry_type.values() if v == itype)
    print(f"  {itype}: {count}")

print(f"\nCyclicality classifications:")
for cclass in ['low', 'medium', 'high']:
    members = [k for k, v in cyclicality_class.items() if v == cclass]
    names = [pkg.CES_SERIES.get(m, m) for m in members]
    print(f"  {cclass}: {', '.join(names)}")

print("\nData cleaning complete.")
