#!/usr/bin/env python3
"""Fetch ACS PUMS data from Census API and save as CSV for R."""

import json
import csv
import time
import urllib.request
import urllib.error
import ssl

# Bypass SSL issues
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

BASE_URL = "https://api.census.gov/data"
YEARS = range(2005, 2024)
VARS = "PWGTP,ESR,INDP,AGEP,SEX,RAC1P,SCHL,OCCP,WAGP,WKHP"

all_rows = []
header = None

for year in YEARS:
    url = f"{BASE_URL}/{year}/acs/acs1/pums?get={VARS}&for=state:*"
    try:
        req = urllib.request.Request(url)
        resp = urllib.request.urlopen(req, timeout=60, context=ctx)
        data = json.loads(resp.read())

        if header is None:
            # Get header, remove duplicate INDP if present
            h = data[0]
            # Add year to header
            seen = set()
            clean_header = []
            for col in h:
                if col in seen:
                    continue
                seen.add(col)
                clean_header.append(col)
            clean_header.append("year")
            header = clean_header

        # Process rows
        for row in data[1:]:
            # Remove duplicate columns
            seen_vals = {}
            clean_row = []
            for i, col in enumerate(data[0]):
                if col in seen_vals:
                    continue
                seen_vals[col] = True
                clean_row.append(row[i])
            clean_row.append(str(year))
            all_rows.append(clean_row)

        print(f"  {year}: {len(data) - 1} records")
    except Exception as e:
        print(f"  {year}: ERROR - {e}")

    time.sleep(0.3)

print(f"\nTotal records: {len(all_rows):,}")

# Save to CSV
outpath = "../data/pums_raw.csv"
with open(outpath, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(all_rows)

print(f"Saved: {outpath}")
