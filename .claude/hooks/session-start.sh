#!/bin/bash
set -euo pipefail

# SessionStart hook for ape-papers fork
# Installs dependencies for paper generation, analysis, and replication

# Install Python data analysis packages
echo "Installing Python packages for data analysis..."
pip install --quiet pandas numpy scipy statsmodels matplotlib seaborn scikit-learn requests jinja2

# Attempt to install R packages if R is available
if command -v Rscript &> /dev/null; then
  echo "Installing R packages for econometric analysis..."
  Rscript --vanilla << 'REOF' 2>/dev/null || true
packages <- c("tidyverse", "did", "fixest", "ggplot2", "lfe", "data.table")
new_packages <- packages[!(packages %in% rownames(installed.packages()))]
if (length(new_packages) > 0) {
  install.packages(new_packages, repos = "http://cran.r-project.org", quiet = TRUE)
}
cat("R packages installed successfully\n")
REOF
else
  echo "R not found - skipping R package installation"
fi

echo "SessionStart initialization complete!"
