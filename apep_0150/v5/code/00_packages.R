# ============================================================
# 00_packages.R - Load packages and set options
# Paper 145: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v4)
# Revision of apep_0157 (family apep_0150)
# ============================================================

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install packages if needed
required_packages <- c(
  "tidyverse",         # Data manipulation and visualization
  "fixest",            # Fast fixed effects, Sun-Abraham
  "did",               # Callaway-Sant'Anna DiD
  "HonestDiD",         # Sensitivity analysis for DiD
  "ggplot2",           # Plotting
  "latex2exp",         # LaTeX expressions in plots
  "bacondecomp",       # Goodman-Bacon decomposition
  "sandwich",          # Robust covariance estimation
  "fwildclusterboot",  # Wild cluster bootstrap inference
  "clubSandwich",      # CR2 small-sample corrected SEs
  "modelsummary",      # Regression tables
  "kableExtra",        # Table formatting
  "haven",             # Read Stata/SAS files
  "readr",             # CSV reading/writing
  "broom",             # Tidy model output
  "httr",              # HTTP requests for API calls
  "jsonlite",          # JSON parsing
  "scales"             # Axis formatting
)

# Optional spatial packages (not critical for core analysis)
optional_packages <- c("sf", "tigris")
HAS_SF <- FALSE

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Suppress package messages on reload
suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
  library(did)
  library(HonestDiD)
  library(ggplot2)
  library(latex2exp)
  library(bacondecomp)
  library(sandwich)
  library(fwildclusterboot)
  library(clubSandwich)
  library(modelsummary)
  library(kableExtra)
  library(haven)
  library(readr)
  library(broom)
  library(httr)
  library(jsonlite)
  library(scales)
})

# Try to load spatial packages
for (pkg in optional_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    if (pkg == "sf") HAS_SF <- TRUE
  } else {
    cat("Note: Optional package", pkg, "not available. Map figure will be skipped.\n")
  }
}

# ---- APEP Theme for Publication-Quality Figures ----

theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40"),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10),
      strip.text = element_text(face = "bold")
    )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

# Set default theme
theme_set(theme_apep())

# Suppress sf spherical geometry warnings if available
if (HAS_SF) {
  sf::sf_use_s2(FALSE)
  options(tigris_use_cache = TRUE)
}

# ---- Helper: format p-values (Flag 8 fix: never print 0.000) ----
format_pval <- function(p, digits = 3) {
  stopifnot(is.numeric(p))
  ifelse(is.na(p), "NA",
    ifelse(p < 0.001, "< 0.001",
      formatC(p, digits = digits, format = "f")
    )
  )
}

# ---- Helper: significance stars with SE > 0 guard ----
sig_stars <- function(coef, se) {
  if (is.na(coef) || is.na(se) || se <= 0) return("")
  z <- abs(coef / se)
  if (z > 2.576) return("***")
  if (z > 1.96)  return("**")
  if (z > 1.645) return("*")
  return("")
}

# Print session info
cat("R version:", R.version.string, "\n")
cat("Packages loaded successfully\n")
cat("Working directory:", getwd(), "\n")
