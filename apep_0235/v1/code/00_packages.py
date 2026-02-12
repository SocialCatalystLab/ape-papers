"""
00_packages.py — Imports, constants, and matplotlib AER-style theme
"""

import os
import sys
import json
import warnings
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.ticker import MaxNLocator
import statsmodels.api as sm
from statsmodels.regression.linear_model import OLS
from scipy import linalg
from fredapi import Fred

warnings.filterwarnings('ignore', category=FutureWarning)
warnings.filterwarnings('ignore', category=UserWarning)

# Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CODE_DIR = os.path.join(BASE_DIR, 'code')
DATA_DIR = os.path.join(BASE_DIR, 'data')
FIG_DIR = os.path.join(BASE_DIR, 'figures')
TAB_DIR = os.path.join(BASE_DIR, 'tables')

for d in [DATA_DIR, FIG_DIR, TAB_DIR]:
    os.makedirs(d, exist_ok=True)

# FRED API key
FRED_API_KEY = os.environ.get('FRED_API_KEY', '')

# AER-style matplotlib theme
plt.rcParams.update({
    'font.family': 'serif',
    'font.serif': ['Computer Modern Roman', 'Times New Roman', 'Times'],
    'font.size': 11,
    'axes.titlesize': 12,
    'axes.labelsize': 11,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'legend.fontsize': 10,
    'figure.figsize': (6.5, 4.5),
    'figure.dpi': 150,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight',
    'axes.linewidth': 0.8,
    'axes.grid': False,
    'axes.spines.top': False,
    'axes.spines.right': False,
    'lines.linewidth': 1.5,
    'lines.markersize': 4,
    'text.usetex': False,
    'pdf.fonttype': 42,
    'ps.fonttype': 42,
})

# Color palette (colorblind-friendly)
COLORS = {
    'blue': '#2166AC',
    'red': '#B2182B',
    'green': '#1B7837',
    'orange': '#E66101',
    'purple': '#7570B3',
    'gray': '#636363',
    'lightblue': '#92C5DE',
    'lightred': '#F4A582',
}

# Industry definitions
CES_SERIES = {
    'PAYEMS': 'Total Nonfarm',
    'MANEMP': 'Manufacturing',
    'USCONS': 'Construction',
    'USMINE': 'Mining/Logging',
    'USWTRADE': 'Wholesale Trade',
    'USTRADE': 'Retail Trade',
    'USINFO': 'Information',
    'USFIRE': 'Financial Activities',
    'USPBS': 'Prof./Business Svcs.',
    'USEHS': 'Education/Health Svcs.',
    'USLAH': 'Leisure/Hospitality',
    'USSERV': 'Other Services',
    'USGOVT': 'Government',
    'USTPU': 'Transp./Utilities',
}

# LaTeX-safe names (for tables)
CES_SERIES_TEX = {k: v.replace('&', '\\&') for k, v in CES_SERIES.items()}

# Goods vs services classification
GOODS_INDUSTRIES = ['MANEMP', 'USCONS', 'USMINE']
SERVICES_INDUSTRIES = ['USWTRADE', 'USTRADE', 'USINFO', 'USFIRE', 'USPBS',
                       'USEHS', 'USLAH', 'USSERV', 'USTPU']

# JOLTS series mapping
JOLTS_FLOWS = {
    'JOL': 'Job Openings',
    'HIL': 'Hires',
    'TSL': 'Total Separations',
    'QUL': 'Quits',
    'LDR': 'Layoffs/Discharges',
}

JOLTS_INDUSTRIES = {
    'total': 'Total Nonfarm',
    '1000': 'Mining/Logging',
    '2000': 'Construction',
    '3000': 'Manufacturing',
    '4000': 'Trade/Transp./Utilities',
    '5100': 'Information',
    '5200': 'Financial Activities',
    '5400': 'Prof./Business Svcs.',
    '6000': 'Education/Health Svcs.',
    '7000': 'Leisure/Hospitality',
    '9000': 'Government',
}

# LP horizons
LP_HORIZONS = [0, 1, 2, 3, 6, 9, 12, 18, 24, 36, 48]

# Significance stars
def stars(pval):
    if pval < 0.01:
        return '***'
    elif pval < 0.05:
        return '**'
    elif pval < 0.10:
        return '*'
    return ''

print("Packages and configuration loaded successfully.")
print(f"Data dir: {DATA_DIR}")
print(f"Figures dir: {FIG_DIR}")
print(f"Tables dir: {TAB_DIR}")
