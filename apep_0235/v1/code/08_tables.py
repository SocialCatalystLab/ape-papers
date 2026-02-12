"""
08_tables.py — Generate all LaTeX tables for the paper
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
TAB_DIR = pkg.TAB_DIR

# Load all results
with open(os.path.join(DATA_DIR, 'lp_results.json')) as f:
    lp = json.load(f)

with open(os.path.join(DATA_DIR, 'robustness_results.json')) as f:
    rob = json.load(f)

with open(os.path.join(DATA_DIR, 'model_results.json')) as f:
    model = json.load(f)

with open(os.path.join(DATA_DIR, 'welfare_results.json')) as f:
    welfare = json.load(f)

with open(os.path.join(DATA_DIR, 'classifications.json')) as f:
    classifications = json.load(f)

main_df = pd.read_csv(os.path.join(DATA_DIR, 'analysis_main.csv'), index_col='date', parse_dates=True)

def fmt(val, decimals=3):
    """Format number with given decimals, handling NaN."""
    if val is None or (isinstance(val, float) and np.isnan(val)):
        return '--'
    return f'{val:.{decimals}f}'

def fmt_se(se, decimals=3):
    """Format standard error in parentheses."""
    if se is None or (isinstance(se, float) and np.isnan(se)):
        return ''
    return f'({se:.{decimals}f})'

def write_table(filename, content):
    """Write LaTeX table to file."""
    path = os.path.join(TAB_DIR, filename)
    with open(path, 'w') as f:
        f.write(content)
    print(f"  Written: {filename}")


# ============================================================
# Table 1: Summary Statistics
# ============================================================
print("Table 1: Summary statistics...")

# Compute stats
stats_rows = []
emp_cols = ['PAYEMS', 'MANEMP', 'USCONS', 'USMINE', 'USTRADE', 'USFIRE', 'USPBS', 'USEHS', 'USLAH']
for col in emp_cols:
    if col in main_df.columns:
        s = main_df[col].dropna()
        stats_rows.append({
            'Variable': pkg.CES_SERIES.get(col, col),
            'Mean': s.mean(),
            'SD': s.std(),
            'Min': s.min(),
            'Max': s.max(),
            'N': len(s),
        })

# Add MP shock
s = main_df['mp_shock'].dropna()
stats_rows.insert(0, {
    'Variable': 'MP Shock (JK)',
    'Mean': s.mean(),
    'SD': s.std(),
    'Min': s.min(),
    'Max': s.max(),
    'N': len(s),
})

# Add macro controls
for var, name in [('FEDFUNDS', 'Federal Funds Rate'), ('UNRATE', 'Unemployment Rate'),
                   ('inflation', 'CPI Inflation (\\%)'), ('ip_growth', 'IP Growth (\\%)')]:
    if var in main_df.columns:
        s = main_df[var].dropna()
        stats_rows.append({
            'Variable': name,
            'Mean': s.mean(),
            'SD': s.std(),
            'Min': s.min(),
            'Max': s.max(),
            'N': len(s),
        })

tex = """\\begin{table}[H]
\\centering
\\caption{Summary Statistics}
\\label{tab:summary}
\\begin{threeparttable}
\\begin{tabular}{l S[table-format=6.1] S[table-format=5.1] S[table-format=6.1] S[table-format=6.1] S[table-format=4.0]}
\\toprule
Variable & {Mean} & {Std. Dev.} & {Min} & {Max} & {N} \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel A: Monetary Policy Shock}} \\\\
"""

for i, row in enumerate(stats_rows):
    if i == 1:
        tex += "\\midrule\n\\multicolumn{6}{l}{\\textit{Panel B: Employment (thousands)}} \\\\\n"
    if row['Variable'] == 'Federal Funds Rate':
        tex += "\\midrule\n\\multicolumn{6}{l}{\\textit{Panel C: Macro Controls}} \\\\\n"

    var_name = row['Variable'].replace('&', '\\&')
    if row['Variable'] == 'MP Shock (JK)':
        tex += f"{var_name} & {row['Mean']:.3f} & {row['SD']:.3f} & {row['Min']:.3f} & {row['Max']:.3f} & {int(row['N'])} \\\\\n"
    else:
        tex += f"{var_name} & {row['Mean']:.1f} & {row['SD']:.1f} & {row['Min']:.1f} & {row['Max']:.1f} & {int(row['N'])} \\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Monthly data, """ + f"{main_df.index[0].strftime('%Y:%m')}--{main_df.index[-1].strftime('%Y:%m')}" + """. Employment from BLS Current Employment Statistics (CES), in thousands. MP Shock is the Jarocinski-Karadi (2020) monetary policy surprise, aggregated to monthly frequency. CPI Inflation is 12-month percentage change in CPI-U. IP Growth is 12-month percentage change in industrial production index.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab1_summary.tex', tex)

# ============================================================
# Table 2: Aggregate LP Results
# ============================================================
print("Table 2: Aggregate LP results...")

agg = lp['aggregate']['PAYEMS']
key_horizons = [0, 3, 6, 12, 24, 36, 48]

tex = """\\begin{table}[H]
\\centering
\\caption{Aggregate Employment Response to Monetary Tightening}
\\label{tab:aggregate}
\\begin{threeparttable}
\\begin{tabular}{l""" + 'c' * len(key_horizons) + """}
\\toprule
& """ + ' & '.join([f'$h={h}$' for h in key_horizons]) + """ \\\\
\\midrule
"""

# Coefficients
tex += "MP Shock "
for h in key_horizons:
    idx = agg['horizons'].index(h) if h in agg['horizons'] else -1
    if idx >= 0:
        b = agg['beta'][idx]
        p = agg['pval'][idx]
        tex += f"& {fmt(b)}{pkg.stars(p) if not np.isnan(p) else ''} "
    else:
        tex += "& -- "
tex += "\\\\\n"

# SEs
tex += " "
for h in key_horizons:
    idx = agg['horizons'].index(h) if h in agg['horizons'] else -1
    if idx >= 0:
        se = agg['se'][idx]
        tex += f"& {fmt_se(se)} "
    else:
        tex += "& "
tex += "\\\\\n"

# N and R2
tex += "\\midrule\n$N$ "
for h in key_horizons:
    idx = agg['horizons'].index(h) if h in agg['horizons'] else -1
    if idx >= 0:
        n = agg['nobs'][idx]
        tex += f"& {int(n)} " if not np.isnan(n) else "& -- "
    else:
        tex += "& -- "
tex += "\\\\\n"

tex += "$R^2$ "
for h in key_horizons:
    idx = agg['horizons'].index(h) if h in agg['horizons'] else -1
    if idx >= 0:
        r2 = agg['r2'][idx]
        tex += f"& {fmt(r2, 2)} " if not np.isnan(r2) else "& -- "
    else:
        tex += "& -- "
tex += "\\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Local projection estimates of the response of log total nonfarm employment (x100) to a 1 standard deviation Jarocinski-Karadi monetary policy shock. Controls include 12 lags of the shock and 4 lags of federal funds rate, unemployment, inflation, and industrial production growth. Newey-West HAC standard errors with bandwidth $\\lfloor 1.5(h+1) \\rfloor$ in parentheses. \\sym{*} $p<0.10$, \\sym{**} $p<0.05$, \\sym{***} $p<0.01$.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab2_aggregate.tex', tex)

# ============================================================
# Table 3: Industry-Level Peak Responses
# ============================================================
print("Table 3: Industry peak responses...")

tex = """\\begin{table}[H]
\\centering
\\caption{Industry-Level Peak Employment Responses to Monetary Tightening}
\\label{tab:industry_peaks}
\\begin{threeparttable}
\\begin{tabular}{llcccccc}
\\toprule
Industry & Type & Peak $h$ & $\\hat{\\beta}_h$ & SE & $p$-value & $N$ & $R^2$ \\\\
\\midrule
"""

industry_peaks = []
for series in ['MANEMP', 'USCONS', 'USMINE', 'USWTRADE', 'USTRADE', 'USINFO',
               'USFIRE', 'USPBS', 'USEHS', 'USLAH', 'USSERV', 'USTPU']:
    if series in lp['industry']:
        res = lp['industry'][series]
        betas = res['beta']
        valid = [(i, b) for i, b in enumerate(betas) if not np.isnan(b)]
        if valid:
            peak_idx = min(valid, key=lambda x: x[1])[0]
            itype = 'Goods' if series in pkg.GOODS_INDUSTRIES else 'Services'
            industry_peaks.append({
                'name': pkg.CES_SERIES.get(series, series),
                'type': itype,
                'peak_h': res['horizons'][peak_idx],
                'beta': betas[peak_idx],
                'se': res['se'][peak_idx],
                'pval': res['pval'][peak_idx],
                'nobs': res['nobs'][peak_idx],
                'r2': res['r2'][peak_idx] if 'r2' in res else float('nan'),
            })

# Sort by peak response (most negative first)
industry_peaks.sort(key=lambda x: x['beta'])

for row in industry_peaks:
    name = row['name'].replace('&', '\\&')
    tex += f"{name} & {row['type']} & {row['peak_h']} & "
    tex += f"{fmt(row['beta'])}{pkg.stars(row['pval'])} & {fmt(row['se'])} & "
    tex += f"{fmt(row['pval'])} & {int(row['nobs'])} & {fmt(row['r2'], 2)} \\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Peak (most negative) response of log industry employment (x100) to a 1 s.d. JK monetary policy shock across horizons $h \\in \\{0, 1, 2, 3, 6, 9, 12, 18, 24, 36, 48\\}$. Newey-West HAC standard errors. Industries sorted by peak response magnitude. \\sym{*} $p<0.10$, \\sym{**} $p<0.05$, \\sym{***} $p<0.01$.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab3_industry_peaks.tex', tex)

# ============================================================
# Table 4: Goods vs Services Interaction
# ============================================================
print("Table 4: Goods vs services interaction...")

gi = lp.get('goods_interaction', {})
tex = """\\begin{table}[H]
\\centering
\\caption{Goods vs. Services: Interaction Local Projections}
\\label{tab:interaction}
\\begin{threeparttable}
\\begin{tabular}{l""" + 'c' * len(key_horizons) + """}
\\toprule
& """ + ' & '.join([f'$h={h}$' for h in key_horizons]) + """ \\\\
\\midrule
"""

if gi and 'horizons' in gi:
    # Base effect (services)
    tex += "MP Shock ($\\hat{\\beta}$) "
    for h in key_horizons:
        idx = gi['horizons'].index(h) if h in gi['horizons'] else -1
        if idx >= 0:
            b = gi['beta'][idx]
            p = gi['beta_pval'][idx]
            tex += f"& {fmt(b)}{pkg.stars(p) if not np.isnan(p) else ''} "
        else:
            tex += "& -- "
    tex += "\\\\\n"

    tex += " "
    for h in key_horizons:
        idx = gi['horizons'].index(h) if h in gi['horizons'] else -1
        if idx >= 0:
            tex += f"& {fmt_se(gi['beta_se'][idx])} "
        else:
            tex += "& "
    tex += "\\\\\n"

    # Interaction
    tex += "MP $\\times$ Goods ($\\hat{\\delta}$) "
    for h in key_horizons:
        idx = gi['horizons'].index(h) if h in gi['horizons'] else -1
        if idx >= 0:
            d = gi['delta'][idx]
            p = gi['delta_pval'][idx]
            tex += f"& {fmt(d)}{pkg.stars(p) if not np.isnan(p) else ''} "
        else:
            tex += "& -- "
    tex += "\\\\\n"

    tex += " "
    for h in key_horizons:
        idx = gi['horizons'].index(h) if h in gi['horizons'] else -1
        if idx >= 0:
            tex += f"& {fmt_se(gi['delta_se'][idx])} "
        else:
            tex += "& "
    tex += "\\\\\n"

    # N
    tex += "\\midrule\n$N$ "
    for h in key_horizons:
        idx = gi['horizons'].index(h) if h in gi['horizons'] else -1
        if idx >= 0:
            n = gi['nobs'][idx]
            tex += f"& {int(n)} " if not np.isnan(n) else "& -- "
        else:
            tex += "& -- "
    tex += "\\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Panel local projections with industry $\\times$ month observations. $\\hat{\\beta}$ is the effect of a 1 s.d. monetary shock on services employment (base category). $\\hat{\\delta}$ is the additional effect for goods-producing industries. Goods = manufacturing, construction, mining/logging. Standard errors clustered by industry (13 industry clusters). \\sym{*} $p<0.10$, \\sym{**} $p<0.05$, \\sym{***} $p<0.01$.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab4_interaction.tex', tex)

# ============================================================
# Table 5: JOLTS Decomposition
# ============================================================
print("Table 5: JOLTS decomposition...")

jolts_horizons = [0, 3, 6, 12, 24]
tex = """\\begin{table}[H]
\\centering
\\caption{JOLTS Flow Responses to Monetary Tightening}
\\label{tab:jolts}
\\begin{threeparttable}
\\begin{tabular}{l""" + 'c' * len(jolts_horizons) + """}
\\toprule
& """ + ' & '.join([f'$h={h}$' for h in jolts_horizons]) + """ \\\\
\\midrule
"""

for flow_code, flow_name in pkg.JOLTS_FLOWS.items():
    if flow_code in lp['jolts']:
        res = lp['jolts'][flow_code]
        tex += f"{flow_name} "
        for h in jolts_horizons:
            idx = res['horizons'].index(h) if h in res['horizons'] else -1
            if idx >= 0:
                b = res['beta'][idx]
                p = res['pval'][idx]
                tex += f"& {fmt(b)}{pkg.stars(p) if not np.isnan(p) else ''} "
            else:
                tex += "& -- "
        tex += "\\\\\n"
        tex += " "
        for h in jolts_horizons:
            idx = res['horizons'].index(h) if h in res['horizons'] else -1
            if idx >= 0:
                tex += f"& {fmt_se(res['se'][idx])} "
            else:
                tex += "& "
        tex += "\\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Local projection estimates of JOLTS flow responses (log $\\times$ 100, percentage deviation) to a 1 s.d. JK monetary policy shock. Sample: 2001:01--2024:01. Controls: 12 shock lags, 4 macro lags. Newey-West HAC standard errors. \\sym{*} $p<0.10$, \\sym{**} $p<0.05$, \\sym{***} $p<0.01$.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab5_jolts.tex', tex)

# ============================================================
# Table 6: Robustness
# ============================================================
print("Table 6: Robustness...")

rob_specs = [
    ('Baseline', lp['aggregate']['PAYEMS']),
]
for name, key in [('Pre-GFC (1990-2007)', 'subsample_pre_gfc'),
                   ('Excl. ZLB (2009-15)', 'subsample_excl_zlb'),
                   ('Excl. COVID (2020-21)', 'subsample_excl_covid'),
                   ('FFR change shock', 'alt_shock_ffr_change'),
                   ('Oil + VIX controls', 'extra_controls'),
                   ('Excl. outlier shocks', 'excl_outliers'),
                   ('6-lag specification', 'short_lags')]:
    if key in rob:
        rob_specs.append((name, rob[key]))

rob_horizons = [6, 12, 24, 48]
tex = """\\begin{table}[H]
\\centering
\\caption{Robustness of Aggregate Employment Response}
\\label{tab:robustness}
\\begin{threeparttable}
\\begin{tabular}{l""" + 'c' * len(rob_horizons) + """}
\\toprule
Specification & """ + ' & '.join([f'$h={h}$' for h in rob_horizons]) + """ \\\\
\\midrule
"""

for spec_name, res in rob_specs:
    tex += f"{spec_name} "
    for h in rob_horizons:
        idx = res['horizons'].index(h) if h in res['horizons'] else -1
        if idx >= 0:
            b = res['beta'][idx]
            p = res['pval'][idx]
            se = res['se'][idx]
            if not np.isnan(b):
                tex += f"& {fmt(b)}{pkg.stars(p)} "
            else:
                tex += "& -- "
        else:
            tex += "& -- "
    tex += "\\\\\n"
    tex += " "
    for h in rob_horizons:
        idx = res['horizons'].index(h) if h in res['horizons'] else -1
        if idx >= 0:
            se = res['se'][idx]
            tex += f"& {fmt_se(se)} "
        else:
            tex += "& "
    tex += "\\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Each row reports LP estimates of aggregate employment response at selected horizons under different specifications. All specifications include 12 shock lags and 4 macro control lags unless noted. Newey-West HAC standard errors. \\sym{*} $p<0.10$, \\sym{**} $p<0.05$, \\sym{***} $p<0.01$.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab6_robustness.tex', tex)

# ============================================================
# Table 7: Model Calibration
# ============================================================
print("Table 7: Model calibration...")

cal = model['calibration']
ss_vals = model['steady_state']

tex = """\\begin{table}[H]
\\centering
\\caption{Model Calibration}
\\label{tab:calibration}
\\begin{threeparttable}
\\begin{tabular}{llcc}
\\toprule
Parameter & Description & Value & Source \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Preferences}} \\\\
$\\beta$ & Monthly discount factor & """ + f"{cal['beta_m']:.4f}" + """ & Standard \\\\
$\\sigma$ & CRRA coefficient & """ + f"{cal['sigma']:.1f}" + """ & Standard \\\\
$\\eta_c$ & CES goods weight & """ + f"{cal['eta_c']:.2f}" + """ & Calibrated \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Labor Market (Goods/Services)}} \\\\
$\\chi_s$ & Matching efficiency & """ + f"{cal['chi_g']:.2f} / {cal['chi_s']:.2f}" + """ & JOLTS match \\\\
$\\xi$ & Matching elasticity & """ + f"{cal['xi']:.2f}" + """ & Hosios condition \\\\
$\\eta$ & Bargaining power & """ + f"{cal['eta_w']:.2f}" + """ & Symmetric Nash \\\\
$\\kappa_s$ & Vacancy cost & """ + f"{cal['kappa_g']:.2f} / {cal['kappa_s']:.2f}" + """ & Calibrated \\\\
$\\rho_s$ & Separation rate & """ + f"{cal['rho_g']:.3f} / {cal['rho_s']:.3f}" + """ & JOLTS \\\\
$b$ & UI replacement & """ + f"{cal['b']:.2f}" + """ & Shimer (2005) \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Price Setting}} \\\\
$\\lambda_s$ & Calvo parameter & """ + f"{cal['lambda_g']:.2f} / {cal['lambda_s']:.2f}" + """ & Nakamura-Steinsson (2008) \\\\
$\\epsilon$ & Elasticity of sub. & """ + f"{cal['epsilon']:.0f}" + """ & 20\\% markup \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Taylor Rule}} \\\\
$\\rho_i$ & Smoothing & """ + f"{cal['rho_i']:.2f}" + """ & Standard \\\\
$\\phi_\\pi$ & Inflation response & """ + f"{cal['phi_pi']:.2f}" + """ & Taylor (1993) \\\\
$\\phi_y$ & Output response & """ + f"{cal['phi_y']:.3f}" + """ & Taylor (1993) \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: The model is calibrated at monthly frequency. Parameters reported as X/Y denote goods/services sector values. Model normalizes private-sector labor force to 1: goods employment = 16.3\\%, services = 83.7\\%, unemployment = 5\\%. Government employment excluded from model. JOLTS moments matched: sector-level separation rates and vacancy-filling rates.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab7_calibration.tex', tex)

# ============================================================
# Table 8: Model Fit
# ============================================================
print("Table 8: Model fit...")

irfs_het = np.array(model['irfs']['heterogeneous'])
irfs_ra = np.array(model['irfs']['representative_agent'])

tex = """\\begin{table}[H]
\\centering
\\caption{Model vs. Data: Employment Responses (\\% Deviation)}
\\label{tab:model_fit}
\\begin{threeparttable}
\\begin{tabular}{lcccccc}
\\toprule
& \\multicolumn{2}{c}{Goods} & \\multicolumn{2}{c}{Services} & \\multicolumn{2}{c}{Aggregate} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}
Month & Data & Model & Data & Model & Data & Model \\\\
\\midrule
"""

n_g_wt = ss_vals['n_g'] / (ss_vals['n_g'] + ss_vals['n_s'])
n_s_wt = ss_vals['n_s'] / (ss_vals['n_g'] + ss_vals['n_s'])

# Get data IRFs
goods_codes = [c for c in pkg.GOODS_INDUSTRIES if c in lp['industry']]
services_codes = [c for c in pkg.SERVICES_INDUSTRIES if c in lp['industry']]

for h in [0, 3, 6, 12, 24, 36, 48]:
    h_idx = pkg.LP_HORIZONS.index(h) if h in pkg.LP_HORIZONS else -1

    # Data goods average
    if h_idx >= 0 and goods_codes:
        goods_data = np.nanmean([lp['industry'][c]['beta'][h_idx] for c in goods_codes])
    else:
        goods_data = float('nan')

    # Data services average
    if h_idx >= 0 and services_codes:
        svc_data = np.nanmean([lp['industry'][c]['beta'][h_idx] for c in services_codes])
    else:
        svc_data = float('nan')

    # Data aggregate
    if h_idx >= 0 and 'PAYEMS' in lp['aggregate']:
        agg_data = lp['aggregate']['PAYEMS']['beta'][h_idx]
    else:
        agg_data = float('nan')

    # Model
    goods_model = irfs_het[h, 0] * 100 if h < len(irfs_het) else float('nan')
    svc_model = irfs_het[h, 1] * 100 if h < len(irfs_het) else float('nan')
    agg_model = (n_g_wt * irfs_het[h, 0] + n_s_wt * irfs_het[h, 1]) * 100 if h < len(irfs_het) else float('nan')

    tex += f"{h} & {fmt(goods_data)} & \\textbf{{{fmt(goods_model)}}} & {fmt(svc_data)} & \\textbf{{{fmt(svc_model)}}} & {fmt(agg_data)} & \\textbf{{{fmt(agg_model)}}} \\\\\n"

tex += """\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Goods and Services data columns report simple (unweighted) averages of individual industry local projection estimates within each sector. Aggregate data column reports the LP estimate for total nonfarm payrolls (PAYEMS). Because the aggregate LP uses a different dependent variable than the sectoral average, these may differ. Model columns report impulse responses from the calibrated two-sector NK-DMP model to a 25bp (annualized) monetary tightening shock. All values in percentage deviations from steady state. Individual industry LPs are imprecisely estimated, particularly at long horizons, and positive values at $h \\geq 36$ reflect estimation noise.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab8_model_fit.tex', tex)

# ============================================================
# Table 9: Welfare Analysis
# ============================================================
print("Table 9: Welfare analysis...")

het = welfare['heterogeneous_model']
ra = welfare['representative_agent']
decomp = welfare['decomposition']

tex = """\\begin{table}[H]
\\centering
\\caption{Welfare Costs of Monetary Tightening: Consumption-Equivalent Losses}
\\label{tab:welfare}
\\begin{threeparttable}
\\begin{tabular}{lcccc}
\\toprule
& \\multicolumn{2}{c}{Heterogeneous Model} & \\multicolumn{2}{c}{Rep. Agent Model} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}
& Goods & Services & Sector 1 & Sector 2 \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel A: Welfare Losses (\\% annual, CE)}} \\\\
Total CE loss & """ + f"{fmt(het['goods_workers']['ce_welfare_loss_annual_pct'])} & {fmt(het['services_workers']['ce_welfare_loss_annual_pct'])} & {fmt(ra['goods_workers']['ce_welfare_loss_annual_pct'])} & {fmt(ra['services_workers']['ce_welfare_loss_annual_pct'])}" + """ \\\\
Peak employment (\\%) & """ + f"{fmt(het['goods_workers']['peak_employment_pct'])} & {fmt(het['services_workers']['peak_employment_pct'])} & {fmt(ra['goods_workers']['peak_employment_pct'])} & {fmt(ra['services_workers']['peak_employment_pct'])}" + """ \\\\
Peak month & """ + f"{het['goods_workers']['peak_employment_month']} & {het['services_workers']['peak_employment_month']} & {ra['goods_workers']['peak_employment_month']} & {ra['services_workers']['peak_employment_month']}" + """ \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel B: Decomposition (Het. Model Only)}} \\\\
Employment channel & """ + f"{fmt(decomp['goods']['employment_component'])} & {fmt(decomp['services']['employment_component'])} & & " + """ \\\\
Wage channel & """ + f"{fmt(decomp['goods']['wage_component'])} & {fmt(decomp['services']['wage_component'])} & & " + """ \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel C: Aggregates}} \\\\
Aggregate CE loss & \\multicolumn{2}{c}{""" + f"{fmt(het['aggregate_ce_annual_pct'])}" + """} & \\multicolumn{2}{c}{""" + f"{fmt(ra['aggregate_ce_annual_pct'])}" + """} \\\\
Het./RA ratio & \\multicolumn{4}{c}{""" + f"{fmt(welfare['distributional_gap']['het_ra_ratio'], 2)}" + """} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Consumption-equivalent (CE) welfare losses from a 25bp (annualized) monetary tightening shock, computed over a 48-month horizon with monthly discount factor $\\beta = """ + f"{cal['beta_m']:.4f}" + """$. The heterogeneous model has distinct goods and services sectors with different separation rates and price stickiness. The representative-agent model imposes identical parameters across sectors. Goods employment share = """ + f"{welfare['parameters']['goods_employment_share']:.2f}" + """, services = """ + f"{welfare['parameters']['services_employment_share']:.2f}" + """.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}"""

write_table('tab9_welfare.tex', tex)

# ============================================================
# Summary
# ============================================================
print("\n" + "=" * 60)
print("TABLES COMPLETE")
print("=" * 60)
tabs = sorted([f for f in os.listdir(TAB_DIR) if f.endswith('.tex')])
for f in tabs:
    print(f"  {f}")
print(f"\nTotal: {len(tabs)} tables")
