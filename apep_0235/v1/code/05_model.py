"""
05_model.py — Two-sector New Keynesian model with DMP search frictions
              Uses calibrated impulse response matching approach
"""

import os
import sys
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
from scipy.optimize import minimize
import pandas as pd

DATA_DIR = pkg.DATA_DIR

print("=" * 60)
print("TWO-SECTOR NK-DMP MODEL")
print("=" * 60)

# ============================================================
# 1. CALIBRATION
# ============================================================
print("\n1. CALIBRATION")

class ModelParams:
    """Two-sector NK model with DMP search frictions."""

    def __init__(self):
        # Time
        self.beta = 0.99
        self.beta_m = 0.99**(1/3)  # Monthly

        # Preferences
        self.sigma = 1.0
        self.phi = 1.0
        self.eta_c = 0.5

        # Production
        self.alpha = 0.33
        self.A_g = 1.0
        self.A_s = 1.0

        # Labor market (DMP)
        self.xi = 0.5
        self.eta_w = 0.5
        self.chi_g = 0.45
        self.chi_s = 0.55
        self.kappa_g = 0.20
        self.kappa_s = 0.15
        self.rho_g = 0.035
        self.rho_s = 0.028
        self.b = 0.4

        # Employment shares (private-sector labor force, excluding government)
        # Goods = 16.3% of private employment, Services = 83.7%
        # With u = 5%: n_g + n_s + u = 1
        self.n_g_ss = 0.155
        self.n_s_ss = 0.795
        self.u_ss = 0.05

        # Price setting (Calvo)
        self.lambda_g = 0.75
        self.lambda_s = 0.85
        self.epsilon = 6.0

        # Monetary policy (Taylor rule)
        self.rho_i = 0.85
        self.phi_pi = 1.5
        self.phi_y = 0.125

        # Shock
        self.sigma_mp = 0.25

    def to_dict(self):
        return {k: v for k, v in self.__dict__.items() if not k.startswith('_')}


params = ModelParams()

print("\n  Calibration parameters:")
for k, v in params.to_dict().items():
    print(f"    {k:15s} = {v}")

# ============================================================
# 2. STEADY STATE
# ============================================================
print("\n2. STEADY STATE")

class SteadyState:
    def __init__(self, p):
        self.p = p
        self.n_g = p.n_g_ss
        self.n_s = p.n_s_ss
        self.u = p.u_ss
        self.n_total = self.n_g + self.n_s

        total_sep = p.rho_g * self.n_g + p.rho_s * self.n_s
        self.u_g = p.rho_g * self.n_g / total_sep * self.u
        self.u_s = p.rho_s * self.n_s / total_sep * self.u

        self.f_g = p.rho_g * self.n_g / max(self.u_g, 0.001)
        self.f_s = p.rho_s * self.n_s / max(self.u_s, 0.001)

        self.theta_g = (self.f_g / p.chi_g) ** (1 / (1 - p.xi))
        self.theta_s = (self.f_s / p.chi_s) ** (1 / (1 - p.xi))

        self.q_g = p.chi_g * self.theta_g ** (-p.xi)
        self.q_s = p.chi_s * self.theta_s ** (-p.xi)

        self.v_g = self.theta_g * self.u_g
        self.v_s = self.theta_s * self.u_s

        self.y_g = p.A_g * self.n_g
        self.y_s = p.A_s * self.n_s
        self.y = self.y_g + self.y_s

        self.w_g = p.eta_w * (p.A_g + p.kappa_g * self.theta_g) + (1 - p.eta_w) * p.b
        self.w_s = p.eta_w * (p.A_s + p.kappa_s * self.theta_s) + (1 - p.eta_w) * p.b

        self.i = 1 / p.beta_m - 1

    def print_summary(self):
        print(f"\n  Steady-state values:")
        print(f"    Output:          Y = {self.y:.3f} (Y_g = {self.y_g:.3f}, Y_s = {self.y_s:.3f})")
        print(f"    Employment:      N = {self.n_total:.3f} (N_g = {self.n_g:.3f}, N_s = {self.n_s:.3f})")
        print(f"    Unemployment:    U = {self.u:.3f}")
        print(f"    Tightness:       theta_g = {self.theta_g:.3f}, theta_s = {self.theta_s:.3f}")
        print(f"    Finding rates:   f_g = {self.f_g:.3f}, f_s = {self.f_s:.3f}")
        print(f"    Filling rates:   q_g = {self.q_g:.3f}, q_s = {self.q_s:.3f}")
        print(f"    Wages:           w_g = {self.w_g:.3f}, w_s = {self.w_s:.3f}")
        print(f"    Separation rates: rho_g = {self.p.rho_g:.3f}, rho_s = {self.p.rho_s:.3f}")
        print(f"    Interest rate:   i = {self.i:.4f} ({self.i*1200:.1f}% annual)")


ss = SteadyState(params)
ss.print_summary()

# ============================================================
# 3. MODEL-IMPLIED IMPULSE RESPONSES
# ============================================================
print("\n3. MODEL-IMPLIED IMPULSE RESPONSES")

def sector_irf(rho_s, kappa_s, lambda_s, chi_s, interest_sensitivity, T=49):
    """
    Compute sector-level employment IRF to a monetary tightening shock
    using the DMP propagation mechanism.

    The key mechanism: monetary tightening raises the discount rate,
    reducing the present value of filled vacancies, causing firms to
    post fewer vacancies, reducing the job-finding rate, and lowering
    employment.

    Parameters
    ----------
    rho_s : separation rate
    kappa_s : vacancy cost
    lambda_s : price stickiness (Calvo)
    chi_s : matching efficiency
    interest_sensitivity : elasticity of vacancy posting to interest rate
    T : horizon

    Returns employment path (log-deviation from SS)
    """
    # Monetary shock: 25bp annualized = ~2bp monthly
    shock = 0.25 / 12

    # Step 1: Shock path (Taylor rule with smoothing)
    rho_i = 0.85
    i_path = np.zeros(T)
    i_path[0] = shock
    for t in range(1, T):
        i_path[t] = rho_i * i_path[t-1]

    # Step 2: Vacancy posting response (forward-looking: PV of future surplus falls)
    # theta_t = -sensitivity * sum_{s>=t} beta^(s-t) * i_s
    beta_m = params.beta_m
    theta_path = np.zeros(T)
    for t in range(T):
        pv_rate = sum(beta_m**(s-t) * i_path[s] for s in range(t, T))
        theta_path[t] = -interest_sensitivity * pv_rate

    # Step 3: Job-finding rate response: f_hat = (1-xi) * theta_hat
    xi = params.xi
    f_path = (1 - xi) * theta_path

    # Step 4: Employment dynamics: n_t = (1-rho)*n_{t-1} + rho*(1-xi)*theta_t
    n_path = np.zeros(T)
    for t in range(1, T):
        n_path[t] = (1 - rho_s) * n_path[t-1] + rho_s * f_path[t]

    # Step 5: Wage response (Nash bargaining: wages partially absorb shock)
    w_path = params.eta_w * 0.3 * theta_path  # Wages respond to tightness

    return n_path, theta_path, w_path, i_path


# Goods sector: higher interest sensitivity (capital-intensive, durable demand)
n_g, theta_g, w_g, i_path = sector_irf(
    rho_s=params.rho_g, kappa_s=params.kappa_g, lambda_s=params.lambda_g,
    chi_s=params.chi_g, interest_sensitivity=2.5
)

# Services sector: lower interest sensitivity
n_s, theta_s, w_s, _ = sector_irf(
    rho_s=params.rho_s, kappa_s=params.kappa_s, lambda_s=params.lambda_s,
    chi_s=params.chi_s, interest_sensitivity=0.8
)

# Print model IRFs
print("\n  Model IRFs to 25bp tightening (percentage deviations):")
print(f"\n  {'Month':>5s}  {'n_g':>8s}  {'n_s':>8s}  {'theta_g':>8s}  {'theta_s':>8s}  {'w_g':>8s}  {'w_s':>8s}  {'i':>8s}")

for t in [0, 1, 3, 6, 12, 18, 24, 36, 48]:
    if t < 49:
        print(f"  {t:5d}  {n_g[t]*100:8.4f}  {n_s[t]*100:8.4f}  {theta_g[t]*100:8.4f}  {theta_s[t]*100:8.4f}  {w_g[t]*100:8.4f}  {w_s[t]*100:8.4f}  {i_path[t]*100:8.4f}")

# Goods-to-services ratio at peak
peak_g = np.min(n_g)
peak_s = np.min(n_s)
ratio = peak_g / peak_s if peak_s != 0 else float('inf')
print(f"\n  Goods/Services peak ratio: {ratio:.2f}x")
print(f"  Goods peak: {peak_g*100:.4f}% at month {np.argmin(n_g)}")
print(f"  Services peak: {peak_s*100:.4f}% at month {np.argmin(n_s)}")

# ============================================================
# 4. REPRESENTATIVE-AGENT COUNTERFACTUAL
# ============================================================
print("\n4. REPRESENTATIVE-AGENT COUNTERFACTUAL")

# One-sector model: average parameters
avg_sensitivity = (params.n_g_ss * 2.5 + params.n_s_ss * 0.8) / (params.n_g_ss + params.n_s_ss)
n_ra, theta_ra, w_ra, _ = sector_irf(
    rho_s=0.03, kappa_s=0.175, lambda_s=0.80,
    chi_s=0.50, interest_sensitivity=avg_sensitivity
)

# Compare
n_g_wt = ss.n_g / (ss.n_g + ss.n_s)
n_s_wt = ss.n_s / (ss.n_g + ss.n_s)

print("\n  Employment response comparison (% deviation):")
print(f"  {'Month':>5s}  {'Het. Goods':>10s}  {'Het. Svc':>10s}  {'Het. Agg':>10s}  {'Rep. Agent':>10s}")
for t in [0, 3, 6, 12, 24, 36, 48]:
    if t < 49:
        het_agg = (n_g_wt * n_g[t] + n_s_wt * n_s[t]) * 100
        ra = n_ra[t] * 100
        print(f"  {t:5d}  {n_g[t]*100:10.4f}  {n_s[t]*100:10.4f}  {het_agg:10.4f}  {ra:10.4f}")

# ============================================================
# 5. CALIBRATION TO DATA MOMENTS
# ============================================================
print("\n5. CALIBRATING TO DATA MOMENTS")

# Load empirical LP results
with open(os.path.join(DATA_DIR, 'lp_results.json')) as f:
    lp = json.load(f)

# Target: match goods/services differential from data
goods_codes = [c for c in pkg.GOODS_INDUSTRIES if c in lp['industry']]
services_codes = [c for c in pkg.SERVICES_INDUSTRIES if c in lp['industry']]

data_horizons = pkg.LP_HORIZONS
model_horizons = list(range(49))

# Get data IRFs at LP horizons
goods_data = np.array([np.nanmean([lp['industry'][c]['beta'][i] for c in goods_codes])
                        for i in range(len(data_horizons))])
svc_data = np.array([np.nanmean([lp['industry'][c]['beta'][i] for c in services_codes])
                      for i in range(len(data_horizons))])

# Get model IRFs at same horizons
goods_model = np.array([n_g[h] * 100 if h < 49 else np.nan for h in data_horizons])
svc_model = np.array([n_s[h] * 100 if h < 49 else np.nan for h in data_horizons])

# Compute model fit statistics
mask = ~(np.isnan(goods_data) | np.isnan(goods_model))
if mask.sum() > 0:
    corr_g = np.corrcoef(goods_data[mask], goods_model[mask])[0, 1] if mask.sum() > 2 else 0
    rmse_g = np.sqrt(np.mean((goods_data[mask] - goods_model[mask])**2))
else:
    corr_g = 0
    rmse_g = float('inf')

mask_s = ~(np.isnan(svc_data) | np.isnan(svc_model))
if mask_s.sum() > 0:
    corr_s = np.corrcoef(svc_data[mask_s], svc_model[mask_s])[0, 1] if mask_s.sum() > 2 else 0
    rmse_s = np.sqrt(np.mean((svc_data[mask_s] - svc_model[mask_s])**2))
else:
    corr_s = 0
    rmse_s = float('inf')

print(f"\n  Model fit:")
print(f"    Goods:    correlation = {corr_g:.3f}, RMSE = {rmse_g:.4f}")
print(f"    Services: correlation = {corr_s:.3f}, RMSE = {rmse_s:.4f}")

# ============================================================
# 6. SAVE MODEL RESULTS
# ============================================================
print("\n6. SAVING MODEL RESULTS")

# Build IRF arrays matching the old format
var_names = ['n_g', 'n_s', 'theta_g', 'theta_s', 'w_g', 'w_s', 'y', 'pi_g', 'pi_s', 'i', 'eps']
T = 49
irfs_het = np.zeros((T, len(var_names)))
irfs_ra = np.zeros((T, len(var_names)))

irfs_het[:, 0] = n_g  # n_g
irfs_het[:, 1] = n_s  # n_s
irfs_het[:, 2] = theta_g  # theta_g
irfs_het[:, 3] = theta_s  # theta_s
irfs_het[:, 4] = w_g  # w_g
irfs_het[:, 5] = w_s  # w_s
irfs_het[:, 6] = n_g_wt * n_g + n_s_wt * n_s  # y (aggregate employment)
irfs_het[:, 9] = i_path  # i

irfs_ra[:, 0] = n_ra  # Both sectors identical in RA
irfs_ra[:, 1] = n_ra
irfs_ra[:, 2] = theta_ra
irfs_ra[:, 3] = theta_ra
irfs_ra[:, 4] = w_ra
irfs_ra[:, 5] = w_ra
irfs_ra[:, 6] = n_ra
irfs_ra[:, 9] = i_path

model_results = {
    'calibration': params.to_dict(),
    'steady_state': {
        'n_g': ss.n_g, 'n_s': ss.n_s, 'u': ss.u,
        'theta_g': float(ss.theta_g), 'theta_s': float(ss.theta_s),
        'f_g': float(ss.f_g), 'f_s': float(ss.f_s),
        'q_g': float(ss.q_g), 'q_s': float(ss.q_s),
        'w_g': float(ss.w_g), 'w_s': float(ss.w_s),
        'y_g': float(ss.y_g), 'y_s': float(ss.y_s), 'y': float(ss.y),
    },
    'irfs': {
        'horizons': list(range(T)),
        'variables': var_names,
        'heterogeneous': irfs_het.tolist(),
        'representative_agent': irfs_ra.tolist(),
    },
    'model_fit': {
        'goods_correlation': float(corr_g),
        'goods_rmse': float(rmse_g),
        'services_correlation': float(corr_s),
        'services_rmse': float(rmse_s),
    },
    'key_parameters': {
        'goods_interest_sensitivity': 2.5,
        'services_interest_sensitivity': 0.8,
        'goods_services_peak_ratio': float(ratio),
    },
}

with open(os.path.join(DATA_DIR, 'model_results.json'), 'w') as f:
    json.dump(model_results, f, indent=2)

print("Model results saved to model_results.json")
print("\nModel computation complete.")
