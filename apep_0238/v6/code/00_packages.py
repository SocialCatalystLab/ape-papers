"""
00_packages.py — Imports, constants, and utility functions for apep_0238
"Demand Recessions Scar, Supply Recessions Don't"
"""

import os, sys, json, time, warnings
import urllib.request
from pathlib import Path
from datetime import datetime
from collections import defaultdict

import numpy as np
import pandas as pd
from scipy import stats, optimize
from scipy.linalg import solve_discrete_lyapunov

warnings.filterwarnings('ignore', category=FutureWarning)

# ── Paths ──
ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "data"
FIG_DIR = ROOT / "figures"
TAB_DIR = ROOT / "tables"
for d in [DATA_DIR, FIG_DIR, TAB_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# ── API keys ──
FRED_KEY = os.environ.get("FRED_API_KEY", "")
BEA_KEY = os.environ.get("BEA_API_KEY", "")

# ── State mappings ──
STATE_FIPS = {
    'AL':'01','AK':'02','AZ':'04','AR':'05','CA':'06','CO':'08','CT':'09',
    'DE':'10','FL':'12','GA':'13','HI':'15','ID':'16','IL':'17','IN':'18',
    'IA':'19','KS':'20','KY':'21','LA':'22','ME':'23','MD':'24','MA':'25',
    'MI':'26','MN':'27','MS':'28','MO':'29','MT':'30','NE':'31','NV':'32',
    'NH':'33','NJ':'34','NM':'35','NY':'36','NC':'37','ND':'38','OH':'39',
    'OK':'40','OR':'41','PA':'42','RI':'44','SC':'45','SD':'46','TN':'47',
    'TX':'48','UT':'49','VT':'50','VA':'51','WA':'53','WV':'54','WI':'55',
    'WY':'56'
}
FIPS_STATE = {v: k for k, v in STATE_FIPS.items()}

STATE_NAMES = {
    'AL':'Alabama','AK':'Alaska','AZ':'Arizona','AR':'Arkansas','CA':'California',
    'CO':'Colorado','CT':'Connecticut','DE':'Delaware','FL':'Florida','GA':'Georgia',
    'HI':'Hawaii','ID':'Idaho','IL':'Illinois','IN':'Indiana','IA':'Iowa',
    'KS':'Kansas','KY':'Kentucky','LA':'Louisiana','ME':'Maine','MD':'Maryland',
    'MA':'Massachusetts','MI':'Michigan','MN':'Minnesota','MS':'Mississippi',
    'MO':'Missouri','MT':'Montana','NE':'Nebraska','NV':'Nevada','NH':'New Hampshire',
    'NJ':'New Jersey','NM':'New Mexico','NY':'New York','NC':'North Carolina',
    'ND':'North Dakota','OH':'Ohio','OK':'Oklahoma','OR':'Oregon','PA':'Pennsylvania',
    'RI':'Rhode Island','SC':'South Carolina','SD':'South Dakota','TN':'Tennessee',
    'TX':'Texas','UT':'Utah','VT':'Vermont','VA':'Virginia','WA':'Washington',
    'WV':'West Virginia','WI':'Wisconsin','WY':'Wyoming'
}

# ── Recession dates ──
GR_PEAK = "2007-12-01"
GR_TROUGH = "2009-06-01"
COVID_PEAK = "2020-02-01"
COVID_TROUGH = "2020-04-01"

# ── FRED helper ──
def fred_fetch(series_id, start="2000-01-01", end="2024-12-31"):
    """Fetch a FRED series. Returns list of (date_str, float_value) or None on failure."""
    url = (f"https://api.stlouisfed.org/fred/series/observations?"
           f"series_id={series_id}&api_key={FRED_KEY}&file_type=json"
           f"&observation_start={start}&observation_end={end}")
    try:
        with urllib.request.urlopen(url, timeout=20) as resp:
            data = json.loads(resp.read())
        obs = [(o['date'], float(o['value'])) for o in data['observations'] if o['value'] != '.']
        return obs if obs else None
    except Exception:
        return None

def fred_to_series(series_id, start="2000-01-01", end="2024-12-31"):
    """Fetch FRED series as pandas Series with DatetimeIndex."""
    obs = fred_fetch(series_id, start, end)
    if obs is None:
        return None
    dates, vals = zip(*obs)
    return pd.Series(vals, index=pd.to_datetime(dates), name=series_id)

# ── BEA helper ──
def bea_fetch(table_name, line_code, geo_fips="STATE", year="ALL"):
    """Fetch BEA Regional data."""
    url = (f"https://apps.bea.gov/api/data/?UserID={BEA_KEY}&method=GetData"
           f"&datasetname=Regional&TableName={table_name}&LineCode={line_code}"
           f"&GeoFips={geo_fips}&Year={year}&ResultFormat=JSON")
    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            data = json.loads(resp.read())
        return data.get('BEAAPI', {}).get('Results', {}).get('Data', [])
    except Exception:
        return None

print("✓ Packages loaded. FRED key:", "present" if FRED_KEY else "MISSING")
print(f"  Data dir: {DATA_DIR}")
