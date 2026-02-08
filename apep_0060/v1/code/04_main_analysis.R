# ============================================================================
# Paper 75: The Making of a City
# 04_main_analysis.R - Repeated Cross-Section DiD Analysis
# ============================================================================
#
# Research Design: The 1906 SF earthquake as natural experiment
# - Treatment: San Francisco (exposed to earthquake + fire)
# - Control: Los Angeles, Seattle (similar Western frontier cities)
# - Pre: 1900 Census
# - Post: 1910 Census
#
# Key insight: Use REPEATED CROSS-SECTIONS to study compositional change
# This doesn't require panel linkage - we compare who lives in each city
# ============================================================================

# Load packages
source("output/paper_75/code/00_packages.R")
library(fixest)

DATA_DIR <- "output/paper_75/data"

# ============================================================================
# Load processed data
# ============================================================================

msg("Loading processed data...")
dt <- readRDS(file.path(DATA_DIR, "sf_la_sea_1900_1910.rds"))
msg("Loaded ", fmt_num(nrow(dt)), " records from 3 cities, 2 census years")

# Create analysis variables
dt[, `:=`(
  # Treatment indicators
  post = as.integer(YEAR == 1910),
  treated = as.integer(city == "San Francisco"),
  did = as.integer(city == "San Francisco" & YEAR == 1910),

  # Demographics
  female = as.integer(SEX == 2),
  literate = as.integer(LIT == 2),
  foreign_born = as.integer(BPL >= 100),  # BPL >= 100 = foreign birthplace
  native_foreign_parent = as.integer(NATIVITY %in% c(2, 3, 4)),  # 2nd gen immigrant
  married = as.integer(MARST %in% c(1, 2)),  # Married/spouse present

  # Age groups
  age_group = cut(AGE, breaks = c(0, 18, 30, 45, 65, Inf),
                  labels = c("0-17", "18-29", "30-44", "45-64", "65+"),
                  right = FALSE),
  working_age = as.integer(AGE >= 18 & AGE <= 65),

  # Occupation
  has_occupation = as.integer(!is.na(OCC1950) & OCC1950 > 0 & OCC1950 < 979)
)]

# ============================================================================
# PART I: Descriptive Statistics - City Composition
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART I: City Composition Before and After 1906")
msg("=" |> strrep(60))

# Population by city and year
pop_summary <- dt[, .(n = .N), by = .(city, YEAR)] |>
  dcast(city ~ YEAR, value.var = "n")
setnames(pop_summary, c("1900", "1910"), c("pop_1900", "pop_1910"))
pop_summary[, pct_change := (pop_1910 - pop_1900) / pop_1900 * 100]

msg("\nPopulation changes 1900-1910:")
print(pop_summary)

# Demographic composition
demo_comp <- dt[, .(
  mean_age = mean(AGE, na.rm = TRUE),
  pct_female = mean(female, na.rm = TRUE) * 100,
  pct_literate = mean(literate, na.rm = TRUE) * 100,
  pct_foreign = mean(foreign_born, na.rm = TRUE) * 100,
  pct_married = mean(married, na.rm = TRUE) * 100,
  mean_occscore = mean(OCCSCORE[OCCSCORE > 0], na.rm = TRUE)
), by = .(city, YEAR)]

msg("\nDemographic composition by city and year:")
print(demo_comp)

# ============================================================================
# PART II: DiD Analysis - Compositional Changes
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART II: Difference-in-Differences Analysis")
msg("=" |> strrep(60))

# DiD on demographic outcomes
# Collapse to city-year cells for aggregate analysis
city_year <- dt[, .(
  n = .N,
  mean_age = mean(AGE, na.rm = TRUE),
  pct_female = mean(female, na.rm = TRUE) * 100,
  pct_literate = mean(literate, na.rm = TRUE) * 100,
  pct_foreign = mean(foreign_born, na.rm = TRUE) * 100,
  pct_married = mean(married, na.rm = TRUE) * 100,
  pct_working_age = mean(working_age, na.rm = TRUE) * 100,
  mean_occscore = mean(OCCSCORE[OCCSCORE > 0], na.rm = TRUE)
), by = .(city, YEAR, treated, post, did)]

msg("\nCity-year aggregates:")
print(city_year)

# Simple DiD estimates (2x2)
msg("\n", "-" |> strrep(60))
msg("Simple 2x2 DiD Estimates")
msg("-" |> strrep(60))

# Calculate DiD manually for transparency
sf_1900 <- city_year[city == "San Francisco" & YEAR == 1900]
sf_1910 <- city_year[city == "San Francisco" & YEAR == 1910]

# Use LA as primary control (same state, similar size)
la_1900 <- city_year[city == "Los Angeles" & YEAR == 1900]
la_1910 <- city_year[city == "Los Angeles" & YEAR == 1910]

# Using both controls (LA + Seattle)
control_1900 <- city_year[city != "San Francisco" & YEAR == 1900,
                           lapply(.SD, mean),
                           .SDcols = c("pct_female", "pct_literate", "pct_foreign",
                                      "mean_age", "mean_occscore")]
control_1910 <- city_year[city != "San Francisco" & YEAR == 1910,
                           lapply(.SD, mean),
                           .SDcols = c("pct_female", "pct_literate", "pct_foreign",
                                      "mean_age", "mean_occscore")]

outcomes <- c("pct_female", "pct_literate", "pct_foreign", "mean_age", "mean_occscore")

msg("\nDiD estimates (SF vs pooled controls):")
for (var in outcomes) {
  sf_change <- sf_1910[[var]] - sf_1900[[var]]
  ctrl_change <- control_1910[[var]] - control_1900[[var]]
  did_est <- sf_change - ctrl_change
  msg(sprintf("  %s: SF change = %.2f, Control change = %.2f, DiD = %.2f",
              var, sf_change, ctrl_change, did_est))
}

# ============================================================================
# PART III: Individual-Level DiD with Controls
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART III: Individual-Level Regressions")
msg("=" |> strrep(60))

# Working-age population for labor outcomes
dt_work <- dt[working_age == 1]
msg("Working-age sample: ", fmt_num(nrow(dt_work)))

# Model 1: Foreign-born share (proxy for migration patterns)
msg("\nModel 1: Foreign-born status")
m1 <- feols(foreign_born ~ did + post + treated, data = dt_work, vcov = "HC1")
print(summary(m1))

# Model 2: Literacy (human capital)
msg("\nModel 2: Literacy")
m2 <- feols(literate ~ did + post + treated + AGE + I(AGE^2) + female,
            data = dt_work, vcov = "HC1")
print(summary(m2))

# Model 3: Occupational score (among those with occupation)
msg("\nModel 3: Occupational score")
dt_occ <- dt_work[has_occupation == 1 & OCCSCORE > 0]
m3 <- feols(OCCSCORE ~ did + post + treated + AGE + I(AGE^2) + female + literate + foreign_born,
            data = dt_occ, vcov = "HC1")
print(summary(m3))

# Model 4: Gender ratio (male share)
msg("\nModel 4: Male share")
m4 <- feols(I(1 - female) ~ did + post + treated + AGE + I(AGE^2),
            data = dt_work, vcov = "HC1")
print(summary(m4))

# ============================================================================
# PART IV: Heterogeneity Analysis
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART IV: Heterogeneity by Demographics")
msg("=" |> strrep(60))

# By age group
msg("\nDiD effect on literacy by age group:")
age_effects <- dt_work[, {
  if(.N > 1000) {
    m <- lm(literate ~ did + post + treated)
    data.table(
      n = .N,
      did_coef = coef(m)["did"],
      did_se = sqrt(vcov(m)["did", "did"])
    )
  } else {
    data.table(n = .N, did_coef = NA_real_, did_se = NA_real_)
  }
}, by = age_group]
print(age_effects)

# By nativity
msg("\nDiD effect on occupational score by nativity:")
nativity_effects <- dt_occ[, {
  if(.N > 1000) {
    m <- lm(OCCSCORE ~ did + post + treated + AGE + female)
    data.table(
      n = .N,
      did_coef = coef(m)["did"],
      did_se = sqrt(vcov(m)["did", "did"])
    )
  } else {
    data.table(n = .N, did_coef = NA_real_, did_se = NA_real_)
  }
}, by = .(foreign_born)]
print(nativity_effects)

# ============================================================================
# PART V: Age Distribution Analysis
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART V: Age Distribution Shifts")
msg("=" |> strrep(60))

# Did the earthquake change the age structure?
age_dist <- dt[, .(n = .N), by = .(city, YEAR, age_group)]
age_dist[, pct := n / sum(n) * 100, by = .(city, YEAR)]

msg("\nAge distribution by city and year:")
age_wide <- dcast(age_dist, city + age_group ~ YEAR, value.var = "pct")
setnames(age_wide, c("1900", "1910"), c("pct_1900", "pct_1910"))
age_wide[, change := pct_1910 - pct_1900]
print(age_wide[order(city, age_group)])

# ============================================================================
# PART VI: Occupation Analysis
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("PART VI: Occupational Composition")
msg("=" |> strrep(60))

# Top occupations by city and year (using OCC1950 codes)
# Group into broad categories
dt_occ[, occ_cat := fcase(
  OCC1950 %in% 0:99, "Professional/Technical",
  OCC1950 %in% 100:199, "Farmers/Farm Managers",
  OCC1950 %in% 200:299, "Managers/Officials",
  OCC1950 %in% 300:399, "Clerical",
  OCC1950 %in% 400:499, "Sales",
  OCC1950 %in% 500:599, "Craftsmen",
  OCC1950 %in% 600:699, "Operatives",
  OCC1950 %in% 700:799, "Service Workers",
  OCC1950 %in% 800:899, "Farm Laborers",
  OCC1950 %in% 900:979, "Laborers",
  default = "Other"
)]

occ_dist <- dt_occ[, .(n = .N), by = .(city, YEAR, occ_cat)]
occ_dist[, pct := n / sum(n) * 100, by = .(city, YEAR)]

msg("\nOccupational distribution (top categories):")
occ_wide <- dcast(occ_dist, city + occ_cat ~ YEAR, value.var = "pct")
setnames(occ_wide, c("1900", "1910"), c("pct_1900", "pct_1910"))
occ_wide[, change := pct_1910 - pct_1900]
print(occ_wide[order(city, -pct_1910)][, head(.SD, 5), by = city])

# ============================================================================
# Save Results
# ============================================================================

results <- list(
  pop_summary = pop_summary,
  demo_comp = demo_comp,
  city_year = city_year,
  models = list(
    foreign_born = m1,
    literacy = m2,
    occscore = m3,
    male_share = m4
  ),
  age_effects = age_effects,
  nativity_effects = nativity_effects,
  age_dist = age_wide,
  occ_dist = occ_wide
)

saveRDS(results, file.path(DATA_DIR, "analysis_results.rds"))
msg("\nResults saved to: ", file.path(DATA_DIR, "analysis_results.rds"))

# Export key tables for LaTeX
write.csv(demo_comp, file.path(DATA_DIR, "table_demographics.csv"), row.names = FALSE)
write.csv(city_year, file.path(DATA_DIR, "table_city_year.csv"), row.names = FALSE)

msg("\n", "=" |> strrep(60))
msg("Analysis complete!")
msg("=" |> strrep(60))
