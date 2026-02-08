#!/usr/bin/env python3
"""
Fetch and merge data for Head Start RDD analysis.
- Opportunity Insights county-level mobility data
- Ludwig-Miller Head Start treatment data
"""

import json
import requests
import pandas as pd
import numpy as np
from pathlib import Path
import io
import zipfile

# Output directory
DATA_DIR = Path(__file__).parent.parent / "data"
DATA_DIR.mkdir(exist_ok=True)

def fetch_opportunity_insights():
    """Download Opportunity Insights county-level mobility data."""
    print("Fetching Opportunity Insights county-level data...")
    
    # Try the simple county outcomes first
    url = "https://opportunityinsights.org/wp-content/uploads/2018/10/county_outcomes_simple.csv"
    
    try:
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        df = pd.read_csv(io.StringIO(response.text))
        print(f"Downloaded {len(df)} rows from Opportunity Insights (simple)")
    except:
        # Try alternative: County covariates which has mobility measures
        print("Trying county covariates instead...")
        url = "https://opportunityinsights.org/wp-content/uploads/2018/12/cty_covariates.csv"
        try:
            response = requests.get(url, timeout=60)
            response.raise_for_status()
            df = pd.read_csv(io.StringIO(response.text))
            print(f"Downloaded {len(df)} rows from Opportunity Insights (covariates)")
        except Exception as e:
            print(f"Could not fetch OI data: {e}")
            # Try the Census Bureau mirror
            print("Trying Census Bureau source...")
            url = "https://www2.census.gov/programs-surveys/ces/data/restricted-use/opportunity-atlas-chetty-2018/cty_outcomes.csv"
            response = requests.get(url, timeout=60)
            response.raise_for_status()
            df = pd.read_csv(io.StringIO(response.text))
            print(f"Downloaded {len(df)} rows from Census")
    
    print(f"Columns in data: {df.columns.tolist()[:20]}...")  # Show first 20 columns
    
    # Create county FIPS if needed
    if 'cty' in df.columns:
        df = df.rename(columns={'cty': 'county_fips'})
    elif 'county' in df.columns and 'state' in df.columns:
        # Create 5-digit FIPS from state and county
        df['county_fips'] = df['state'].astype(str).str.zfill(2) + df['county'].astype(str).str.zfill(3)
    
    df.to_csv(DATA_DIR / "oi_county_outcomes.csv", index=False)
    print(f"Saved Opportunity Insights data to {DATA_DIR / 'oi_county_outcomes.csv'}")
    
    return df

def fetch_ludwig_miller_headstart():
    """
    Get Ludwig-Miller Head Start treatment data from rdrobust R package data.
    The headst dataset contains county-level poverty rates and mortality outcomes.
    """
    print("\nFetching Ludwig-Miller Head Start data...")
    
    # The rdrobust package hosts the data at GitHub
    # Try multiple potential sources
    urls = [
        # R rdrobust package data
        ("https://raw.githubusercontent.com/rdpackages/rdrobust/master/R/headst.rda", "rda"),
        # Stata version
        ("https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata/rdrobust_headst.dta", "dta"),
        # Hansen's econometrics page (text format)
        ("https://users.ssc.wisc.edu/~behansen/econometrics/headstart.txt", "txt"),
    ]
    
    df = None
    
    for url, fmt in urls:
        try:
            print(f"Trying {url}...")
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            if fmt == 'txt':
                # Parse space-delimited text
                lines = response.text.strip().split('\n')
                data = []
                for line in lines:
                    parts = line.split()
                    if len(parts) >= 2:
                        try:
                            data.append([float(parts[0]), float(parts[1])])
                        except:
                            continue
                
                df = pd.DataFrame(data, columns=['poverty_centered', 'mort_related'])
                print(f"Parsed {len(df)} observations from text format")
                
            elif fmt == 'dta':
                # Save and read Stata file
                with open(DATA_DIR / "headst_temp.dta", 'wb') as f:
                    f.write(response.content)
                df = pd.read_stata(DATA_DIR / "headst_temp.dta")
                print(f"Read {len(df)} observations from Stata format")
                
            if df is not None and len(df) > 0:
                break
                
        except Exception as e:
            print(f"  Failed: {e}")
            continue
    
    if df is None:
        print("Could not fetch from known sources. Creating structure from documentation...")
        return None
    
    # Process the data - standardize column names
    CUTOFF = 59.1984  # The Ludwig-Miller cutoff
    
    if 'povrate60' in df.columns:
        df['poverty_1960'] = df['povrate60']
        df['poverty_centered'] = df['poverty_1960'] - CUTOFF
    elif 'poverty_centered' in df.columns:
        df['poverty_1960'] = df['poverty_centered'] + CUTOFF
    
    df['above_cutoff'] = (df['poverty_1960'] >= CUTOFF).astype(int)
    
    print(f"\nHead Start data summary:")
    print(f"  N counties: {len(df)}")
    print(f"  Poverty range: {df['poverty_1960'].min():.2f} - {df['poverty_1960'].max():.2f}")
    print(f"  Counties above cutoff: {df['above_cutoff'].sum()}")
    print(f"  Counties below cutoff: {(1 - df['above_cutoff']).sum()}")
    
    df.to_csv(DATA_DIR / "headstart_treatment.csv", index=False)
    print(f"Saved Head Start data to {DATA_DIR / 'headstart_treatment.csv'}")
    
    return df

def main():
    """Main data fetching routine."""
    print("=" * 60)
    print("HEAD START RDD DATA ACQUISITION")
    print("=" * 60)
    
    # Fetch Opportunity Insights data
    oi_df = fetch_opportunity_insights()
    
    # Fetch Ludwig-Miller Head Start data
    headstart_df = fetch_ludwig_miller_headstart()
    
    if headstart_df is None:
        print("\nWARNING: Could not fetch Ludwig-Miller data from known sources.")
        print("The headst dataset is required for the running variable.")
        print("\nOptions:")
        print("1. Install R package 'rdrobust' and export data")
        print("2. Download from NBER/QJE replication files")
        print("3. Use NHGIS to get county-level 1960 poverty rates")
    
    print("\n" + "=" * 60)
    print("DATA ACQUISITION COMPLETE")
    print("=" * 60)
    
    print(f"\nOpportunity Insights: {len(oi_df) if oi_df is not None else 0} counties")
    if headstart_df is not None:
        print(f"Ludwig-Miller Head Start: {len(headstart_df)} observations")
        
        # Save summary statistics
        summary = {
            "n_counties_oi": len(oi_df) if oi_df is not None else 0,
            "n_obs_headstart": len(headstart_df),
            "cutoff": 59.1984,
            "n_above_cutoff": int(headstart_df['above_cutoff'].sum()),
            "n_below_cutoff": int((1 - headstart_df['above_cutoff']).sum()),
            "poverty_min": float(headstart_df['poverty_1960'].min()),
            "poverty_max": float(headstart_df['poverty_1960'].max()),
        }
        
        with open(DATA_DIR / "data_summary.json", 'w') as f:
            json.dump(summary, f, indent=2)
    
    return oi_df, headstart_df

if __name__ == "__main__":
    main()
