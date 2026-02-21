## ============================================================
## 02_clean_data.R — Data cleaning and variable construction
## Merges RNE councillor data, commune characteristics, and
## INSEE census employment data into analysis dataset
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## ----------------------------------------------------------
## 1. Process RNE — Compute female councillor share by commune
## ----------------------------------------------------------

cat("Processing RNE councillor data...\n")
rne <- read_delim(file.path(data_dir, "rne_conseillers_municipaux.csv"),
                  delim = ";", locale = locale(encoding = "UTF-8"),
                  show_col_types = FALSE)

# Rename columns for easier use
rne <- rne %>%
  rename(
    dep_code = `Code du département`,
    commune_code = `Code de la commune`,
    commune_name = `Libellé de la commune`,
    sexe = `Code sexe`,
    date_mandat = `Date de début du mandat`,
    fonction = `Libellé de la fonction`,
    csp_code = `Code de la catégorie socio-professionnelle`,
    csp_label = `Libellé de la catégorie socio-professionnelle`
  )

# Female indicator
rne <- rne %>%
  mutate(female = ifelse(sexe == "F", 1, 0))

# Compute commune-level councillor statistics
council_stats <- rne %>%
  group_by(dep_code, commune_code, commune_name) %>%
  summarise(
    n_councillors = n(),
    n_female = sum(female),
    female_share = mean(female),
    has_female_mayor = any(fonction == "Maire" & female == 1, na.rm = TRUE),
    .groups = "drop"
  )

cat("  Council stats: ", nrow(council_stats), " communes\n")
cat("  Mean female share: ", round(mean(council_stats$female_share), 3), "\n")

## ----------------------------------------------------------
## 2. Process commune characteristics — Population
## ----------------------------------------------------------

cat("Processing commune population data...\n")
communes <- read_csv(file.path(data_dir, "communes_france.csv"),
                     show_col_types = FALSE)

# Select key columns
communes <- communes %>%
  select(
    code_insee, nom_standard, population, superficie_km2,
    densite, dep_code, dep_nom, reg_code, reg_nom,
    grille_densite, grille_densite_texte,
    latitude_mairie, longitude_mairie,
    any_of(c("zone_emploi", "code_unite_urbaine",
             "nom_unite_urbaine", "type_commune_unite_urbain"))
  ) %>%
  rename(commune_code_geo = code_insee)

cat("  Communes with population: ", nrow(communes), "\n")
cat("  Around threshold (500-1500): ",
    sum(communes$population >= 500 & communes$population <= 1500, na.rm = TRUE), "\n")

## ----------------------------------------------------------
## 3. Process INSEE census employment data
## ----------------------------------------------------------

cat("Processing INSEE census employment data...\n")

# Read only needed columns to save memory
insee_cols <- c(
  "CODGEO",
  # Total population 15-64
  "P22_POP1564", "P22_H1564", "P22_F1564",
  # Active (labor force) 15-64
  "P22_ACT1564", "P22_HACT1564", "P22_FACT1564",
  # Employed (active occupied) 15-64
  "P22_ACTOCC1564", "P22_HACTOCC1564", "P22_FACTOCC1564",
  # Unemployed
  "P22_CHOM1564",
  # Employment at workplace by gender
  "P22_EMPLT_FSAL", "P22_EMPLT_FNSAL",
  # Historical data (2016, 2011) for pre-treatment outcomes
  "P16_POP1564", "P16_F1564", "P16_FACT1564", "P16_FACTOCC1564",
  "P16_ACT1564", "P16_ACTOCC1564",
  "P11_POP1564", "P11_F1564", "P11_FACT1564", "P11_FACTOCC1564",
  "P11_ACT1564", "P11_ACTOCC1564"
)

# Read header to check available columns
header <- read_delim(
  file.path(data_dir, "insee_emploi", "base-cc-emploi-pop-active-2022.CSV"),
  delim = ";", n_max = 0, show_col_types = FALSE
)
avail_cols <- names(header)

# Find which requested columns exist
cols_to_read <- insee_cols[insee_cols %in% avail_cols]
missing_cols <- insee_cols[!insee_cols %in% avail_cols]
if (length(missing_cols) > 0) {
  cat("  Missing columns:", paste(missing_cols, collapse = ", "), "\n")
}

# Read the full file (only needed columns)
insee <- read_delim(
  file.path(data_dir, "insee_emploi", "base-cc-emploi-pop-active-2022.CSV"),
  delim = ";", show_col_types = FALSE,
  col_select = all_of(cols_to_read)
)

cat("  INSEE employment: ", nrow(insee), " communes\n")

# Construct outcome variables
insee <- insee %>%
  mutate(
    # 2022 outcomes
    female_emp_rate = P22_FACTOCC1564 / P22_F1564,
    female_lfpr = P22_FACT1564 / P22_F1564,
    male_emp_rate = P22_HACTOCC1564 / (P22_POP1564 - P22_F1564),
    male_lfpr = P22_HACT1564 / (P22_POP1564 - P22_F1564),
    total_emp_rate = P22_ACTOCC1564 / P22_POP1564,
    total_lfpr = P22_ACT1564 / P22_POP1564,
    gender_emp_gap = male_emp_rate - female_emp_rate,
    gender_lfpr_gap = male_lfpr - female_lfpr,
    female_share_employed = P22_FACTOCC1564 / P22_ACTOCC1564,
    female_self_emp_share = P22_EMPLT_FNSAL / (P22_EMPLT_FSAL + P22_EMPLT_FNSAL),
    unemployment_rate = P22_CHOM1564 / P22_ACT1564
  )

# Pre-treatment outcomes (2011 — before 2014 threshold change)
if ("P11_F1564" %in% names(insee)) {
  insee <- insee %>%
    mutate(
      female_emp_rate_2011 = P11_FACTOCC1564 / P11_F1564,
      female_lfpr_2011 = P11_FACT1564 / P11_F1564,
      total_emp_rate_2011 = P11_ACTOCC1564 / P11_POP1564
    )
}

# 2016 outcomes (intermediate)
if ("P16_F1564" %in% names(insee)) {
  insee <- insee %>%
    mutate(
      female_emp_rate_2016 = P16_FACTOCC1564 / P16_F1564,
      female_lfpr_2016 = P16_FACT1564 / P16_F1564,
      total_emp_rate_2016 = P16_ACTOCC1564 / P16_POP1564
    )
}

## ----------------------------------------------------------
## 4. Merge all datasets
## ----------------------------------------------------------

cat("Merging datasets...\n")

# RNE commune_code is already the full 5-digit INSEE code (e.g., "01001")
# Merge council stats with commune population and INSEE employment
df <- communes %>%
  inner_join(council_stats, by = c("commune_code_geo" = "commune_code")) %>%
  inner_join(insee, by = c("commune_code_geo" = "CODGEO"))

cat("  After merging:", nrow(df), "communes\n")

## ----------------------------------------------------------
## 5. Construct RDD variables
## ----------------------------------------------------------

# Running variable: centered population
df <- df %>%
  mutate(
    pop = population,
    pop_centered = population - 1000,
    above_threshold = as.integer(population >= 1000),
    # Treatment labels
    parity_status = ifelse(above_threshold == 1,
                           "Parity (≥1000)", "No parity (<1000)")
  )

# Drop communes with missing key variables
df <- df %>%
  filter(
    !is.na(pop),
    !is.na(female_share),
    !is.na(female_emp_rate),
    is.finite(female_emp_rate),
    pop > 0,
    P22_F1564 > 10  # Need minimum female pop for meaningful rates
  )

cat("  After cleaning:", nrow(df), "communes\n")

## ----------------------------------------------------------
## 6. Summary of analysis data
## ----------------------------------------------------------

cat("\n=== Analysis Dataset Summary ===\n")
cat("Total communes:", nrow(df), "\n")
cat("  Above 1000:", sum(df$above_threshold), "\n")
cat("  Below 1000:", sum(1 - df$above_threshold), "\n")
cat("  Within bandwidth [500, 1500]:",
    sum(df$pop >= 500 & df$pop <= 1500), "\n")

cat("\nKey outcomes (full sample):\n")
cat("  Female employment rate:   ",
    round(mean(df$female_emp_rate, na.rm = TRUE), 3), "\n")
cat("  Female LFPR:              ",
    round(mean(df$female_lfpr, na.rm = TRUE), 3), "\n")
cat("  Gender employment gap:    ",
    round(mean(df$gender_emp_gap, na.rm = TRUE), 3), "\n")
cat("  Female councillor share:  ",
    round(mean(df$female_share), 3), "\n")

cat("\nAround threshold (+/- 200):\n")
near <- df %>% filter(abs(pop_centered) <= 200)
cat("  N:", nrow(near), "\n")
cat("  Female share (above): ",
    round(mean(near$female_share[near$above_threshold == 1]), 3), "\n")
cat("  Female share (below): ",
    round(mean(near$female_share[near$above_threshold == 0]), 3), "\n")
cat("  Jump: ",
    round(mean(near$female_share[near$above_threshold == 1]) -
            mean(near$female_share[near$above_threshold == 0]), 3), "\n")

## ----------------------------------------------------------
## 7. Save analysis dataset
## ----------------------------------------------------------

saveRDS(df, file.path(data_dir, "analysis_data.rds"))
cat("\nSaved analysis dataset:", file.path(data_dir, "analysis_data.rds"), "\n")
