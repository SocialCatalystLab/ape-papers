## ============================================================
## 02_clean_data.R — Clean referendum data, build analysis panel
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"

## ---------------------------------------------------------------
## 1. Load raw data
## ---------------------------------------------------------------
cat("=== Loading raw referendum data ===\n")
all_votes <- readRDS(file.path(DATA_DIR, "all_votes_raw.rds"))

cat(sprintf("Total rows: %s\n", format(nrow(all_votes), big.mark = ",")))
cat(sprintf("Columns: %s\n", paste(names(all_votes), collapse = ", ")))
cat(sprintf("Vote dates: %d unique from %s to %s\n",
            length(unique(all_votes$votedate)),
            min(all_votes$votedate), max(all_votes$votedate)))

# Municipalities per vote
muni_per_vote <- all_votes |>
  group_by(votedate) |>
  summarise(n_muni = n_distinct(mun_id), .groups = "drop")
cat(sprintf("Municipalities per vote: min=%d, median=%d, max=%d\n",
            min(muni_per_vote$n_muni), median(muni_per_vote$n_muni),
            max(muni_per_vote$n_muni)))

## ---------------------------------------------------------------
## 2. Identify proposals on target dates
## ---------------------------------------------------------------
cat("\n=== Identifying target proposals ===\n")

target_dates <- as.Date(c(
  "1981-06-14",  # Gleichstellungsartikel
  "1984-12-02",  # Maternity insurance initiative
  "1999-06-13",  # Maternity insurance
  "2004-09-26",  # Maternity insurance
  "2020-09-27",  # Paternity leave + fighter jets
  "2021-09-26",  # Same-sex marriage
  "2014-02-09",  # Mass immigration
  "2020-11-29",  # Corporate responsibility
  "2021-03-07"   # Burqa ban
))

# All proposals on target dates with their national yes-share
proposals <- all_votes |>
  filter(votedate %in% target_dates) |>
  group_by(votedate, id, name) |>
  summarise(
    nat_yes = weighted.mean(jaStimmenInProzent, gueltigeStimmen, na.rm = TRUE),
    n_muni = n(),
    .groups = "drop"
  ) |>
  arrange(votedate, id)

cat("Proposals on target dates:\n")
print(proposals, n = 50)

## ---------------------------------------------------------------
## 3. Map proposal IDs to labels based on known national results
## ---------------------------------------------------------------

# Known national results for identification:
# 1981-06-14 Gleichstellungsartikel: ~60.3% yes
# 1984-12-02 Maternity initiative: ~15.8% yes (Mutterschaftsversicherung)
# 1999-06-13 Maternity insurance: ~38.9% yes
# 2004-09-26 Maternity insurance: ~55.5% yes
# 2020-09-27 Paternity leave: ~60.3% yes
# 2020-09-27 Fighter jets: ~50.1% yes (barely passed)
# 2021-09-26 Same-sex marriage: ~64.1% yes
# 2014-02-09 Mass immigration: ~50.3% yes
# 2020-11-29 Corporate responsibility: ~50.7% yes (failed Ständemehr)
# 2021-03-07 Burqa ban: ~51.2% yes

# Map each target date to the correct proposal ID
# We'll match by closest national yes-share to known values

known_targets <- tribble(
  ~label, ~target_date, ~expected_yes, ~type,
  "equal_rights_1981", "1981-06-14", 60.3, "gender",
  "maternity_1984", "1984-12-02", 15.8, "gender",
  "maternity_1999", "1999-06-13", 38.9, "gender",
  "maternity_2004", "2004-09-26", 55.5, "gender",
  "paternity_2020", "2020-09-27", 60.3, "gender",
  "jets_2020", "2020-09-27", 50.1, "non_gender",
  "marriage_2021", "2021-09-26", 64.1, "gender",
  "immigration_2014", "2014-02-09", 50.3, "non_gender",
  "corporate_2020", "2020-11-29", 50.7, "non_gender",
  "burqa_2021", "2021-03-07", 51.2, "non_gender"
)

# For each target, find the proposal with closest national yes-share
vote_map <- known_targets |>
  mutate(target_date = as.Date(target_date)) |>
  rowwise() |>
  mutate(
    matched_id = {
      p <- proposals |> filter(votedate == target_date)
      if (nrow(p) == 0) { NA_real_ }
      else if (nrow(p) == 1) { p$id[1] }
      else { p$id[which.min(abs(p$nat_yes - expected_yes))] }
    },
    matched_yes = {
      p <- proposals |> filter(votedate == target_date, id == matched_id)
      if (nrow(p) == 0) NA_real_ else p$nat_yes[1]
    }
  ) |>
  ungroup()

cat("\nMatched proposals:\n")
vote_map |>
  mutate(matched_yes = round(matched_yes, 1)) |>
  select(label, target_date, expected_yes, matched_id, matched_yes, type) |>
  print(n = 15)

## ---------------------------------------------------------------
## 4. Extract municipality-level YES shares for each referendum
## ---------------------------------------------------------------
cat("\n=== Extracting municipality-level data ===\n")

# Extract and reshape to wide format
vote_long <- vote_map |>
  filter(!is.na(matched_id)) |>
  select(label, target_date, matched_id, type) |>
  pmap_dfr(function(label, target_date, matched_id, type) {
    all_votes |>
      filter(votedate == target_date, id == matched_id) |>
      transmute(
        mun_id = mun_id,
        mun_name = mun_name,
        canton_id = canton_id,
        canton_name = canton_name,
        vote_label = label,
        vote_type = type,
        votedate = votedate,
        yes_pct = jaStimmenInProzent,
        yes_abs = jaStimmenAbsolut,
        no_abs = neinStimmenAbsolut,
        turnout_pct = stimmbeteiligungInProzent,
        eligible = anzahlStimmberechtigte,
        valid = gueltigeStimmen
      )
  })

cat(sprintf("Long-format data: %s rows, %d vote types\n",
            format(nrow(vote_long), big.mark = ","),
            n_distinct(vote_long$vote_label)))

# Summary statistics per vote
vote_long |>
  group_by(vote_label, votedate, vote_type) |>
  summarise(
    n_muni = n(),
    mean_yes = round(mean(yes_pct, na.rm = TRUE), 1),
    sd_yes = round(sd(yes_pct, na.rm = TRUE), 1),
    min_yes = round(min(yes_pct, na.rm = TRUE), 1),
    max_yes = round(max(yes_pct, na.rm = TRUE), 1),
    .groups = "drop"
  ) |>
  arrange(votedate) |>
  print(n = 15)

## ---------------------------------------------------------------
## 5. Reshape to wide format (one row per municipality)
## ---------------------------------------------------------------
cat("\n=== Reshaping to wide format ===\n")

# Create wide panel: each municipality has a column for each vote's YES share
vote_wide <- vote_long |>
  select(mun_id, mun_name, canton_id, canton_name, vote_label, yes_pct) |>
  pivot_wider(
    id_cols = c(mun_id, mun_name, canton_id, canton_name),
    names_from = vote_label,
    values_from = yes_pct,
    names_prefix = "yes_"
  )

cat(sprintf("Wide-format: %d municipalities, %d columns\n",
            nrow(vote_wide), ncol(vote_wide)))

# How many municipalities have data for ALL gender referenda?
gender_cols <- paste0("yes_", c("equal_rights_1981", "maternity_2004",
                                "paternity_2020", "marriage_2021"))
has_all_gender <- vote_wide |>
  filter(if_all(any_of(gender_cols), ~ !is.na(.)))
cat(sprintf("Municipalities with all 4 main gender referenda: %d\n",
            nrow(has_all_gender)))

## ---------------------------------------------------------------
## 6. Add canton characteristics
## ---------------------------------------------------------------
canton_chars <- readRDS(file.path(DATA_DIR, "canton_characteristics.rds"))

# Map canton abbreviations
canton_abbrev <- tibble(
  canton_id = as.character(1:26),
  canton = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
             "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
             "TI", "VD", "VS", "NE", "GE", "JU")
)

# Join canton characteristics
analysis_data <- vote_wide |>
  left_join(canton_abbrev, by = "canton_id") |>
  left_join(canton_chars, by = "canton")

cat(sprintf("\nAnalysis dataset: %d municipalities\n", nrow(analysis_data)))
cat("Canton coverage:\n")
analysis_data |>
  count(canton, primary_language, suffrage_year) |>
  arrange(suffrage_year) |>
  print(n = 26)

## ---------------------------------------------------------------
## 7. Create derived variables
## ---------------------------------------------------------------
cat("\n=== Creating derived variables ===\n")

analysis_data <- analysis_data |>
  mutate(
    # Change variables (convergence analysis)
    delta_gender = yes_paternity_2020 - yes_equal_rights_1981,
    delta_gender2 = yes_marriage_2021 - yes_equal_rights_1981,

    # Binary: above/below median in 1981
    progressive_1981 = yes_equal_rights_1981 > median(yes_equal_rights_1981, na.rm = TRUE),

    # Language dummies
    lang_french = primary_language == "fr",
    lang_italian = primary_language == "it",
    lang_german = primary_language == "de",

    # Suffrage timing groups
    suffrage_early = suffrage_year < 1970,
    suffrage_late = suffrage_year > 1975,
    years_since_suffrage = 2020 - suffrage_year
  )

# Summary statistics
cat("\n=== Key summary statistics ===\n")
analysis_data |>
  select(starts_with("yes_"), delta_gender) |>
  pivot_longer(everything()) |>
  group_by(name) |>
  summarise(
    n = sum(!is.na(value)),
    mean = round(mean(value, na.rm = TRUE), 1),
    sd = round(sd(value, na.rm = TRUE), 1),
    min = round(min(value, na.rm = TRUE), 1),
    max = round(max(value, na.rm = TRUE), 1),
    .groups = "drop"
  ) |>
  print(n = 20)

## ---------------------------------------------------------------
## 8. Save analysis dataset
## ---------------------------------------------------------------
saveRDS(analysis_data, file.path(DATA_DIR, "analysis_data.rds"))
saveRDS(vote_long, file.path(DATA_DIR, "vote_long.rds"))

cat(sprintf("\nSaved analysis_data.rds (%d rows, %d cols)\n",
            nrow(analysis_data), ncol(analysis_data)))
cat("Saved vote_long.rds for panel analysis\n")
cat("\n=== Data cleaning complete ===\n")
