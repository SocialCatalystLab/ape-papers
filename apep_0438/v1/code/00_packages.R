###############################################################################
# 00_packages.R — Load packages, set paths, define spatial helper functions
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# --- Packages ----------------------------------------------------------------
required <- c(
  "tidyverse", "sf", "rdrobust", "fixest", "modelsummary",
  "swissdd", "BFS", "SMMT", "ggthemes", "patchwork",
  "sandwich", "lmtest", "kableExtra"
)

for (pkg in required) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# --- Paths -------------------------------------------------------------------
get_script_dir <- function() {
  # Try --file= arg first (Rscript)
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("--file=", "", file_arg))))
  }
  # Try sys.frame for source()
  for (i in seq_len(sys.nframe())) {
    ofile <- tryCatch(sys.frame(i)$ofile, error = function(e) NULL)
    if (!is.null(ofile)) return(dirname(normalizePath(ofile)))
  }
  return(getwd())
}

script_dir <- get_script_dir()
base_dir   <- file.path(script_dir, "..")
data_dir   <- file.path(base_dir, "data")
fig_dir    <- file.path(base_dir, "figures")
tab_dir    <- file.path(base_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir,  showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir,  showWarnings = FALSE, recursive = TRUE)

# --- Plot theme --------------------------------------------------------------
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

set.seed(20260221)

# --- Spatial helper: extract ONLY internal treated-control borders -----------
# Lesson from apep_0088: st_boundary() includes NATIONAL borders → corrupt RDD.
# This function extracts only the shared boundary between treated & control cantons.

get_policy_border <- function(canton_sf, treated_ids, canton_id_col = "KTNR") {
  treated_sf <- canton_sf %>% filter(!!sym(canton_id_col) %in% treated_ids)
  control_sf <- canton_sf %>% filter(!(!!sym(canton_id_col) %in% treated_ids))

  touches_mat <- st_touches(treated_sf, control_sf, sparse = TRUE)
  borders <- list()

  for (i in seq_len(nrow(treated_sf))) {
    if (length(touches_mat[[i]]) == 0) next
    for (j in touches_mat[[i]]) {
      shared <- st_intersection(
        st_geometry(treated_sf[i, ]),
        st_geometry(control_sf[j, ])
      )
      # Convert polygon intersection to linestring (boundary)
      geom_type <- as.character(st_geometry_type(shared))
      if (geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
        shared <- st_cast(st_boundary(shared), "MULTILINESTRING")
      }
      if (geom_type %in% c("LINESTRING", "MULTILINESTRING") ||
          geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
        borders <- c(borders, list(shared))
      }
    }
  }

  if (length(borders) == 0) {
    stop("No shared treated-control borders found. Check canton IDs.")
  }

  border_union <- st_union(do.call(c, lapply(borders, st_geometry)))
  return(st_set_crs(border_union, st_crs(canton_sf)))
}

# --- Treatment coding --------------------------------------------------------
# Landsgemeinde status by canton
# TRUE = has/had Landsgemeinde at some point in modern era
landsgemeinde_cantons <- tibble::tribble(
  ~canton_abbr, ~KTNR, ~landsgemeinde, ~abolished_year,
  "AI",  16L,  TRUE,  NA_integer_,     # Still active (Innerrhoden)

  "GL",  8L,   TRUE,  NA_integer_,     # Still active
  "AR",  15L,  TRUE,  1997L,           # Ausserrhoden — abolished 1997
  "OW",  6L,   TRUE,  1998L,
  "NW",  7L,   TRUE,  1996L,
  # All other cantons: never had cantonal Landsgemeinde in modern era
  "ZH",  1L,   FALSE, NA_integer_,
  "BE",  2L,   FALSE, NA_integer_,
  "LU",  3L,   FALSE, NA_integer_,
  "UR",  4L,   FALSE, NA_integer_,
  "SZ",  5L,   FALSE, NA_integer_,
  "ZG",  9L,   FALSE, NA_integer_,
  "FR",  10L,  FALSE, NA_integer_,
  "SO",  11L,  FALSE, NA_integer_,
  "BS",  12L,  FALSE, NA_integer_,
  "BL",  13L,  FALSE, NA_integer_,
  "SH",  14L,  FALSE, NA_integer_,
  "SG",  17L,  FALSE, NA_integer_,
  "GR",  18L,  FALSE, NA_integer_,
  "AG",  19L,  FALSE, NA_integer_,
  "TG",  20L,  FALSE, NA_integer_,
  "TI",  21L,  FALSE, NA_integer_,
  "VD",  22L,  FALSE, NA_integer_,
  "VS",  23L,  FALSE, NA_integer_,
  "NE",  24L,  FALSE, NA_integer_,
  "GE",  25L,  FALSE, NA_integer_,
  "JU",  26L,  FALSE, NA_integer_
)

# --- Gender-related referendum classification --------------------------------
# Federal referendums clearly tied to gender policy
gender_topics <- c(
  "Fristenregelung",          # 2002: Abortion liberalization
  "Mutterschaftsversicherung", # 2003 (rejected) & 2004 (passed)
  "Vaterschaftsurlaub",       # 2020: Paternity leave
  "Ehe für alle",             # 2021: Marriage for all
  "Gleichstellung",           # 1981: Equal rights article
  "Familieninitiative",       # Various family policy
  "Familienvorlage"           # Family policy proposals
)

cat("✓ Packages loaded, paths set, spatial helpers defined\n")
cat("  Base dir:", base_dir, "\n")
cat("  Data dir:", data_dir, "\n")
