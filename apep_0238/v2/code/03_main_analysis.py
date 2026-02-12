"""
03_main_analysis.py — LP-IV estimation for hysteresis comparison
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

with open(DATA_DIR / "processed_data.json") as f:
    proc = json.load(f)

bartik_gr = proc['bartik_gr']
bartik_covid = proc['bartik_covid']
hpi_boom = proc['hpi_boom']
gr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_paths'].items()}
covid_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_paths'].items()}
gr_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_ur_paths'].items()}
gr_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_lfpr_paths'].items()}
covid_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_ur_paths'].items()}
covid_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_lfpr_paths'].items()}

# ──────────────────────────────────────────────────────────────
# LP estimation functions
# ──────────────────────────────────────────────────────────────

def lp_ols(paths, instrument, horizons, controls=None):
    """
    Cross-sectional LP: Δy_{s,h} = α + β_h * Z_s + ε_{s,h}
    Returns: betas, ses, n_obs, r2s, pvals at each horizon
    """
    results = []
    for h in horizons:
        # Build cross-section
        y_list, x_list = [], []
        for st in sorted(paths.keys()):
            if st not in instrument:
                continue
            if h not in paths[st]:
                continue
            y_list.append(paths[st][h])
            x_list.append(instrument[st])

        y = np.array(y_list)
        x = np.array(x_list)

        if len(y) < 10:
            results.append({'h': h, 'beta': np.nan, 'se': np.nan,
                           'n': len(y), 'r2': np.nan, 'pval': np.nan})
            continue

        # OLS with constant
        X = np.column_stack([np.ones(len(x)), x])
        if controls is not None:
            ctrl_vals = []
            for st in sorted(paths.keys()):
                if st in instrument and h in paths[st]:
                    ctrl_vals.append(controls.get(st, 0))
            X = np.column_stack([X, np.array(ctrl_vals)])

        try:
            beta_hat = np.linalg.lstsq(X, y, rcond=None)[0]
            resid = y - X @ beta_hat
            n = len(y)
            k = X.shape[1]
            sigma2 = np.sum(resid**2) / (n - k)

            # HC1 robust standard errors
            meat = np.zeros((k, k))
            for i in range(n):
                xi = X[i:i+1, :]
                meat += (resid[i]**2) * (xi.T @ xi)
            bread = np.linalg.inv(X.T @ X)
            V_hc1 = (n / (n - k)) * bread @ meat @ bread
            se = np.sqrt(np.diag(V_hc1))

            # R-squared
            ss_res = np.sum(resid**2)
            ss_tot = np.sum((y - np.mean(y))**2)
            r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 0

            tstat = beta_hat[1] / se[1] if se[1] > 0 else 0
            pval = 2 * (1 - stats.t.cdf(abs(tstat), n - k))

            results.append({
                'h': h, 'beta': float(beta_hat[1]), 'se': float(se[1]),
                'n': n, 'r2': float(r2), 'pval': float(pval),
                'intercept': float(beta_hat[0])
            })
        except np.linalg.LinAlgError:
            results.append({'h': h, 'beta': np.nan, 'se': np.nan,
                           'n': len(y), 'r2': np.nan, 'pval': np.nan})
    return results

# ──────────────────────────────────────────────────────────────
# Main LP estimates
# ──────────────────────────────────────────────────────────────
print("="*60)
print("LOCAL PROJECTION ESTIMATES: EMPLOYMENT")
print("="*60)

# Key horizons for tables
table_horizons = [0, 3, 6, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120]
covid_table_horizons = [0, 3, 6, 12, 24, 36, 48]

# Fine horizons for figures (every 3 months)
fig_horizons = list(range(0, 133, 3))
covid_fig_horizons = list(range(0, 49, 3))

# 1. Great Recession — Bartik instrument
print("\n--- Great Recession: Bartik Instrument ---")
gr_bartik_results = lp_ols(gr_paths, bartik_gr, fig_horizons)
for r in gr_bartik_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 2. Great Recession — Housing price instrument
print("\n--- Great Recession: Housing Price Instrument ---")
gr_hpi_results = lp_ols(gr_paths, hpi_boom, fig_horizons)
for r in gr_hpi_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 3. COVID — Bartik instrument
print("\n--- COVID Recession: Bartik Instrument ---")
covid_bartik_results = lp_ols(covid_paths, bartik_covid, covid_fig_horizons)
for r in covid_bartik_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# ──────────────────────────────────────────────────────────────
# LP estimates for unemployment rate
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: UNEMPLOYMENT RATE")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_ur_results = lp_ols(gr_ur_paths, hpi_boom, fig_horizons)
for r in gr_ur_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_ur_results = lp_ols(covid_ur_paths, bartik_covid, covid_fig_horizons)
for r in covid_ur_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

# ──────────────────────────────────────────────────────────────
# LP estimates for LFPR
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: LFPR")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_lfpr_results = lp_ols(gr_lfpr_paths, hpi_boom, fig_horizons)
for r in gr_lfpr_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_lfpr_results = lp_ols(covid_lfpr_paths, bartik_covid, covid_fig_horizons)
for r in covid_lfpr_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

# ──────────────────────────────────────────────────────────────
# Half-life computation
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("HALF-LIFE ANALYSIS")
print("="*60)

def compute_half_life(results, negative=True):
    """Find the peak response and compute half-life (months to recover halfway).
    negative=True: look for most negative beta (demand recession)
    negative=False: look for most positive beta (supply recession / COVID)
    """
    valid = [r for r in results if not np.isnan(r['beta'])]
    if not valid:
        return 0, 0.0, np.nan

    if negative:
        peak = min(valid, key=lambda r: r['beta'])
        if peak['beta'] >= 0:
            return peak['h'], peak['beta'], np.nan
        half_target = peak['beta'] / 2
        for r in sorted(valid, key=lambda x: x['h']):
            if r['h'] > peak['h'] and r['beta'] > half_target:
                return peak['h'], peak['beta'], r['h'] - peak['h']
        return peak['h'], peak['beta'], np.inf
    else:
        peak = max(valid, key=lambda r: r['beta'])
        if peak['beta'] <= 0:
            return peak['h'], peak['beta'], np.nan
        half_target = peak['beta'] / 2
        for r in sorted(valid, key=lambda x: x['h']):
            if r['h'] > peak['h'] and r['beta'] < half_target:
                return peak['h'], peak['beta'], r['h'] - peak['h']
        return peak['h'], peak['beta'], np.inf

gr_peak_h, gr_peak_beta, gr_half_life = compute_half_life(gr_hpi_results, negative=True)
covid_peak_h, covid_peak_beta, covid_half_life = compute_half_life(covid_bartik_results, negative=False)

print(f"  Great Recession (HPI): peak at h={gr_peak_h}, β={gr_peak_beta:.4f}, half-life={gr_half_life} months")
print(f"  COVID (Bartik): peak at h={covid_peak_h}, β={covid_peak_beta:.4f}, half-life={covid_half_life} months")

# Persistence ratio: β at h=48 / β at peak
gr_48 = next((r['beta'] for r in gr_hpi_results if r['h'] == 48), np.nan)
gr_peak_val = next((r['beta'] for r in gr_hpi_results if r['h'] == gr_peak_h), np.nan)
covid_48 = next((r['beta'] for r in covid_bartik_results if r['h'] == 48), np.nan)
covid_peak_val = next((r['beta'] for r in covid_bartik_results if r['h'] == covid_peak_h), np.nan)

if gr_peak_val != 0 and not np.isnan(gr_peak_val):
    gr_persist = gr_48 / gr_peak_val
else:
    gr_persist = np.nan
if covid_peak_val != 0 and not np.isnan(covid_peak_val):
    covid_persist = covid_48 / covid_peak_val
else:
    covid_persist = np.nan

print(f"  Persistence ratio (β_48/β_peak):")
print(f"    Great Recession: {gr_persist:.3f}")
print(f"    COVID: {covid_persist:.3f}")

# ──────────────────────────────────────────────────────────────
# Save all results
# ──────────────────────────────────────────────────────────────
lp_results = {
    'gr_bartik': gr_bartik_results,
    'gr_hpi': gr_hpi_results,
    'covid_bartik': covid_bartik_results,
    'gr_ur': gr_ur_results,
    'covid_ur': covid_ur_results,
    'gr_lfpr': gr_lfpr_results,
    'covid_lfpr': covid_lfpr_results,
    'half_lives': {
        'gr': {'peak_h': gr_peak_h, 'peak_beta': gr_peak_beta, 'half_life': gr_half_life,
               'beta_48': gr_48, 'persistence': gr_persist},
        'covid': {'peak_h': covid_peak_h, 'peak_beta': covid_peak_beta, 'half_life': covid_half_life,
                  'beta_48': covid_48, 'persistence': covid_persist}
    }
}

with open(DATA_DIR / "lp_results.json", 'w') as f:
    json.dump(lp_results, f, indent=2, default=lambda x: None if (isinstance(x, float) and np.isnan(x)) else x)

print(f"\n✓ LP results saved to {DATA_DIR / 'lp_results.json'}")
