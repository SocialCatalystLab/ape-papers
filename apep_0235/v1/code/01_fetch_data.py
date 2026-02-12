"""
01_fetch_data.py — Fetch all data: JK shocks (GitHub CSV), FRED CES/JOLTS/macro (fredapi)
"""

import os
import sys
import urllib.request
import json
import time

# Add parent to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
import pandas as pd
from fredapi import Fred

DATA_DIR = pkg.DATA_DIR
FRED_API_KEY = pkg.FRED_API_KEY

# ============================================================
# 1. Jarocinski-Karadi Monetary Policy Shocks
# ============================================================
print("=" * 60)
print("Fetching Jarocinski-Karadi monetary policy shocks...")
print("=" * 60)

JK_URL = "https://raw.githubusercontent.com/marekjarocinski/jkshocks_update_fed_202401/main/shocks_fed_jk_m.csv"

try:
    jk_path = os.path.join(DATA_DIR, 'jk_shocks_monthly.csv')
    urllib.request.urlretrieve(JK_URL, jk_path)
    jk = pd.read_csv(jk_path)
    print(f"  JK shocks downloaded: {len(jk)} rows")
    print(f"  Columns: {list(jk.columns)}")
    print(f"  Date range: {jk.iloc[0, 0]} to {jk.iloc[-1, 0]}")
except Exception as e:
    print(f"  WARNING: JK GitHub download failed ({e}). Trying alternative...")
    # Create from known data if download fails
    raise SystemExit(f"Cannot proceed without monetary policy shocks: {e}")

# ============================================================
# 2. FRED CES Employment Data
# ============================================================
print("\n" + "=" * 60)
print("Fetching FRED CES employment data...")
print("=" * 60)

fred = Fred(api_key=FRED_API_KEY)

ces_data = {}
for series_id, name in pkg.CES_SERIES.items():
    try:
        s = fred.get_series(series_id, observation_start='1990-01-01', observation_end='2024-12-31')
        ces_data[series_id] = s
        print(f"  {series_id} ({name}): {len(s)} obs, {s.index[0].strftime('%Y-%m')} to {s.index[-1].strftime('%Y-%m')}")
    except Exception as e:
        print(f"  WARNING: Failed to fetch {series_id}: {e}")

# Save CES data
ces_df = pd.DataFrame(ces_data)
ces_df.index.name = 'date'
ces_df.to_csv(os.path.join(DATA_DIR, 'ces_employment.csv'))
print(f"\nCES employment saved: {ces_df.shape[0]} months x {ces_df.shape[1]} series")

# ============================================================
# 3. FRED JOLTS Data
# ============================================================
print("\n" + "=" * 60)
print("Fetching FRED JOLTS data...")
print("=" * 60)

jolts_data = {}

# JOLTS series use format: JTS{industry_code}{flow_suffix}
# Total nonfarm uses short codes: JTSJOL, JTSHIL, JTSTSL, JTSQUL, JTSLDR
# Industry-level uses: JTS{4-digit}{flow_suffix}
JOLTS_SERIES_MAP = {
    # Total nonfarm
    ('total', 'JOL'): 'JTSJOL',
    ('total', 'HIL'): 'JTSHIL',
    ('total', 'TSL'): 'JTSTSL',
    ('total', 'QUL'): 'JTSQUL',
    ('total', 'LDR'): 'JTSLDR',
    # By industry (4-digit codes)
    ('1000', 'JOL'): 'JTS1000JOL', ('1000', 'HIL'): 'JTS1000HIL', ('1000', 'TSL'): 'JTS1000TSL', ('1000', 'QUL'): 'JTS1000QUL', ('1000', 'LDR'): 'JTS1000LDR',
    ('2000', 'JOL'): 'JTS2000JOL', ('2000', 'HIL'): 'JTS2000HIL', ('2000', 'TSL'): 'JTS2000TSL', ('2000', 'QUL'): 'JTS2000QUL', ('2000', 'LDR'): 'JTS2000LDR',
    ('3000', 'JOL'): 'JTS3000JOL', ('3000', 'HIL'): 'JTS3000HIL', ('3000', 'TSL'): 'JTS3000TSL', ('3000', 'QUL'): 'JTS3000QUL', ('3000', 'LDR'): 'JTS3000LDR',
    ('4000', 'JOL'): 'JTS4000JOL', ('4000', 'HIL'): 'JTS4000HIL', ('4000', 'TSL'): 'JTS4000TSL', ('4000', 'QUL'): 'JTS4000QUL', ('4000', 'LDR'): 'JTS4000LDR',
    ('5100', 'JOL'): 'JTS5100JOL', ('5100', 'HIL'): 'JTS5100HIL', ('5100', 'TSL'): 'JTS5100TSL', ('5100', 'QUL'): 'JTS5100QUL', ('5100', 'LDR'): 'JTS5100LDR',
    ('5200', 'JOL'): 'JTS5200JOL', ('5200', 'HIL'): 'JTS5200HIL', ('5200', 'TSL'): 'JTS5200TSL', ('5200', 'QUL'): 'JTS5200QUL', ('5200', 'LDR'): 'JTS5200LDR',
    ('5400', 'JOL'): 'JTS5400JOL', ('5400', 'HIL'): 'JTS5400HIL', ('5400', 'TSL'): 'JTS5400TSL', ('5400', 'QUL'): 'JTS5400QUL', ('5400', 'LDR'): 'JTS5400LDR',
    ('6000', 'JOL'): 'JTS6000JOL', ('6000', 'HIL'): 'JTS6000HIL', ('6000', 'TSL'): 'JTS6000TSL', ('6000', 'QUL'): 'JTS6000QUL', ('6000', 'LDR'): 'JTS6000LDR',
    ('7000', 'JOL'): 'JTS7000JOL', ('7000', 'HIL'): 'JTS7000HIL', ('7000', 'TSL'): 'JTS7000TSL', ('7000', 'QUL'): 'JTS7000QUL', ('7000', 'LDR'): 'JTS7000LDR',
    ('9000', 'JOL'): 'JTS9000JOL', ('9000', 'HIL'): 'JTS9000HIL', ('9000', 'TSL'): 'JTS9000TSL', ('9000', 'QUL'): 'JTS9000QUL', ('9000', 'LDR'): 'JTS9000LDR',
}

# Map flow suffixes to readable names
JOLTS_FLOW_NAMES = {'JOL': 'Job Openings', 'HIL': 'Hires', 'TSL': 'Total Separations', 'QUL': 'Quits', 'LDR': 'Layoffs & Discharges'}

for (ind_code, flow_code), series_id in JOLTS_SERIES_MAP.items():
    try:
        s = fred.get_series(series_id, observation_start='2001-01-01', observation_end='2024-12-31')
        col_name = f"{ind_code}_{flow_code}"
        jolts_data[col_name] = s
        if ind_code == 'total':
            print(f"  {series_id} ({JOLTS_FLOW_NAMES[flow_code]}, Total): {len(s)} obs")
    except Exception as e:
        pass

jolts_df = pd.DataFrame(jolts_data)
jolts_df.index.name = 'date'
jolts_df.to_csv(os.path.join(DATA_DIR, 'jolts_flows.csv'))
print(f"\nJOLTS flows saved: {jolts_df.shape[0]} months x {jolts_df.shape[1]} series")

# ============================================================
# 4. FRED Macro Controls
# ============================================================
print("\n" + "=" * 60)
print("Fetching FRED macro control variables...")
print("=" * 60)

macro_series = {
    'FEDFUNDS': 'Federal Funds Rate',
    'GS10': '10-Year Treasury',
    'CPIAUCSL': 'CPI (All Urban)',
    'UNRATE': 'Unemployment Rate',
    'INDPRO': 'Industrial Production',
    'GDPC1': 'Real GDP',
    'VIXCLS': 'VIX',
    'DCOILWTICO': 'WTI Crude Oil',
}

macro_data = {}
for series_id, name in macro_series.items():
    try:
        s = fred.get_series(series_id, observation_start='1990-01-01', observation_end='2024-12-31')
        macro_data[series_id] = s
        freq = 'Q' if series_id == 'GDPC1' else 'M'
        print(f"  {series_id} ({name}): {len(s)} obs [{freq}]")
    except Exception as e:
        print(f"  WARNING: Failed to fetch {series_id}: {e}")

macro_df = pd.DataFrame(macro_data)
macro_df.index.name = 'date'
macro_df.to_csv(os.path.join(DATA_DIR, 'macro_controls.csv'))
print(f"\nMacro controls saved: {macro_df.shape[0]} rows x {macro_df.shape[1]} series")

# ============================================================
# Summary
# ============================================================
print("\n" + "=" * 60)
print("DATA FETCH COMPLETE")
print("=" * 60)
files = os.listdir(DATA_DIR)
for f in sorted(files):
    fpath = os.path.join(DATA_DIR, f)
    size_kb = os.path.getsize(fpath) / 1024
    print(f"  {f}: {size_kb:.1f} KB")
print(f"\nTotal files: {len(files)}")
