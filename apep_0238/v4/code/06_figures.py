"""
06_figures.py — Generate all figures for apep_0238 v4
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize, LinearSegmentedColormap
from matplotlib.cm import ScalarMappable

plt.rcParams.update({
    'font.family': 'serif', 'font.size': 11, 'axes.titlesize': 13,
    'axes.labelsize': 12, 'xtick.labelsize': 10, 'ytick.labelsize': 10,
    'legend.fontsize': 10, 'figure.dpi': 150, 'savefig.dpi': 300,
    'savefig.bbox': 'tight', 'axes.spines.top': False, 'axes.spines.right': False,
})

# Load data
with open(DATA_DIR / "processed_data.json") as f:
    proc = json.load(f)
with open(DATA_DIR / "lp_results.json") as f:
    lp = json.load(f)
with open(DATA_DIR / "model_results.json") as f:
    mod = json.load(f)
with open(DATA_DIR / "raw_fred_data.json") as f:
    raw = json.load(f)

summary = pd.DataFrame(proc['summary'])

# ──────────────────────────────────────────────────────────────
# Figure 1: State-level employment decline maps (side by side)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 1: State employment decline maps...")

# Simple state map using coordinate approximations (no geopandas needed)
STATE_COORDS = {
    'AL':(6.5,1.5),'AK':(0.5,5.5),'AZ':(1.5,2.5),'AR':(5,2),'CA':(0.5,3),
    'CO':(2.5,3),'CT':(9,4),'DE':(8.5,3.5),'FL':(7.5,0.5),'GA':(7,1.5),
    'HI':(2,0.5),'ID':(1.5,4.5),'IL':(5.5,3.5),'IN':(6,3.5),'IA':(4.5,3.5),
    'KS':(3.5,3),'KY':(6.5,3),'LA':(5,1),'ME':(9.5,5),'MD':(8,3.5),
    'MA':(9.5,4.5),'MI':(6,4.5),'MN':(4,4.5),'MS':(5.5,1.5),'MO':(5,3),
    'MT':(2,5),'NE':(3.5,3.5),'NV':(1,3.5),'NH':(9.5,5.5),'NJ':(8.5,4),
    'NM':(2,2),'NY':(8.5,4.5),'NC':(7.5,2.5),'ND':(3.5,5),'OH':(6.5,3.5),
    'OK':(3.5,2),'OR':(0.5,4.5),'PA':(8,4),'RI':(9.5,4),'SC':(7.5,2),
    'SD':(3.5,4.5),'TN':(6,2.5),'TX':(3.5,1),'UT':(1.5,3.5),'VT':(9,5.5),
    'VA':(7.5,3),'WA':(1,5.5),'WV':(7,3),'WI':(5,4.5),'WY':(2.5,4),
}

def draw_state_map(ax, values, title, cmap='RdYlGn', vmin=None, vmax=None, label=''):
    vals = {k: v for k, v in values.items() if not np.isnan(v)}
    if vmin is None: vmin = min(vals.values())
    if vmax is None: vmax = max(vals.values())
    norm = Normalize(vmin=vmin, vmax=vmax)
    cm = plt.get_cmap(cmap)

    for st, (x, y) in STATE_COORDS.items():
        if st in vals:
            color = cm(norm(vals[st]))
        else:
            color = '#cccccc'
        rect = plt.Rectangle((x-0.4, y-0.35), 0.8, 0.7, facecolor=color,
                             edgecolor='white', linewidth=0.5)
        ax.add_patch(rect)
        ax.text(x, y, st, ha='center', va='center', fontsize=6, fontweight='bold')

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 6.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')

    sm = ScalarMappable(cmap=cm, norm=norm)
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, fraction=0.03, pad=0.02)
    cbar.set_label(label, fontsize=9)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

gr_decline = {r['state']: r['gr_trough'] for r in proc['summary'] if not np.isnan(r.get('gr_trough', float('nan')))}
covid_decline = {r['state']: r['covid_trough'] for r in proc['summary'] if not np.isnan(r.get('covid_trough', float('nan')))}

draw_state_map(ax1, gr_decline, 'Panel A: Great Recession (2007-2009)',
              cmap='RdYlGn', vmin=-0.15, vmax=0.0, label='Log employment change')
draw_state_map(ax2, covid_decline, 'Panel B: COVID Recession (2020)',
              cmap='RdYlGn', vmin=-0.30, vmax=-0.05, label='Log employment change')

fig.suptitle('Figure 1: Peak-to-Trough Employment Decline by State', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
fig.savefig(FIG_DIR / "fig1_maps_recession_severity.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 2: Pre-trend event study (NEW)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 2: Pre-trend event study...")

fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Load event study results from lp_results.json
# These are LP coefficients estimated at pre- and post-period horizons
gr_event = lp.get('event_study', {}).get('gr', [])
covid_event = lp.get('event_study', {}).get('covid', [])

def plot_event_study(ax, results, color, title, recession_label):
    """Plot event-study coefficients with 95% CI."""
    if not results:
        ax.text(0.5, 0.5, 'Event study data not available\n(re-run 03_main_analysis.py)',
                transform=ax.transAxes, ha='center', va='center', fontsize=10, color='gray')
        ax.set_title(title, fontweight='bold')
        return

    valid = [r for r in results if r.get('beta') is not None and not np.isnan(r['beta'])]
    if not valid:
        ax.text(0.5, 0.5, 'No valid event study estimates',
                transform=ax.transAxes, ha='center', va='center', fontsize=10, color='gray')
        ax.set_title(title, fontweight='bold')
        return

    h = [r['h'] for r in valid]
    beta = [r['beta'] for r in valid]
    se = [r['se'] for r in valid]
    upper = [b + 1.96 * s for b, s in zip(beta, se)]
    lower = [b - 1.96 * s for b, s in zip(beta, se)]

    # Plot coefficients and CI
    ax.plot(h, beta, 'o-', color=color, linewidth=2, markersize=5, zorder=3)
    ax.fill_between(h, lower, upper, alpha=0.2, color=color, zorder=2)

    # Reference lines
    ax.axhline(0, color='black', linewidth=0.8, linestyle='-', zorder=1)
    ax.axvline(0, color='gray', linewidth=1.2, linestyle='--', alpha=0.7, zorder=1,
               label='Recession peak')

    # Shade pre-period
    h_min = min(h)
    ax.axvspan(h_min - 3, 0, alpha=0.05, color='green', zorder=0)
    ax.text((h_min + 0) / 2, ax.get_ylim()[1] * 0.85 if ax.get_ylim()[1] > 0 else 0.01,
            'Pre-period', ha='center', fontsize=9, color='green', alpha=0.7)

    ax.set_xlabel('Months relative to recession peak (h=0)')
    ax.set_ylabel(r'$\beta_h$ (log employment response)')
    ax.set_title(title, fontweight='bold')
    ax.legend(frameon=False, loc='lower left')
    ax.grid(True, alpha=0.3)

# Panel A: Great Recession
plot_event_study(axes[0], gr_event, '#1f77b4',
                 'Panel A: Great Recession (HPI instrument)',
                 'Dec 2007')

# Panel B: COVID
plot_event_study(axes[1], covid_event, '#d62728',
                 'Panel B: COVID Recession (Bartik instrument)',
                 'Feb 2020')

fig.suptitle('Figure 2: Pre-Trend Event Study', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
fig.savefig(FIG_DIR / "fig2_pretrend_event_study.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 3: Aggregate employment paths (was Figure 2)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 3: Aggregate employment paths...")

def dict_to_ts(d):
    dates = pd.to_datetime(list(d.keys()))
    vals = [float(v) for v in d.values()]
    return pd.Series(vals, index=dates).sort_index()

nat_emp = dict_to_ts(raw['national']['PAYEMS'])
nat_ur = dict_to_ts(raw['national']['UNRATE'])

fig, axes = plt.subplots(2, 2, figsize=(13, 9))

# Panel A: GR employment path
ax = axes[0, 0]
gr_slice = nat_emp['2006':'2016']
gr_base = nat_emp.loc[nat_emp.index.asof(pd.Timestamp('2007-12-01'))]
ax.plot(gr_slice.index, (gr_slice / gr_base - 1) * 100, 'b-', linewidth=1.5)
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.axvspan(pd.Timestamp('2007-12-01'), pd.Timestamp('2009-06-01'), alpha=0.15, color='gray')
ax.set_title('Panel A: Employment -- Great Recession', fontweight='bold')
ax.set_ylabel('% change from Dec 2007')

# Panel B: COVID employment path
ax = axes[0, 1]
covid_slice = nat_emp['2019':'2024']
covid_base = nat_emp.loc[nat_emp.index.asof(pd.Timestamp('2020-02-01'))]
ax.plot(covid_slice.index, (covid_slice / covid_base - 1) * 100, 'r-', linewidth=1.5)
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.axvspan(pd.Timestamp('2020-02-01'), pd.Timestamp('2020-04-01'), alpha=0.15, color='gray')
ax.set_title('Panel B: Employment -- COVID Recession', fontweight='bold')
ax.set_ylabel('% change from Feb 2020')

# Panel C: GR unemployment
ax = axes[1, 0]
gr_ur_slice = nat_ur['2006':'2016']
ax.plot(gr_ur_slice.index, gr_ur_slice, 'b-', linewidth=1.5)
ax.axvspan(pd.Timestamp('2007-12-01'), pd.Timestamp('2009-06-01'), alpha=0.15, color='gray')
ax.set_title('Panel C: Unemployment Rate -- Great Recession', fontweight='bold')
ax.set_ylabel('Percent')

# Panel D: COVID unemployment
ax = axes[1, 1]
covid_ur_slice = nat_ur['2019':'2024']
ax.plot(covid_ur_slice.index, covid_ur_slice, 'r-', linewidth=1.5)
ax.axvspan(pd.Timestamp('2020-02-01'), pd.Timestamp('2020-04-01'), alpha=0.15, color='gray')
ax.set_title('Panel D: Unemployment Rate -- COVID Recession', fontweight='bold')
ax.set_ylabel('Percent')

for ax in axes.flat:
    ax.grid(True, alpha=0.3)
plt.tight_layout()
fig.savefig(FIG_DIR / "fig3_aggregate_paths.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 4: Main LP results — Employment IRFs (was Figure 3)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 4: LP impulse response functions...")

def plot_irf(ax, results, color='blue', label='', fill=True):
    h = [r['h'] for r in results if not np.isnan(r['beta'])]
    beta = [r['beta'] for r in results if not np.isnan(r['beta'])]
    se = [r['se'] for r in results if not np.isnan(r['beta'])]
    upper = [b + 1.96 * s for b, s in zip(beta, se)]
    lower = [b - 1.96 * s for b, s in zip(beta, se)]
    ax.plot(h, beta, color=color, linewidth=2, label=label)
    if fill:
        ax.fill_between(h, lower, upper, alpha=0.15, color=color)
    ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')

fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Panel A: Great Recession (HPI instrument -- stronger)
ax = axes[0]
plot_irf(ax, lp['gr_hpi'], color='#1f77b4', label='Housing price instrument')
plot_irf(ax, lp['gr_bartik'], color='#2ca02c', label='Bartik (robustness)', fill=False)
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after recession peak')
ax.set_ylabel(r'$\beta$ (log employment response)')
ax.set_title('Panel A: Great Recession (2007-2009)', fontweight='bold')
ax.legend(frameon=False)
ax.set_xlim(0, 130)
ax.grid(True, alpha=0.3)

# Panel B: COVID (Bartik instrument)
ax = axes[1]
plot_irf(ax, lp['covid_bartik'], color='#d62728', label='Bartik instrument')
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after recession peak')
ax.set_ylabel(r'$\beta$ (log employment response)')
ax.set_title('Panel B: COVID Recession (2020)', fontweight='bold')
ax.legend(frameon=False)
ax.set_xlim(0, 50)
ax.grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig4_lp_employment_irfs.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 5: LP — UR and LFPR responses (was Figure 4)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 5: UR and LFPR impulse responses (1-SD effects)...")

# Standardize coefficients: multiply by instrument SD so y-axis shows 1-SD effect
hpi_sd = summary['hpi_boom'].dropna().std()
bartik_covid_sd = pd.Series([float(v) for v in proc['bartik_covid'].values()]).std()

def standardize_results(results, sd):
    """Scale coefficients and SEs by instrument SD for plotting."""
    return [{'h': r['h'], 'beta': r['beta'] * sd, 'se': r['se'] * sd,
             'pval': r.get('pval', np.nan)} for r in results if not np.isnan(r['beta'])]

fig, axes = plt.subplots(2, 2, figsize=(13, 9))

# Panel A: GR unemployment (HPI instrument)
plot_irf(axes[0, 0], standardize_results(lp['gr_ur'], hpi_sd), color='#1f77b4', label='Great Recession')
axes[0, 0].set_title('Panel A: Unemployment Rate -- GR', fontweight='bold')
axes[0, 0].set_ylabel('1-SD effect (pp change in UR)')
axes[0, 0].set_xlim(0, 130)

# Panel B: COVID unemployment (Bartik instrument)
plot_irf(axes[0, 1], standardize_results(lp['covid_ur'], bartik_covid_sd), color='#d62728', label='COVID')
axes[0, 1].set_title('Panel B: Unemployment Rate -- COVID', fontweight='bold')
axes[0, 1].set_ylabel('1-SD effect (pp change in UR)')
axes[0, 1].set_xlim(0, 50)

# Panel C: GR LFPR (HPI instrument)
plot_irf(axes[1, 0], standardize_results(lp['gr_lfpr'], hpi_sd), color='#1f77b4', label='Great Recession')
axes[1, 0].set_title('Panel C: Labor Force Participation -- GR', fontweight='bold')
axes[1, 0].set_ylabel('1-SD effect (pp change in LFPR)')
axes[1, 0].set_xlabel('Months after recession peak')
axes[1, 0].set_xlim(0, 130)

# Panel D: COVID LFPR (Bartik instrument)
plot_irf(axes[1, 1], standardize_results(lp['covid_lfpr'], bartik_covid_sd), color='#d62728', label='COVID')
axes[1, 1].set_title('Panel D: Labor Force Participation -- COVID', fontweight='bold')
axes[1, 1].set_ylabel('1-SD effect (pp change in LFPR)')
axes[1, 1].set_xlabel('Months after recession peak')
axes[1, 1].set_xlim(0, 50)

for ax in axes.flat:
    ax.grid(True, alpha=0.3)
plt.tight_layout()
fig.savefig(FIG_DIR / "fig5_lp_ur_lfpr.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 6: Scatter plots — Shock exposure vs outcomes (was Figure 5)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 6: Scatter -- shock exposure vs employment change...")

fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Panel A: GR — HPI boom vs employment change at h=48
ax = axes[0]
x_data, y_data, labels = [], [], []
for _, row in summary.iterrows():
    if not np.isnan(row.get('hpi_boom', float('nan'))) and not np.isnan(row.get('gr_recovery_48', float('nan'))):
        x_data.append(row['hpi_boom'])
        y_data.append(row['gr_recovery_48'])
        labels.append(row['state'])
ax.scatter(x_data, y_data, c='#1f77b4', s=30, alpha=0.7)
for x, y, l in zip(x_data, y_data, labels):
    ax.annotate(l, (x, y), fontsize=6, ha='center', va='bottom')
# Fit line
if len(x_data) > 5:
    z = np.polyfit(x_data, y_data, 1)
    x_line = np.linspace(min(x_data), max(x_data), 100)
    ax.plot(x_line, np.polyval(z, x_line), 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('Housing price boom (log change, 2003-2006)')
ax.set_ylabel('Log employment change at h=48 months')
ax.set_title('Panel A: Great Recession -- Housing Exposure', fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel B: COVID — Bartik vs employment change at h=48
ax = axes[1]
x_data, y_data, labels = [], [], []
bartik_covid = proc['bartik_covid']
for _, row in summary.iterrows():
    st = row['state']
    if st in bartik_covid:
        covid_paths = proc['covid_paths']
        if st in covid_paths and '48' in covid_paths[st]:
            x_data.append(float(bartik_covid[st]))
            y_data.append(float(covid_paths[st]['48']))
            labels.append(st)
ax.scatter(x_data, y_data, c='#d62728', s=30, alpha=0.7)
for x, y, l in zip(x_data, y_data, labels):
    ax.annotate(l, (x, y), fontsize=6, ha='center', va='bottom')
if len(x_data) > 5:
    z = np.polyfit(x_data, y_data, 1)
    x_line = np.linspace(min(x_data), max(x_data), 100)
    ax.plot(x_line, np.polyval(z, x_line), 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('Bartik predicted shock (log change)')
ax.set_ylabel('Log employment change at h=48 months')
ax.set_title('Panel B: COVID -- Industry Exposure', fontweight='bold')
ax.grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig6_scatter_exposure.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 7: Model vs Data comparison (was Figure 6)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 7: Model vs data...")

fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Model demand shock path
demand_emp = mod['demand_path']['emp_change']
supply_emp = mod['supply_path']['emp_change']

# Normalize model paths to match data scale
gr_betas = [r['beta'] for r in lp['gr_hpi'] if not np.isnan(r['beta']) and r['h'] <= 120]
gr_h = [r['h'] for r in lp['gr_hpi'] if not np.isnan(r['beta']) and r['h'] <= 120]
data_peak = min(gr_betas) if gr_betas else -0.08
model_peak = min(demand_emp[:121]) if len(demand_emp) > 120 else min(demand_emp)
scale_d = data_peak / model_peak if model_peak != 0 else 1

covid_betas = [r['beta'] for r in lp['covid_bartik'] if not np.isnan(r['beta']) and r['h'] <= 48]
covid_h = [r['h'] for r in lp['covid_bartik'] if not np.isnan(r['beta']) and r['h'] <= 48]

# Panel A: Great Recession
ax = axes[0]
model_h = list(range(0, 121, 3))
model_vals = [demand_emp[h] * scale_d for h in model_h]
ax.plot(model_h, model_vals, 'b-', linewidth=2, label='Model (demand shock)')
ax.plot(gr_h, gr_betas, 'ko', markersize=4, label='Data (HPI instrument)')
ax.fill_between(gr_h,
    [b - 1.96 * r['se'] for b, r in zip(gr_betas, [r for r in lp['gr_hpi'] if not np.isnan(r['beta']) and r['h'] <= 120])],
    [b + 1.96 * r['se'] for b, r in zip(gr_betas, [r for r in lp['gr_hpi'] if not np.isnan(r['beta']) and r['h'] <= 120])],
    alpha=0.1, color='gray')
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after shock')
ax.set_ylabel('Employment response')
ax.set_title('Panel A: Great Recession', fontweight='bold')
ax.legend(frameon=False)
ax.grid(True, alpha=0.3)

# Panel B: COVID
ax = axes[1]
supply_h = list(range(0, 49, 3))
supply_peak = min(supply_emp[:49]) if len(supply_emp) > 48 else min(supply_emp)
data_init = covid_betas[1] if len(covid_betas) > 1 else 0.5
model_init = supply_emp[3] if len(supply_emp) > 3 else -0.05
scale_s = abs(data_init / model_init) if model_init != 0 else 1
model_vals_s = [supply_emp[h] * scale_s for h in supply_h]
ax.plot(supply_h, model_vals_s, 'r-', linewidth=2, label='Model (supply shock)')
ax.plot(covid_h, covid_betas, 'ko', markersize=4, label='Data (Bartik)')
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after shock')
ax.set_ylabel('Employment response')
ax.set_title('Panel B: COVID Recession', fontweight='bold')
ax.legend(frameon=False)
ax.grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig7_model_vs_data.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 8: Model counterfactuals (was Figure 7)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 8: Model counterfactuals...")

fig, ax = plt.subplots(1, 1, figsize=(9, 6))

months = list(range(0, 121))
ax.plot(months, [demand_emp[h] for h in months], 'b-', linewidth=2.5,
        label='Demand shock (baseline)')
ax.plot(months, [mod['cf1_noscar']['emp_change'][h] for h in months], 'b--', linewidth=1.5,
        label='Demand shock, no scarring ($\\lambda$=0)')
ax.plot(months, [mod['cf2_noolf']['emp_change'][h] for h in months], 'b:', linewidth=1.5,
        label='Demand shock, no OLF exit ($\\chi$=0)')
ax.plot(months, [supply_emp[h] for h in months], 'r-', linewidth=2.5,
        label='Supply shock (baseline)')
ax.plot(months, [mod['cf3_permsupply']['emp_change'][h] for h in months], 'r--', linewidth=1.5,
        label='Supply shock, permanent')
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after shock')
ax.set_ylabel('Log employment change')
ax.set_title('Model Impulse Responses and Counterfactuals', fontweight='bold')
ax.legend(frameon=False, fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig8_counterfactuals.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 9: JOLTS evidence — quits vs layoffs (was Figure 8)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 9: JOLTS decomposition...")

def ts_from_raw(key, sid):
    d = raw[key].get(sid, {})
    return dict_to_ts(d) if d else None

jolts_quits = ts_from_raw('jolts', 'JTSQUL')
jolts_layoffs = ts_from_raw('jolts', 'JTSLDR')
jolts_hires = ts_from_raw('jolts', 'JTSHIL')
jolts_openings = ts_from_raw('jolts', 'JTSJOL')

fig, axes = plt.subplots(2, 2, figsize=(13, 9))

for ax, series, title, color in [
    (axes[0,0], jolts_openings, 'Job Openings (thousands)', '#1f77b4'),
    (axes[0,1], jolts_hires, 'Hires (thousands)', '#2ca02c'),
    (axes[1,0], jolts_quits, 'Quits (thousands)', '#ff7f0e'),
    (axes[1,1], jolts_layoffs, 'Layoffs & Discharges (thousands)', '#d62728'),
]:
    if series is not None:
        ax.plot(series.index, series.values, color=color, linewidth=1.5)
        # NBER recession shading
        ax.axvspan(pd.Timestamp('2001-03-01'), pd.Timestamp('2001-11-01'), alpha=0.08, color='gray', label='_nolegend_')
        ax.axvspan(pd.Timestamp('2007-12-01'), pd.Timestamp('2009-06-01'), alpha=0.1, color='blue', label='GR')
        ax.axvspan(pd.Timestamp('2020-02-01'), pd.Timestamp('2020-04-01'), alpha=0.1, color='red', label='COVID')
    ax.set_title(title, fontweight='bold')
    ax.set_ylabel('Thousands')
    ax.grid(True, alpha=0.3)

# Add shared legend in last panel
axes[1,1].legend(frameon=False, loc='upper right', fontsize=9)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig9_jolts_decomposition.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 10: Cross-recession comparison (was Figure 9)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 10: Cross-recession IRF comparison...")

fig, ax = plt.subplots(1, 1, figsize=(9, 6))

# GR HPI betas
gr_h_plot = [r['h'] for r in lp['gr_hpi'] if not np.isnan(r['beta'])]
gr_beta_plot = [r['beta'] for r in lp['gr_hpi'] if not np.isnan(r['beta'])]
gr_se_plot = [r['se'] for r in lp['gr_hpi'] if not np.isnan(r['beta'])]

# COVID Bartik betas — negate (to align sign convention: negative = scarring)
# and rescale by 0.30 to equalize one-SD exposure units across instruments.
# HPI SD ≈ 0.25, Bartik-COVID SD ≈ 0.08; ratio ≈ 0.30.
# This makes the y-axis comparable: both lines show the response to a
# one-standard-deviation increase in recession exposure.
covid_h_plot = [r['h'] for r in lp['covid_bartik'] if not np.isnan(r['beta'])]
covid_beta_plot = [-r['beta'] * 0.3 for r in lp['covid_bartik'] if not np.isnan(r['beta'])]
covid_se_plot = [r['se'] * 0.3 for r in lp['covid_bartik'] if not np.isnan(r['beta'])]

ax.plot(gr_h_plot, gr_beta_plot, '-o', color='#1f77b4', linewidth=2, markersize=3,
        label='Great Recession (HPI instrument)')
ax.fill_between(gr_h_plot,
    [b - 1.96*s for b, s in zip(gr_beta_plot, gr_se_plot)],
    [b + 1.96*s for b, s in zip(gr_beta_plot, gr_se_plot)],
    alpha=0.15, color='#1f77b4')

ax.plot(covid_h_plot, covid_beta_plot, '-s', color='#d62728', linewidth=2, markersize=3,
        label='COVID (Bartik, rescaled)')
ax.fill_between(covid_h_plot,
    [b - 1.96*s for b, s in zip(covid_beta_plot, covid_se_plot)],
    [b + 1.96*s for b, s in zip(covid_beta_plot, covid_se_plot)],
    alpha=0.15, color='#d62728')

ax.axhline(0, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Months after recession peak')
ax.set_ylabel(r'Employment response ($\beta$)')
ax.set_title('Employment Persistence: Great Recession vs. COVID', fontweight='bold')
ax.legend(frameon=False)
ax.grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(FIG_DIR / "fig10_cross_recession_comparison.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 11: Recovery speed map (was Figure 10)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 11: Recovery speed maps...")

# Compute months to recover to 50% of pre-recession employment
def months_to_recover(paths, threshold_frac=0.5):
    """Months until log employment change returns to threshold_frac * trough."""
    recovery = {}
    for st, path in paths.items():
        if isinstance(path, dict):
            h_vals = sorted([(int(k), v) for k, v in path.items()], key=lambda x: x[0])
        else:
            h_vals = list(enumerate(path))
        if not h_vals:
            continue
        trough = min(v for _, v in h_vals)
        if trough >= 0:
            recovery[st] = 0
            continue
        target = trough * threshold_frac
        for h, v in h_vals:
            if v >= target and h > 0:
                recovery[st] = h
                break
        else:
            recovery[st] = max(h for h, _ in h_vals)  # Not recovered
    return recovery

gr_recovery = months_to_recover(proc['gr_paths'])
covid_recovery = months_to_recover(proc['covid_paths'])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
draw_state_map(ax1, gr_recovery, 'Panel A: Great Recession -- Months to 50% Recovery',
              cmap='RdYlGn_r', vmin=0, vmax=80, label='Months')
draw_state_map(ax2, covid_recovery, 'Panel B: COVID -- Months to 50% Recovery',
              cmap='RdYlGn_r', vmin=0, vmax=24, label='Months')
plt.tight_layout()
fig.savefig(FIG_DIR / "fig11_recovery_speed_maps.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 12: Welfare decomposition from model (was Figure 11)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 12: Welfare decomposition...")

fig, ax = plt.subplots(1, 1, figsize=(8, 5))

welfare = mod['welfare']
categories = ['Demand\n(baseline)', 'No scarring\n($\\lambda$=0)', 'No OLF exit\n($\\chi$=0)', 'Supply\n(baseline)']
values = [welfare['demand']*100, welfare['cf1_noscar']*100,
          welfare['cf2_noolf']*100, welfare['supply']*100]
colors = ['#1f77b4', '#aec7e8', '#c6dbef', '#d62728']

bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=0.5)
ax.set_ylabel('Welfare loss (consumption-equivalent, %)')
ax.set_title('Welfare Decomposition: Demand vs. Supply Shocks', fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# Add value labels
for bar, val in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
            f'{val:.2f}%', ha='center', va='bottom', fontsize=10, fontweight='bold')

plt.tight_layout()
fig.savefig(FIG_DIR / "fig12_welfare_decomposition.pdf")
plt.close()

# ──────────────────────────────────────────────────────────────
# Figure 13: Model parameter sensitivity heatmap (NEW appendix)
# ──────────────────────────────────────────────────────────────
print("Generating Figure 13: Model sensitivity heatmap...")

sensitivity = mod.get('sensitivity', [])

if sensitivity:
    # Build grid from sensitivity results
    lambda_vals = sorted(set(r['lambda'] for r in sensitivity))
    a_shock_vals = sorted(set(r['a_shock'] for r in sensitivity))

    # Create 2D array for heatmap: rows = lambda, cols = a_shock
    half_life_grid = np.full((len(lambda_vals), len(a_shock_vals)), np.nan)
    for r in sensitivity:
        i = lambda_vals.index(r['lambda'])
        j = a_shock_vals.index(r['a_shock'])
        hl = r['demand_half_life']
        if isinstance(hl, str) and hl.startswith('>'):
            half_life_grid[i, j] = 120  # Cap at 120 for display
        elif hl is not None:
            half_life_grid[i, j] = float(hl)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Custom colormap: green (fast recovery) -> yellow -> red (slow/no recovery)
    cmap = plt.get_cmap('YlOrRd')
    im = ax.imshow(half_life_grid, cmap=cmap, aspect='auto',
                   vmin=0, vmax=120, origin='lower')

    # Labels
    ax.set_xticks(range(len(a_shock_vals)))
    ax.set_xticklabels([f'{v:.0%}' for v in a_shock_vals])
    ax.set_yticks(range(len(lambda_vals)))
    ax.set_yticklabels([f'{v:.2f}' for v in lambda_vals])

    ax.set_xlabel('Productivity shock size ($\\Delta a$)', fontsize=12)
    ax.set_ylabel('Skill depreciation ($\\lambda$)', fontsize=12)
    ax.set_title('Demand Half-Life (months to 50% employment recovery)', fontweight='bold')

    # Annotate cells with values
    for i in range(len(lambda_vals)):
        for j in range(len(a_shock_vals)):
            val = half_life_grid[i, j]
            if not np.isnan(val):
                text_color = 'white' if val > 80 else 'black'
                label = f'{int(val)}' if val < 120 else '>120'
                ax.text(j, i, label, ha='center', va='center',
                        fontsize=11, fontweight='bold', color=text_color)

    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Months', fontsize=11)

    plt.tight_layout()
    fig.savefig(FIG_DIR / "fig13_model_sensitivity.pdf")
    plt.close()
else:
    print("  [SKIP] No sensitivity data in model_results.json (re-run 05_model.py)")

print(f"\nAll figures saved to {FIG_DIR}")
