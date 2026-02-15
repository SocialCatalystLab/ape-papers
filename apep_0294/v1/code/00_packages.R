## ============================================================================
## 00_packages.R — Package installation and loading
## T-MSIS Medicaid Provider Spending Data Overview Paper
## ============================================================================

# Core data manipulation
if (!require("data.table")) install.packages("data.table", repos="https://cloud.r-project.org")
if (!require("arrow")) install.packages("arrow", repos="https://cloud.r-project.org")

# Visualization
if (!require("ggplot2")) install.packages("ggplot2", repos="https://cloud.r-project.org")
if (!require("scales")) install.packages("scales", repos="https://cloud.r-project.org")
if (!require("patchwork")) install.packages("patchwork", repos="https://cloud.r-project.org")
if (!require("RColorBrewer")) install.packages("RColorBrewer", repos="https://cloud.r-project.org")
if (!require("viridis")) install.packages("viridis", repos="https://cloud.r-project.org")

# Maps
if (!require("sf")) install.packages("sf", repos="https://cloud.r-project.org")
if (!require("tigris")) install.packages("tigris", repos="https://cloud.r-project.org")

# Tables
if (!require("xtable")) install.packages("xtable", repos="https://cloud.r-project.org")
if (!require("knitr")) install.packages("knitr", repos="https://cloud.r-project.org")

# Misc
if (!require("stringr")) install.packages("stringr", repos="https://cloud.r-project.org")
if (!require("lubridate")) install.packages("lubridate", repos="https://cloud.r-project.org")

library(data.table)
library(arrow)
library(ggplot2)
library(scales)
library(patchwork)
library(RColorBrewer)
library(viridis)
library(sf)
library(tigris)
library(xtable)
library(knitr)
library(stringr)
library(lubridate)

# Set tigris options
options(tigris_use_cache = TRUE, tigris_class = "sf")

# Set ggplot2 theme — clean, publication-ready
theme_set(
  theme_minimal(base_size = 11, base_family = "") +
    theme(
      plot.title = element_text(face = "bold", size = 12, hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey92"),
      strip.text = element_text(face = "bold", size = 10),
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 8),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9)
    )
)

cat("All packages loaded successfully.\n")
