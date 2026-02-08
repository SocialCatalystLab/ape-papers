# Paper 52: Urban-Rural Suffrage Heterogeneity
# Package installation and loading

# Install if needed
packages <- c(
  # Core
  "tidyverse", "data.table",
  # IPUMS
  "ipumsr",
  # DiD estimation
  "did", "DRDID", "fixest", "did2s", "bacondecomp",
  # Inference
  "sandwich", "lmtest", "clubSandwich",
  # Tables and figures
  "ggplot2", "latex2exp", "ggthemes", "scales",
  # LaTeX tables
  "modelsummary", "kableExtra"
)
# Note: sf, tigris, ggspatial require system libraries - install separately if needed

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# Install HonestDiD from GitHub if needed
if (!require("HonestDiD", quietly = TRUE)) {
  if (!require("remotes", quietly = TRUE)) install.packages("remotes")
  remotes::install_github("asheshrambachan/HonestDiD")
}

# APEP standard theme for publication-ready figures
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    axis.line = element_line(color = "grey30", linewidth = 0.4),
    axis.ticks = element_line(color = "grey30", linewidth = 0.3),
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    plot.title = element_text(size = 13, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
    plot.margin = margin(10, 15, 10, 10)
  )
}

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue (treated/urban)
  "#D55E00",  # Orange (control/rural)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Suffrage adoption dates
suffrage_dates <- data.frame(
  state = c("CO", "ID", "WA", "CA", "OR", "KS", "AZ", "MT", "NV", "NY", "MI", "OK", "SD"),
  statefip = c(8, 16, 53, 6, 41, 20, 4, 30, 32, 36, 26, 40, 46),
  year_suffrage = c(1893, 1896, 1910, 1911, 1912, 1912, 1912, 1914, 1914, 1917, 1918, 1918, 1918)
)

cat("Packages loaded. APEP theme and colors defined.\n")
cat("Suffrage dates defined for", nrow(suffrage_dates), "states.\n")
