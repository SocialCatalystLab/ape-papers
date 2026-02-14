"""
03_main_analysis.py — LP-IV estimation for hysteresis comparison
v6: adds Saiz 2SLS, wild cluster bootstrap, AKM SEs, migration decomposition,
    and formal mechanism test
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

with open(DATA_DIR / "processed_data.json") as f:
    proc = json.load(f)

bartik_gr = proc['bartik_gr']
bartik_covid = proc['bartik_covid']
hpi_boom = proc['hpi_boom']
saiz_instrument = proc.get('saiz_instrument', {})
shares_covid = proc.get('shares_covid', {})
gr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_paths'].items()}
covid_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_paths'].items()}
gr_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_ur_paths'].items()}
gr_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['gr_lfpr_paths'].items()}
covid_ur_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_ur_paths'].items()}
covid_lfpr_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc['covid_lfpr_paths'].items()}
gr_emppop_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc.get('gr_emppop_paths', {}).items()}
covid_emppop_paths = {st: {int(k): v for k, v in p.items()} for st, p in proc.get('covid_emppop_paths', {}).items()}

# ──────────────────────────────────────────────────────────────
# Build pre-recession control vectors
# ──────────────────────────────────────────────────────────────
print("Building pre-recession control matrices...")

panel = pd.read_csv(DATA_DIR / "state_panel.csv")
panel['date'] = pd.to_datetime(panel['date'])
summary_df = pd.DataFrame(proc['summary'])

CENSUS_REGIONS_CTRL = {
    'Northeast': ['CT','ME','MA','NH','RI','VT','NJ','NY','PA'],
    'Midwest': ['IL','IN','IA','KS','MI','MN','MO','NE','ND','OH','SD','WI'],
    'South': ['AL','AR','DE','FL','GA','KY','LA','MD','MS','NC','OK','SC','TN','TX','VA','WV'],
    'West': ['AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY'],
}
STATE_TO_REGION_CTRL = {}
for region, sts in CENSUS_REGIONS_CTRL.items():
    for st in sts:
        STATE_TO_REGION_CTRL[st] = region

# Census division mapping for clustering
CENSUS_DIVISIONS = {
    'New England': ['CT','ME','MA','NH','RI','VT'],
    'Mid Atlantic': ['NJ','NY','PA'],
    'E N Central': ['IL','IN','MI','OH','WI'],
    'W N Central': ['IA','KS','MN','MO','NE','ND','SD'],
    'S Atlantic': ['DE','FL','GA','MD','NC','SC','VA','WV'],
    'E S Central': ['AL','KY','MS','TN'],
    'W S Central': ['AR','LA','OK','TX'],
    'Mountain': ['AZ','CO','ID','MT','NV','NM','UT','WY'],
    'Pacific': ['AK','CA','HI','OR','WA'],
}
STATE_TO_DIVISION = {}
for div, sts in CENSUS_DIVISIONS.items():
    for st in sts:
        STATE_TO_DIVISION[st] = div

def build_state_controls(states, emp_col, growth_start, growth_end):
    controls = {}
    for st in states:
        ctrl = []
        row = summary_df[summary_df['state'] == st]
        emp = float(row[emp_col].values[0]) if len(row) > 0 else np.nan
        ctrl.append(np.log(emp) if emp > 0 and not np.isnan(emp) else 0.0)
        st_panel = panel[panel['state'] == st].set_index('date').sort_index()
        try:
            start_dt = pd.Timestamp(growth_start)
            end_dt = pd.Timestamp(growth_end)
            emp_s = st_panel.loc[st_panel.index.asof(start_dt), 'emp']
            emp_e = st_panel.loc[st_panel.index.asof(end_dt), 'emp']
            growth = np.log(emp_e / emp_s) if emp_s > 0 else 0.0
        except (KeyError, ValueError):
            growth = 0.0
        ctrl.append(growth)
        region = STATE_TO_REGION_CTRL.get(st, 'West')
        ctrl.append(1.0 if region == 'Northeast' else 0.0)
        ctrl.append(1.0 if region == 'Midwest' else 0.0)
        ctrl.append(1.0 if region == 'South' else 0.0)
        controls[st] = np.array(ctrl)
    return controls

all_states = sorted(STATE_FIPS.keys())
gr_controls = build_state_controls(all_states, 'emp_2007', '2004-12-01', '2007-12-01')
covid_controls = build_state_controls(all_states, 'emp_2020', '2017-01-01', '2019-12-01')

print(f"  GR controls: {len(gr_controls)} states, {len(next(iter(gr_controls.values())))} variables")
print(f"  COVID controls: {len(covid_controls)} states, {len(next(iter(covid_controls.values())))} variables")

# ──────────────────────────────────────────────────────────────
# LP estimation functions
# ──────────────────────────────────────────────────────────────

def lp_ols(paths, instrument, horizons, controls=None, min_n=10):
    """Cross-sectional LP: Δy_{s,h} = α + β_h * Z_s + X_s'γ + ε_{s,h}"""
    results = []
    for h in horizons:
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

        if len(y) < min_n:
            results.append({'h': h, 'beta': np.nan, 'se': np.nan,
                           'n': len(y), 'r2': np.nan, 'pval': np.nan})
            continue

        X = np.column_stack([np.ones(len(x)), x])
        if controls is not None:
            ctrl_rows = []
            for st in sorted(paths.keys()):
                if st in instrument and h in paths[st]:
                    cv = controls.get(st)
                    if cv is not None:
                        ctrl_rows.append(np.asarray(cv, dtype=float))
            if ctrl_rows:
                ctrl_matrix = np.array(ctrl_rows)
                if ctrl_matrix.ndim == 1:
                    ctrl_matrix = ctrl_matrix.reshape(-1, 1)
                X = np.column_stack([X, ctrl_matrix])

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
# 2SLS: Saiz (2010) IV for housing exposure (WS1)
# ──────────────────────────────────────────────────────────────

def lp_2sls(paths, endogenous, instrument, horizons, controls=None, min_n=10):
    """
    2SLS LP: instrument Z (Saiz) → endogenous X (HPI) → outcome Y (employment)
    First stage: X_s = π_0 + π_1*Z_s + W_s'δ + v_s
    Second stage: Y_{s,h} = α + β_h*X̂_s + W_s'γ + ε_{s,h}
    Returns: list of result dicts with beta_iv, se_iv, first_stage_F, etc.
    """
    results = []
    for h in horizons:
        # Build aligned cross-section
        states_h = []
        for st in sorted(paths.keys()):
            if st in endogenous and st in instrument and h in paths[st]:
                states_h.append(st)

        n = len(states_h)
        if n < min_n:
            results.append({'h': h, 'beta_iv': np.nan, 'se_iv': np.nan,
                           'n': n, 'first_stage_F': np.nan, 'pval_iv': np.nan,
                           'ar_ci_low': np.nan, 'ar_ci_high': np.nan})
            continue

        y = np.array([paths[st][h] for st in states_h])
        x_endog = np.array([endogenous[st] for st in states_h])  # HPI
        z = np.array([instrument[st] for st in states_h])  # Saiz

        # Build W matrix (controls)
        W = np.ones((n, 1))  # intercept
        if controls is not None:
            ctrl_rows = [np.asarray(controls.get(st, np.zeros(5)), dtype=float) for st in states_h]
            ctrl_matrix = np.array(ctrl_rows)
            W = np.column_stack([W, ctrl_matrix])

        # First stage: x_endog = W*delta + z*pi + v
        Z_first = np.column_stack([W, z])
        try:
            pi_hat = np.linalg.lstsq(Z_first, x_endog, rcond=None)[0]
            x_hat = Z_first @ pi_hat
            v_first = x_endog - x_hat

            # First-stage F-statistic
            # Restricted model (without z)
            pi_restricted = np.linalg.lstsq(W, x_endog, rcond=None)[0]
            ssr_restricted = np.sum((x_endog - W @ pi_restricted)**2)
            ssr_unrestricted = np.sum(v_first**2)
            k_w = W.shape[1]
            F_stat = ((ssr_restricted - ssr_unrestricted) / 1) / (ssr_unrestricted / (n - k_w - 1))

            # Second stage: y = W*gamma + x_hat*beta + epsilon
            X_second = np.column_stack([W, x_hat])
            gamma_hat = np.linalg.lstsq(X_second, y, rcond=None)[0]
            beta_iv = gamma_hat[-1]  # last coefficient is on x_hat
            resid_2s = y - np.column_stack([W, x_endog]) @ gamma_hat  # Use actual x for residuals

            # 2SLS SE (HC1)
            k2 = X_second.shape[1]
            meat = np.zeros((k2, k2))
            for i in range(n):
                xi = X_second[i:i+1, :]
                meat += (resid_2s[i]**2) * (xi.T @ xi)
            bread = np.linalg.inv(X_second.T @ X_second)
            V_2sls = (n / (n - k2)) * bread @ meat @ bread
            se_iv = np.sqrt(V_2sls[-1, -1])

            tstat = beta_iv / se_iv if se_iv > 0 else 0
            pval_iv = 2 * (1 - stats.t.cdf(abs(tstat), n - k2))

            # Anderson-Rubin confidence interval (robust to weak instruments)
            ar_ci_low, ar_ci_high = anderson_rubin_ci(y, x_endog, z, W, alpha=0.05)

            results.append({
                'h': h, 'beta_iv': float(beta_iv), 'se_iv': float(se_iv),
                'n': n, 'first_stage_F': float(F_stat), 'pval_iv': float(pval_iv),
                'ar_ci_low': float(ar_ci_low), 'ar_ci_high': float(ar_ci_high),
                'beta_ols': float(next((r['beta'] for r in lp_ols(paths, endogenous, [h], controls) if r['h'] == h), np.nan)),
            })
        except (np.linalg.LinAlgError, ValueError):
            results.append({'h': h, 'beta_iv': np.nan, 'se_iv': np.nan,
                           'n': n, 'first_stage_F': np.nan, 'pval_iv': np.nan,
                           'ar_ci_low': np.nan, 'ar_ci_high': np.nan})
    return results


def anderson_rubin_ci(y, x, z, W, alpha=0.05):
    """Anderson-Rubin confidence set for β: invert AR test statistic."""
    n = len(y)
    beta_grid = np.linspace(-2.0, 2.0, 2000)
    ar_stats = []
    k_w = W.shape[1]

    for b in beta_grid:
        y_tilde = y - b * x  # Residualized outcome
        Z_ar = np.column_stack([W, z])
        try:
            coef = np.linalg.lstsq(Z_ar, y_tilde, rcond=None)[0]
            resid = y_tilde - Z_ar @ coef
            ssr_u = np.sum(resid**2)
            coef_r = np.linalg.lstsq(W, y_tilde, rcond=None)[0]
            ssr_r = np.sum((y_tilde - W @ coef_r)**2)
            ar_stat = ((ssr_r - ssr_u) / 1) / (ssr_u / (n - k_w - 1))
            ar_stats.append(ar_stat)
        except np.linalg.LinAlgError:
            ar_stats.append(np.inf)

    ar_stats = np.array(ar_stats)
    critical_val = stats.f.ppf(1 - alpha, 1, n - k_w - 1)
    in_ci = ar_stats < critical_val

    if not np.any(in_ci):
        return -np.inf, np.inf  # empty set → report unbounded

    ci_indices = np.where(in_ci)[0]
    return float(beta_grid[ci_indices[0]]), float(beta_grid[ci_indices[-1]])


# ──────────────────────────────────────────────────────────────
# Wild cluster bootstrap (WS4)
# ──────────────────────────────────────────────────────────────

def wild_cluster_bootstrap(paths, instrument, horizons, controls=None,
                           n_boot=999, seed=42):
    """
    Wild cluster bootstrap with Rademacher weights at census division level.
    MacKinnon & Webb (2017): appropriate for few clusters (9 divisions).
    Returns dict: horizon -> bootstrap p-value (two-sided).
    """
    rng = np.random.RandomState(seed)
    boot_pvals = {}

    for h in horizons:
        # Build cross-section
        states_h = [st for st in sorted(paths.keys())
                    if st in instrument and h in paths[st]]
        n = len(states_h)
        if n < 10:
            boot_pvals[h] = np.nan
            continue

        y = np.array([paths[st][h] for st in states_h])
        x = np.array([instrument[st] for st in states_h])
        divisions = [STATE_TO_DIVISION.get(st, 'Unknown') for st in states_h]
        unique_divs = sorted(set(divisions))
        div_idx = [unique_divs.index(d) for d in divisions]

        X = np.column_stack([np.ones(n), x])
        if controls is not None:
            ctrl_rows = [np.asarray(controls.get(st, np.zeros(5)), dtype=float) for st in states_h]
            X = np.column_stack([X, np.array(ctrl_rows)])

        try:
            beta_hat = np.linalg.lstsq(X, y, rcond=None)[0]
            resid = y - X @ beta_hat
            t_actual = abs(beta_hat[1]) / max(1e-10, np.std(resid) / np.sqrt(n))

            # Bootstrap loop
            t_boot_count = 0
            for _ in range(n_boot):
                # Rademacher weights: +1 or -1 per cluster
                cluster_weights = rng.choice([-1, 1], size=len(unique_divs))
                w = np.array([cluster_weights[div_idx[i]] for i in range(n)])

                # Impose null: y* = X*beta_null + w*resid (null: beta_1 = 0)
                y_star = X @ beta_hat
                y_star[...] = beta_hat[0] * X[:, 0]  # Only intercept + controls
                if X.shape[1] > 2:
                    y_star += X[:, 2:] @ beta_hat[2:]  # Add control effects
                y_star += w * resid

                beta_boot = np.linalg.lstsq(X, y_star, rcond=None)[0]
                resid_boot = y_star - X @ beta_boot
                se_boot = np.std(resid_boot) / np.sqrt(n)
                t_boot = abs(beta_boot[1]) / max(1e-10, se_boot)

                if t_boot >= t_actual:
                    t_boot_count += 1

            boot_pvals[h] = (t_boot_count + 1) / (n_boot + 1)
        except np.linalg.LinAlgError:
            boot_pvals[h] = np.nan

    return boot_pvals


# ──────────────────────────────────────────────────────────────
# AKM exposure-robust SEs (WS5)
# ──────────────────────────────────────────────────────────────

def lp_ols_akm(paths, instrument, horizons, shares, controls=None, min_n=10):
    """
    OLS with Adao-Kolesár-Morales (2019) exposure-robust SEs.
    Accounts for correlated shocks in shift-share (Bartik) designs.
    """
    results = []
    for h in horizons:
        states_h = [st for st in sorted(paths.keys())
                    if st in instrument and h in paths[st] and st in shares]
        n = len(states_h)
        if n < min_n:
            results.append({'h': h, 'beta': np.nan, 'se_akm': np.nan,
                           'n': n, 'pval_akm': np.nan})
            continue

        y = np.array([paths[st][h] for st in states_h])
        x = np.array([instrument[st] for st in states_h])

        X = np.column_stack([np.ones(n), x])
        if controls is not None:
            ctrl_rows = [np.asarray(controls.get(st, np.zeros(5)), dtype=float) for st in states_h]
            X = np.column_stack([X, np.array(ctrl_rows)])

        try:
            beta_hat = np.linalg.lstsq(X, y, rcond=None)[0]
            resid = y - X @ beta_hat
            k = X.shape[1]

            # Build shares matrix S (n × J)
            ind_codes = sorted(set().union(*[shares[st].keys() for st in states_h]))
            J = len(ind_codes)
            S = np.zeros((n, J))
            for i, st in enumerate(states_h):
                for j, ind in enumerate(ind_codes):
                    S[i, j] = shares[st].get(ind, 0)

            # AKM variance: V_AKM = (X'X)^{-1} X' S Σ_e S' X (X'X)^{-1}
            # where Σ_e accounts for sector-level clustering
            # Simplified: cluster residuals at industry level via shares
            bread = np.linalg.inv(X.T @ X)

            # Compute industry-level sum of share-weighted residuals
            Se = np.zeros(J)
            for j in range(J):
                Se[j] = np.sum(S[:, j] * resid * x)  # share-weighted

            # AKM meat: sum_j (s_j' e * x)^2
            meat_akm = np.zeros((k, k))
            for j in range(J):
                xj = np.zeros((1, k))
                for i in range(n):
                    xj += S[i, j] * resid[i] * X[i:i+1, :]
                meat_akm += xj.T @ xj

            V_akm = bread @ meat_akm @ bread
            se_akm = np.sqrt(max(0, V_akm[1, 1]))

            tstat = beta_hat[1] / se_akm if se_akm > 0 else 0
            pval_akm = 2 * (1 - stats.t.cdf(abs(tstat), max(1, J - 1)))  # df = J-1

            results.append({
                'h': h, 'beta': float(beta_hat[1]), 'se_akm': float(se_akm),
                'n': n, 'pval_akm': float(pval_akm), 'n_sectors': J
            })
        except (np.linalg.LinAlgError, ValueError):
            results.append({'h': h, 'beta': np.nan, 'se_akm': np.nan,
                           'n': n, 'pval_akm': np.nan})
    return results


# ──────────────────────────────────────────────────────────────
# Permutation inference
# ──────────────────────────────────────────────────────────────

def permutation_test(paths, instrument, horizons, n_perms=1000, seed=42, controls=None):
    rng = np.random.RandomState(seed)
    actual = lp_ols(paths, instrument, horizons, controls=controls)
    actual_betas = {r['h']: r['beta'] for r in actual}
    states = sorted([st for st in paths.keys() if st in instrument])
    z_vals = np.array([instrument[st] for st in states])
    perm_counts = {h: 0 for h in horizons}

    for _ in range(n_perms):
        z_perm = rng.permutation(z_vals)
        perm_instrument = {st: float(z_perm[i]) for i, st in enumerate(states)}
        perm_results = lp_ols(paths, perm_instrument, horizons, controls=controls)
        for r in perm_results:
            h = r['h']
            if h in actual_betas and not np.isnan(r['beta']) and not np.isnan(actual_betas[h]):
                if abs(r['beta']) >= abs(actual_betas[h]):
                    perm_counts[h] += 1

    perm_pvals = {h: perm_counts[h] / n_perms for h in horizons}
    return perm_pvals


# ──────────────────────────────────────────────────────────────
# Main LP estimates
# ──────────────────────────────────────────────────────────────
print("="*60)
print("LOCAL PROJECTION ESTIMATES: EMPLOYMENT")
print("="*60)

table_horizons = [0, 3, 6, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120]
covid_table_horizons = [0, 3, 6, 12, 24, 36, 48]
fig_horizons = list(range(0, 133, 3))
covid_fig_horizons = list(range(0, 49, 3))

# 1. Great Recession — Bartik instrument
print("\n--- Great Recession: Bartik Instrument ---")
gr_bartik_results = lp_ols(gr_paths, bartik_gr, fig_horizons, controls=gr_controls)
for r in gr_bartik_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 2. Great Recession — Housing price instrument
print("\n--- Great Recession: Housing Price Instrument ---")
gr_hpi_results = lp_ols(gr_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_hpi_results:
    if r['h'] in table_horizons:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# 3. COVID — Bartik instrument
print("\n--- COVID Recession: Bartik Instrument ---")
covid_bartik_results = lp_ols(covid_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
for r in covid_bartik_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}  R²={r['r2']:.3f}")

# ──────────────────────────────────────────────────────────────
# 2SLS: Saiz IV (WS1)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("2SLS: SAIZ HOUSING SUPPLY ELASTICITY IV")
print("="*60)

iv_horizons = [6, 12, 24, 36, 48, 60, 84, 120]
saiz_2sls_results = lp_2sls(gr_paths, hpi_boom, saiz_instrument, iv_horizons, controls=gr_controls)

print("\n--- First Stage & IV Estimates ---")
for r in saiz_2sls_results:
    if r['beta_iv'] is not None and not np.isnan(r.get('beta_iv', np.nan)):
        sig = "***" if r.get('pval_iv', 1) < 0.01 else "**" if r.get('pval_iv', 1) < 0.05 else "*" if r.get('pval_iv', 1) < 0.1 else ""
        print(f"  h={r['h']:3d}: β_IV={r['beta_iv']:8.4f} ({r['se_iv']:.4f}){sig}  "
              f"F={r['first_stage_F']:.1f}  AR=[{r['ar_ci_low']:.3f}, {r['ar_ci_high']:.3f}]  "
              f"β_OLS={r.get('beta_ols', np.nan):.4f}  N={r['n']}")
    else:
        print(f"  h={r['h']:3d}: estimation failed (N={r['n']})")

# ──────────────────────────────────────────────────────────────
# Wild cluster bootstrap (WS4)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("WILD CLUSTER BOOTSTRAP (999 iterations, Rademacher, 9 divisions)")
print("="*60)

boot_horizons_gr = [6, 12, 24, 36, 48, 60, 84, 120]
boot_horizons_covid = [3, 6, 12, 24, 36, 48]

print("\n--- Great Recession (HPI instrument) ---")
gr_boot_pvals = wild_cluster_bootstrap(gr_paths, hpi_boom, boot_horizons_gr,
                                        controls=gr_controls, n_boot=999)
for h in boot_horizons_gr:
    pv = gr_boot_pvals.get(h, np.nan)
    print(f"  h={h:3d}: bootstrap p-value = {pv:.3f}" if not np.isnan(pv) else f"  h={h:3d}: NA")

print("\n--- COVID (Bartik instrument) ---")
covid_boot_pvals = wild_cluster_bootstrap(covid_paths, bartik_covid, boot_horizons_covid,
                                           controls=covid_controls, n_boot=999)
for h in boot_horizons_covid:
    pv = covid_boot_pvals.get(h, np.nan)
    print(f"  h={h:3d}: bootstrap p-value = {pv:.3f}" if not np.isnan(pv) else f"  h={h:3d}: NA")

# ──────────────────────────────────────────────────────────────
# AKM exposure-robust SEs for COVID Bartik (WS5)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("AKM EXPOSURE-ROBUST SEs (COVID Bartik)")
print("="*60)

akm_horizons = [3, 6, 12, 24, 36, 48]
covid_akm_results = lp_ols_akm(covid_paths, bartik_covid, akm_horizons,
                                shares_covid, controls=covid_controls)
for r in covid_akm_results:
    if r['beta'] is not None and not np.isnan(r.get('beta', np.nan)):
        sig = "***" if r.get('pval_akm', 1) < 0.01 else "**" if r.get('pval_akm', 1) < 0.05 else "*" if r.get('pval_akm', 1) < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f}  SE_AKM={r['se_akm']:.4f}{sig}  sectors={r.get('n_sectors', '?')}")

# ──────────────────────────────────────────────────────────────
# Permutation inference
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PERMUTATION INFERENCE (1,000 reassignments)")
print("="*60)

perm_horizons_gr = [3, 6, 12, 24, 36, 48, 60, 84, 120]
perm_horizons_covid = [3, 6, 12, 24, 36, 48]

print("\n--- Great Recession (HPI instrument) ---")
gr_perm_pvals = permutation_test(gr_paths, hpi_boom, perm_horizons_gr, n_perms=1000, controls=gr_controls)
for h in perm_horizons_gr:
    print(f"  h={h:3d}: perm p-value = {gr_perm_pvals[h]:.3f}")

print("\n--- COVID (Bartik instrument) ---")
covid_perm_pvals = permutation_test(covid_paths, bartik_covid, perm_horizons_covid, n_perms=1000, controls=covid_controls)
for h in perm_horizons_covid:
    print(f"  h={h:3d}: perm p-value = {covid_perm_pvals[h]:.3f}")

# ──────────────────────────────────────────────────────────────
# Pre-trend estimation
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PRE-TREND EVENT STUDY")
print("="*60)

panel = pd.read_csv(DATA_DIR / "state_panel.csv")
panel['date'] = pd.to_datetime(panel['date'])

gr_peak_dt = pd.Timestamp("2007-12-01")
pre_horizons_gr = [-36, -24, -12]
post_horizons_gr = [0, 6, 12, 24, 36, 48, 60, 84, 120]
all_event_horizons_gr = pre_horizons_gr + post_horizons_gr

gr_pretrend_paths = {}
for st in panel['state'].unique():
    st_data = panel[panel['state'] == st].set_index('date').sort_index()
    if 'log_emp' not in st_data.columns:
        continue
    peak_val = st_data.loc[st_data.index.asof(gr_peak_dt), 'log_emp'] if gr_peak_dt <= st_data.index.max() else np.nan
    if np.isnan(peak_val):
        continue
    path = {}
    for h in all_event_horizons_gr:
        target = gr_peak_dt + pd.DateOffset(months=h)
        candidates = st_data.index[(st_data.index >= target - pd.Timedelta(days=15)) &
                                    (st_data.index <= target + pd.Timedelta(days=15))]
        if len(candidates) > 0:
            path[h] = st_data.loc[candidates[0], 'log_emp'] - peak_val
    gr_pretrend_paths[st] = path

covid_peak_dt = pd.Timestamp("2020-02-01")
pre_horizons_covid = [-36, -24, -12]
post_horizons_covid = [0, 6, 12, 24, 36, 48]
all_event_horizons_covid = pre_horizons_covid + post_horizons_covid

covid_pretrend_paths = {}
for st in panel['state'].unique():
    st_data = panel[panel['state'] == st].set_index('date').sort_index()
    if 'log_emp' not in st_data.columns:
        continue
    peak_val = st_data.loc[st_data.index.asof(covid_peak_dt), 'log_emp'] if covid_peak_dt <= st_data.index.max() else np.nan
    if np.isnan(peak_val):
        continue
    path = {}
    for h in all_event_horizons_covid:
        target = covid_peak_dt + pd.DateOffset(months=h)
        candidates = st_data.index[(st_data.index >= target - pd.Timedelta(days=15)) &
                                    (st_data.index <= target + pd.Timedelta(days=15))]
        if len(candidates) > 0:
            path[h] = st_data.loc[candidates[0], 'log_emp'] - peak_val
    covid_pretrend_paths[st] = path

gr_event_results = lp_ols(gr_pretrend_paths, hpi_boom, all_event_horizons_gr, controls=gr_controls)
covid_event_results = lp_ols(covid_pretrend_paths, bartik_covid, all_event_horizons_covid, controls=covid_controls)

print("\n--- Great Recession pre-trends (HPI instrument) ---")
for r in gr_event_results:
    if r['h'] < 0:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:4d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  p={r['pval']:.3f}")

print("\n--- COVID pre-trends (Bartik instrument) ---")
for r in covid_event_results:
    if r['h'] < 0:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:4d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}  p={r['pval']:.3f}")

# ──────────────────────────────────────────────────────────────
# Migration decomposition: emp/pop ratio LP (WS3)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("MIGRATION DECOMPOSITION: EMP/POP RATIO")
print("="*60)

migration_horizons_gr = [12, 24, 36, 48, 60, 84, 120]
migration_horizons_covid = [6, 12, 24, 36, 48]

print("\n--- Great Recession (HPI instrument) ---")
gr_emppop_results = lp_ols(gr_emppop_paths, hpi_boom, migration_horizons_gr, controls=gr_controls)
for r in gr_emppop_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    # Compare with baseline emp results
    emp_r = next((x for x in gr_hpi_results if x['h'] == r['h']), None)
    emp_beta = emp_r['beta'] if emp_r else np.nan
    print(f"  h={r['h']:3d}: β_emppop={r['beta']:8.4f} ({r['se']:.4f}){sig}  "
          f"β_emp={emp_beta:.4f}  N={r['n']}")

print("\n--- COVID (Bartik instrument) ---")
covid_emppop_results = lp_ols(covid_emppop_paths, bartik_covid, migration_horizons_covid, controls=covid_controls)
for r in covid_emppop_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    emp_r = next((x for x in covid_bartik_results if x['h'] == r['h']), None)
    emp_beta = emp_r['beta'] if emp_r else np.nan
    print(f"  h={r['h']:3d}: β_emppop={r['beta']:8.4f} ({r['se']:.4f}){sig}  "
          f"β_emp={emp_beta:.4f}  N={r['n']}")

# ──────────────────────────────────────────────────────────────
# Mechanism test: UR persistence comparison (WS2)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("MECHANISM TEST: UNEMPLOYMENT RATE PERSISTENCE")
print("="*60)

# If HPI predicts persistently elevated UR at h=24-48 but COVID Bartik does not,
# this confirms duration-dependent scarring
mechanism_horizons = [6, 12, 24, 36, 48]

print("\n--- GR: UR response (HPI instrument) ---")
gr_ur_mechanism = lp_ols(gr_ur_paths, hpi_boom, mechanism_horizons + [60, 84, 120], controls=gr_controls)
for r in gr_ur_mechanism:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β_ur={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID: UR response (Bartik instrument) ---")
covid_ur_mechanism = lp_ols(covid_ur_paths, bartik_covid, mechanism_horizons, controls=covid_controls)
for r in covid_ur_mechanism:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β_ur={r['beta']:8.4f} ({r['se']:.4f}){sig}")

# Persistence ratio: UR at h=48 / UR at h=12 (within each recession)
gr_ur_12 = next((r['beta'] for r in gr_ur_mechanism if r['h'] == 12), np.nan)
gr_ur_48 = next((r['beta'] for r in gr_ur_mechanism if r['h'] == 48), np.nan)
covid_ur_12 = next((r['beta'] for r in covid_ur_mechanism if r['h'] == 12), np.nan)
covid_ur_48 = next((r['beta'] for r in covid_ur_mechanism if r['h'] == 48), np.nan)

gr_ur_persist = gr_ur_48 / gr_ur_12 if gr_ur_12 and not np.isnan(gr_ur_12) and gr_ur_12 != 0 else np.nan
covid_ur_persist = covid_ur_48 / covid_ur_12 if covid_ur_12 and not np.isnan(covid_ur_12) and covid_ur_12 != 0 else np.nan

print(f"\n  UR persistence ratio (β_48/β_12):")
print(f"    Great Recession: {gr_ur_persist:.3f}" if not np.isnan(gr_ur_persist) else "    Great Recession: N/A")
print(f"    COVID: {covid_ur_persist:.3f}" if not np.isnan(covid_ur_persist) else "    COVID: N/A")

# ──────────────────────────────────────────────────────────────
# Subsample robustness
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("SUBSAMPLE ROBUSTNESS")
print("="*60)

CENSUS_REGIONS = {
    'Northeast': ['CT','ME','MA','NH','RI','VT','NJ','NY','PA'],
    'Midwest': ['IL','IN','IA','KS','MI','MN','MO','NE','ND','OH','SD','WI'],
    'South': ['AL','AR','DE','FL','GA','KY','LA','MD','MS','NC','OK','SC','TN','TX','VA','WV'],
    'West': ['AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY'],
}

summary = pd.DataFrame(proc['summary'])
median_emp = summary['emp_2007'].median()

subsample_results = {}

print("\n--- By Census Region (GR, HPI instrument, h=60) ---")
for region, region_states in CENSUS_REGIONS.items():
    region_paths = {st: p for st, p in gr_paths.items() if st in region_states}
    if len(region_paths) < 5:
        print(f"  {region}: too few states ({len(region_paths)})")
        subsample_results[f'region_{region}'] = {'beta_60': np.nan, 'se_60': np.nan, 'n': len(region_paths)}
        continue
    region_ctrl = {st: gr_controls[st][:2] for st in region_states if st in gr_controls}
    region_res = lp_ols(region_paths, hpi_boom, [60], min_n=5, controls=region_ctrl)
    if region_res and not np.isnan(region_res[0]['beta']):
        r = region_res[0]
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  {region:12s}: β_60={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}")
        subsample_results[f'region_{region}'] = {'beta_60': r['beta'], 'se_60': r['se'], 'n': r['n'], 'pval': r['pval']}
    else:
        print(f"  {region}: estimation failed")
        subsample_results[f'region_{region}'] = {'beta_60': np.nan, 'se_60': np.nan, 'n': 0}

print("\n--- By State Size (GR, HPI instrument, h=60) ---")
large_states = summary[summary['emp_2007'] >= median_emp]['state'].tolist()
small_states = summary[summary['emp_2007'] < median_emp]['state'].tolist()

for label, state_list in [('Large (above median)', large_states), ('Small (below median)', small_states)]:
    sub_paths = {st: p for st, p in gr_paths.items() if st in state_list}
    sub_res = lp_ols(sub_paths, hpi_boom, [60], controls=gr_controls)
    if sub_res and not np.isnan(sub_res[0]['beta']):
        r = sub_res[0]
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  {label:25s}: β_60={r['beta']:8.4f} ({r['se']:.4f}){sig}  N={r['n']}")
        subsample_results[label.lower().replace(' ', '_').replace('(', '').replace(')', '')] = {
            'beta_60': r['beta'], 'se_60': r['se'], 'n': r['n'], 'pval': r['pval']
        }

# ──────────────────────────────────────────────────────────────
# LP estimates for unemployment rate and LFPR
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: UNEMPLOYMENT RATE")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_ur_results = lp_ols(gr_ur_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_ur_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_ur_results = lp_ols(covid_ur_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
for r in covid_ur_results:
    sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
    print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n" + "="*60)
print("LOCAL PROJECTION ESTIMATES: LFPR")
print("="*60)

print("\n--- Great Recession (HPI instrument) ---")
gr_lfpr_results = lp_ols(gr_lfpr_paths, hpi_boom, fig_horizons, controls=gr_controls)
for r in gr_lfpr_results:
    if r['h'] in [0, 12, 24, 48, 72, 96, 120]:
        sig = "***" if r['pval'] < 0.01 else "**" if r['pval'] < 0.05 else "*" if r['pval'] < 0.1 else ""
        print(f"  h={r['h']:3d}: β={r['beta']:8.4f} ({r['se']:.4f}){sig}")

print("\n--- COVID ---")
covid_lfpr_results = lp_ols(covid_lfpr_paths, bartik_covid, covid_fig_horizons, controls=covid_controls)
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

gr_48 = next((r['beta'] for r in gr_hpi_results if r['h'] == 48), np.nan)
gr_peak_val = next((r['beta'] for r in gr_hpi_results if r['h'] == gr_peak_h), np.nan)
covid_48 = next((r['beta'] for r in covid_bartik_results if r['h'] == 48), np.nan)
covid_peak_val = next((r['beta'] for r in covid_bartik_results if r['h'] == covid_peak_h), np.nan)

gr_persist = gr_48 / gr_peak_val if gr_peak_val and not np.isnan(gr_peak_val) and gr_peak_val != 0 else np.nan
covid_persist = covid_48 / covid_peak_val if covid_peak_val and not np.isnan(covid_peak_val) and covid_peak_val != 0 else np.nan

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
    },
    'permutation_pvals': {
        'gr_hpi': {str(k): v for k, v in gr_perm_pvals.items()},
        'covid_bartik': {str(k): v for k, v in covid_perm_pvals.items()},
    },
    'wild_cluster_bootstrap': {
        'gr_hpi': {str(k): v for k, v in gr_boot_pvals.items()},
        'covid_bartik': {str(k): v for k, v in covid_boot_pvals.items()},
    },
    'event_study': {
        'gr': gr_event_results,
        'covid': covid_event_results,
    },
    'subsample': subsample_results,
    'saiz_2sls': saiz_2sls_results,
    'covid_akm': covid_akm_results,
    'migration': {
        'gr_emppop': gr_emppop_results,
        'covid_emppop': covid_emppop_results,
    },
    'mechanism': {
        'gr_ur': [{'h': r['h'], 'beta': r['beta'], 'se': r['se'], 'pval': r['pval']} for r in gr_ur_mechanism],
        'covid_ur': [{'h': r['h'], 'beta': r['beta'], 'se': r['se'], 'pval': r['pval']} for r in covid_ur_mechanism],
        'gr_ur_persist_ratio': gr_ur_persist,
        'covid_ur_persist_ratio': covid_ur_persist,
    },
}

with open(DATA_DIR / "lp_results.json", 'w') as f:
    json.dump(lp_results, f, indent=2, default=lambda x: None if (isinstance(x, float) and np.isnan(x)) else x)

print(f"\n✓ LP results saved to {DATA_DIR / 'lp_results.json'}")
