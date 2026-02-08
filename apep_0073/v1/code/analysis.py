#!/usr/bin/env python3
"""
APEP Paper 93: SNAP Work Requirements and Employment
Main analysis script (Python version)
"""

import json
import urllib.request
import pandas as pd
import numpy as np
from collections import defaultdict
import warnings
warnings.filterwarnings('ignore')

# ==============================================================================
# 1. ABAWD Waiver Status Data
# ==============================================================================

print("=" * 60)
print("APEP Paper 93: SNAP Work Requirements and Employment")
print("=" * 60)

# Waiver status: 1 = waiver in effect (no work requirement), 0 = work requirement active
# Based on USDA FNS data
waiver_data = {
    '01': {'name': 'Alabama', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '02': {'name': 'Alaska', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 0, 2019: 1},
    '04': {'name': 'Arizona', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '05': {'name': 'Arkansas', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '06': {'name': 'California', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '08': {'name': 'Colorado', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '09': {'name': 'Connecticut', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '10': {'name': 'Delaware', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '11': {'name': 'DC', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 0, 2019: 1},
    '12': {'name': 'Florida', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '13': {'name': 'Georgia', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '15': {'name': 'Hawaii', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 0, 2018: 1, 2019: 1},
    '16': {'name': 'Idaho', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '17': {'name': 'Illinois', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '18': {'name': 'Indiana', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '19': {'name': 'Iowa', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '20': {'name': 'Kansas', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '21': {'name': 'Kentucky', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '22': {'name': 'Louisiana', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '23': {'name': 'Maine', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 1},
    '24': {'name': 'Maryland', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '25': {'name': 'Massachusetts', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '26': {'name': 'Michigan', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '27': {'name': 'Minnesota', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '28': {'name': 'Mississippi', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '29': {'name': 'Missouri', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '30': {'name': 'Montana', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '31': {'name': 'Nebraska', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '32': {'name': 'Nevada', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 1, 2019: 0},
    '33': {'name': 'New Hampshire', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '34': {'name': 'New Jersey', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '35': {'name': 'New Mexico', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '36': {'name': 'New York', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '37': {'name': 'North Carolina', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '38': {'name': 'North Dakota', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '39': {'name': 'Ohio', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '40': {'name': 'Oklahoma', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '41': {'name': 'Oregon', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '42': {'name': 'Pennsylvania', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '44': {'name': 'Rhode Island', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '45': {'name': 'South Carolina', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 0, 2018: 0, 2019: 0},
    '46': {'name': 'South Dakota', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '47': {'name': 'Tennessee', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '48': {'name': 'Texas', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '49': {'name': 'Utah', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '50': {'name': 'Vermont', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '51': {'name': 'Virginia', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 1, 2017: 1, 2018: 1, 2019: 1},  # Never treated
    '53': {'name': 'Washington', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '54': {'name': 'West Virginia', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 1, 2017: 1, 2018: 1, 2019: 1},
    '55': {'name': 'Wisconsin', 2012: 1, 2013: 1, 2014: 1, 2015: 1, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
    '56': {'name': 'Wyoming', 2012: 1, 2013: 1, 2014: 1, 2015: 0, 2016: 0, 2017: 0, 2018: 0, 2019: 0},
}

# Identify first treatment year (when work requirements came into effect)
first_treat = {}
for st, data in waiver_data.items():
    first_year = None
    for year in range(2012, 2020):
        if data.get(year) == 0:  # Work requirement active
            first_year = year
            break
    first_treat[st] = first_year if first_year else 0  # 0 means never treated

print("\nFirst treatment year by state:")
never_treated_states = [st for st, yr in first_treat.items() if yr == 0]
print(f"Never-treated states: {len(never_treated_states)}")
print(f"Treated states: {len([st for st, yr in first_treat.items() if yr > 0])}")

# ==============================================================================
# 2. Fetch ACS PUMS Data
# ==============================================================================

print("\n" + "=" * 60)
print("Fetching ACS PUMS Data from Census API")
print("=" * 60)

def fetch_pums_year(year):
    """Fetch ACS PUMS data for a single year."""
    url = f"https://api.census.gov/data/{year}/acs/acs1/pums?get=AGEP,ESR,FS,PWGTP,ST,SEX,RAC1P,SCHL,DIS&for=state:*"
    
    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            data = json.load(response)
        
        # Convert to DataFrame
        df = pd.DataFrame(data[1:], columns=data[0])
        
        # Convert types
        for col in ['AGEP', 'ESR', 'FS', 'PWGTP', 'SEX', 'RAC1P', 'SCHL', 'DIS']:
            df[col] = pd.to_numeric(df[col], errors='coerce')
        
        df['ST'] = df['ST'].astype(str).str.zfill(2)
        df['year'] = year
        
        print(f"  Year {year}: {len(df):,} records")
        return df
    
    except Exception as e:
        print(f"  Year {year}: ERROR - {e}")
        return None

# Fetch data for 2012-2019
print("\nFetching data...")
dfs = []
for year in range(2012, 2020):
    df = fetch_pums_year(year)
    if df is not None:
        dfs.append(df)

pums_raw = pd.concat(dfs, ignore_index=True)
print(f"\nTotal records: {len(pums_raw):,}")

# ==============================================================================
# 3. Clean Data and Construct Variables
# ==============================================================================

print("\n" + "=" * 60)
print("Cleaning Data")
print("=" * 60)

# Filter to ABAWD-eligible (18-49, no disability)
pums = pums_raw[
    (pums_raw['AGEP'] >= 18) & 
    (pums_raw['AGEP'] <= 49) &
    (pums_raw['DIS'] != 1)  # No disability
].copy()

print(f"ABAWD-eligible sample: {len(pums):,} records")

# Construct variables
# Employment: ESR 1,2 = employed; 3 = unemployed; 6 = not in labor force
pums['employed'] = pums['ESR'].isin([1, 2]).astype(int)
pums['in_labor_force'] = pums['ESR'].isin([1, 2, 3]).astype(int)

# SNAP receipt
pums['snap'] = (pums['FS'] == 1).astype(int)

# Demographics
pums['female'] = (pums['SEX'] == 2).astype(int)
pums['white'] = (pums['RAC1P'] == 1).astype(int)
pums['black'] = (pums['RAC1P'] == 2).astype(int)
pums['less_than_hs'] = (pums['SCHL'] <= 15).astype(int)

# Add treatment variables
pums['first_treat'] = pums['ST'].map(first_treat)
pums['treated'] = ((pums['first_treat'] > 0) & (pums['year'] >= pums['first_treat'])).astype(int)
pums['event_time'] = np.where(pums['first_treat'] > 0, pums['year'] - pums['first_treat'], np.nan)

# Add waiver status
def get_waiver(row):
    st = row['ST']
    yr = row['year']
    if st in waiver_data:
        return waiver_data[st].get(yr, np.nan)
    return np.nan

pums['waiver'] = pums.apply(get_waiver, axis=1)
pums['work_req'] = 1 - pums['waiver']

print(f"Treatment rate: {pums['treated'].mean():.3f}")

# Save cleaned data
pums.to_csv('../data/pums_clean.csv', index=False)
print("Saved: ../data/pums_clean.csv")

# ==============================================================================
# 4. Create State-Year Aggregates
# ==============================================================================

print("\n" + "=" * 60)
print("Creating State-Year Aggregates")
print("=" * 60)

# Aggregate to state-year level
state_year = pums.groupby(['ST', 'year']).apply(
    lambda x: pd.Series({
        'employed': np.average(x['employed'], weights=x['PWGTP']),
        'in_lf': np.average(x['in_labor_force'], weights=x['PWGTP']),
        'snap': np.average(x['snap'], weights=x['PWGTP']),
        'pop': x['PWGTP'].sum(),
        'n_obs': len(x),
        'first_treat': x['first_treat'].iloc[0],
        'treated': x['treated'].iloc[0],
        'work_req': x['work_req'].iloc[0] if 'work_req' in x.columns else np.nan,
    })
).reset_index()

print(f"State-year observations: {len(state_year)}")

# Save state-year data
state_year.to_csv('../data/state_year.csv', index=False)
print("Saved: ../data/state_year.csv")

# ==============================================================================
# 5. DiD Estimation
# ==============================================================================

print("\n" + "=" * 60)
print("DiD Estimation")
print("=" * 60)

# Simple 2x2 DiD comparison
# Pre: 2012-2014, Post: 2016-2019
# Treated: states that reinstated work requirements by 2015
# Control: never-treated states

# Define treated cohort (early adopters - reinstated in 2015)
early_treated = [st for st, yr in first_treat.items() if yr == 2015]
never_treated = [st for st, yr in first_treat.items() if yr == 0]

print(f"\nEarly treated states (2015): {len(early_treated)}")
print(f"Never treated states: {len(never_treated)}")

# Simple DiD
pre_years = [2012, 2013, 2014]
post_years = [2016, 2017, 2018, 2019]

# Treatment group means
treat_pre = state_year[
    (state_year['ST'].isin(early_treated)) & 
    (state_year['year'].isin(pre_years))
]['employed'].mean()

treat_post = state_year[
    (state_year['ST'].isin(early_treated)) & 
    (state_year['year'].isin(post_years))
]['employed'].mean()

# Control group means
ctrl_pre = state_year[
    (state_year['ST'].isin(never_treated)) & 
    (state_year['year'].isin(pre_years))
]['employed'].mean()

ctrl_post = state_year[
    (state_year['ST'].isin(never_treated)) & 
    (state_year['year'].isin(post_years))
]['employed'].mean()

# DiD estimate
did_estimate = (treat_post - treat_pre) - (ctrl_post - ctrl_pre)

print(f"\n--- Simple 2x2 DiD (Early Treated vs Never Treated) ---")
print(f"Treatment group pre:  {treat_pre:.4f}")
print(f"Treatment group post: {treat_post:.4f}")
print(f"Control group pre:    {ctrl_pre:.4f}")
print(f"Control group post:   {ctrl_post:.4f}")
print(f"\nDiD Estimate: {did_estimate:.4f} ({did_estimate*100:.2f} pp)")

# ==============================================================================
# 6. Event Study (Simple Version)
# ==============================================================================

print("\n" + "=" * 60)
print("Event Study")
print("=" * 60)

# For states treated in 2015, compute employment relative to treatment
event_study_data = state_year[state_year['ST'].isin(early_treated)].copy()
event_study_data['event_time'] = event_study_data['year'] - 2015

# Control mean by year
control_means = state_year[state_year['ST'].isin(never_treated)].groupby('year')['employed'].mean()

# Compute event study coefficients (treatment - control difference by event time)
es_results = []
for et in range(-3, 5):
    year = 2015 + et
    if year in event_study_data['year'].values:
        treat_mean = event_study_data[event_study_data['year'] == year]['employed'].mean()
        ctrl_mean = control_means.get(year, np.nan)
        diff = treat_mean - ctrl_mean
        es_results.append({'event_time': et, 'diff': diff, 'treat': treat_mean, 'control': ctrl_mean})

es_df = pd.DataFrame(es_results)
print("\nEvent Study Coefficients (Treatment - Control):")
print(es_df.to_string(index=False))

# ==============================================================================
# 7. SNAP Receipt Analysis
# ==============================================================================

print("\n" + "=" * 60)
print("SNAP Receipt Analysis")
print("=" * 60)

# SNAP receipt DiD
snap_treat_pre = state_year[
    (state_year['ST'].isin(early_treated)) & 
    (state_year['year'].isin(pre_years))
]['snap'].mean()

snap_treat_post = state_year[
    (state_year['ST'].isin(early_treated)) & 
    (state_year['year'].isin(post_years))
]['snap'].mean()

snap_ctrl_pre = state_year[
    (state_year['ST'].isin(never_treated)) & 
    (state_year['year'].isin(pre_years))
]['snap'].mean()

snap_ctrl_post = state_year[
    (state_year['ST'].isin(never_treated)) & 
    (state_year['year'].isin(post_years))
]['snap'].mean()

snap_did = (snap_treat_post - snap_treat_pre) - (snap_ctrl_post - snap_ctrl_pre)

print(f"\n--- SNAP Receipt DiD ---")
print(f"Treatment group pre:  {snap_treat_pre:.4f}")
print(f"Treatment group post: {snap_treat_post:.4f}")
print(f"Control group pre:    {snap_ctrl_pre:.4f}")
print(f"Control group post:   {snap_ctrl_post:.4f}")
print(f"\nDiD Estimate: {snap_did:.4f} ({snap_did*100:.2f} pp)")

# ==============================================================================
# 8. Placebo Test: Ages 50-64 (Exempt from ABAWD)
# ==============================================================================

print("\n" + "=" * 60)
print("Placebo Test: Ages 50-64 (Exempt Population)")
print("=" * 60)

# Filter to exempt age group
pums_exempt = pums_raw[
    (pums_raw['AGEP'] >= 50) & 
    (pums_raw['AGEP'] <= 64) &
    (pums_raw['DIS'] != 1)
].copy()

pums_exempt['employed'] = pums_exempt['ESR'].isin([1, 2]).astype(int)
pums_exempt['first_treat'] = pums_exempt['ST'].map(first_treat)

# Aggregate
exempt_sy = pums_exempt.groupby(['ST', 'year']).apply(
    lambda x: pd.Series({
        'employed': np.average(x['employed'], weights=x['PWGTP']),
        'pop': x['PWGTP'].sum(),
        'first_treat': x['first_treat'].iloc[0]
    })
).reset_index()

# Placebo DiD
placebo_treat_pre = exempt_sy[
    (exempt_sy['ST'].isin(early_treated)) & 
    (exempt_sy['year'].isin(pre_years))
]['employed'].mean()

placebo_treat_post = exempt_sy[
    (exempt_sy['ST'].isin(early_treated)) & 
    (exempt_sy['year'].isin(post_years))
]['employed'].mean()

placebo_ctrl_pre = exempt_sy[
    (exempt_sy['ST'].isin(never_treated)) & 
    (exempt_sy['year'].isin(pre_years))
]['employed'].mean()

placebo_ctrl_post = exempt_sy[
    (exempt_sy['ST'].isin(never_treated)) & 
    (exempt_sy['year'].isin(post_years))
]['employed'].mean()

placebo_did = (placebo_treat_post - placebo_treat_pre) - (placebo_ctrl_post - placebo_ctrl_pre)

print(f"\n--- Placebo DiD (Ages 50-64) ---")
print(f"Treatment group pre:  {placebo_treat_pre:.4f}")
print(f"Treatment group post: {placebo_treat_post:.4f}")
print(f"Control group pre:    {placebo_ctrl_pre:.4f}")
print(f"Control group post:   {placebo_ctrl_post:.4f}")
print(f"\nPlacebo DiD Estimate: {placebo_did:.4f} ({placebo_did*100:.2f} pp)")
print("(Expect ~0 if identification valid)")

# ==============================================================================
# 9. Summary Statistics
# ==============================================================================

print("\n" + "=" * 60)
print("Summary Statistics")
print("=" * 60)

# Sample characteristics
print("\n--- ABAWD-Eligible Sample (Ages 18-49, No Disability) ---")
print(f"Total observations: {len(pums):,}")
print(f"Employment rate: {pums['employed'].mean():.3f}")
print(f"LFP rate: {pums['in_labor_force'].mean():.3f}")
print(f"SNAP receipt rate: {pums['snap'].mean():.3f}")
print(f"Female: {pums['female'].mean():.3f}")
print(f"White: {pums['white'].mean():.3f}")
print(f"Black: {pums['black'].mean():.3f}")
print(f"Less than HS: {pums['less_than_hs'].mean():.3f}")

# Save results
results = {
    'did_employment': did_estimate,
    'did_snap': snap_did,
    'placebo_did': placebo_did,
    'n_obs': len(pums),
    'n_states': len(state_year['ST'].unique()),
    'n_treated_states': len(early_treated),
    'n_control_states': len(never_treated),
    'event_study': es_df.to_dict('records'),
}

with open('../data/results.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\n" + "=" * 60)
print("Results saved to ../data/results.json")
print("=" * 60)
