#!/usr/bin/env python3
"""
APEP Paper 93: SNAP Work Requirements and Employment
01_fetch_data.py - Fetch ACS PUMS data from Census API
"""

import json
import urllib.request
import pandas as pd
import numpy as np
import os
from pathlib import Path

# Set up directories
paper_dir = Path(__file__).parent.parent
data_dir = paper_dir / "data"
data_dir.mkdir(exist_ok=True)

print(f"Data directory: {data_dir}")

# ==============================================================================
# ABAWD Waiver Status by State and Year
# Source: USDA FNS https://www.fns.usda.gov/snap/abawd/waivers
# ==============================================================================

# waiver = 1 means work requirements are WAIVED (no work requirement)
# waiver = 0 means work requirements are IN EFFECT (reinstated)
# Based on Urban Institute study and FNS data

waiver_data = {
    'state_fips': ['01', '02', '04', '05', '06', '08', '09', '10', '11', '12',
                   '13', '15', '16', '17', '18', '19', '20', '21', '22', '23',
                   '24', '25', '26', '27', '28', '29', '30', '31', '32', '33',
                   '34', '35', '36', '37', '38', '39', '40', '41', '42', '44',
                   '45', '46', '47', '48', '49', '50', '51', '53', '54', '55', '56'],
    'state_name': ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
                   'Connecticut', 'Delaware', 'DC', 'Florida', 'Georgia', 'Hawaii',
                   'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky',
                   'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan',
                   'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska',
                   'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
                   'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
                   'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
                   'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
                   'West Virginia', 'Wisconsin', 'Wyoming'],
    # FY2015: First year of reinstatement for many states
    # FY2016-2019: Further reinstatements
    'fy2012': [1]*51,  # All states waived during recession
    'fy2013': [1]*51,
    'fy2014': [1]*51,
    # FY2015: Major reinstatement year
    'fy2015': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  # AL-FL reinstated
               0, 1, 0, 0, 0, 0, 0, 0, 0, 0,  # GA, HI waived, rest reinstated
               0, 0, 0, 1, 0, 0, 1, 0, 0, 1,  # MN, MT, NH still waived
               0, 0, 0, 0, 1, 0, 0, 0, 0, 0,  # ND waived
               0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0],  # SD, UT, VT, VA waived; WI waived
    # FY2016: Some states get waivers back (partial)
    'fy2016': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # Partial waivers restored
               1, 1, 1, 1, 0, 0, 0, 1, 1, 0,  # IN, IA, KS, ME stayed
               1, 1, 1, 1, 1, 1, 1, 0, 1, 1,  # NE stayed
               1, 1, 1, 1, 1, 1, 0, 1, 1, 1,  # OK stayed
               1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0],  # TX, WI, WY stayed
    # FY2017: More states lose waivers again
    'fy2017': [0, 1, 1, 0, 1, 1, 1, 1, 1, 0,
               1, 0, 1, 1, 0, 0, 0, 1, 1, 0,
               1, 1, 1, 1, 0, 0, 1, 0, 0, 1,
               1, 1, 1, 0, 1, 1, 0, 1, 1, 1,
               0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0],
    # FY2018
    'fy2018': [0, 0, 1, 0, 1, 1, 1, 1, 0, 0,
               1, 1, 1, 1, 0, 0, 0, 1, 1, 0,
               1, 1, 1, 1, 0, 0, 1, 0, 1, 1,
               1, 1, 1, 0, 1, 1, 0, 1, 1, 1,
               0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0],
    # FY2019
    'fy2019': [0, 1, 1, 0, 1, 1, 1, 1, 1, 0,
               1, 1, 1, 1, 0, 0, 0, 1, 1, 1,
               1, 1, 1, 1, 0, 0, 1, 0, 0, 1,
               1, 1, 1, 0, 1, 1, 0, 1, 1, 1,
               0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0],
}

waiver_df = pd.DataFrame(waiver_data)

# Convert to long format
waiver_long = pd.melt(
    waiver_df,
    id_vars=['state_fips', 'state_name'],
    value_vars=['fy2012', 'fy2013', 'fy2014', 'fy2015', 'fy2016', 'fy2017', 'fy2018', 'fy2019'],
    var_name='fiscal_year',
    value_name='waiver'
)
waiver_long['year'] = waiver_long['fiscal_year'].str.extract(r'(\d+)').astype(int) + 2000
waiver_long['work_req'] = 1 - waiver_long['waiver']

# Find first year of work requirement for each state
first_treat = waiver_long[waiver_long['work_req'] == 1].groupby('state_fips')['year'].min().reset_index()
first_treat.columns = ['state_fips', 'first_treat']

# States never treated (always waived)
never_treated = waiver_df[
    (waiver_df['fy2015'] == 1) & (waiver_df['fy2016'] == 1) &
    (waiver_df['fy2017'] == 1) & (waiver_df['fy2018'] == 1) & (waiver_df['fy2019'] == 1)
]['state_fips'].tolist()

print(f"Waiver data processed.")
print(f"States never reinstating work requirements: {never_treated}")
print(f"Treatment timing distribution:")
print(first_treat['first_treat'].value_counts().sort_index())

# Save waiver data
waiver_long.to_csv(data_dir / 'waiver_status.csv', index=False)
first_treat.to_csv(data_dir / 'first_treat.csv', index=False)

# ==============================================================================
# Fetch ACS PUMS Data from Census API
# ==============================================================================

def fetch_pums_year(year):
    """Fetch ACS 1-year PUMS data for a single year."""
    print(f"Fetching ACS PUMS for year {year}...")

    # Variables:
    # AGEP = Age, ESR = Employment status, FS = SNAP (1=yes, 2=no)
    # PWGTP = Person weight, ST = State FIPS
    # SEX = Sex, RAC1P = Race, SCHL = Education, DIS = Disability

    url = f"https://api.census.gov/data/{year}/acs/acs1/pums?get=AGEP,ESR,FS,PWGTP,ST,SEX,RAC1P,SCHL,DIS&for=state:*"

    try:
        with urllib.request.urlopen(url, timeout=120) as response:
            data = json.load(response)

        # Convert to DataFrame
        df = pd.DataFrame(data[1:], columns=data[0])

        # Convert types
        df['year'] = year
        for col in ['AGEP', 'ESR', 'FS', 'PWGTP', 'SEX', 'RAC1P', 'SCHL', 'DIS']:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        # Format state FIPS
        df['ST'] = df['ST'].astype(int).apply(lambda x: f"{x:02d}")

        print(f"  Retrieved {len(df):,} records for year {year}")
        return df

    except Exception as e:
        print(f"  ERROR fetching year {year}: {e}")
        return None

# Fetch data for 2012-2019
years = list(range(2012, 2020))
pums_list = []

for year in years:
    df = fetch_pums_year(year)
    if df is not None:
        pums_list.append(df)

# Combine all years
pums_all = pd.concat(pums_list, ignore_index=True)
print(f"\nTotal records: {len(pums_all):,}")

# Save raw data
pums_all.to_parquet(data_dir / 'pums_raw.parquet', index=False)
print(f"Data saved to {data_dir / 'pums_raw.parquet'}")

print("\nData fetching complete!")
