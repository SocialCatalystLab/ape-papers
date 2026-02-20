## ── 00_packages.R ─────────────────────────────────────────────────────────
## Load required packages for apep_0426: JJM and School Enrollment
## ──────────────────────────────────────────────────────────────────────────

required_packages <- c(
  "data.table",    # Fast data manipulation
  "fixest",        # Fixed effects estimation (feols, Sun-Abraham)
  "did",           # Callaway-Sant'Anna DiD estimator
  "ggplot2",       # Figures
  "scales",        # Number formatting
  "modelsummary",  # Regression tables
  "kableExtra",    # Table formatting
  "bacondecomp",   # Bacon decomposition for TWFE diagnostics
  "HonestDiD",     # Rambachan-Roth sensitivity analysis
  "jsonlite"       # Read/write JSON
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

## ── Global settings ──────────────────────────────────────────────────────
theme_set(theme_minimal(base_size = 12) +
            theme(panel.grid.minor = element_blank(),
                  plot.title = element_text(face = "bold")))

options(scipen = 999)
setDTthreads(4)

cat("All packages loaded successfully.\n")
