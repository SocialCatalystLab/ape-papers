## ============================================================
## 01_fetch_data.R — Data acquisition
## Downloads: RNE councillor data, commune population data,
## INSEE census employment data, France Travail unemployment
## ============================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ----------------------------------------------------------
## 1. Répertoire National des Élus (RNE) — Municipal Councillors
##    Source: data.gouv.fr, Ministry of Interior
##    Contains: All elected municipal councillors with gender
## ----------------------------------------------------------

rne_url <- "https://static.data.gouv.fr/resources/repertoire-national-des-elus-1/20251223-103336/elus-conseillers-municipaux-cm.csv"
rne_file <- file.path(data_dir, "rne_conseillers_municipaux.csv")

if (!file.exists(rne_file)) {
  cat("Downloading RNE municipal councillors data...\n")
  download.file(rne_url, rne_file, mode = "wb")
  cat("  Downloaded:", round(file.info(rne_file)$size / 1e6, 1), "MB\n")
} else {
  cat("RNE data already exists.\n")
}

rne <- read_delim(rne_file, delim = ";",
                  locale = locale(encoding = "UTF-8"),
                  show_col_types = FALSE)
cat("RNE:", nrow(rne), "rows,", ncol(rne), "columns\n")

## ----------------------------------------------------------
## 2. Commune Data (Population + Geography)
##    Source: data.gouv.fr community dataset
##    Contains: Population, coordinates, department, region
## ----------------------------------------------------------

commune_url <- "https://www.data.gouv.fr/api/1/datasets/r/f5df602b-3800-44d7-b2df-fa40a0350325"
commune_file <- file.path(data_dir, "communes_france.csv")

if (!file.exists(commune_file)) {
  cat("Downloading commune data...\n")
  download.file(commune_url, commune_file, mode = "wb")
  cat("  Downloaded:", round(file.info(commune_file)$size / 1e6, 1), "MB\n")
} else {
  cat("Commune data already exists.\n")
}

communes <- read_csv(commune_file, show_col_types = FALSE)
cat("Communes:", nrow(communes), "rows,", ncol(communes), "columns\n")
cat("  Population range:", min(communes$population, na.rm = TRUE), "-",
    max(communes$population, na.rm = TRUE), "\n")

## ----------------------------------------------------------
## 3. INSEE Census Employment Data (Commune Level)
##    Source: INSEE Recensement 2022
##    Contains: Employment, unemployment, activity by gender
## ----------------------------------------------------------

insee_url <- "https://www.insee.fr/fr/statistiques/fichier/8581444/base-cc-emploi-pop-active-2022_csv.zip"
insee_zip <- file.path(data_dir, "base_cc_emploi_2022.zip")
insee_dir <- file.path(data_dir, "insee_emploi")

if (!file.exists(insee_zip)) {
  cat("Downloading INSEE census employment data (2022)...\n")
  download.file(insee_url, insee_zip, mode = "wb")
  cat("  Downloaded:", round(file.info(insee_zip)$size / 1e6, 1), "MB\n")
}

if (!dir.exists(insee_dir)) {
  dir.create(insee_dir, showWarnings = FALSE)
  unzip(insee_zip, exdir = insee_dir)
  cat("  Unzipped to:", insee_dir, "\n")
}

# List extracted files
insee_files <- list.files(insee_dir, pattern = "\\.csv$|\\.CSV$",
                          recursive = TRUE, full.names = TRUE)
cat("INSEE employment files:\n")
for (f in insee_files) {
  cat("  ", basename(f), "(",
      round(file.info(f)$size / 1e6, 1), "MB)\n")
}

## ----------------------------------------------------------
## 4. France Travail (Pôle Emploi) — Unemployment by Commune
##    Source: DARES via data.gouv.fr
##    Contains: Registered jobseekers by commune, gender, age
## ----------------------------------------------------------

ft_url <- "https://www.data.gouv.fr/api/1/datasets/r/c3de380a-3829-4e04-aca4-19e685f9da1a"
ft_file <- file.path(data_dir, "france_travail_communes.csv")

if (!file.exists(ft_file)) {
  cat("Downloading France Travail commune data...\n")
  download.file(ft_url, ft_file, mode = "wb")
  cat("  Downloaded:", round(file.info(ft_file)$size / 1e6, 1), "MB\n")
} else {
  cat("France Travail data already exists.\n")
}

# Read header to check structure
ft_header <- read_csv(ft_file, n_max = 5, show_col_types = FALSE)
cat("France Travail:", ncol(ft_header), "columns\n")
cat("  Columns:", paste(names(ft_header), collapse = ", "), "\n")

## ----------------------------------------------------------
## 5. Populations Légales (Historical)
##    Source: data.gouv.fr
##    Contains: Legal population by commune and year
## ----------------------------------------------------------

pop_url <- "https://www.data.gouv.fr/api/1/datasets/r/8cb92c8f-26e2-4705-b9bf-a76aba8c0450"
pop_file <- file.path(data_dir, "populations_legales.csv")

if (!file.exists(pop_file)) {
  cat("Downloading populations légales...\n")
  download.file(pop_url, pop_file, mode = "wb")
  cat("  Downloaded:", round(file.info(pop_file)$size / 1e6, 2), "MB\n")
} else {
  cat("Populations légales data already exists.\n")
}

pop_header <- read_delim(pop_file, delim = ";", n_max = 5,
                         show_col_types = FALSE)
cat("Populations légales columns:",
    paste(names(pop_header), collapse = ", "), "\n")

cat("\n=== Data acquisition complete ===\n")
cat("Files in data directory:\n")
for (f in list.files(data_dir, recursive = FALSE)) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, "(", round(sz / 1e6, 1), "MB)\n")
}
