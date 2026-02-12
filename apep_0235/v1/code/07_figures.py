"""
07_figures.py — Generate all figures as PDF for the paper
"""

import os
import sys
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from importlib import import_module
pkg = import_module('00_packages')
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

DATA_DIR = pkg.DATA_DIR
FIG_DIR = pkg.FIG_DIR

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

COLORS = pkg.COLORS

def plot_irf(ax, horizons, beta, ci_lo, ci_hi, ci68_lo=None, ci68_hi=None,
             ci95_lo=None, ci95_hi=None,
             color='blue', label=None, linestyle='-'):
    """Plot a single IRF with confidence bands (68%, 90%, and optionally 95%)."""
    c = COLORS.get(color, color)
    h = np.array(horizons)
    b = np.array(beta)
    lo = np.array(ci_lo)
    hi = np.array(ci_hi)

    # Filter NaN
    mask = ~(np.isnan(b) | np.isnan(lo) | np.isnan(hi))
    if mask.sum() == 0:
        return

    # 95% CI (outermost, lightest)
    if ci95_lo is not None and ci95_hi is not None:
        lo95 = np.array(ci95_lo)
        hi95 = np.array(ci95_hi)
        ax.fill_between(h[mask], lo95[mask], hi95[mask], alpha=0.08, color=c)
    # 90% CI
    ax.fill_between(h[mask], lo[mask], hi[mask], alpha=0.15, color=c)
    # 68% CI (innermost, darkest)
    if ci68_lo is not None and ci68_hi is not None:
        lo68 = np.array(ci68_lo)
        hi68 = np.array(ci68_hi)
        ax.fill_between(h[mask], lo68[mask], hi68[mask], alpha=0.25, color=c)
    ax.plot(h[mask], b[mask], color=c, linewidth=1.5, label=label, linestyle=linestyle)
    ax.axhline(0, color='black', linewidth=0.5, linestyle='-')
    ax.set_xlabel('Months')
    ax.xaxis.set_major_locator(MaxNLocator(integer=True))


# ============================================================
# Figure 1: JK Monetary Policy Shock Series
# ============================================================
print("Figure 1: JK shock time series...")
main_df = pd.read_csv(os.path.join(DATA_DIR, 'analysis_main.csv'), index_col='date', parse_dates=True)

fig, ax = plt.subplots(figsize=(7, 3.5))
ax.bar(main_df.index, main_df['mp_shock'], width=25, color=COLORS['blue'], alpha=0.7, linewidth=0)
ax.axhline(0, color='black', linewidth=0.5)
ax.set_ylabel('Monetary Policy Shock (pp)')
ax.set_title('Jarocinski-Karadi Monetary Policy Shocks')
# Shade NBER recessions approximately
for start, end in [('2001-03-01', '2001-11-01'), ('2007-12-01', '2009-06-01'), ('2020-02-01', '2020-04-01')]:
    ax.axvspan(pd.Timestamp(start), pd.Timestamp(end), alpha=0.1, color='gray')
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig1_jk_shocks.pdf'))
plt.close()

# ============================================================
# Figure 2: Aggregate Employment IRF
# ============================================================
print("Figure 2: Aggregate employment IRF...")
agg = lp['aggregate']['PAYEMS']

# Compute 95% CIs: beta +/- 1.96*se
agg_ci95_lo = [b - 1.96 * s if not (np.isnan(b) or np.isnan(s)) else np.nan
               for b, s in zip(agg['beta'], agg['se'])]
agg_ci95_hi = [b + 1.96 * s if not (np.isnan(b) or np.isnan(s)) else np.nan
               for b, s in zip(agg['beta'], agg['se'])]

fig, ax = plt.subplots(figsize=(6.5, 4.5))
plot_irf(ax, agg['horizons'], agg['beta'], agg['ci90_lo'], agg['ci90_hi'],
         agg['ci68_lo'], agg['ci68_hi'],
         ci95_lo=agg_ci95_lo, ci95_hi=agg_ci95_hi, color='blue')
ax.set_ylabel('Employment Response (%)')
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig2_aggregate_irf.pdf'))
plt.close()

# ============================================================
# Figure 3: Industry-Level IRF Panel (4x3 grid)
# ============================================================
print("Figure 3: Industry-level IRF panel...")
industry_order = ['MANEMP', 'USCONS', 'USMINE', 'USWTRADE', 'USTRADE',
                  'USINFO', 'USFIRE', 'USPBS', 'USEHS', 'USLAH', 'USSERV', 'USTPU']

fig, axes = plt.subplots(4, 3, figsize=(10, 11))
axes = axes.flatten()

for i, series in enumerate(industry_order):
    if i >= len(axes):
        break
    ax = axes[i]
    if series in lp['industry']:
        res = lp['industry'][series]
        is_goods = series in pkg.GOODS_INDUSTRIES
        color = 'red' if is_goods else 'blue'
        plot_irf(ax, res['horizons'], res['beta'], res['ci90_lo'], res['ci90_hi'],
                 res['ci68_lo'], res['ci68_hi'], color=color)
    name = pkg.CES_SERIES.get(series, series)
    sector_label = ' [G]' if series in pkg.GOODS_INDUSTRIES else ' [S]'
    ax.set_title(name + sector_label, fontsize=9)
    if i >= 9:
        ax.set_xlabel('Months')
    if i % 3 == 0:
        ax.set_ylabel('Response (%)')

fig.suptitle('Industry-Level Employment Responses to Monetary Tightening', fontsize=12, y=1.02)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig3_industry_irfs.pdf'))
plt.close()

# ============================================================
# Figure 4: Goods vs Services IRF Comparison
# ============================================================
print("Figure 4: Goods vs services comparison...")

fig, ax = plt.subplots(figsize=(6.5, 4.5))

# Average goods IRF
goods_codes = [c for c in pkg.GOODS_INDUSTRIES if c in lp['industry']]
services_codes = [c for c in pkg.SERVICES_INDUSTRIES if c in lp['industry']]

if goods_codes:
    goods_avg_beta = np.nanmean([lp['industry'][c]['beta'] for c in goods_codes], axis=0)
    goods_avg_lo = np.nanmean([lp['industry'][c]['ci90_lo'] for c in goods_codes], axis=0)
    goods_avg_hi = np.nanmean([lp['industry'][c]['ci90_hi'] for c in goods_codes], axis=0)
    goods_avg_68lo = np.nanmean([lp['industry'][c]['ci68_lo'] for c in goods_codes], axis=0)
    goods_avg_68hi = np.nanmean([lp['industry'][c]['ci68_hi'] for c in goods_codes], axis=0)
    # 95% CI from averaged se: beta +/- 1.96*se
    goods_avg_se = np.nanmean([lp['industry'][c]['se'] for c in goods_codes], axis=0)
    goods_avg_95lo = goods_avg_beta - 1.96 * goods_avg_se
    goods_avg_95hi = goods_avg_beta + 1.96 * goods_avg_se
    plot_irf(ax, pkg.LP_HORIZONS, goods_avg_beta, goods_avg_lo, goods_avg_hi,
             ci68_lo=goods_avg_68lo, ci68_hi=goods_avg_68hi,
             ci95_lo=goods_avg_95lo, ci95_hi=goods_avg_95hi,
             color='red', label='Goods sectors')

if services_codes:
    svc_avg_beta = np.nanmean([lp['industry'][c]['beta'] for c in services_codes], axis=0)
    svc_avg_lo = np.nanmean([lp['industry'][c]['ci90_lo'] for c in services_codes], axis=0)
    svc_avg_hi = np.nanmean([lp['industry'][c]['ci90_hi'] for c in services_codes], axis=0)
    svc_avg_68lo = np.nanmean([lp['industry'][c]['ci68_lo'] for c in services_codes], axis=0)
    svc_avg_68hi = np.nanmean([lp['industry'][c]['ci68_hi'] for c in services_codes], axis=0)
    svc_avg_se = np.nanmean([lp['industry'][c]['se'] for c in services_codes], axis=0)
    svc_avg_95lo = svc_avg_beta - 1.96 * svc_avg_se
    svc_avg_95hi = svc_avg_beta + 1.96 * svc_avg_se
    plot_irf(ax, pkg.LP_HORIZONS, svc_avg_beta, svc_avg_lo, svc_avg_hi,
             ci68_lo=svc_avg_68lo, ci68_hi=svc_avg_68hi,
             ci95_lo=svc_avg_95lo, ci95_hi=svc_avg_95hi,
             color='blue', label='Services sectors')

ax.set_ylabel('Employment Response (%)')
ax.set_title('Goods vs. Services Employment Responses')
ax.legend(frameon=False)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig4_goods_vs_services.pdf'))
plt.close()

# ============================================================
# Figure 5: JOLTS Flow Decomposition
# ============================================================
print("Figure 5: JOLTS decomposition...")

fig, axes = plt.subplots(2, 3, figsize=(10, 6.5))
axes = axes.flatten()

flow_colors = {'JOL': 'blue', 'JOH': 'green', 'JST': 'red', 'JQU': 'orange', 'JLD': 'purple'}

for i, (flow_code, flow_name) in enumerate(pkg.JOLTS_FLOWS.items()):
    if i >= len(axes):
        break
    ax = axes[i]
    if flow_code in lp['jolts']:
        res = lp['jolts'][flow_code]
        plot_irf(ax, res['horizons'], res['beta'], res['ci90_lo'], res['ci90_hi'],
                 res.get('ci68_lo'), res.get('ci68_hi'),
                 color=flow_colors.get(flow_code, 'blue'))
    ax.set_title(flow_name, fontsize=10)
    if i >= 3:
        ax.set_xlabel('Months')
    if i % 3 == 0:
        ax.set_ylabel('Response (log × 100)')

# Hide unused subplot
if len(pkg.JOLTS_FLOWS) < len(axes):
    axes[-1].set_visible(False)

fig.suptitle('JOLTS Flow Responses to Monetary Tightening', fontsize=12, y=1.02)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig5_jolts_decomposition.pdf'))
plt.close()

# ============================================================
# Figure 6: Cyclicality Gradient
# ============================================================
print("Figure 6: Cyclicality gradient...")

fig, ax = plt.subplots(figsize=(6.5, 4.5))

cyc_class = classifications.get('cyclicality_class', {})
for tercile, color, ls in [('high', 'red', '-'), ('medium', 'gray', '--'), ('low', 'blue', ':')]:
    members = [k for k, v in cyc_class.items() if v == tercile]
    if members:
        tercile_betas = [lp['industry'][c]['beta'] for c in members if c in lp['industry']]
        if tercile_betas:
            avg = np.nanmean(tercile_betas, axis=0)
            ax.plot(pkg.LP_HORIZONS, avg, color=COLORS.get(color, color),
                    linewidth=1.5, linestyle=ls, label=f'{tercile.title()} cyclicality')

ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('Months')
ax.set_ylabel('Employment Response (%)')
ax.set_title('Employment Response by Industry Cyclicality')
ax.legend(frameon=False)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig6_cyclicality.pdf'))
plt.close()

# ============================================================
# Figure 7: Model vs Data IRFs
# ============================================================
print("Figure 7: Model vs data IRFs...")

irfs_het = np.array(model['irfs']['heterogeneous'])
irfs_ra = np.array(model['irfs']['representative_agent'])
var_names = model['irfs']['variables']
model_h = model['irfs']['horizons']

fig, axes = plt.subplots(1, 3, figsize=(10, 3.5))

# Panel A: Goods employment
ax = axes[0]
# Model
ax.plot(model_h, irfs_het[:, 0] * 100, color=COLORS['red'], linewidth=1.5, label='Model (goods)')
# Data (from LP)
if goods_codes:
    data_h = pkg.LP_HORIZONS
    ax.plot(data_h, goods_avg_beta, 'o', color=COLORS['red'], markersize=5, label='Data (goods)')
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('Months')
ax.set_ylabel('Response (%)')
ax.set_title('Goods Employment')
ax.legend(frameon=False, fontsize=8)

# Panel B: Services employment
ax = axes[1]
ax.plot(model_h, irfs_het[:, 1] * 100, color=COLORS['blue'], linewidth=1.5, label='Model (services)')
if services_codes:
    ax.plot(data_h, svc_avg_beta, 'o', color=COLORS['blue'], markersize=5, label='Data (services)')
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('Months')
ax.set_title('Services Employment')
ax.legend(frameon=False, fontsize=8)

# Panel C: Aggregate
ax = axes[2]
ss_vals = model['steady_state']
n_g_wt = ss_vals['n_g'] / (ss_vals['n_g'] + ss_vals['n_s'])
n_s_wt = ss_vals['n_s'] / (ss_vals['n_g'] + ss_vals['n_s'])
agg_model = (n_g_wt * irfs_het[:, 0] + n_s_wt * irfs_het[:, 1]) * 100
agg_ra = (0.5 * irfs_ra[:, 0] + 0.5 * irfs_ra[:, 1]) * 100

ax.plot(model_h, agg_model, color=COLORS['green'], linewidth=1.5, label='Het. model')
ax.plot(model_h, agg_ra, color=COLORS['gray'], linewidth=1.5, linestyle='--', label='Rep. agent')
# Data
if 'PAYEMS' in lp['aggregate']:
    agg_data = lp['aggregate']['PAYEMS']
    ax.plot(agg_data['horizons'], agg_data['beta'], 'o', color=COLORS['green'], markersize=5, label='Data')
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('Months')
ax.set_title('Aggregate Employment')
ax.legend(frameon=False, fontsize=8)

fig.suptitle('Model vs. Data: Employment Responses to Monetary Tightening', fontsize=11, y=1.04)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig7_model_vs_data.pdf'))
plt.close()

# ============================================================
# Figure 8: Welfare Decomposition
# ============================================================
print("Figure 8: Welfare decomposition...")

decomp = welfare['decomposition']
fig, ax = plt.subplots(figsize=(6.5, 4.5))

sectors = ['goods', 'services']
labels = ['Goods', 'Services']
x = np.arange(len(sectors))
width = 0.25

emp_vals = [decomp[s]['employment_component'] for s in sectors]
wage_vals = [decomp[s]['wage_component'] for s in sectors]
trans_vals = [decomp[s]['transition_component'] for s in sectors]

ax.bar(x - width/2, emp_vals, width, label='Employment', color=COLORS['blue'])
ax.bar(x + width/2, wage_vals, width, label='Wage', color=COLORS['red'])
# Omit Transition bars — negligible/zero values would clutter the legend

ax.set_ylabel('CE Welfare Loss (% annual)')
ax.set_title('Welfare Decomposition by Sector and Channel')
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.legend(frameon=False)
ax.axhline(0, color='black', linewidth=0.5)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig8_welfare_decomposition.pdf'))
plt.close()

# ============================================================
# Figure 9: Robustness — Alternative Shocks
# ============================================================
print("Figure 9: Robustness (subsample stability)...")

fig, ax = plt.subplots(figsize=(6.5, 4.5))

# Baseline with 68%, 90%, and 95% CI bands
agg_res = lp['aggregate']['PAYEMS']
h_arr = np.array(agg_res['horizons'])
b_arr = np.array(agg_res['beta'])
se_arr = np.array(agg_res['se'])
ci90_lo_arr = np.array(agg_res['ci90_lo'])
ci90_hi_arr = np.array(agg_res['ci90_hi'])
ci68_lo_arr = np.array(agg_res['ci68_lo'])
ci68_hi_arr = np.array(agg_res['ci68_hi'])
ci95_lo_arr = b_arr - 1.96 * se_arr
ci95_hi_arr = b_arr + 1.96 * se_arr
mask = ~np.isnan(b_arr)
plot_irf(ax, agg_res['horizons'], agg_res['beta'],
         agg_res['ci90_lo'], agg_res['ci90_hi'],
         ci68_lo=agg_res['ci68_lo'], ci68_hi=agg_res['ci68_hi'],
         ci95_lo=ci95_lo_arr.tolist(), ci95_hi=ci95_hi_arr.tolist(),
         color='blue', label='Baseline (full sample)')

# Subsamples
subsample_colors = {
    'subsample_pre_gfc': ('Pre-GFC (1990-2007)', 'red', '--'),
    'subsample_excl_zlb': ('Excl. ZLB (2009-2015)', 'green', '-.'),
    'subsample_excl_covid': ('Excl. COVID (2020-21)', 'orange', ':'),
}

for key, (label, color, ls) in subsample_colors.items():
    if key in rob:
        res = rob[key]
        h = res['horizons']
        b = res['beta']
        mask = [not np.isnan(x) for x in b]
        if any(mask):
            ax.plot([h[i] for i, m in enumerate(mask) if m],
                    [b[i] for i, m in enumerate(mask) if m],
                    color=COLORS.get(color, color), linewidth=1.2, linestyle=ls, label=label)

ax.set_ylabel('Employment Response (%)')
ax.set_title('Subsample Stability of Aggregate Employment Response')
ax.legend(frameon=False, fontsize=9)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig9_robustness_subsamples.pdf'))
plt.close()

# ============================================================
# Figure 10: Placebo Test
# ============================================================
print("Figure 10: Placebo test...")

fig, ax = plt.subplots(figsize=(6.5, 4.5))

if 'placebo_pre_fomc' in rob:
    placebo = rob['placebo_pre_fomc']
    h = placebo['horizons']
    b = placebo['beta']
    se = placebo['se']
    mask = [not np.isnan(x) for x in b]
    if any(mask):
        h_f = [h[i] for i, m in enumerate(mask) if m]
        b_f = [b[i] for i, m in enumerate(mask) if m]
        se_f = [se[i] for i, m in enumerate(mask) if m]

        ax.errorbar(h_f, b_f, yerr=[1.645 * s for s in se_f],
                    fmt='o-', color=COLORS['blue'], capsize=4, linewidth=1.5,
                    label='Pre-FOMC employment change')

ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('Months prior to FOMC')
ax.set_ylabel('Coefficient on MP shock')
ax.set_title('Placebo: Monetary Shocks Should Not Predict Prior Employment Changes')
ax.legend(frameon=False)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig10_placebo.pdf'))
plt.close()

# ============================================================
# Figure 11: Goods Interaction Coefficients
# ============================================================
print("Figure 11: Goods interaction coefficients...")

fig, ax = plt.subplots(figsize=(6.5, 4.5))

gi = lp.get('goods_interaction', {})
if gi and 'horizons' in gi:
    h = gi['horizons']
    delta = gi['delta']
    delta_se = gi['delta_se']
    mask = [not (np.isnan(d) or np.isnan(s)) for d, s in zip(delta, delta_se)]
    if any(mask):
        h_f = [h[i] for i, m in enumerate(mask) if m]
        d_f = [delta[i] for i, m in enumerate(mask) if m]
        se_f = [delta_se[i] for i, m in enumerate(mask) if m]

        lo = [d - 1.645 * s for d, s in zip(d_f, se_f)]
        hi = [d + 1.645 * s for d, s in zip(d_f, se_f)]

        ax.fill_between(h_f, lo, hi, alpha=0.15, color=COLORS['red'])
        ax.plot(h_f, d_f, color=COLORS['red'], linewidth=1.5, marker='o', markersize=4)

ax.axhline(0, color='black', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months')
ax.set_ylabel('Interaction Coefficient')
ax.set_title('Differential Response: Goods vs. Services (Interaction Term)')
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, 'fig11_goods_interaction.pdf'))
plt.close()

# ============================================================
# Summary
# ============================================================
print("\n" + "=" * 60)
print("FIGURES COMPLETE")
print("=" * 60)
figs = sorted([f for f in os.listdir(FIG_DIR) if f.endswith('.pdf')])
for f in figs:
    print(f"  {f}")
print(f"\nTotal: {len(figs)} figures")
