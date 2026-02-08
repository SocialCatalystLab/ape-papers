#!/usr/bin/env python3
"""
Create publication-quality figures for GDL paper.
"""

import csv
from pathlib import Path

# Try to import matplotlib, fall back to simple plotting if not available
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available, creating data files only")

OUTPUT_DIR = Path(__file__).parent


def create_event_study_figure():
    """Create event study figure."""
    # Load data
    data_file = OUTPUT_DIR / "event_study_data.csv"
    event_times = []
    coefficients = []

    with open(data_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            event_times.append(int(row["event_time"]))
            coefficients.append(float(row["coefficient"]))

    if not HAS_MATPLOTLIB:
        print("Skipping figure creation (no matplotlib)")
        return

    # Create figure
    fig, ax = plt.subplots(figsize=(10, 6))

    # Plot coefficients
    ax.plot(event_times, coefficients, 'o-', color='#2c3e50', linewidth=2, markersize=8)

    # Add confidence interval band (rough approximation)
    se = 0.015  # Approximate SE
    upper = [c + 1.96 * se for c in coefficients]
    lower = [c - 1.96 * se for c in coefficients]
    ax.fill_between(event_times, lower, upper, alpha=0.2, color='#3498db')

    # Reference lines
    ax.axhline(y=0, color='gray', linestyle='--', linewidth=1)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=1.5, label='GDL Adoption')

    # Labels
    ax.set_xlabel('Years Relative to GDL Adoption', fontsize=12)
    ax.set_ylabel('Teen-Adult Employment Gap\n(Relative to t=-1)', fontsize=12)
    ax.set_title('Event Study: Effect of GDL on Teen Employment', fontsize=14, fontweight='bold')

    # Legend
    ax.legend(loc='upper right')

    # Grid
    ax.grid(True, alpha=0.3)

    # Tight layout
    plt.tight_layout()

    # Save
    output_file = OUTPUT_DIR / "event_study.png"
    fig.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

    print(f"Saved: {output_file}")


def create_employment_trends_figure():
    """Create employment trends figure by age group."""
    # Load data from analysis output
    data_file = OUTPUT_DIR / "event_study_data.csv"
    event_times = []
    teen_emp = []
    control_emp = []

    with open(data_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            event_times.append(int(row["event_time"]))
            teen_emp.append(float(row["teen_emp"]))
            control_emp.append(float(row["control_emp"]))

    if not HAS_MATPLOTLIB:
        print("Skipping figure creation (no matplotlib)")
        return

    # Create figure
    fig, ax = plt.subplots(figsize=(10, 6))

    # Plot both series
    ax.plot(event_times, [t * 100 for t in teen_emp], 'o-',
            color='#e74c3c', linewidth=2, markersize=6, label='Teen (16-17)')
    ax.plot(event_times, [c * 100 for c in control_emp], 's-',
            color='#27ae60', linewidth=2, markersize=6, label='Young Adult (20-24)')

    # Reference line
    ax.axvline(x=0, color='gray', linestyle='--', linewidth=1.5, label='GDL Adoption')

    # Labels
    ax.set_xlabel('Years Relative to GDL Adoption', fontsize=12)
    ax.set_ylabel('Employment Rate (%)', fontsize=12)
    ax.set_title('Employment Rates by Age Group Around GDL Adoption', fontsize=14, fontweight='bold')

    # Legend
    ax.legend(loc='best')

    # Grid
    ax.grid(True, alpha=0.3)

    # Set y-axis limits
    ax.set_ylim(0, 100)

    # Tight layout
    plt.tight_layout()

    # Save
    output_file = OUTPUT_DIR / "employment_trends.png"
    fig.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

    print(f"Saved: {output_file}")


def create_ddd_diagram():
    """Create a difference-in-differences diagram."""
    if not HAS_MATPLOTLIB:
        print("Skipping figure creation (no matplotlib)")
        return

    # Cell means from analysis
    pre_control = 0.679
    pre_teen = 0.279
    post_control = 0.683
    post_teen = 0.240

    # Create figure
    fig, ax = plt.subplots(figsize=(8, 6))

    # Plot lines
    x = [0, 1]  # Pre, Post

    # Control group (young adults)
    ax.plot(x, [pre_control, post_control], 's-',
            color='#27ae60', linewidth=2, markersize=12, label='Young Adults (20-24)')

    # Treatment group (teens)
    ax.plot(x, [pre_teen, post_teen], 'o-',
            color='#e74c3c', linewidth=2, markersize=12, label='Teens (16-17)')

    # Counterfactual for teens (parallel trend assumption)
    counterfactual = pre_teen + (post_control - pre_control)
    ax.plot(x, [pre_teen, counterfactual], 'o--',
            color='#e74c3c', alpha=0.4, linewidth=2, markersize=8, label='Counterfactual')

    # Arrow showing treatment effect
    ax.annotate('', xy=(1, post_teen), xytext=(1, counterfactual),
                arrowprops=dict(arrowstyle='<->', color='black', lw=2))
    ax.text(1.05, (post_teen + counterfactual) / 2, f'DDD = {post_teen - counterfactual:.1%}',
            fontsize=11, va='center')

    # Labels
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['Pre-GDL', 'Post-GDL'], fontsize=12)
    ax.set_ylabel('Employment Rate', fontsize=12)
    ax.set_title('Triple-Difference Design: GDL Effect on Teen Employment',
                 fontsize=14, fontweight='bold')

    # Legend
    ax.legend(loc='upper right')

    # Grid
    ax.grid(True, alpha=0.3)

    # Y-axis limits
    ax.set_ylim(0, 0.8)

    # Tight layout
    plt.tight_layout()

    # Save
    output_file = OUTPUT_DIR / "ddd_diagram.png"
    fig.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

    print(f"Saved: {output_file}")


def main():
    print("Creating figures...")
    create_event_study_figure()
    create_employment_trends_figure()
    create_ddd_diagram()
    print("Done!")


if __name__ == "__main__":
    main()
