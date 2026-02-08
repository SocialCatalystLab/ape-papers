#!/usr/bin/env python3
"""
Paper 75: The Making of a City
01_fetch_data.py - Submit IPUMS extract requests

This script submits extract requests to IPUMS USA for:
1. PILOT: 1% samples (1900, 1910, 1950) to test pipeline
2. Full-count 1900-1910 for earthquake analysis (with HISTID for MLP linking)

The extracts take hours to complete. Use 02_check_status.py to monitor.
"""

import os
import json
from datetime import datetime
from pathlib import Path

from ipumspy import IpumsApiClient, MicrodataExtract

# ============================================================================
# Configuration
# ============================================================================

DATA_DIR = Path("output/paper_75/data")
DATA_DIR.mkdir(exist_ok=True)

# Load API key from environment
IPUMS_API_KEY = os.environ.get("IPUMS_API_KEY")
if not IPUMS_API_KEY:
    raise ValueError("IPUMS_API_KEY not set. Run: source .env")

# Initialize client
client = IpumsApiClient(IPUMS_API_KEY)

# ============================================================================
# Variable Lists - Carefully curated for availability
# ============================================================================

# Variables available in 1% pilot samples (1900, 1910, 1950)
PILOT_VARS = [
    # Core geo/ID
    "SERIAL",    # Household serial
    "PERNUM",    # Person number
    "YEAR",      # Census year
    "STATEFIP",  # State FIPS
    "COUNTYICP", # County (ICPSR code - more widely available than FIPS)
    # Demographics
    "AGE",
    "SEX",
    "RACE",
    "MARST",     # Marital status
    "BPL",       # Birthplace
    "NATIVITY", # Native/foreign born
    # Human capital
    "SCHOOL",    # School attendance
    # Labor/economic
    "LABFORCE",  # Labor force participation
    "OCC1950",   # Occupation (1950 basis)
    "CLASSWKR", # Class of worker
    "OCCSCORE",  # Occupational income score
    # Family
    "MOMLOC",    # Mother's line number
    "POPLOC",    # Father's line number
    "SPLOC",     # Spouse's line number
    "RELATE",    # Relationship to head
    "NCHILD",    # Number of children
]

# Variables for FULL-COUNT samples with MLP linking (1900m, 1910m have HISTID)
FULLCOUNT_VARS = [
    # Core linking (MLP)
    "HISTID",    # Unique person ID for MLP linking
    "SERIAL",    # Household serial
    "PERNUM",    # Person number
    "YEAR",      # Census year
    "STATEFIP",  # State FIPS
    "COUNTYICP", # County (ICPSR code)
    # Demographics
    "AGE",
    "SEX",
    "RACE",
    "MARST",     # Marital status
    "BPL",       # Birthplace
    "NATIVITY", # Native/foreign born
    # Human capital (LIT available in 1900/1910 full-count)
    "LIT",       # Literacy
    "SCHOOL",    # School attendance
    # Labor/economic
    "LABFORCE",  # Labor force participation
    "OCC1950",   # Occupation (1950 basis)
    "CLASSWKR", # Class of worker
    "OCCSCORE",  # Occupational income score
    # Family
    "MOMLOC",    # Mother's line number
    "POPLOC",    # Father's line number
    "SPLOC",     # Spouse's line number
    "RELATE",    # Relationship to head
    "NCHILD",    # Number of children
]

# ============================================================================
# Extract Definitions
# ============================================================================

def create_pilot_extract():
    """
    Stage 1: Pilot sample using 1% samples to validate pipeline.
    Much smaller, faster to download and process.
    Note: 1% samples don't have HISTID, so can't do cross-census linking.
    """
    # Use 1% samples that have the basic variables
    samples = [
        "us1900l",  # 1900 1.2% sample (larger than 1%)
        "us1910m",  # Let's try 1910 full-count instead for pilot
    ]

    extract = MicrodataExtract(
        collection="usa",
        samples=samples,
        variables=PILOT_VARS,
        description="Paper 75 PILOT: SF migration analysis (samples)",
        data_format="csv"
    )

    return extract


def create_earthquake_extract():
    """
    1900 and 1910 full-count for SF + comparison cities.
    For analyzing 1906 earthquake migration responses.
    These samples have HISTID for MLP cross-census linking.
    """
    samples = [
        "us1900m",  # 1900 full-count
        "us1910m",  # 1910 full-count
    ]

    extract = MicrodataExtract(
        collection="usa",
        samples=samples,
        variables=FULLCOUNT_VARS,
        description="Paper 75: 1900-1910 SF earthquake analysis (full-count with MLP)",
        data_format="csv"
    )

    return extract


def create_1920_1940_extract():
    """
    1920 and 1940 full-count for tracking through mid-century.
    """
    samples = [
        "us1920b",  # 1920 full-count
        "us1940b",  # 1940 full-count
    ]

    # 1920 and 1940 have different variable availability
    vars_1920_1940 = [
        "HISTID",
        "SERIAL",
        "PERNUM",
        "YEAR",
        "STATEFIP",
        "COUNTYICP",
        "AGE",
        "SEX",
        "RACE",
        "MARST",
        "BPL",
        "NATIVITY",
        "SCHOOL",
        "LABFORCE",
        "OCC1950",
        "CLASSWKR",
        "OCCSCORE",
        "MOMLOC",
        "POPLOC",
        "SPLOC",
        "RELATE",
        "NCHILD",
    ]

    extract = MicrodataExtract(
        collection="usa",
        samples=samples,
        variables=vars_1920_1940,
        description="Paper 75: 1920-1940 full-count with MLP",
        data_format="csv"
    )

    return extract


# ============================================================================
# Main: Submit Extracts
# ============================================================================

def main():
    print("=" * 60)
    print("IPUMS Extract Submission for Paper 75")
    print("=" * 60)

    # Track submitted extracts
    extracts_submitted = {}

    # Stage 1: Submit 1900-1910 earthquake extract (main analysis)
    print("\n[Stage 1] Submitting 1900-1910 earthquake extract (full-count with MLP)...")
    eq = create_earthquake_extract()
    try:
        eq_result = client.submit_extract(eq)
        eq_id = eq_result.extract_id
        print(f"  ✓ Earthquake extract submitted: ID = {eq_id}")
        extracts_submitted["earthquake_1900_1910"] = str(eq_id)
    except Exception as e:
        print(f"  ✗ Failed to submit earthquake: {e}")

    # Stage 2: Submit 1920-1940 extract for longer tracking
    print("\n[Stage 2] Submitting 1920-1940 extract (full-count with MLP)...")
    try:
        ext_1920_1940 = create_1920_1940_extract()
        ext_result = client.submit_extract(ext_1920_1940)
        ext_id = ext_result.extract_id
        print(f"  ✓ 1920-1940 extract submitted: ID = {ext_id}")
        extracts_submitted["fullcount_1920_1940"] = str(ext_id)
    except Exception as e:
        print(f"  ✗ Failed to submit 1920-1940: {e}")

    # Save extract IDs for later retrieval
    extract_file = DATA_DIR / "extract_ids.json"
    with open(extract_file, "w") as f:
        json.dump({
            "submitted_at": datetime.now().isoformat(),
            "extracts": extracts_submitted
        }, f, indent=2)

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Extracts submitted: {len(extracts_submitted)}")
    print(f"Extract IDs saved to: {extract_file}")
    print("\nNext steps:")
    print("  1. Run: python3 output/paper_75/code/02_check_status.py to monitor progress")
    print("  2. Full-count extracts may take 2-6 hours to complete")
    print("  3. Once complete, run 02_check_status.py again to download")
    print("\nNote: Full-count 1900+1910 is ~168 million records (76M + 92M)")
    print("      Expect 10-20 GB download, several hours processing")
    print("=" * 60)


if __name__ == "__main__":
    main()
