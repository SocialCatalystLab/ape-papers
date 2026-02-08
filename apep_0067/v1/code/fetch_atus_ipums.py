#!/usr/bin/env python3
"""
Fetch ATUS data from IPUMS via API
Paper 86: Minimum Wage and Teen Time Allocation
"""

import os
import sys

# Load .env file
env_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", ".env")
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, value = line.partition("=")
                os.environ[key.strip()] = value.strip()

from ipumspy import IpumsApiClient, MicrodataExtract

# Get API key
api_key = os.environ.get("IPUMS_API_KEY")
if not api_key:
    print("Error: IPUMS_API_KEY not found")
    print(f"Checked .env at: {env_path}")
    sys.exit(1)

print(f"IPUMS API key found (length: {len(api_key)})")

client = IpumsApiClient(api_key)

# Get available ATUS samples
print("\nFetching available ATUS samples...")
try:
    samples_info = client.get_all_sample_info("atus")
    print(f"Found {len(samples_info)} ATUS samples")

    # Print sample names
    sample_names = []
    for sample in samples_info:
        if hasattr(sample, 'name'):
            sample_names.append(sample.name)
        elif isinstance(sample, dict):
            sample_names.append(sample.get('name', str(sample)))
        else:
            sample_names.append(str(sample))

    print("Sample names:", sample_names[:15], "...")
except Exception as e:
    print(f"Error getting sample info: {e}")
    sample_names = []

# ATUS samples are typically named like "at2003", "at2004", etc.
# Let's use what we found or fall back to expected naming
if sample_names:
    atus_samples = [s for s in sample_names if s.startswith("at20")]
else:
    atus_samples = [f"at{year}" for year in range(2003, 2024)]

print(f"\nUsing samples: {atus_samples[:5]}...{atus_samples[-3:]}")

# Variables we need - ATUS core variables
variables = [
    # Time/date
    "YEAR",
    "MONTH",
    "DAY",

    # Demographics
    "AGE",
    "SEX",
    "RACE",
    "HISPAN",
    "MARST",
    "EDUC",

    # Geographic
    "STATEFIP",
    "METRO",

    # Labor force status
    "EMPSTAT",
    "FULLPART",
    "UHRSWORKT",
    "EARNWEEK",
    "CLWKR",

    # Industry/occupation
    "IND2",
    "OCC2",

    # Household
    "FAMINCOME",

    # School enrollment
    "SCHLCOLL",
]

print(f"\nCreating ATUS extract request...")
print(f"  Samples: {len(atus_samples)} years (2003-2023)")
print(f"  Variables: {len(variables)}")

try:
    # Create extract - person-level rectangular
    extract = MicrodataExtract(
        collection="atus",
        samples=atus_samples,
        variables=variables,
        description="Paper 86: MW and teen time allocation",
        data_structure={"rectangular": {"on": "P"}}  # Person-level
    )

    # Submit extract
    print("\nSubmitting extract to IPUMS...")
    client.submit_extract(extract)
    print(f"Extract submitted successfully!")
    print(f"Extract ID: {extract.extract_id}")

    # Wait for completion
    print("\nWaiting for extract to complete...")
    print("(This may take 5-15 minutes for a multi-year extract)")

    client.wait_for_extract(extract, timeout=3600)  # 1 hour timeout

    print("\nExtract ready! Downloading...")

    # Download
    data_dir = "../data"
    os.makedirs(data_dir, exist_ok=True)
    client.download_extract(extract, download_dir=data_dir)

    print(f"\nExtract downloaded to {data_dir}")
    print("Files:")
    for f in os.listdir(data_dir):
        fpath = os.path.join(data_dir, f)
        size = os.path.getsize(fpath) / 1024 / 1024  # MB
        print(f"  {f} ({size:.1f} MB)")

    print("\nSuccess! Data ready for analysis.")

except Exception as e:
    print(f"\nError during extract process: {e}")
    print(f"\nError type: {type(e).__name__}")

    import traceback
    traceback.print_exc()

    print("\n" + "="*60)
    print("ALTERNATIVE: Manual extract via IPUMS website")
    print("="*60)
    print("""
1. Go to https://www.atusdata.org/atus/
2. Create account or login
3. Click "Create an Extract"
4. Select samples: 2003-2023 (all years)
5. Select variables:
   - YEAR, MONTH, STATEFIP, AGE, SEX, RACE, HISPAN, EDUC
   - EMPSTAT, FULLPART, EARNWEEK, IND2, OCC2
   - FAMINCOME, SCHLCOLL
6. In Time Use Variables: Select or create activity totals
7. Submit extract and download when ready
8. Place files in output/paper_86/data/
""")
