#!/bin/bash
# run_all.sh — Master script running all analysis scripts in sequence
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================"
echo "APEP Paper: Who Bears the Burden of Monetary Tightening?"
echo "Running full analysis pipeline..."
echo "============================================"

echo -e "\n[1/8] Loading packages..."
python3 00_packages.py

echo -e "\n[2/8] Fetching data..."
python3 01_fetch_data.py

echo -e "\n[3/8] Cleaning data..."
python3 02_clean_data.py

echo -e "\n[4/8] Main analysis (local projections)..."
python3 03_main_analysis.py

echo -e "\n[5/8] Robustness checks..."
python3 04_robustness.py

echo -e "\n[6/8] Structural model..."
python3 05_model.py

echo -e "\n[7/8] Welfare analysis..."
python3 06_welfare.py

echo -e "\n[8/8] Generating figures and tables..."
python3 07_figures.py
python3 08_tables.py

echo -e "\n============================================"
echo "PIPELINE COMPLETE"
echo "============================================"
echo "Figures: $(ls ../figures/*.pdf 2>/dev/null | wc -l | tr -d ' ') PDFs"
echo "Tables:  $(ls ../tables/*.tex 2>/dev/null | wc -l | tr -d ' ') TEX files"
echo "Data:    $(ls ../data/ 2>/dev/null | wc -l | tr -d ' ') files"
