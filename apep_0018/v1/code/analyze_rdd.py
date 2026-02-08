#!/usr/bin/env python3
"""
Regression Discontinuity Analysis for Head Start OEO Treatment.

This script replicates and extends the Ludwig-Miller (2007) Head Start RDD design.
We analyze the effect of OEO grant-writing assistance on:
1. Child mortality (original LM2007 outcome) - to verify the first stage
2. Additional outcomes available in the dataset

The RDD exploits the discontinuity at the 59.1984% poverty rate threshold.
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from scipy import stats
import json
from pathlib import Path

# Paths
DATA_DIR = Path(__file__).parent.parent / "data"
FIG_DIR = Path(__file__).parent.parent / "figures"
FIG_DIR.mkdir(exist_ok=True)

# The Ludwig-Miller cutoff
CUTOFF = 59.1984

def load_data():
    """Load the Ludwig-Miller Head Start data."""
    df = pd.read_csv(DATA_DIR / "headstart_treatment.csv")
    print(f"Loaded {len(df)} observations")
    print(f"Columns: {df.columns.tolist()}")
    return df

def mccrary_density_test(df, bandwidth=18):
    """
    McCrary (2008) style density test for manipulation.
    Test for bunching at the cutoff.
    """
    print("\n" + "="*60)
    print("McCrary Density Test")
    print("="*60)
    
    # Restrict to bandwidth
    pov = df['poverty_1960'].values
    in_bw = (pov >= CUTOFF - bandwidth) & (pov <= CUTOFF + bandwidth)
    pov_bw = pov[in_bw]
    
    # Bin the data
    n_bins = 40
    bins = np.linspace(CUTOFF - bandwidth, CUTOFF + bandwidth, n_bins + 1)
    hist, bin_edges = np.histogram(pov_bw, bins=bins)
    bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
    
    # Fit local linear regressions on each side
    left_mask = bin_centers < CUTOFF
    right_mask = bin_centers >= CUTOFF
    
    # Left side
    X_left = bin_centers[left_mask]
    y_left = hist[left_mask]
    if len(X_left) > 2:
        slope_left, intercept_left, r_left, p_left, se_left = stats.linregress(X_left, y_left)
        pred_at_cutoff_left = intercept_left + slope_left * CUTOFF
    else:
        pred_at_cutoff_left = np.mean(y_left)
    
    # Right side
    X_right = bin_centers[right_mask]
    y_right = hist[right_mask]
    if len(X_right) > 2:
        slope_right, intercept_right, r_right, p_right, se_right = stats.linregress(X_right, y_right)
        pred_at_cutoff_right = intercept_right + slope_right * CUTOFF
    else:
        pred_at_cutoff_right = np.mean(y_right)
    
    # Log discontinuity
    log_disc = np.log(pred_at_cutoff_right + 1) - np.log(pred_at_cutoff_left + 1)
    
    print(f"Predicted density left of cutoff: {pred_at_cutoff_left:.2f}")
    print(f"Predicted density right of cutoff: {pred_at_cutoff_right:.2f}")
    print(f"Log discontinuity: {log_disc:.3f}")
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(bin_centers, hist, width=(bins[1]-bins[0])*0.9, color='steelblue', alpha=0.7, edgecolor='black')
    ax.axvline(CUTOFF, color='red', linestyle='--', linewidth=2, label=f'Cutoff = {CUTOFF}%')
    ax.set_xlabel('County 1960 Poverty Rate (%)', fontsize=12)
    ax.set_ylabel('Number of Counties', fontsize=12)
    ax.set_title('McCrary Density Test: Distribution of Running Variable', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(FIG_DIR / "figure1_mccrary_density.png", dpi=300, bbox_inches='tight')
    plt.close(fig)
    
    print(f"Saved McCrary density plot to {FIG_DIR / 'figure1_mccrary_density.png'}")
    
    return {
        'log_discontinuity': log_disc,
        'pred_left': pred_at_cutoff_left,
        'pred_right': pred_at_cutoff_right
    }

def rd_plot(df, outcome_var, outcome_label, bandwidth=18, n_bins=20, filename=None):
    """
    Create RD plot with binned scatter and local linear fits.
    """
    # Restrict to bandwidth
    pov = df['poverty_1960'].values
    in_bw = (pov >= CUTOFF - bandwidth) & (pov <= CUTOFF + bandwidth)
    df_bw = df[in_bw].copy()
    
    # Remove missing outcomes
    df_bw = df_bw[df_bw[outcome_var].notna()].copy()
    
    if len(df_bw) < 50:
        print(f"Warning: Only {len(df_bw)} observations with non-missing {outcome_var}")
        return None
    
    # Create bins
    bins = np.linspace(CUTOFF - bandwidth, CUTOFF + bandwidth, n_bins + 1)
    df_bw['bin'] = pd.cut(df_bw['poverty_1960'], bins=bins, labels=False, include_lowest=True)
    
    # Calculate bin means
    bin_means = df_bw.groupby('bin').agg({
        'poverty_1960': 'mean',
        outcome_var: 'mean'
    }).reset_index()
    bin_means = bin_means.dropna()
    
    # Fit local linear regressions
    left_data = df_bw[df_bw['poverty_1960'] < CUTOFF]
    right_data = df_bw[df_bw['poverty_1960'] >= CUTOFF]
    
    # Left fit
    if len(left_data) > 10:
        X_left = left_data['poverty_1960'].values
        y_left = left_data[outcome_var].values
        slope_left, intercept_left, _, _, se_left = stats.linregress(X_left, y_left)
        x_fit_left = np.linspace(CUTOFF - bandwidth, CUTOFF, 50)
        y_fit_left = intercept_left + slope_left * x_fit_left
        pred_left = intercept_left + slope_left * CUTOFF
    else:
        x_fit_left = np.array([])
        y_fit_left = np.array([])
        pred_left = None
    
    # Right fit
    if len(right_data) > 10:
        X_right = right_data['poverty_1960'].values
        y_right = right_data[outcome_var].values
        slope_right, intercept_right, _, _, se_right = stats.linregress(X_right, y_right)
        x_fit_right = np.linspace(CUTOFF, CUTOFF + bandwidth, 50)
        y_fit_right = intercept_right + slope_right * x_fit_right
        pred_right = intercept_right + slope_right * CUTOFF
    else:
        x_fit_right = np.array([])
        y_fit_right = np.array([])
        pred_right = None
    
    # Calculate RD estimate
    if pred_left is not None and pred_right is not None:
        rd_estimate = pred_right - pred_left
    else:
        rd_estimate = None
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 7))
    
    # Binned scatter
    ax.scatter(bin_means['poverty_1960'], bin_means[outcome_var], 
               s=100, color='steelblue', alpha=0.7, zorder=5, edgecolors='black', linewidth=0.5)
    
    # Fitted lines
    if len(x_fit_left) > 0:
        ax.plot(x_fit_left, y_fit_left, color='darkblue', linewidth=2, label='Left fit')
    if len(x_fit_right) > 0:
        ax.plot(x_fit_right, y_fit_right, color='darkred', linewidth=2, label='Right fit')
    
    # Cutoff
    ax.axvline(CUTOFF, color='red', linestyle='--', linewidth=2, alpha=0.7)
    
    # Labels
    ax.set_xlabel('County 1960 Poverty Rate (%)', fontsize=12)
    ax.set_ylabel(outcome_label, fontsize=12)
    
    if rd_estimate is not None:
        title = f'RD Plot: {outcome_label}\nRD Estimate = {rd_estimate:.3f}'
    else:
        title = f'RD Plot: {outcome_label}'
    ax.set_title(title, fontsize=14)
    
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    
    if filename:
        fig.savefig(FIG_DIR / filename, dpi=300, bbox_inches='tight')
        print(f"Saved RD plot to {FIG_DIR / filename}")
    
    plt.close(fig)
    
    return {
        'rd_estimate': rd_estimate,
        'n_left': len(left_data),
        'n_right': len(right_data),
        'pred_left': pred_left,
        'pred_right': pred_right
    }

def estimate_rdd(df, outcome_var, bandwidth=18, polynomial=1):
    """
    Estimate RDD using OLS with specified polynomial order.
    
    Model: Y = α + τ*D + β₁*(X-c) + β₂*D*(X-c) + ε
    
    Where D = 1 if X >= c (above cutoff)
    """
    # Restrict to bandwidth
    pov = df['poverty_1960'].values
    in_bw = (pov >= CUTOFF - bandwidth) & (pov <= CUTOFF + bandwidth)
    df_bw = df[in_bw].copy()
    
    # Remove missing outcomes
    df_bw = df_bw[df_bw[outcome_var].notna()].copy()
    
    if len(df_bw) < 50:
        return None
    
    # Create variables
    df_bw['X_centered'] = df_bw['poverty_1960'] - CUTOFF
    df_bw['D'] = (df_bw['poverty_1960'] >= CUTOFF).astype(float)
    df_bw['D_X'] = df_bw['D'] * df_bw['X_centered']
    
    # Design matrix
    if polynomial == 1:
        X_vars = ['D', 'X_centered', 'D_X']
    elif polynomial == 2:
        df_bw['X_centered_sq'] = df_bw['X_centered'] ** 2
        df_bw['D_X_sq'] = df_bw['D'] * df_bw['X_centered_sq']
        X_vars = ['D', 'X_centered', 'D_X', 'X_centered_sq', 'D_X_sq']
    else:
        X_vars = ['D', 'X_centered', 'D_X']
    
    # Manual OLS
    y = df_bw[outcome_var].values
    X = np.column_stack([np.ones(len(df_bw))] + [df_bw[v].values for v in X_vars])
    
    # OLS: β = (X'X)^(-1) X'y
    try:
        beta = np.linalg.solve(X.T @ X, X.T @ y)
    except np.linalg.LinAlgError:
        return None
    
    # Residuals and standard errors
    y_hat = X @ beta
    resid = y - y_hat
    n = len(y)
    k = X.shape[1]
    s2 = (resid ** 2).sum() / (n - k)
    
    # Robust (HC1) standard errors
    XtX_inv = np.linalg.inv(X.T @ X)
    meat = np.zeros((k, k))
    for i in range(n):
        meat += (resid[i] ** 2) * np.outer(X[i], X[i])
    var_robust = XtX_inv @ meat @ XtX_inv * (n / (n - k))
    se_robust = np.sqrt(np.diag(var_robust))
    
    # Treatment effect is beta[1] (coefficient on D)
    tau = beta[1]
    se_tau = se_robust[1]
    t_stat = tau / se_tau
    p_value = 2 * (1 - stats.t.cdf(abs(t_stat), n - k))
    
    return {
        'tau': tau,
        'se': se_tau,
        't_stat': t_stat,
        'p_value': p_value,
        'n_obs': n,
        'bandwidth': bandwidth,
        'polynomial': polynomial,
        'ci_lower': tau - 1.96 * se_tau,
        'ci_upper': tau + 1.96 * se_tau
    }

def main():
    """Run the full RDD analysis."""
    print("="*60)
    print("HEAD START RDD ANALYSIS")
    print("Ludwig-Miller (2007) Replication and Extension")
    print("="*60)
    
    # Load data
    df = load_data()
    
    # Summary statistics
    print("\n" + "="*60)
    print("Summary Statistics")
    print("="*60)
    print(f"\nCounties above cutoff (treated): {df['above_cutoff'].sum()}")
    print(f"Counties below cutoff (control): {(1 - df['above_cutoff']).sum()}")
    print(f"Poverty rate range: {df['poverty_1960'].min():.2f}% - {df['poverty_1960'].max():.2f}%")
    print(f"Cutoff: {CUTOFF}%")
    
    # McCrary density test
    mccrary_result = mccrary_density_test(df, bandwidth=18)
    
    # Primary outcome: Child mortality (ages 5-9, Head Start related causes)
    # This is the original Ludwig-Miller outcome
    primary_outcome = 'mort_age59_related_postHS'
    primary_label = 'Mortality Rate (Ages 5-9, HS-Related Causes)'
    
    print("\n" + "="*60)
    print(f"Main RD Analysis: {primary_outcome}")
    print("="*60)
    
    # RD plot for primary outcome
    rd_plot_result = rd_plot(df, primary_outcome, primary_label, 
                             bandwidth=18, filename="figure2_rd_mortality.png")
    
    if rd_plot_result:
        print(f"\nRD estimate (graphical): {rd_plot_result['rd_estimate']:.3f}")
        print(f"N left of cutoff: {rd_plot_result['n_left']}")
        print(f"N right of cutoff: {rd_plot_result['n_right']}")
    
    # Formal RDD estimates
    print("\n" + "-"*60)
    print("Formal RDD Estimates (Local Linear)")
    print("-"*60)
    
    results = {}
    bandwidths = [10, 12, 15, 18, 20]
    
    for bw in bandwidths:
        est = estimate_rdd(df, primary_outcome, bandwidth=bw, polynomial=1)
        if est:
            results[f'bw_{bw}_linear'] = est
            sig = "*" if est['p_value'] < 0.05 else ""
            sig += "*" if est['p_value'] < 0.01 else ""
            sig += "*" if est['p_value'] < 0.001 else ""
            print(f"Bandwidth = {bw}pp: τ = {est['tau']:.3f} (SE = {est['se']:.3f}){sig}, N = {est['n_obs']}")
    
    # Quadratic specification for primary bandwidth
    print("\n" + "-"*60)
    print("Polynomial Sensitivity (Bandwidth = 18)")
    print("-"*60)
    
    for poly in [1, 2]:
        est = estimate_rdd(df, primary_outcome, bandwidth=18, polynomial=poly)
        if est:
            results[f'bw_18_poly{poly}'] = est
            sig = "*" if est['p_value'] < 0.05 else ""
            print(f"Polynomial = {poly}: τ = {est['tau']:.3f} (SE = {est['se']:.3f}){sig}")
    
    # Additional outcomes
    print("\n" + "="*60)
    print("Additional Outcome Analysis")
    print("="*60)
    
    other_outcomes = [
        ('mort_age59_injury_postHS', 'Injury Mortality (Ages 5-9)'),
        ('mort_age59_all_postHS', 'All-Cause Mortality (Ages 5-9)'),
        ('mort_age59_related_preHS', 'HS-Related Mortality (Pre-Treatment Placebo)'),
    ]
    
    for outcome_var, outcome_label in other_outcomes:
        if outcome_var in df.columns:
            est = estimate_rdd(df, outcome_var, bandwidth=18, polynomial=1)
            if est:
                sig = "*" if est['p_value'] < 0.05 else ""
                print(f"{outcome_label}: τ = {est['tau']:.3f} (SE = {est['se']:.3f}){sig}")
                results[outcome_var] = est
    
    # Placebo test: Pre-treatment mortality (should show no effect)
    print("\n" + "-"*60)
    print("Placebo Test: Pre-Head-Start Mortality")
    print("-"*60)
    
    placebo_var = 'mort_age59_related_preHS'
    if placebo_var in df.columns:
        rd_plot_result_placebo = rd_plot(df, placebo_var, 
                                         'Mortality Rate (Pre-Head Start Period)',
                                         bandwidth=18, filename="figure3_rd_placebo.png")
        
        est_placebo = estimate_rdd(df, placebo_var, bandwidth=18, polynomial=1)
        if est_placebo:
            print(f"Pre-HS Mortality: τ = {est_placebo['tau']:.3f} (SE = {est_placebo['se']:.3f})")
            print(f"P-value: {est_placebo['p_value']:.3f}")
            if est_placebo['p_value'] > 0.05:
                print("✓ Placebo test passed: No significant effect on pre-treatment outcome")
            else:
                print("⚠ Placebo test concern: Significant effect on pre-treatment outcome")
    
    # Bandwidth sensitivity plot
    print("\n" + "-"*60)
    print("Creating bandwidth sensitivity plot...")
    print("-"*60)
    
    bw_range = list(range(8, 25, 2))
    tau_values = []
    se_values = []
    
    for bw in bw_range:
        est = estimate_rdd(df, primary_outcome, bandwidth=bw, polynomial=1)
        if est:
            tau_values.append(est['tau'])
            se_values.append(est['se'])
        else:
            tau_values.append(np.nan)
            se_values.append(np.nan)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.errorbar(bw_range, tau_values, yerr=[1.96*se for se in se_values], 
                fmt='o-', capsize=5, color='steelblue', linewidth=2, markersize=8)
    ax.axhline(0, color='black', linestyle='--', alpha=0.5)
    ax.axvline(18, color='red', linestyle='--', alpha=0.5, label='Primary bandwidth')
    ax.set_xlabel('Bandwidth (percentage points)', fontsize=12)
    ax.set_ylabel('RD Estimate (τ)', fontsize=12)
    ax.set_title('Bandwidth Sensitivity Analysis', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(FIG_DIR / "figure4_bandwidth_sensitivity.png", dpi=300, bbox_inches='tight')
    plt.close(fig)
    
    print(f"Saved bandwidth sensitivity plot")
    
    # Save results
    results_summary = {
        'mccrary': mccrary_result,
        'primary_outcome': primary_outcome,
        'estimates': {k: {
            'tau': v['tau'],
            'se': v['se'],
            'p_value': v['p_value'],
            'n_obs': v['n_obs'],
            'ci_lower': v['ci_lower'],
            'ci_upper': v['ci_upper']
        } for k, v in results.items()}
    }
    
    with open(DATA_DIR / "analysis_results.json", 'w') as f:
        json.dump(results_summary, f, indent=2)
    
    print("\n" + "="*60)
    print("ANALYSIS COMPLETE")
    print("="*60)
    print(f"\nResults saved to {DATA_DIR / 'analysis_results.json'}")
    print(f"Figures saved to {FIG_DIR}")
    
    return results_summary

if __name__ == "__main__":
    main()
