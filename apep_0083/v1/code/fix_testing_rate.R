# Fix Drug Testing Rate Figure - Use raw data

source(here::here("output/paper_108/code/00_packages.R"))

# Load RAW data
fars_raw <- readRDS(file.path(dir_data_raw, "fars_accident_all.rds"))
drugs_raw <- readRDS(file.path(dir_data_raw, "fars_drugs_all.rds"))

THC_YEARS <- c(2018, 2019)

# State FIPS codes for Western states
WESTERN_FIPS <- c("04", "06", "08", "16", "20", "30", "31", "32", "35", "41", "49", "53", "56", "02")
# AZ=04, CA=06, CO=08, ID=16, KS=20, MT=30, NE=31, NV=32, NM=35, OR=41, UT=49, WA=53, WY=56, AK=02

# State name lookup
state_lookup <- data.frame(
  state_fips = c("02", "04", "06", "08", "16", "20", "30", "31", "32", "35", "41", "49", "53", "56"),
  state_abbr = c("AK", "AZ", "CA", "CO", "ID", "KS", "MT", "NE", "NV", "NM", "OR", "UT", "WA", "WY")
)

# All crashes by state in Western states, 2018-2019
total_crashes <- fars_raw %>%
  filter(year %in% THC_YEARS) %>%
  mutate(state_fips = sprintf("%02d", as.integer(state))) %>%
  filter(state_fips %in% WESTERN_FIPS) %>%
  group_by(state_fips) %>%
  summarise(total = n(), .groups = "drop")

# Crashes with any drug test in Western states
crashes_tested <- drugs_raw %>%
  filter(year %in% THC_YEARS) %>%
  mutate(state_fips = sprintf("%02d", as.integer(state))) %>%
  filter(state_fips %in% WESTERN_FIPS) %>%
  distinct(st_case, state_fips, year) %>%
  group_by(state_fips) %>%
  summarise(tested = n(), .groups = "drop")

# Merge
testing_rate <- total_crashes %>%
  left_join(crashes_tested, by = "state_fips") %>%
  left_join(state_lookup, by = "state_fips") %>%
  mutate(
    tested = ifelse(is.na(tested), 0, tested),
    pct_tested = 100 * tested / total
  ) %>%
  arrange(desc(pct_tested))

message("Drug Testing Rates in Western States (2018-2019):")
message("  Range: ", round(min(testing_rate$pct_tested), 1), "% to ",
        round(max(testing_rate$pct_tested), 1), "%")
message("  Mean: ", round(mean(testing_rate$pct_tested), 1), "%")

print(testing_rate)

# Create figure
fig8 <- ggplot(testing_rate, aes(x = reorder(state_abbr, pct_tested), y = pct_tested)) +
  geom_col(fill = "#4DAF4A", alpha = 0.8) +
  geom_hline(yintercept = mean(testing_rate$pct_tested), linetype = "dashed", color = "red") +
  annotate("text", x = 1.5, y = mean(testing_rate$pct_tested) + 3,
           label = paste0("Mean: ", round(mean(testing_rate$pct_tested), 1), "%"),
           hjust = 0, size = 3, color = "red") +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(testing_rate$pct_tested) + 10)) +
  labs(
    title = "Drug Testing Rate by State",
    subtitle = "Percent of fatal crashes with any drug test result, 2018-2019",
    x = NULL,
    y = "Percent of Crashes with Drug Test",
    caption = "Source: FARS drugs file. Rate = crashes with any drug record / total fatal crashes."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.png"), fig8, width = 8, height = 8, dpi = 300)
message("\nSaved fig08_testing_rate_by_state")
