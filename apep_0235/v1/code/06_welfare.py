"""
06_welfare.py — Welfare analysis: consumption-equivalent losses by worker type,
                representative-agent counterfactual comparison
"""

import os
import sys
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
import pandas as pd

DATA_DIR = pkg.DATA_DIR

print("=" * 60)
print("WELFARE ANALYSIS")
print("=" * 60)

# ============================================================
# 1. Load model results
# ============================================================
with open(os.path.join(DATA_DIR, 'model_results.json')) as f:
    model = json.load(f)

irfs_het = np.array(model['irfs']['heterogeneous'])
irfs_ra = np.array(model['irfs']['representative_agent'])
var_names = model['irfs']['variables']
cal = model['calibration']
ss = model['steady_state']

# Variable indices
NG, NS, TG, TS, WG, WS, Y, PIG, PIS, I, EPS = range(11)

print("\nLoaded model with", irfs_het.shape[0], "periods")

# ============================================================
# 2. Consumption-Equivalent Welfare Calculation
# ============================================================
print("\n2. CONSUMPTION-EQUIVALENT WELFARE LOSSES")

# Welfare = E[sum_{t=0}^T beta^t * u(c_t, n_t)]
# With CRRA preferences: u(c,n) = c^(1-sigma)/(1-sigma) - phi*n^(1+1/phi_e)/(1+1/phi_e)
# CE welfare loss: lambda such that u((1-lambda)*c_ss) = u(c_ss) + Delta_W

sigma = cal['sigma']
beta_m = cal['beta_m']
T = 48  # Horizon for welfare calculation

def compute_welfare_loss(irfs, sector_idx_n, sector_idx_w, n_ss, w_ss, label):
    """
    Compute consumption-equivalent welfare loss for a worker type.

    Workers in sector s consume c = w * n (wage income).
    Welfare loss from employment + wage declines.
    """
    # Employment and wage paths (log-deviations)
    n_path = irfs[:T+1, sector_idx_n]
    w_path = irfs[:T+1, sector_idx_w]

    # Consumption deviation: hat_c = hat_w + hat_n (log-linear)
    c_path = n_path + w_path

    # Discounted welfare loss (percentage terms)
    discount = np.array([beta_m**t for t in range(T+1)])

    # Present value of consumption loss (in percent of SS consumption)
    pv_c_loss = np.sum(discount * c_path) * 100

    # Employment loss (in percent of SS employment)
    pv_n_loss = np.sum(discount * n_path) * 100

    # Consumption-equivalent = annualized PV loss / (1/(1-beta))
    annuity_factor = (1 - beta_m**(T+1)) / (1 - beta_m)
    ce_loss = pv_c_loss / annuity_factor  # % per period

    # Annualize
    ce_annual = ce_loss * 12  # Monthly to annual

    print(f"\n  {label}:")
    print(f"    PV consumption loss: {pv_c_loss:.4f}% of SS")
    print(f"    PV employment loss:  {pv_n_loss:.4f}% of SS")
    print(f"    CE welfare loss:     {ce_annual:.4f}% annual")
    print(f"    Peak employment:     {np.min(n_path)*100:.4f}% at month {np.argmin(n_path)}")
    print(f"    Peak wage:           {np.min(w_path)*100:.4f}% at month {np.argmin(w_path)}")

    return {
        'pv_consumption_loss_pct': float(pv_c_loss),
        'pv_employment_loss_pct': float(pv_n_loss),
        'ce_welfare_loss_annual_pct': float(ce_annual),
        'peak_employment_pct': float(np.min(n_path) * 100),
        'peak_employment_month': int(np.argmin(n_path)),
        'peak_wage_pct': float(np.min(w_path) * 100),
        'peak_wage_month': int(np.argmin(w_path)),
    }


# Heterogeneous model
goods_het = compute_welfare_loss(irfs_het, NG, WG, ss['n_g'], ss['w_g'], "Goods workers (heterogeneous)")
services_het = compute_welfare_loss(irfs_het, NS, WS, ss['n_s'], ss['w_s'], "Services workers (heterogeneous)")

# Aggregate heterogeneous
n_g_share = ss['n_g'] / (ss['n_g'] + ss['n_s'])
n_s_share = ss['n_s'] / (ss['n_g'] + ss['n_s'])
agg_het_ce = n_g_share * goods_het['ce_welfare_loss_annual_pct'] + n_s_share * services_het['ce_welfare_loss_annual_pct']
print(f"\n  Aggregate (heterogeneous): CE = {agg_het_ce:.4f}% annual")

# Representative-agent model
goods_ra = compute_welfare_loss(irfs_ra, NG, WG, 0.43, ss['w_g'], "Goods workers (rep-agent)")
services_ra = compute_welfare_loss(irfs_ra, NS, WS, 0.43, ss['w_s'], "Services workers (rep-agent)")
agg_ra_ce = 0.5 * goods_ra['ce_welfare_loss_annual_pct'] + 0.5 * services_ra['ce_welfare_loss_annual_pct']
print(f"\n  Aggregate (rep-agent): CE = {agg_ra_ce:.4f}% annual")

# ============================================================
# 3. Distributional Welfare Gap
# ============================================================
print("\n3. DISTRIBUTIONAL WELFARE GAP")

if agg_ra_ce != 0:
    welfare_ratio = agg_het_ce / agg_ra_ce
else:
    welfare_ratio = float('inf')

goods_services_ratio = goods_het['ce_welfare_loss_annual_pct'] / services_het['ce_welfare_loss_annual_pct'] if services_het['ce_welfare_loss_annual_pct'] != 0 else float('inf')

print(f"\n  Het/RA welfare ratio:      {welfare_ratio:.2f}")
print(f"  Goods/Services loss ratio: {goods_services_ratio:.2f}")

# ============================================================
# 4. Welfare Decomposition
# ============================================================
print("\n4. WELFARE DECOMPOSITION")

# Decompose into: (a) employment loss, (b) wage loss, (c) transition cost
discount = np.array([beta_m**t for t in range(T+1)])
annuity = (1 - beta_m**(T+1)) / (1 - beta_m)

decomposition = {}
for label, irf, n_idx, w_idx in [
    ('goods', irfs_het, NG, WG),
    ('services', irfs_het, NS, WS),
]:
    n_path = irf[:T+1, n_idx]
    w_path = irf[:T+1, w_idx]

    # Employment component
    emp_loss = np.sum(discount * n_path) * 100 / annuity * 12

    # Wage component
    wage_loss = np.sum(discount * w_path) * 100 / annuity * 12

    # Transition/interaction
    transition = (np.sum(discount * (n_path + w_path)) * 100 / annuity * 12) - emp_loss - wage_loss

    decomposition[label] = {
        'employment_component': float(emp_loss),
        'wage_component': float(wage_loss),
        'transition_component': float(transition),
        'total': float(emp_loss + wage_loss + transition),
    }

    print(f"\n  {label.title()} sector decomposition:")
    print(f"    Employment channel: {emp_loss:.4f}%")
    print(f"    Wage channel:      {wage_loss:.4f}%")
    print(f"    Transition:        {transition:.4f}%")

# ============================================================
# 5. Policy Implications
# ============================================================
print("\n5. POLICY IMPLICATIONS")

# Optimal policy comparison: Taylor rule vs. sector-weighted rule
# If Fed responds to sectoral employment, welfare improves
print("\n  Standard Taylor rule: responds to aggregate inflation + output")
print(f"    Total welfare cost: {agg_het_ce:.4f}% annual")
print(f"    Goods workers bear {n_g_share*goods_het['ce_welfare_loss_annual_pct']/agg_het_ce*100:.0f}% of cost")
print(f"    Services workers bear {n_s_share*services_het['ce_welfare_loss_annual_pct']/agg_het_ce*100:.0f}% of cost")

# ============================================================
# 6. Save welfare results
# ============================================================
print("\n6. SAVING WELFARE RESULTS")

welfare_results = {
    'heterogeneous_model': {
        'goods_workers': goods_het,
        'services_workers': services_het,
        'aggregate_ce_annual_pct': float(agg_het_ce),
    },
    'representative_agent': {
        'goods_workers': goods_ra,
        'services_workers': services_ra,
        'aggregate_ce_annual_pct': float(agg_ra_ce),
    },
    'distributional_gap': {
        'het_ra_ratio': float(welfare_ratio),
        'goods_services_ratio': float(goods_services_ratio),
    },
    'decomposition': decomposition,
    'parameters': {
        'horizon_months': T,
        'discount_factor': float(beta_m),
        'goods_employment_share': float(n_g_share),
        'services_employment_share': float(n_s_share),
    },
}

with open(os.path.join(DATA_DIR, 'welfare_results.json'), 'w') as f:
    json.dump(welfare_results, f, indent=2)

print("Welfare results saved to welfare_results.json")
print("\nWelfare analysis complete.")
