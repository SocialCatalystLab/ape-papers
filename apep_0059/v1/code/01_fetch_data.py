#!/usr/bin/env python3
"""
01_fetch_data.py
Fetch ACS PUMS data from Census Bureau API
"""

import json
import urllib.request
import pandas as pd
import time
import os

# Variables to fetch
vars_list = [
    # Demographics
    "AGEP",   # Age
    "SEX",    # Sex
    "RAC1P",  # Race
    "HISP",   # Hispanic origin
    "SCHL",   # Educational attainment
    "MAR",    # Marital status
    "MSP",    # Married spouse present

    # Labor market
    "COW",    # Class of worker
    "ESR",    # Employment status
    "OCCP",   # Occupation
    "INDP",   # Industry
    "WKHP",   # Usual hours worked
    "WKWN",   # Weeks worked

    # Household
    "HINCP",  # Household income
    "NP",     # Number of persons
    "PAOC",   # Presence and age of children

    # Geography
    "ST",     # State
    "PUMA",   # PUMA

    # Health insurance
    "HICOV",  # Health insurance coverage
    "PRIVCOV", # Private coverage
    "PUBCOV", # Public coverage
    "HINS1",  # Employer/union
    "HINS2",  # Direct purchase
    "HINS3",  # Medicare
    "HINS4",  # Medicaid
    "HINS5",  # TRICARE
    "HINS6",  # VA

    # Weight
    "PWGTP"   # Person weight
]

def fetch_pums_year(year, vars, state="*"):
    """Fetch PUMS data for a single year."""
    print(f"Fetching {year} ACS PUMS data...")

    var_string = ",".join(vars)
    url = f"https://api.census.gov/data/{year}/acs/acs1/pums?get={var_string}&for=state:{state}"

    try:
        with urllib.request.urlopen(url, timeout=300) as response:
            data = json.load(response)
    except Exception as e:
        print(f"  Error fetching {year}: {e}")
        return None

    # Convert to DataFrame
    df = pd.DataFrame(data[1:], columns=data[0])
    df['YEAR'] = year

    print(f"  Fetched {len(df):,} records")
    return df

def main():
    # Create data directory
    os.makedirs("data", exist_ok=True)

    # Fetch 2018-2022 data
    years = [2018, 2019, 2020, 2021, 2022]
    all_data = []

    for year in years:
        df = fetch_pums_year(year, vars_list)
        if df is not None:
            all_data.append(df)
        time.sleep(1)  # Be nice to API

    # Combine all years
    pums = pd.concat(all_data, ignore_index=True)

    print(f"\n=== Data Summary ===")
    print(f"Total observations: {len(pums):,}")
    print(f"Years: {pums['YEAR'].unique()}")

    # Add Medicaid expansion status
    expansion_states = {
        '02': True, '04': True, '05': True, '06': True, '08': True,
        '09': True, '10': True, '11': True, '15': True, '16': True,
        '17': True, '18': True, '19': True, '21': True, '22': True,
        '23': True, '24': True, '25': True, '26': True, '27': True,
        '29': True, '30': True, '31': True, '32': True, '33': True,
        '34': True, '35': True, '36': True, '38': True, '39': True,
        '41': True, '42': True, '44': True, '49': True, '50': True,
        '51': True, '53': True, '54': True,
        # Non-expansion
        '01': False, '12': False, '13': False, '20': False, '28': False,
        '37': False, '45': False, '47': False, '48': False, '55': False,
        '56': False, '40': False, '46': False
    }

    pums['expanded'] = pums['ST'].map(expansion_states)

    # Save
    pums.to_csv("data/pums_raw_2018_2022.csv", index=False)
    print(f"\nRaw data saved to: data/pums_raw_2018_2022.csv")

    # Print year distribution
    print("\nObservations by year:")
    print(pums['YEAR'].value_counts().sort_index())

if __name__ == "__main__":
    main()
