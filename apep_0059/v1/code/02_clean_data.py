#!/usr/bin/env python3
"""
02_clean_data.py
Clean PUMS data and prepare for analysis
"""

import pandas as pd
import numpy as np

# Load raw data
print("Loading raw data...")
df = pd.read_csv("data/pums_raw_2018_2022.csv")
print(f"Raw data: {len(df):,} observations")

# Sample restrictions
print("\nApplying sample restrictions...")

# Convert to numeric
df['AGEP'] = pd.to_numeric(df['AGEP'], errors='coerce')
df['COW'] = df['COW'].astype(str)
df['ESR'] = df['ESR'].astype(str)
df['PWGTP'] = pd.to_numeric(df['PWGTP'], errors='coerce')

# Filter
df = df[
    (df['AGEP'] >= 25) & (df['AGEP'] <= 64) &  # Working age
    (df['ESR'].isin(['1', '2'])) &  # Employed
    (df['COW'].isin(['1', '2', '3', '4', '5', '6', '7'])) &  # Valid worker class
    (df['PWGTP'] > 0)  # Positive weight
].copy()

print(f"After restrictions: {len(df):,} observations")

# Treatment definition
df['self_employed'] = df['COW'].isin(['6', '7']).astype(int)

se_rate = df['self_employed'].mean()
print(f"\nSelf-employment rate: {100*se_rate:.1f}%")

# Outcome variables
df['any_insurance'] = (df['HICOV'] == 1).astype(int)
df['private_coverage'] = (df['PRIVCOV'] == 1).astype(int)
df['public_coverage'] = (df['PUBCOV'] == 1).astype(int)
df['employer_insurance'] = (df['HINS1'] == 1).astype(int)
df['direct_purchase'] = (df['HINS2'] == 1).astype(int)
df['medicaid'] = (df['HINS4'] == 1).astype(int)
df['medicare'] = (df['HINS3'] == 1).astype(int)

print("\nInsurance coverage rates:")
print(f"  Any insurance: {100*df['any_insurance'].mean():.1f}%")
print(f"  Employer: {100*df['employer_insurance'].mean():.1f}%")
print(f"  Direct purchase: {100*df['direct_purchase'].mean():.1f}%")
print(f"  Medicaid: {100*df['medicaid'].mean():.1f}%")

# Covariates
df['age'] = df['AGEP']
df['age_sq'] = df['AGEP'] ** 2
df['female'] = (df['SEX'] == 2).astype(int)

# Race/ethnicity
df['race'] = 'Other'
df.loc[df['HISP'] != 1, 'race'] = 'Hispanic'
df.loc[(df['HISP'] == 1) & (df['RAC1P'] == 1), 'race'] = 'White'
df.loc[(df['HISP'] == 1) & (df['RAC1P'] == 2), 'race'] = 'Black'
df.loc[(df['HISP'] == 1) & (df['RAC1P'].isin([6, 7])), 'race'] = 'Asian'

# Education
df['SCHL'] = pd.to_numeric(df['SCHL'], errors='coerce')
df['educ'] = 'Unknown'
df.loc[df['SCHL'] < 16, 'educ'] = 'Less than HS'
df.loc[df['SCHL'].isin([16, 17]), 'educ'] = 'High School'
df.loc[df['SCHL'].isin([18, 19, 20]), 'educ'] = 'Some College'
df.loc[df['SCHL'] == 21, 'educ'] = 'Bachelors'
df.loc[df['SCHL'] >= 22, 'educ'] = 'Graduate'

# Marital status
df['married'] = (df['MAR'] == 1).astype(int)
df['married_spouse_present'] = (df['MSP'] == 1).astype(int)

# Hours worked
df['WKHP'] = pd.to_numeric(df['WKHP'], errors='coerce')
df['hours_worked'] = df['WKHP'].clip(upper=80)
df['hours_worked_sq'] = df['hours_worked'] ** 2

# Household
df['NP'] = pd.to_numeric(df['NP'], errors='coerce')
df['household_size'] = df['NP'].clip(upper=10)

# Income
df['HINCP'] = pd.to_numeric(df['HINCP'], errors='coerce')
df['income_quintile'] = pd.qcut(df['HINCP'], 5, labels=['Q1', 'Q2', 'Q3', 'Q4', 'Q5'], duplicates='drop')

# Medicaid expansion
df['medicaid_expanded'] = df['expanded'].fillna(False).astype(int)

# State
df['state'] = df['ST'].astype(str)

# Select final variables
keep_vars = [
    'YEAR', 'ST', 'PWGTP',
    'self_employed',
    'any_insurance', 'private_coverage', 'public_coverage',
    'employer_insurance', 'direct_purchase', 'medicaid', 'medicare',
    'age', 'age_sq', 'female', 'race', 'educ',
    'married', 'married_spouse_present', 'hours_worked', 'hours_worked_sq',
    'household_size', 'income_quintile', 'medicaid_expanded', 'state'
]

df_clean = df[keep_vars].dropna()

print(f"\n=== Final Analysis Sample ===")
print(f"Observations: {len(df_clean):,}")
print(f"Self-employed: {df_clean['self_employed'].sum():,}")
print(f"Wage workers: {(1 - df_clean['self_employed']).sum():,.0f}")

# Insurance by group
print("\n=== Insurance by Self-Employment ===")
for se in [0, 1]:
    subset = df_clean[df_clean['self_employed'] == se]
    label = "Self-employed" if se == 1 else "Wage workers"
    print(f"\n{label} (n={len(subset):,}):")
    print(f"  Any insurance: {100*subset['any_insurance'].mean():.1f}%")
    print(f"  Employer: {100*subset['employer_insurance'].mean():.1f}%")
    print(f"  Direct purchase: {100*subset['direct_purchase'].mean():.1f}%")
    print(f"  Medicaid: {100*subset['medicaid'].mean():.1f}%")

# Save
df_clean.to_csv("data/pums_clean.csv", index=False)
print(f"\nClean data saved to: data/pums_clean.csv")
