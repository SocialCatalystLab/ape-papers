"""
05_model.py — Structural DMP model with endogenous participation and skill depreciation
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

# ──────────────────────────────────────────────────────────────
# Model: DMP with participation and scarring
# ──────────────────────────────────────────────────────────────
# States: Employed (E), Unemployed (U), Out of Labor Force (O)
# Key mechanisms:
#   1. Demand shock: productivity a falls → fewer vacancies → long unemployment → scarring
#   2. Supply shock: separation δ spikes temporarily → mass layoff → quick recovery
#   3. Skill depreciation: after d* months unemployed, human capital drops
#   4. Participation: discouraged workers exit labor force

class DMPModel:
    def __init__(self, params=None):
        p = params or {}
        # Calibrated parameters
        self.beta = p.get('beta', 0.996)       # Monthly discount factor
        self.alpha = p.get('alpha', 0.5)        # Matching function elasticity
        self.A = p.get('A', 0.60)               # Matching efficiency
        self.delta = p.get('delta', 0.034)      # Separation rate
        self.kappa = p.get('kappa', 3.40)       # Vacancy posting cost
        self.a = p.get('a', 1.0)                # Aggregate productivity
        self.b = p.get('b', 0.71)               # Unemployment benefit
        self.b_olf = p.get('b_olf', 0.65)       # OLF home production
        self.gamma = p.get('gamma', 0.5)        # Nash bargaining power
        self.lam = p.get('lam', 0.12)           # Skill depreciation upon scarring
        self.d_star = p.get('d_star', 12)       # Months until skill depreciation
        self.chi_base = p.get('chi_base', 0.008) # Base OLF exit rate from U
        self.chi_dur = p.get('chi_dur', 0.004)  # Duration-dependent OLF exit
        self.psi = p.get('psi', 0.03)           # Re-entry rate from OLF to U

    def matching(self, u, v):
        """Cobb-Douglas matching function."""
        return self.A * u**self.alpha * v**(1 - self.alpha)

    def job_finding_rate(self, theta):
        """f(θ) = A * θ^(1-α)"""
        return self.A * theta**(1 - self.alpha)

    def vacancy_filling_rate(self, theta):
        """q(θ) = A * θ^(-α)"""
        return self.A * theta**(-self.alpha)

    def wage(self, a=None, h=1.0, theta=None):
        """Nash-bargained wage."""
        if a is None: a = self.a
        if theta is None: theta = self.solve_theta(a, h)
        return self.gamma * (a * h + self.kappa * theta) + (1 - self.gamma) * self.b

    def solve_theta(self, a=None, h=1.0):
        """Solve for market tightness from free entry condition."""
        if a is None: a = self.a
        # Free entry: kappa / q(theta) = (1 - gamma) * (a*h - b) / (1 - beta*(1-delta))
        surplus = (1 - self.gamma) * (a * h - self.b)
        if surplus <= 0:
            return 0.001  # No entry
        rhs = surplus / (1 - self.beta * (1 - self.delta))
        # Free entry: kappa / q(theta) = rhs, where q(theta) = A * theta^(-alpha)
        # => kappa * theta^alpha / A = rhs
        # => theta = (A * rhs / kappa)^(1/alpha)
        ratio = self.A * rhs / self.kappa
        if ratio <= 0:
            return 0.001
        theta = ratio**(1 / self.alpha)
        return max(theta, 0.001)

    def steady_state(self, a=None, h=1.0):
        """Compute steady state (E, U, O) shares and rates."""
        if a is None: a = self.a
        theta = self.solve_theta(a, h)
        f = self.job_finding_rate(theta)
        # Transition rates
        delta = self.delta
        chi = self.chi_base  # simplified: no duration dependence in SS
        psi = self.psi
        # Solve for SS: flow balance
        # δ*E = f*U
        # χ*U = ψ*O
        # E + U + O = 1
        # From (1): E = f*U / δ
        # From (2): O = χ*U / ψ
        # Sub into (3): f*U/δ + U + χ*U/ψ = 1
        # U * (f/δ + 1 + χ/ψ) = 1
        u_ss = 1.0 / (f / delta + 1 + chi / psi)
        e_ss = f * u_ss / delta
        o_ss = chi * u_ss / psi
        w = self.wage(a, h, theta)
        return {
            'theta': theta, 'f': f, 'u': u_ss, 'e': e_ss, 'o': o_ss,
            'w': w, 'a': a, 'h': h
        }

    def simulate_transition(self, shock_type='demand', shock_size=0.05,
                           shock_duration=3, T=120):
        """
        Simulate transition dynamics after a shock.
        shock_type: 'demand' (a drops) or 'supply' (delta spikes)
        shock_size: magnitude (fraction for demand, multiplier for supply)
        shock_duration: months shock persists (inf for permanent demand)
        """
        # Get initial SS
        ss0 = self.steady_state()
        E, U, O = ss0['e'], ss0['u'], ss0['o']

        # Track states
        path = {'E': [E], 'U': [U], 'O': [O], 'theta': [ss0['theta']],
                'f': [ss0['f']], 'w': [ss0['w']], 'emp_change': [0.0],
                'ur': [U / (E + U)]}

        # Duration tracking (simplified: fraction with d > d_star)
        scarred_frac = 0.0  # Fraction of U that is long-term unemployed
        h_effective = 1.0   # Average human capital

        for t in range(1, T + 1):
            # Current shock state
            if shock_type == 'demand':
                a_t = self.a * (1 - shock_size)  # Permanent
            elif shock_type == 'supply':
                if t <= shock_duration:
                    delta_t = self.delta * (1 + shock_size)
                else:
                    delta_t = self.delta
                a_t = self.a
            else:
                a_t = self.a
                delta_t = self.delta

            if shock_type == 'demand':
                delta_t = self.delta

            # Solve for market tightness
            theta_t = self.solve_theta(a_t, h_effective)
            f_t = self.job_finding_rate(theta_t)

            # Transition flows
            eu = delta_t * E  # E → U (separations)
            ue = f_t * U      # U → E (hiring)
            uo = (self.chi_base + self.chi_dur * scarred_frac) * U  # U → O (discouragement)
            ou = self.psi * O  # O → U (re-entry)

            # Update states
            E_new = E + ue - eu
            U_new = U + eu + ou - ue - uo
            O_new = O + uo - ou

            # Normalize (keep sum = 1)
            total = E_new + U_new + O_new
            E, U, O = E_new / total, U_new / total, O_new / total

            # Update scarring
            if shock_type == 'demand':
                # Long-term U increases when finding rate is low
                new_scarred = max(0, 1 - f_t / 0.4) * 0.1  # Proxy
                scarred_frac = min(1.0, scarred_frac * 0.95 + new_scarred)
                h_effective = 1.0 - self.lam * scarred_frac
            else:
                # Supply shock: short durations, scarring decays fast
                scarred_frac = scarred_frac * 0.9
                h_effective = 1.0 - self.lam * scarred_frac

            w_t = self.wage(a_t, h_effective, theta_t)
            emp_change = np.log(E / ss0['e'])

            path['E'].append(E)
            path['U'].append(U)
            path['O'].append(O)
            path['theta'].append(theta_t)
            path['f'].append(f_t)
            path['w'].append(w_t)
            path['emp_change'].append(emp_change)
            path['ur'].append(U / (E + U))

        return path

# ──────────────────────────────────────────────────────────────
# Calibrate and simulate
# ──────────────────────────────────────────────────────────────
print("="*60)
print("STRUCTURAL MODEL: DMP WITH PARTICIPATION AND SCARRING")
print("="*60)

model = DMPModel()
ss = model.steady_state()
print(f"\nSteady State:")
print(f"  Employment rate: {ss['e']:.4f}")
print(f"  Unemployment rate: {ss['u']:.4f} (UR = {ss['u']/(ss['e']+ss['u']):.4f})")
print(f"  OLF rate: {ss['o']:.4f}")
print(f"  Market tightness θ: {ss['theta']:.4f}")
print(f"  Job finding rate f: {ss['f']:.4f}")
print(f"  Wage: {ss['w']:.4f}")

# Demand shock: productivity falls by 5% permanently
print("\n--- Demand Shock (GR analog): a falls by 5% ---")
demand_path = model.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Peak employment decline: {min(demand_path['emp_change']):.4f} "
      f"at month {demand_path['emp_change'].index(min(demand_path['emp_change']))}")
print(f"  Employment at month 48: {demand_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {demand_path['emp_change'][120]:.4f}")
print(f"  Peak UR: {max(demand_path['ur']):.4f}")

# Supply shock: separation rate doubles for 3 months
print("\n--- Supply Shock (COVID analog): δ doubles for 3 months ---")
supply_path = model.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=120)
print(f"  Peak employment decline: {min(supply_path['emp_change']):.4f} "
      f"at month {supply_path['emp_change'].index(min(supply_path['emp_change']))}")
print(f"  Employment at month 12: {supply_path['emp_change'][12]:.4f}")
print(f"  Employment at month 48: {supply_path['emp_change'][48]:.4f}")
print(f"  Peak UR: {max(supply_path['ur']):.4f}")

# Counterfactual 1: Demand shock with NO skill depreciation
print("\n--- Counterfactual: Demand shock, no scarring (λ=0) ---")
model_noscar = DMPModel({'lam': 0.0})
cf1_path = model_noscar.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Employment at month 48: {cf1_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf1_path['emp_change'][120]:.4f}")

# Counterfactual 2: Demand shock with NO participation exit
print("\n--- Counterfactual: Demand shock, no OLF exit (χ=0) ---")
model_noolf = DMPModel({'chi_base': 0.0, 'chi_dur': 0.0})
cf2_path = model_noolf.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Employment at month 48: {cf2_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf2_path['emp_change'][120]:.4f}")

# Counterfactual 3: Supply shock but permanent (make it demand-like)
print("\n--- Counterfactual: Supply shock but permanent ---")
# Model where delta stays elevated
class DMPPermanentSupply(DMPModel):
    def simulate_transition(self, shock_type='supply', shock_size=0.5,
                           shock_duration=120, T=120):
        return super().simulate_transition('supply', shock_size, shock_duration, T)
model_permsupply = DMPPermanentSupply()
cf3_path = model_permsupply.simulate_transition(T=120)
print(f"  Employment at month 48: {cf3_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf3_path['emp_change'][120]:.4f}")

# ──────────────────────────────────────────────────────────────
# Welfare computation
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("WELFARE ANALYSIS")
print("="*60)

def compute_welfare_loss(path, ss, model, T=120):
    """Compute consumption-equivalent welfare loss."""
    beta = model.beta
    a = model.a

    # SS welfare: PV of consumption in SS
    # Workers: w if employed, b if unemployed, b_olf if OLF
    ss_welfare = 0
    for t in range(T):
        E_t, U_t, O_t = ss['e'], ss['u'], ss['o']
        period_welfare = E_t * ss['w'] + U_t * model.b + O_t * model.b_olf
        ss_welfare += beta**t * period_welfare

    # Shock welfare
    shock_welfare = 0
    for t in range(T):
        E_t = path['E'][t]
        U_t = path['U'][t]
        O_t = path['O'][t]
        w_t = path['w'][t]
        period_welfare = E_t * w_t + U_t * model.b + O_t * model.b_olf
        shock_welfare += beta**t * period_welfare

    # CE loss: 1 - (shock_welfare / ss_welfare)
    ce_loss = 1 - shock_welfare / ss_welfare
    return ce_loss

demand_welfare = compute_welfare_loss(demand_path, ss, model)
supply_welfare = compute_welfare_loss(supply_path, ss, model)
cf1_welfare = compute_welfare_loss(cf1_path, ss, model_noscar)
cf2_welfare = compute_welfare_loss(cf2_path, ss, model_noolf)

print(f"  Demand shock welfare loss (CE): {demand_welfare*100:.2f}%")
print(f"  Supply shock welfare loss (CE): {supply_welfare*100:.2f}%")
print(f"  CF1 (no scarring) welfare loss: {cf1_welfare*100:.2f}%")
print(f"  CF2 (no OLF exit) welfare loss: {cf2_welfare*100:.2f}%")
print(f"  Scarring contribution: {(demand_welfare - cf1_welfare) / demand_welfare * 100:.1f}% of demand loss")
print(f"  OLF exit contribution: {(demand_welfare - cf2_welfare) / demand_welfare * 100:.1f}% of demand loss")

# ──────────────────────────────────────────────────────────────
# Save model results
# ──────────────────────────────────────────────────────────────
model_results = {
    'steady_state': ss,
    'demand_path': {k: [float(v) for v in vals] for k, vals in demand_path.items()},
    'supply_path': {k: [float(v) for v in vals] for k, vals in supply_path.items()},
    'cf1_noscar': {k: [float(v) for v in vals] for k, vals in cf1_path.items()},
    'cf2_noolf': {k: [float(v) for v in vals] for k, vals in cf2_path.items()},
    'cf3_permsupply': {k: [float(v) for v in vals] for k, vals in cf3_path.items()},
    'welfare': {
        'demand': float(demand_welfare),
        'supply': float(supply_welfare),
        'cf1_noscar': float(cf1_welfare),
        'cf2_noolf': float(cf2_welfare),
        'scarring_share': float((demand_welfare - cf1_welfare) / demand_welfare) if demand_welfare != 0 else 0,
        'olf_share': float((demand_welfare - cf2_welfare) / demand_welfare) if demand_welfare != 0 else 0,
    },
    'calibration': {
        'beta': model.beta, 'alpha': model.alpha, 'A': model.A,
        'delta': model.delta, 'kappa': model.kappa, 'b': model.b,
        'b_olf': model.b_olf, 'gamma': model.gamma, 'lam': model.lam,
        'd_star': model.d_star, 'chi_base': model.chi_base,
        'chi_dur': model.chi_dur, 'psi': model.psi,
    }
}

with open(DATA_DIR / "model_results.json", 'w') as f:
    json.dump(model_results, f, indent=2, default=str)

print(f"\n✓ Model results saved")

# ──────────────────────────────────────────────────────────────
# Parameter sensitivity analysis (Change 3)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PARAMETER SENSITIVITY: λ × A_shock grid")
print("="*60)

lambda_vals = [0.01, 0.02, 0.03, 0.05, 0.10, 0.12]
a_shock_vals = [0.03, 0.05, 0.07]

sensitivity_results = []

for lam in lambda_vals:
    for a_shock in a_shock_vals:
        m = DMPModel({'lam': lam})
        path = m.simulate_transition('demand', shock_size=a_shock, T=120)

        # GR half-life: months from peak decline to 50% recovery
        emp = path['emp_change']
        peak_decline = min(emp)
        peak_month = emp.index(peak_decline)
        half_target = peak_decline / 2
        half_life = None
        for t in range(peak_month + 1, 121):
            if emp[t] > half_target:
                half_life = t - peak_month
                break
        if half_life is None:
            half_life = '>120'

        # COVID recovery month (supply shock): months until within 0.5% of SS
        supply_path = m.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=120)
        supply_emp = supply_path['emp_change']
        recovery_month = 120
        for t in range(1, 121):
            if abs(supply_emp[t]) < 0.005:
                recovery_month = t
                break

        row = {
            'lambda': lam, 'a_shock': a_shock,
            'demand_half_life': half_life,
            'demand_emp_48': emp[48],
            'demand_emp_120': emp[120],
            'supply_recovery_month': recovery_month,
        }
        sensitivity_results.append(row)
        hl_str = str(half_life) if isinstance(half_life, int) else half_life
        print(f"  λ={lam:.2f}, Δa={a_shock:.2f}: half-life={hl_str:>4s}m, "
              f"emp_48={emp[48]:.4f}, recovery={recovery_month}m")

model_results['sensitivity'] = sensitivity_results

with open(DATA_DIR / "model_results.json", 'w') as f:
    json.dump(model_results, f, indent=2, default=str)

print(f"\n✓ Sensitivity results appended to model_results.json")
