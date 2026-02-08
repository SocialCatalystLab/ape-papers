# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 10_tables.R - Summary statistics and data quality tables
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))
marijuana_policy <- readRDS(file.path(dir_data_policy, "marijuana_policy.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")

# =============================================================================
# Table 1: Marijuana Policy Timeline
# =============================================================================

message("Creating Table 1: Policy timeline...")

table1 <- marijuana_policy %>%
  select(state, state_abbr, rec_effective_date, retail_open_date, policy_category) %>%
  arrange(rec_effective_date) %>%
  mutate(
    rec_effective_date = as.character(rec_effective_date),
    retail_open_date = as.character(retail_open_date),
    rec_effective_date = ifelse(is.na(rec_effective_date), "--", rec_effective_date),
    retail_open_date = ifelse(is.na(retail_open_date), "--", retail_open_date)
  ) %>%
  rename(
    State = state,
    Abbr = state_abbr,
    `Legalization Date` = rec_effective_date,
    `Retail Opens` = retail_open_date,
    Category = policy_category
  )

write_csv(table1, file.path(dir_tabs, "table1_policy_timeline.csv"))

# Also create LaTeX version
cat("
\\begin{table}[H]
\\centering
\\caption{Marijuana Legalization Timeline: Western States}
\\begin{threeparttable}
\\begin{tabular}{llllc}
\\toprule
State & Abbr & Legalization Date & Retail Opens & Category \\\\
\\midrule
", file = file.path(dir_tabs, "table1_policy_timeline.tex"))

for (i in 1:nrow(table1)) {
  row <- table1[i, ]
  cat(paste(row$State, "&", row$Abbr, "&", row$`Legalization Date`, "&",
            row$`Retail Opens`, "&", row$Category, "\\\\\n"),
      file = file.path(dir_tabs, "table1_policy_timeline.tex"), append = TRUE)
}

cat("
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Legalization date is when recreational possession became legal.
Retail date is when licensed sales began. -- indicates not applicable.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:policy}
\\end{table}
", file = file.path(dir_tabs, "table1_policy_timeline.tex"), append = TRUE)

message("  Saved table1_policy_timeline")

# =============================================================================
# Table 2: Summary Statistics by State
# =============================================================================

message("Creating Table 2: Summary statistics by state...")

table2 <- fars %>%
  group_by(state_abbr) %>%
  summarise(
    `Total Crashes` = n(),
    `Total Fatalities` = sum(n_fatals, na.rm = TRUE),
    `Fatals/Crash` = round(sum(n_fatals, na.rm = TRUE) / n(), 2),
    `% THC Tested` = round(100 * sum(!is.na(thc_positive)) / n(), 1),
    `% THC Positive` = round(100 * sum(thc_positive, na.rm = TRUE) / sum(!is.na(thc_positive)), 1),
    `% Alcohol Positive` = round(100 * sum(any_alc_positive, na.rm = TRUE) / sum(!is.na(any_alc_positive)), 1),
    `Legal Status` = first(policy_category),
    .groups = "drop"
  ) %>%
  arrange(desc(`Total Crashes`))

write_csv(table2, file.path(dir_tabs, "table2_summary_by_state.csv"))

message("  Saved table2_summary_by_state")

# =============================================================================
# Table 3: Summary Statistics by Year
# =============================================================================

message("Creating Table 3: Summary statistics by year...")

table3 <- fars %>%
  group_by(year) %>%
  summarise(
    `Total Crashes` = n(),
    `Total Fatalities` = sum(n_fatals, na.rm = TRUE),
    `% Geocoded` = round(100 * sum(!is.na(x_albers)) / n(), 1),
    `% THC Tested` = round(100 * sum(!is.na(thc_positive)) / n(), 1),
    `% THC Positive` = round(100 * sum(thc_positive, na.rm = TRUE) / sum(!is.na(thc_positive)), 1),
    `% Alcohol Positive` = round(100 * sum(any_alc_positive, na.rm = TRUE) / sum(!is.na(any_alc_positive)), 1),
    .groups = "drop"
  )

write_csv(table3, file.path(dir_tabs, "table3_summary_by_year.csv"))

message("  Saved table3_summary_by_year")

# =============================================================================
# Table 4: THC Rates Before/After Legalization
# =============================================================================

message("Creating Table 4: THC rates before/after...")

table4 <- fars %>%
  filter(!is.na(thc_positive), state_abbr %in% c("CO", "WA", "OR", "CA", "NV")) %>%
  mutate(
    period = ifelse(rec_legal, "Post-Legalization", "Pre-Legalization")
  ) %>%
  group_by(state_abbr, period) %>%
  summarise(
    `N Crashes` = n(),
    `THC Positive` = sum(thc_positive),
    `% THC Positive` = round(100 * sum(thc_positive) / n(), 1),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = period,
    values_from = c(`N Crashes`, `THC Positive`, `% THC Positive`),
    names_sep = " - "
  )

write_csv(table4, file.path(dir_tabs, "table4_thc_before_after.csv"))

message("  Saved table4_thc_before_after")

# =============================================================================
# Table 5: Border Region Statistics
# =============================================================================

message("Creating Table 5: Border region statistics...")

border_pairs <- tribble(
  ~legal, ~illegal, ~pair_name,
  "CO", "WY", "Colorado-Wyoming",
  "WA", "ID", "Washington-Idaho",
  "OR", "ID", "Oregon-Idaho",
  "NV", "UT", "Nevada-Utah",
  "CA", "AZ", "California-Arizona"
)

table5_rows <- list()
for (i in 1:nrow(border_pairs)) {
  bp <- border_pairs[i, ]

  legal_stats <- fars %>%
    filter(state_abbr == bp$legal, year >= 2014, !is.na(thc_positive)) %>%
    summarise(
      n = n(),
      thc_pct = round(100 * sum(thc_positive) / n(), 1),
      alc_pct = round(100 * sum(any_alc_positive, na.rm = TRUE) / sum(!is.na(any_alc_positive)), 1)
    )

  illegal_stats <- fars %>%
    filter(state_abbr == bp$illegal, year >= 2014, !is.na(thc_positive)) %>%
    summarise(
      n = n(),
      thc_pct = round(100 * sum(thc_positive) / n(), 1),
      alc_pct = round(100 * sum(any_alc_positive, na.rm = TRUE) / sum(!is.na(any_alc_positive)), 1)
    )

  table5_rows[[i]] <- tibble(
    `Border Pair` = bp$pair_name,
    `Legal State` = bp$legal,
    `Illegal State` = bp$illegal,
    `N (Legal)` = legal_stats$n,
    `N (Illegal)` = illegal_stats$n,
    `% THC (Legal)` = legal_stats$thc_pct,
    `% THC (Illegal)` = illegal_stats$thc_pct,
    `Difference` = legal_stats$thc_pct - illegal_stats$thc_pct
  )
}

table5 <- bind_rows(table5_rows)
write_csv(table5, file.path(dir_tabs, "table5_border_statistics.csv"))

message("  Saved table5_border_statistics")

# =============================================================================
# Table 6: Data Quality Summary
# =============================================================================

message("Creating Table 6: Data quality summary...")

table6 <- fars %>%
  group_by(state_abbr) %>%
  summarise(
    `Total Crashes` = n(),
    `Geocoded (%)` = round(100 * sum(!is.na(x_albers)) / n(), 1),
    `Drug Test (%)` = round(100 * sum(!is.na(thc_positive)) / n(), 1),
    `Alcohol Test (%)` = round(100 * sum(!is.na(any_alc_positive)) / n(), 1),
    `Hour Known (%)` = round(100 * sum(!is.na(hour) & hour < 24) / n(), 1),
    .groups = "drop"
  ) %>%
  arrange(state_abbr)

write_csv(table6, file.path(dir_tabs, "table6_data_quality.csv"))

message("  Saved table6_data_quality")

# =============================================================================
# Table 7: Substance Involvement Patterns
# =============================================================================

message("Creating Table 7: Substance involvement patterns...")

table7 <- fars %>%
  filter(!is.na(thc_positive) & !is.na(any_alc_positive)) %>%
  count(substance_cat) %>%
  mutate(
    `Percent` = round(100 * n / sum(n), 1)
  ) %>%
  rename(
    Category = substance_cat,
    `N Crashes` = n
  ) %>%
  arrange(desc(`N Crashes`))

write_csv(table7, file.path(dir_tabs, "table7_substance_patterns.csv"))

message("  Saved table7_substance_patterns")

# =============================================================================
# Table 8: Time of Day Patterns
# =============================================================================

message("Creating Table 8: Time of day patterns...")

table8 <- fars %>%
  filter(!is.na(hour) & hour < 24) %>%
  mutate(
    `Time Period` = case_when(
      hour >= 6 & hour < 12 ~ "Morning (6am-12pm)",
      hour >= 12 & hour < 18 ~ "Afternoon (12pm-6pm)",
      hour >= 18 & hour < 22 ~ "Evening (6pm-10pm)",
      TRUE ~ "Night (10pm-6am)"
    )
  ) %>%
  group_by(`Time Period`) %>%
  summarise(
    `N Crashes` = n(),
    `% of Total` = round(100 * n() / nrow(filter(fars, !is.na(hour) & hour < 24)), 1),
    `% THC Positive` = round(100 * sum(thc_positive, na.rm = TRUE) / sum(!is.na(thc_positive)), 1),
    `% Alcohol Positive` = round(100 * sum(any_alc_positive, na.rm = TRUE) / sum(!is.na(any_alc_positive)), 1),
    .groups = "drop"
  )

write_csv(table8, file.path(dir_tabs, "table8_time_patterns.csv"))

message("  Saved table8_time_patterns")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("Tables complete!")
message("Tables saved to: ", dir_tabs)
message(strrep("=", 60))

# List tables
message("\nGenerated tables:")
list.files(dir_tabs, pattern = "^table") %>%
  sort() %>%
  walk(~ message("  ", .x))
