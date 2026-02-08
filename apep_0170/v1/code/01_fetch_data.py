#!/usr/bin/env python3
"""
01_fetch_data.py - Submit IPUMS ACS Extract
Paper: Salary History Bans and Wage Compression

This script submits an IPUMS ACS extract request for 2012-2023 data.
The extract includes variables needed to study wage dispersion and job changes.
"""

import os
import sys
import time
from pathlib import Path

# Add IPUMS API client
try:
    from ipumspy import IpumsApiClient, AcsExtract
except ImportError:
    print("ERROR: ipumspy not installed. Run: pip install ipumspy")
    sys.exit(1)

# Configuration
OUTPUT_DIR = Path(__file__).parent.parent / "data"
OUTPUT_DIR.mkdir(exist_ok=True)

# IPUMS ACS variables for wage dispersion study
VARIABLES = [
    # Demographics
    "YEAR",
    "SAMPLE",
    "SERIAL",
    "PERNUM",
    "PERWT",
    "STATEFIP",
    "COUNTYFIP",
    "MET2013",  # Metro area
    "DATANUM",
    
    # Interview timing (critical for aligning with law effective dates)
    "MONTH",
    
    # Demographics
    "AGE",
    "SEX",
    "RACE",
    "HISPAN",
    "EDUC",
    "EDUCD",
    
    # Employment
    "EMPSTAT",
    "EMPSTATD",
    "LABFORCE",
    "CLASSWKR",
    "CLASSWKRD",
    "OCC",
    "IND",
    "WKSWORK1",  # Weeks worked last year
    "UHRSWORK",  # Usual hours per week
    
    # Income
    "INCTOT",
    "INCWAGE",  # Wage and salary income - PRIMARY OUTCOME
    "INCBUS00",  # Self-employment income (placebo)
    "INCINVST",  # Investment income (placebo)
    
    # Migration/job change indicators
    "MIGRATE1",  # Migration status (moved last year)
    "MIGRATE1D",
    "MIGPLAC1",  # Where lived 1 year ago
    "DIFFREM",   # Changed employment status
    "DIFFMOVE",  # Changed address
    
    # Additional controls
    "MARST",
    "NCHILD",
    "VETSTAT",
]

# ACS samples 2012-2023 (1-year samples)
SAMPLES = [
    "us2012a", "us2013a", "us2014a", "us2015a", "us2016a",
    "us2017a", "us2018a", "us2019a", "us2020a", "us2021a",
    "us2022a", "us2023a"
]


def submit_extract():
    """Submit IPUMS ACS extract."""
    api_key = os.environ.get("IPUMS_API_KEY")
    if not api_key:
        print("ERROR: IPUMS_API_KEY environment variable not set")
        sys.exit(1)
    
    client = IpumsApiClient(api_key)
    
    print("Submitting IPUMS ACS extract...")
    print(f"  Samples: {len(SAMPLES)} (2012-2023)")
    print(f"  Variables: {len(VARIABLES)}")
    
    extract = AcsExtract(
        samples=SAMPLES,
        variables=VARIABLES,
        description="Salary History Bans and Wage Compression (APEP paper_156)"
    )
    
    extract_id = client.submit_extract(extract)
    print(f"  Extract submitted: ID = {extract_id}")
    
    return client, extract_id


def wait_and_download(client, extract_id):
    """Wait for extract to complete and download."""
    print("\nWaiting for extract to complete...")
    print("  (ACS extracts typically take 5-15 minutes)")
    
    poll_interval = 60  # Check every minute
    max_wait = 3600  # 1 hour max
    elapsed = 0
    
    while elapsed < max_wait:
        status = client.extract_status(extract_id)
        print(f"  [{time.strftime('%H:%M:%S')}] Status: {status}")
        
        if status == "completed":
            print("\nExtract ready! Downloading...")
            client.download_extract(extract_id, str(OUTPUT_DIR))
            print(f"  Downloaded to: {OUTPUT_DIR}")
            return True
        elif status == "failed":
            print("ERROR: Extract failed!")
            return False
        
        time.sleep(poll_interval)
        elapsed += poll_interval
    
    print("WARNING: Extract not ready after 1 hour. Check IPUMS website.")
    return False


def main():
    """Main entry point."""
    print("=" * 60)
    print("IPUMS ACS Extract for Salary History Ban Study")
    print("=" * 60)
    
    client, extract_id = submit_extract()
    
    # Save extract ID for later reference
    with open(OUTPUT_DIR / "extract_id.txt", "w") as f:
        f.write(f"{extract_id}\n")
    
    success = wait_and_download(client, extract_id)
    
    if success:
        print("\n" + "=" * 60)
        print("SUCCESS: Data ready for analysis")
        print("=" * 60)
    else:
        print("\n" + "=" * 60)
        print("Extract not yet complete. Run script again or check IPUMS.")
        print("=" * 60)


if __name__ == "__main__":
    main()
