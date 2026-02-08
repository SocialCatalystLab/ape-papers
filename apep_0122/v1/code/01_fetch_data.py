#!/usr/bin/env python3
"""Fetch ACS data from Census API — filtered approach.

Strategy:
1. PUMS filtered to electricity sector (INDP=0570) for individual-level detail
2. PUMS filtered to all utilities (INDP=0570,0580,0590)
3. Summary tables for total employment and population by state-year
4. Summary table for manufacturing employment by state-year (placebo)
"""

import json
import csv
import time
import sys
import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

BASE_URL = "https://api.census.gov/data"
YEARS = list(range(2005, 2024))

def fetch_url(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(url)
            resp = urllib.request.urlopen(req, timeout=120, context=ctx)
            return json.loads(resp.read())
        except Exception as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
            else:
                raise e

# ==============================================================================
# Part 1: Electricity sector individual data from PUMS (filtered)
# ==============================================================================
print("=== Part 1: Electricity sector individual data (PUMS) ===")
all_elec = []
elec_header = None

for year in YEARS:
    # INDP=0570 = Electric power generation, transmission and distribution
    url = f"{BASE_URL}/{year}/acs/acs1/pums?get=PWGTP,ESR,INDP,AGEP,SEX,RAC1P,SCHL,WAGP,WKHP&for=state:*&INDP=0570"
    try:
        data = fetch_url(url)
        if elec_header is None:
            h = data[0]
            seen = set()
            elec_header = []
            for col in h:
                if col in seen:
                    continue
                seen.add(col)
                elec_header.append(col)
            elec_header.append("year")

        for row in data[1:]:
            seen_vals = {}
            clean = []
            for i, col in enumerate(data[0]):
                if col in seen_vals:
                    continue
                seen_vals[col] = True
                clean.append(row[i])
            clean.append(str(year))
            all_elec.append(clean)

        print(f"  {year}: {len(data)-1} elec workers", flush=True)
    except Exception as e:
        print(f"  {year}: ERROR - {e}", flush=True)
    time.sleep(0.3)

print(f"Total electricity sector records: {len(all_elec):,}")

with open("../data/pums_electricity.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(elec_header)
    w.writerows(all_elec)

# ==============================================================================
# Part 2: All utility sector from PUMS (0570 + 0580 + 0590)
# ==============================================================================
print("\n=== Part 2: All utilities PUMS data ===")
all_util = []
util_header = None

for year in YEARS:
    for indp in ["0570", "0580", "0590"]:
        url = f"{BASE_URL}/{year}/acs/acs1/pums?get=PWGTP,ESR,INDP,AGEP,SEX,WAGP&for=state:*&INDP={indp}"
        try:
            data = fetch_url(url)
            if util_header is None:
                h = data[0]
                seen = set()
                util_header = []
                for col in h:
                    if col in seen:
                        continue
                    seen.add(col)
                    util_header.append(col)
                util_header.append("year")

            for row in data[1:]:
                seen_vals = {}
                clean = []
                for i, col in enumerate(data[0]):
                    if col in seen_vals:
                        continue
                    seen_vals[col] = True
                    clean.append(row[i])
                clean.append(str(year))
                all_util.append(clean)
        except:
            pass
        time.sleep(0.15)
    if year % 5 == 0:
        print(f"  {year}: running total {len(all_util):,}", flush=True)

print(f"Total utility sector records: {len(all_util):,}")
with open("../data/pums_utilities.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(util_header)
    w.writerows(all_util)

# ==============================================================================
# Part 3: State-year total employment from ACS Summary Tables
# ==============================================================================
print("\n=== Part 3: State-year aggregate data (Summary Tables) ===")

# Variables:
# B01003_001E = Total population
# B23025_001E = Population 16+
# B23025_002E = In labor force
# B23025_004E = Employed (civilian)
# B23025_005E = Unemployed

agg_rows = []
for year in YEARS:
    vars_str = "NAME,B01003_001E,B23025_001E,B23025_002E,B23025_004E,B23025_005E"
    url = f"{BASE_URL}/{year}/acs/acs1?get={vars_str}&for=state:*"
    try:
        data = fetch_url(url)
        for row in data[1:]:
            agg_rows.append([year] + row)
        print(f"  {year}: {len(data)-1} states", flush=True)
    except Exception as e:
        print(f"  {year}: ERROR - {e}", flush=True)
    time.sleep(0.3)

agg_header = ["year", "state_name", "total_pop", "pop_16plus", "labor_force",
              "employed_civilian", "unemployed", "state_fips"]

with open("../data/state_year_aggregates.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(agg_header)
    w.writerows(agg_rows)

print(f"Total state-year aggregate records: {len(agg_rows)}")

# ==============================================================================
# Part 4: Manufacturing employment from Summary Tables (placebo)
# ==============================================================================
print("\n=== Part 4: Manufacturing employment (Summary Tables) ===")

# B24030: SEX BY INDUSTRY - need to find manufacturing variables
# Use S2403 (Industry by Sex) or C24030 simpler version
# Actually, use B24050 or try the NAICS-based table
# Simpler: use B24030_001E (total), and individual industry vars

# For manufacturing, trying to get direct counts
# B24030_021E = Male, Manufacturing  (approx position varies by year)
# Alternative: Use employment by industry detail table

# Let's use a simpler approach - get total employment from subject table
mfg_rows = []
for year in YEARS:
    # S2403: Industry by Sex (subject table - pre-computed percentages and counts)
    # Try direct count approach with B24030
    # B24030_004E = Male, Agriculture
    # We need to find correct variable index for manufacturing
    # Let's try getting multiple variables and identifying them
    try:
        # Use the profile table DP03 which has employment by industry
        vars_str = "NAME,DP03_0004E,DP03_0033E,DP03_0034E,DP03_0035E,DP03_0036E,DP03_0037E,DP03_0038E"
        url = f"{BASE_URL}/{year}/acs/acs1/profile?get={vars_str}&for=state:*"
        data = fetch_url(url)
        for row in data[1:]:
            mfg_rows.append([year] + row)
        if year % 5 == 0:
            print(f"  {year}: {len(data)-1} states", flush=True)
    except Exception as e:
        print(f"  {year}: ERROR (profile table) - {e}", flush=True)
        # Fallback: skip year
    time.sleep(0.3)

mfg_header = ["year", "state_name", "employed_16plus", "agriculture", "construction",
              "manufacturing", "wholesale", "retail", "transport_utilities", "state_fips"]

with open("../data/state_year_industry.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(mfg_header)
    w.writerows(mfg_rows)

print(f"Total industry records: {len(mfg_rows)}")
print("\n=== All data fetched ===")
