# =============================================================================
# 00_packages.R - Package Loading and Configuration
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# =============================================================================

# Core tidyverse
library(tidyverse)
library(lubridate)

# Swiss data packages
library(swissdd)    # Referendum voting data
library(BFS)        # Federal statistics and maps
library(sf)         # Spatial data handling

# RDD analysis
library(rdrobust)   # Robust RDD estimation
library(rddensity)  # McCrary density test

# Econometrics
library(fixest)     # Fixed effects estimation
library(modelsummary)  # Tables

# Visualization
library(ggplot2)
library(patchwork)  # Combining plots
library(scales)

# Set APEP theme
theme_apep <- theme_minimal(base_size = 11, base_family = "Helvetica") +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(color = "gray40", size = 10),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray90"),
    axis.title = element_text(size = 10),
    legend.position = "bottom",
    plot.caption = element_text(hjust = 0, color = "gray50", size = 8)
  )

theme_set(theme_apep)

# Set seed for reproducibility
set.seed(20260127)

# =============================================================================
# RELATIVE PATH SETUP
# =============================================================================
# Determine script directory for portable paths
# This works whether run from RStudio, command line, or source()

get_script_dir <- function() {
  # Try different methods to find script location
  # Method 1: Check for ofile in parent frames (when source()'d)
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  # Method 2: RStudio project
  if (!is.null(getOption("rstudio.proj.path"))) {
    proj_path <- getOption("rstudio.proj.path")
    if (dir.exists(file.path(proj_path, "code"))) {
      return(file.path(proj_path, "code"))
    }
  }
  # Fallback: assume we're in the code directory
  return(getwd())
}

# Set base directory (parent of code/)
script_dir <- get_script_dir()
if (basename(script_dir) == "code") {
  base_dir <- dirname(script_dir)
} else {
  base_dir <- script_dir
}

# Output paths relative to base directory
data_dir <- file.path(base_dir, "data")
fig_dir <- file.path(base_dir, "figures")
tab_dir <- file.path(base_dir, "tables")

# Create directories if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message(paste("Base directory:", base_dir))

# =============================================================================
# SPATIAL UTILITY: CORRECT POLICY BORDER COMPUTATION
# =============================================================================
# CRITICAL FIX: The original code used st_boundary() intersection which includes
# national borders (France, Italy, Germany). This function computes ONLY the
# internal canton-to-canton boundaries between treated and control cantons.

get_policy_border <- function(canton_sf, treated_ids, canton_id_col = "canton_id") {
  # Ensure we have valid geometries
  # Use st_geometry() to work regardless of geometry column name
  canton_sf <- canton_sf %>%
    filter(!st_is_empty(st_geometry(.))) %>%
    st_make_valid()

  # Separate treated and control cantons
  treated_sf <- canton_sf %>% filter(!!sym(canton_id_col) %in% treated_ids)
  control_sf <- canton_sf %>% filter(!(!!sym(canton_id_col) %in% treated_ids))

  if (nrow(treated_sf) == 0 || nrow(control_sf) == 0) {
    warning("No treated or control cantons found")
    return(st_sfc(st_multilinestring(), crs = st_crs(canton_sf)))
  }

  # Find pairs that actually touch (share a boundary)
  touches_mat <- st_touches(treated_sf, control_sf, sparse = TRUE)

  # Extract shared boundary for each touching pair
  borders <- list()
  for (i in seq_len(nrow(treated_sf))) {
    touching_controls <- touches_mat[[i]]
    for (j in touching_controls) {
      # Get the shared boundary between this treated-control pair
      shared <- tryCatch({
        st_intersection(
          st_geometry(treated_sf[i,]),
          st_geometry(control_sf[j,])
        )
      }, error = function(e) NULL)

      if (is.null(shared)) next

      # Check if geometry is valid and non-empty
      if (!any(st_is_empty(shared))) {
        # Keep only linear features (the actual border, not points)
        geom_type <- as.character(st_geometry_type(shared))
        if (geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
          shared <- st_cast(st_boundary(shared), "MULTILINESTRING")
        }
        borders <- c(borders, list(shared))
      }
    }
  }

  if (length(borders) == 0) {
    warning("No shared borders found between treated and control cantons")
    return(st_sfc(st_multilinestring(), crs = st_crs(canton_sf)))
  }

  # Combine all border segments
  border_geoms <- do.call(c, lapply(borders, st_geometry))
  border_union <- st_union(border_geoms)
  return(st_set_crs(border_union, st_crs(canton_sf)))
}

message("Packages loaded. Ready for analysis.")
