"""
08_tables.py — Generate all LaTeX tables for apep_0234
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

with open(DATA_DIR / "processed_data.json") as f:
    proc = json.load(f)
with open(DATA_DIR / "lp_results.json") as f:
    lp = json.load(f)
with open(DATA_DIR / "model_results.json") as f:
    mod = json.load(f)

summary = pd.DataFrame(proc['summary'])

def stars(pval):
    if pval is None or np.isnan(pval): return ""
    if pval < 0.01: return "^{***}"
    if pval < 0.05: return "^{**}"
    if pval < 0.10: return "^{*}"
    return ""

# ──────────────────────────────────────────────────────────────
# Table 1: Summary Statistics
# ──────────────────────────────────────────────────────────────
print("Generating Table 1: Summary statistics...")

panel = pd.read_csv(DATA_DIR / "state_panel.csv")

desc_vars = [
    ('emp', 'Nonfarm payrolls (thousands)'),
    ('ur', 'Unemployment rate (\\%)'),
    ('lfpr', 'Labor force participation rate (\\%)'),
]

tex = r"""\begin{table}[H]
\centering
\caption{Summary Statistics}
\begin{threeparttable}
\begin{tabular}{lrrrrr}
\toprule
Variable & Mean & Std. Dev. & Min & Max & N \\
\midrule
\multicolumn{6}{l}{\textit{Panel A: State-level outcomes (monthly, 2000--2024)}} \\[3pt]
"""
for var, label in desc_vars:
    s = panel[var].dropna()
    tex += f"{label} & {s.mean():,.1f} & {s.std():,.1f} & {s.min():,.1f} & {s.max():,.1f} & {len(s):,} \\\\\n"

tex += r"""\midrule
\multicolumn{6}{l}{\textit{Panel B: Recession exposure measures}} \\[3pt]
"""
for var, label in [
    ('bartik_gr', 'Bartik shock: Great Recession'),
    ('bartik_covid', 'Bartik shock: COVID'),
    ('hpi_boom', 'Housing price boom (log, 2003--2006)'),
    ('gr_trough', 'Peak-to-trough employment (GR)'),
    ('covid_trough', 'Peak-to-trough employment (COVID)'),
]:
    s = summary[var].dropna()
    tex += f"{label} & {s.mean():.4f} & {s.std():.4f} & {s.min():.4f} & {s.max():.4f} & {len(s)} \\\\\n"

tex += r"""\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Panel A reports summary statistics for the balanced state-month panel. Nonfarm payrolls are from BLS Current Employment Statistics via FRED. Panel B reports cross-state recession exposure measures. Bartik shocks are constructed using pre-recession industry employment shares weighted by national industry employment changes. Housing price boom is the log change in the FHFA state-level house price index from 2003Q1 to 2006Q4.
\end{tablenotes}
\end{threeparttable}
\label{tab:summary}
\end{table}
"""
with open(TAB_DIR / "tab1_summary.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 2: Main LP Results — Employment (with permutation p-values)
# ──────────────────────────────────────────────────────────────
print("Generating Table 2: Main LP results...")

horizons_tab = [3, 6, 12, 24, 36, 48, 60, 84, 120]

# Load permutation p-values if available
perm_pvals = lp.get('permutation_pvals', {})
perm_gr = perm_pvals.get('gr_hpi', {})      # dict: str(h) -> p-value
perm_covid = perm_pvals.get('covid_bartik', {})  # dict: str(h) -> p-value

tex = r"""\begin{table}[H]
\centering
\caption{Local Projection Estimates: Employment Response to Recession Exposure}
\begin{threeparttable}
\small
\begin{tabular}{l""" + "c" * len(horizons_tab) + r"""}
\toprule
& """ + " & ".join([f"$h={h}$" for h in horizons_tab]) + r""" \\
\midrule
\multicolumn{""" + str(len(horizons_tab)+1) + r"""}{l}{\textit{Panel A: Great Recession --- Housing price instrument}} \\[3pt]
"""

# Row 1: coefficients with stars
for h in horizons_tab:
    r = next((x for x in lp['gr_hpi'] if x['h'] == h), None)
    if r and r['beta'] is not None:
        tex += f"& ${r['beta']:.4f}{stars(r['pval'])}$ "
    else:
        tex += "& --- "
tex += r"\\" + "\n"

# Row 2: HC1 standard errors in parentheses
for h in horizons_tab:
    r = next((x for x in lp['gr_hpi'] if x['h'] == h), None)
    if r and r['se'] is not None:
        tex += f"& ({r['se']:.4f}) "
    else:
        tex += "& "
tex += r"\\" + "\n"

# Row 3: permutation p-values in brackets (if available)
if perm_gr:
    for h in horizons_tab:
        pval = perm_gr.get(str(h))
        if pval is not None:
            tex += f"& [{pval:.3f}] "
        else:
            tex += "& "
    tex += r"\\" + "\n"

# R-squared row
tex += r"""$R^2$ """
for h in horizons_tab:
    r = next((x for x in lp['gr_hpi'] if x['h'] == h), None)
    if r and r['r2'] is not None:
        tex += f"& {r['r2']:.3f} "
    else:
        tex += "& "
tex += r""" \\
\midrule
\multicolumn{""" + str(len(horizons_tab)+1) + r"""}{l}{\textit{Panel B: COVID Recession --- Bartik instrument}} \\[3pt]
"""

# Row 1: coefficients with stars
for h in horizons_tab:
    r = next((x for x in lp['covid_bartik'] if x['h'] == h), None)
    if r and r['beta'] is not None:
        tex += f"& ${r['beta']:.4f}{stars(r['pval'])}$ "
    else:
        tex += "& --- "
tex += r"\\" + "\n"

# Row 2: HC1 standard errors in parentheses
for h in horizons_tab:
    r = next((x for x in lp['covid_bartik'] if x['h'] == h), None)
    if r and r['se'] is not None:
        tex += f"& ({r['se']:.4f}) "
    else:
        tex += "& "
tex += r"\\" + "\n"

# Row 3: permutation p-values in brackets (if available)
if perm_covid:
    for h in horizons_tab:
        pval = perm_covid.get(str(h))
        if pval is not None:
            tex += f"& [{pval:.3f}] "
        else:
            tex += "& "
    tex += r"\\" + "\n"

# R-squared row
tex += r"""$R^2$ """
for h in horizons_tab:
    r = next((x for x in lp['covid_bartik'] if x['h'] == h), None)
    if r and r['r2'] is not None:
        tex += f"& {r['r2']:.3f} "
    else:
        tex += "& "

tex += r""" \\
\midrule
$N$ & \multicolumn{""" + str(len(horizons_tab)) + r"""}{c}{46 (GR) / 48 (COVID)} \\
\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Each column reports the coefficient from a cross-state regression of log employment change (relative to recession peak) on recession exposure at horizon $h$ months. Negative $\hat{\beta}_h$ indicates employment decline relative to the pre-recession level. Panel A uses the 2003--2006 housing price boom as the exposure measure for the Great Recession; Panel B uses the Bartik-predicted employment shock for COVID. COVID horizons beyond $h=48$ are not reported because the post-peak observation window extends only 52 months (through June 2024). Robust (HC1) standard errors in parentheses. Permutation $p$-values in brackets; 1,000 random reassignments of the state-level exposure measure. $R^2$ reported without brackets. $^{*}$~$p<0.10$, $^{**}$~$p<0.05$, $^{***}$~$p<0.01$.
\end{tablenotes}
\end{threeparttable}
\label{tab:main}
\end{table}
"""
with open(TAB_DIR / "tab2_main_lp.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 3: Half-life and persistence
# ──────────────────────────────────────────────────────────────
print("Generating Table 3: Half-life and persistence...")

hl = lp['half_lives']
tex = r"""\begin{table}[H]
\centering
\caption{Employment Persistence: Half-Lives and Recovery Measures}
\begin{threeparttable}
\begin{tabular}{lcc}
\toprule
& Great Recession & COVID Recession \\
\midrule
"""
gr_peak = hl['gr']['peak_beta']
covid_peak = hl['covid']['peak_beta']
gr_peak_str = f"${gr_peak:.4f}$" if gr_peak is not None and not np.isnan(gr_peak) and gr_peak != 0 else "---"
covid_peak_str = f"${covid_peak:.4f}$" if covid_peak is not None and not np.isnan(covid_peak) and covid_peak != 0 else "---"
tex += f"Peak response ($\\hat{{\\beta}}_{{peak}}$) & {gr_peak_str} & {covid_peak_str} \\\\\n"
tex += f"Peak horizon (months) & {hl['gr']['peak_h']} & {hl['covid']['peak_h'] if covid_peak != 0 else '---'} \\\\\n"

gr_hl = hl['gr']['half_life']
covid_hl = hl['covid']['half_life']
gr_hl_str = f"{int(gr_hl)}" if gr_hl is not None and not np.isnan(gr_hl) and gr_hl != float('inf') else "$>$120"
covid_hl_str = f"{int(covid_hl)}" if covid_hl is not None and not np.isnan(covid_hl) and covid_hl != float('inf') else "---"
tex += f"Half-life (months) & {gr_hl_str} & {covid_hl_str} \\\\\n"

tex += f"$\\hat{{\\beta}}_{{48}}$ & ${hl['gr']['beta_48']:.4f}$ & "
b48c = hl['covid']['beta_48']
tex += f"${b48c:.4f}$" if b48c is not None else "---"
tex += " \\\\\n"

pers_gr = hl['gr']['persistence']
pers_c = hl['covid']['persistence']
tex += f"Persistence ratio ($\\hat{{\\beta}}_{{48}} / \\hat{{\\beta}}_{{peak}}$) & "
tex += f"${pers_gr:.3f}$" if pers_gr and not np.isnan(pers_gr) else "---"
tex += " & "
tex += f"${pers_c:.3f}$" if pers_c and not np.isnan(pers_c) else "---"
tex += " \\\\\n"

tex += r"""\midrule
Instrument & Housing price boom & Bartik (industry shares) \\
States & 46 & 48 \\
\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} For the Great Recession, peak response is the most negative $\hat{\beta}_h$ across all horizons; for COVID, it is the most positive (capturing the initial strong relationship between exposure and employment loss that fades as states recover). Half-life is the number of months after peak until $|\hat{\beta}_h|$ decays to half its peak value. Persistence ratio measures how much of the peak effect remains at $h=48$ months.
\end{tablenotes}
\end{threeparttable}
\label{tab:halflife}
\end{table}
"""
with open(TAB_DIR / "tab3_halflife.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 4: Model Calibration
# ──────────────────────────────────────────────────────────────
print("Generating Table 4: Model calibration...")

cal = mod['calibration']
ss = mod['steady_state']

tex = r"""\begin{table}[H]
\centering
\caption{Model Calibration}
\begin{threeparttable}
\begin{tabular}{llcc}
\toprule
Parameter & Description & Value & Target/Source \\
\midrule
\multicolumn{4}{l}{\textit{Panel A: Calibrated parameters}} \\[3pt]
"""
params = [
    (r'$\beta$', 'Monthly discount factor', f"{cal['beta']:.3f}", 'Standard (annual 4.8\\%)'),
    (r'$\alpha$', 'Matching elasticity', f"{cal['alpha']:.2f}", 'Petrongolo \\& Pissarides (2001)'),
    ('$A$', 'Matching efficiency', f"{cal['A']:.2f}", 'Match monthly job finding rate'),
    (r'$\delta$', 'Separation rate', f"{cal['delta']:.3f}", 'JOLTS 2001--2019 average'),
    (r'$\kappa$', 'Vacancy posting cost', f"{cal['kappa']:.2f}", 'Free entry condition'),
    ('$b$', 'Unemployment benefit', f"{cal['b']:.2f}", 'Replacement ratio $\\approx$ 0.71'),
    ('$b_{olf}$', 'OLF home production', f"{cal['b_olf']:.2f}", 'Below unemployment benefit'),
    (r'$\gamma$', 'Worker bargaining power', f"{cal['gamma']:.2f}", 'Hosios condition'),
    (r'$\lambda$', 'Skill depreciation', f"{cal['lam']:.2f}", 'Jacobson et al.\\ (1993)'),
    (r'$\chi$', 'OLF exit rate', f"{cal['chi_base']:.3f}", 'Match LFP cyclicality'),
    (r'$\psi$', 'LF re-entry rate', f"{cal['psi']:.2f}", 'Match OLF-to-U flows'),
]
for sym, desc, val, target in params:
    tex += f"{sym} & {desc} & {val} & {target} \\\\\n"

tex += r"""\midrule
\multicolumn{4}{l}{\textit{Panel B: Steady-state outcomes}} \\[3pt]
"""
ur_model = ss['u'] / (ss['e'] + ss['u'])
lfpr_model = (ss['e'] + ss['u']) / (ss['e'] + ss['u'] + ss['o'])
ss_rows = [
    ('Employment share $E/(E+U+O)$', f"{ss['e']:.4f}", '---'),
    ('Unemployment rate $U/(E+U)$', f"{ur_model:.4f}", '0.055 (BLS 2001--2019)'),
    ('LFPR $(E+U)/(E+U+O)$', f"{lfpr_model:.4f}", '0.96 (prime-age, CPS)'),
    ('OLF share $O/(E+U+O)$', f"{ss['o']:.4f}", '---'),
    ('Market tightness $\\theta$', f"{ss['theta']:.4f}", '0.72 (JOLTS 2001--2019)'),
    ('Job finding rate $f$', f"{ss['f']:.4f}", '0.40 (Shimer 2005)'),
    ('Wage $w$', f"{ss['w']:.4f}", '---'),
]
for desc, val, target in ss_rows:
    tex += f"{desc} & & {val} & {target} \\\\\n"

tex += r"""\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} The model is a Diamond-Mortensen-Pissarides search model with endogenous labor force participation and skill depreciation during unemployment. Time period is one month. Panel A reports externally calibrated parameters. Panel B reports implied steady-state values.
\end{tablenotes}
\end{threeparttable}
\label{tab:calibration}
\end{table}
"""
with open(TAB_DIR / "tab4_calibration.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 5: Welfare results
# ──────────────────────────────────────────────────────────────
print("Generating Table 5: Welfare results...")

w = mod['welfare']
tex = r"""\begin{table}[H]
\centering
\caption{Welfare Losses from Demand vs.\ Supply Shocks: Model Counterfactuals}
\begin{threeparttable}
\begin{tabular}{lcc}
\toprule
Scenario & CE Welfare Loss (\%) & Relative to Baseline \\
\midrule
\multicolumn{3}{l}{\textit{Panel A: Demand shock (Great Recession analog)}} \\[3pt]
"""
tex += f"Baseline (all mechanisms) & {w['demand']*100:.2f} & 1.00 \\\\\n"
tex += f"No skill depreciation ($\\lambda = 0$) & {w['cf1_noscar']*100:.2f} & {w['cf1_noscar']/w['demand']:.2f} \\\\\n"
tex += f"No OLF exit ($\\chi = 0$) & {w['cf2_noolf']*100:.2f} & {w['cf2_noolf']/w['demand']:.2f} \\\\\n"

tex += r"""\midrule
\multicolumn{3}{l}{\textit{Panel B: Supply shock (COVID analog)}} \\[3pt]
"""
tex += f"Baseline (temporary shock) & {w['supply']*100:.2f} & --- \\\\\n"

tex += r"""\midrule
Demand/Supply welfare ratio & \multicolumn{2}{c}{"""
tex += f"{w['demand']/w['supply']:.1f}" if w['supply'] != 0 else "---"
tex += r"""} \\
\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Consumption-equivalent (CE) welfare losses are computed as the permanent percentage reduction in consumption that would make agents indifferent between the steady state and the post-shock transition path. The demand shock reduces aggregate productivity by 5\% permanently. The supply shock doubles the separation rate for 3 months.
\end{tablenotes}
\end{threeparttable}
\label{tab:welfare}
\end{table}
"""
with open(TAB_DIR / "tab5_welfare.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 6: Most and least affected states (n/a for missing HPI)
# ──────────────────────────────────────────────────────────────
print("Generating Table 6: Most/least affected states...")

tex = r"""\begin{table}[H]
\centering
\caption{Most and Least Affected States by Recession}
\begin{threeparttable}
\small
\begin{tabular}{llrr|llrr}
\toprule
\multicolumn{4}{c}{\textit{Great Recession}} & \multicolumn{4}{c}{\textit{COVID Recession}} \\
State & Name & Trough & HPI Boom & State & Name & Trough & Bartik \\
\midrule
\multicolumn{4}{l}{\textit{5 Most Affected}} & \multicolumn{4}{l}{\textit{5 Most Affected}} \\
"""

gr_sorted = summary.dropna(subset=['gr_trough']).sort_values('gr_trough')
covid_sorted = summary.dropna(subset=['covid_trough']).sort_values('covid_trough')

for i in range(5):
    gr_row = gr_sorted.iloc[i]
    covid_row = covid_sorted.iloc[i]
    gr_hpi = gr_row.get('hpi_boom', float('nan'))
    covid_bart = covid_row.get('bartik_covid', float('nan'))
    tex += f"{gr_row['state']} & {gr_row['state_name'][:12]} & {gr_row['gr_trough']:.3f} & "
    tex += f"{gr_hpi:.3f}" if not np.isnan(gr_hpi) else "n/a"
    tex += f" & {covid_row['state']} & {covid_row['state_name'][:12]} & {covid_row['covid_trough']:.3f} & "
    tex += f"{covid_bart:.3f}" if not np.isnan(covid_bart) else "n/a"
    tex += " \\\\\n"

tex += r"""\midrule
\multicolumn{4}{l}{\textit{5 Least Affected}} & \multicolumn{4}{l}{\textit{5 Least Affected}} \\
"""

for i in range(5):
    gr_row = gr_sorted.iloc[-(i+1)]
    covid_row = covid_sorted.iloc[-(i+1)]
    gr_hpi = gr_row.get('hpi_boom', float('nan'))
    covid_bart = covid_row.get('bartik_covid', float('nan'))
    tex += f"{gr_row['state']} & {gr_row['state_name'][:12]} & {gr_row['gr_trough']:.3f} & "
    tex += f"{gr_hpi:.3f}" if not np.isnan(gr_hpi) else "n/a"
    tex += f" & {covid_row['state']} & {covid_row['state_name'][:12]} & {covid_row['covid_trough']:.3f} & "
    tex += f"{covid_bart:.3f}" if not np.isnan(covid_bart) else "n/a"
    tex += " \\\\\n"

tex += r"""\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Trough is the log employment change from recession peak to trough. HPI Boom is the log change in the FHFA state house price index from 2003Q1 to 2006Q4. Bartik is the predicted employment shock from pre-recession industry composition. ``n/a'' indicates data unavailable for this state.
\end{tablenotes}
\end{threeparttable}
\label{tab:states}
\end{table}
"""
with open(TAB_DIR / "tab6_states.tex", 'w') as f:
    f.write(tex)

# ──────────────────────────────────────────────────────────────
# Table 7: Subsample Robustness (Appendix)
# ──────────────────────────────────────────────────────────────
print("Generating Table 7: Subsample robustness...")

subsample = lp.get('subsample', {})

if subsample:
    tex = r"""\begin{table}[H]
\centering
\caption{Subsample Robustness: Great Recession Employment Effects}
\begin{threeparttable}
\small
\begin{tabular}{lcccc}
\toprule
Subsample & $N$ & $\hat{\beta}_{60}$ & SE & $p$-value \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Census regions}} \\[3pt]
"""
    region_order = [('region_Northeast', 'Northeast'), ('region_Midwest', 'Midwest'),
                    ('region_South', 'South'), ('region_West', 'West')]
    for key, label in region_order:
        r = subsample.get(key, {})
        if r:
            b = r.get('beta_60')
            se = r.get('se_60')
            pv = r.get('pval', r.get('pval_60'))
            n = r.get('n', '')
            import math
            if b is not None and not (isinstance(b, float) and math.isnan(b)):
                tex += f"{label} & {n} & ${b:.4f}{stars(pv)}$ & ({se:.4f}) & {pv:.3f} \\\\\n"
            else:
                tex += f"{label} & {n} & --- & --- & --- \\\\\n"
        else:
            tex += f"{label} & --- & --- & --- & --- \\\\\n"

    tex += r"""\midrule
\multicolumn{5}{l}{\textit{Panel B: State employment size}} \\[3pt]
"""
    size_groups = [('large_above_median', 'Large states'), ('small_below_median', 'Small states')]
    for key, label in size_groups:
        r = subsample.get(key, {})
        if r:
            b = r.get('beta_60')
            se = r.get('se_60')
            pv = r.get('pval', r.get('pval_60'))
            n = r.get('n', '')
            import math
            if b is not None and not (isinstance(b, float) and math.isnan(b)):
                tex += f"{label} & {n} & ${b:.4f}{stars(pv)}$ & ({se:.4f}) & {pv:.3f} \\\\\n"
            else:
                tex += f"{label} & {n} & --- & --- & --- \\\\\n"
        else:
            tex += f"{label} & --- & --- & --- & --- \\\\\n"

    tex += r"""\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Each row reports the local projection coefficient $\hat{\beta}_{60}$ from the Great Recession housing-price specification estimated on the indicated subsample. Panel A splits states by Census region. Panel B splits at the median of pre-recession nonfarm employment. Robust (HC1) standard errors in parentheses. $^{*}$~$p<0.10$, $^{**}$~$p<0.05$, $^{***}$~$p<0.01$.
\end{tablenotes}
\end{threeparttable}
\label{tab:subsample}
\end{table}
"""
    with open(TAB_DIR / "tab7_subsample.tex", 'w') as f:
        f.write(tex)
    print("  Table 7 written.")
else:
    print("  Skipping Table 7: lp['subsample'] not yet available.")

# ──────────────────────────────────────────────────────────────
# Table 8: Model Parameter Sensitivity (Appendix)
# ──────────────────────────────────────────────────────────────
print("Generating Table 8: Model sensitivity...")

sensitivity = mod.get('sensitivity', [])

if sensitivity:
    # Data is a list of dicts with keys: lambda, a_shock, demand_half_life, demand_emp_48, etc.
    lam_vals = sorted(set(float(r['lambda']) for r in sensitivity))
    a_vals = sorted(set(float(r['a_shock']) for r in sensitivity))
    # Build lookup
    sens_lookup = {}
    for r in sensitivity:
        sens_lookup[(float(r['lambda']), float(r['a_shock']))] = r

    ncols = len(a_vals)
    tex = r"""\begin{table}[H]
\centering
\caption{Model Sensitivity: Employment Impact at 48 Months Across Parameter Values}
\begin{threeparttable}
\begin{tabular}{l""" + "c" * ncols + r"""}
\toprule
& """ + " & ".join([f"$\\Delta a = {a:.0%}$".replace('%', r'\%') for a in a_vals]) + r""" \\
\midrule
"""
    for lam in lam_vals:
        tex += f"$\\lambda = {lam:.2f}$ "
        for a in a_vals:
            r = sens_lookup.get((lam, a))
            if r:
                emp48 = r['demand_emp_48']
                tex += f"& ${emp48:.3f}$ "
            else:
                tex += "& --- "
        tex += "\\\\\n"

    tex += r"""\bottomrule
\end{tabular}
\begin{tablenotes}[flushleft]
\small
\item \textit{Notes:} Each cell reports the log employment change at $h = 48$ months from the calibrated DMP model following a permanent demand shock of magnitude $\Delta a$. $\lambda$ is the skill depreciation rate upon crossing the scarring threshold. All parameter combinations produce permanent demand-shock effects (half-life exceeds 120 months), while the temporary supply shock (not shown) recovers within 9 months regardless of $\lambda$. The baseline calibration uses $\lambda = 0.12$ and $\Delta a = 5\%$.
\end{tablenotes}
\end{threeparttable}
\label{tab:sensitivity}
\end{table}
"""
    with open(TAB_DIR / "tab8_sensitivity.tex", 'w') as f:
        f.write(tex)
    print("  Table 8 written.")
else:
    print("  Skipping Table 8: mod['sensitivity'] not yet available.")

n_tables = 6
if subsample:
    n_tables += 1
if sensitivity:
    n_tables += 1
print(f"\n✓ All {n_tables} tables saved to {TAB_DIR}")
