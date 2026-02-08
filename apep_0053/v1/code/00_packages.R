# ============================================================================
# Paper 66: Pay Transparency Laws and Gender Wage Gaps
# Script 00: Package Installation and APEP Theme
# ============================================================================

# Required packages
packages <- c(
  # Data manipulation
  "tidyverse", "data.table", "haven",

  # DiD estimation
  "did",          # Callaway-Sant'Anna
  "fixest",       # Sun-Abraham via sunab()
  "did2s",        # Gardner two-stage
  "HonestDiD",    # Rambachan-Roth sensitivity

  # Inference
  "fwildclusterboot",  # Wild cluster bootstrap
  "lmtest", "sandwich",  # Cluster-robust SE

  # Figures
  "ggplot2", "patchwork", "sf", "viridis",
  "modelsummary", "gt",

  # Tables
  "gt", "gtExtras", "kableExtra",

  # Maps
  "tigris", "rnaturalearth",

  # API access
  "httr", "jsonlite"
)

# Install missing packages
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org")

# Load all packages
invisible(lapply(packages, library, character.only = TRUE))

# ============================================================================
# APEP ggplot2 Theme
# ============================================================================

theme_apep <- function(base_size = 11, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Text
      plot.title = element_text(size = rel(1.2), face = "bold", hjust = 0),
      plot.subtitle = element_text(size = rel(1.0), color = "gray30", hjust = 0),
      plot.caption = element_text(size = rel(0.8), color = "gray50", hjust = 1),
      axis.title = element_text(size = rel(1.0), face = "bold"),
      axis.text = element_text(size = rel(0.9), color = "gray20"),

      # Grid
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9), face = "bold"),
      legend.text = element_text(size = rel(0.85)),
      legend.key.size = unit(0.8, "lines"),

      # Facets
      strip.text = element_text(size = rel(1.0), face = "bold"),
      strip.background = element_rect(fill = "gray95", color = NA),

      # Margins
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Set as default
theme_set(theme_apep())

# Color palettes
apep_colors <- list(
  primary = "#2C3E50",      # Dark blue-gray
  secondary = "#E74C3C",    # Red
  tertiary = "#3498DB",     # Blue
  quaternary = "#2ECC71",   # Green
  neutral = "#95A5A6",      # Gray

  # Diverging (for gaps)
  gap_pos = "#E74C3C",      # Positive gap (male advantage)
  gap_neg = "#2ECC71",      # Negative gap (female advantage)

  # Sequential (for time/cohorts)
  cohort = viridis::viridis(6, option = "D")
)

# ============================================================================
# Helper Functions
# ============================================================================

# Format numbers for tables
fmt_num <- function(x, digits = 2) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

# Format percentages
fmt_pct <- function(x, digits = 1) {
  paste0(formatC(x * 100, format = "f", digits = digits), "%")
}

# Format p-values
fmt_pval <- function(p) {
  case_when(
    p < 0.001 ~ "< 0.001***",
    p < 0.01 ~ paste0(fmt_num(p, 3), "**"),
    p < 0.05 ~ paste0(fmt_num(p, 3), "*"),
    p < 0.10 ~ paste0(fmt_num(p, 3), "+"),
    TRUE ~ fmt_num(p, 3)
  )
}

# Standard error in parentheses
fmt_se <- function(se) {
  paste0("(", fmt_num(se, 3), ")")
}

cat("✓ Packages loaded\n")
cat("✓ APEP theme set\n")
cat("✓ Helper functions defined\n")
