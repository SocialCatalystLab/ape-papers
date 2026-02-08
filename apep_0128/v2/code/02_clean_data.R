# ==============================================================================
# 02_clean_data.R
# Clean data and construct treatment variables for sub-national DiD
# Paper 184: Revision of apep_0128 (Dutch Nitrogen Crisis & Housing)
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Step 1: Clean CBS Housing Prices (municipality x year panel)
# ==============================================================================
cat("\n=== Step 1: Clean CBS Housing Prices ===\n")

cbs_housing <- readRDS("../data/raw/cbs_housing_prices.rds")

# Parse municipality codes and years
prices <- cbs_housing %>%
  mutate(
    muni_code = trimws(Regions),
    period_raw = trimws(Periods),
    year = as.integer(gsub("JJ00", "", period_raw)),
    price = as.numeric(AveragePurchasePrice_1)
  ) %>%
  filter(!is.na(year), year >= 2012, year <= 2024) %>%
  filter(!is.na(price), price > 0) %>%
  select(muni_code, year, price) %>%
  mutate(log_price = log(price))

cat(sprintf("  Observations: %d\n", nrow(prices)))
cat(sprintf("  Municipalities: %d\n", n_distinct(prices$muni_code)))
cat(sprintf("  Years: %d (%d-%d)\n",
            n_distinct(prices$year), min(prices$year), max(prices$year)))
cat(sprintf("  Price range: %.0f - %.0f\n", min(prices$price), max(prices$price)))

# ==============================================================================
# Step 2: Clean CBS Building Permits (municipality x quarter panel)
# ==============================================================================
cat("\n=== Step 2: Clean CBS Building Permits ===\n")

cbs_permits <- readRDS("../data/raw/cbs_building_permits.rds")

permits <- cbs_permits %>%
  mutate(
    muni_code = trimws(RegioS),
    period_raw = trimws(Perioden)
  ) %>%
  filter(grepl("KW", period_raw)) %>%  # Keep only quarterly data
  mutate(
    year = as.integer(substr(period_raw, 1, 4)),
    qtr = as.integer(gsub("KW0?", "", substr(period_raw, 5, 8))),
    dwellings_permitted = as.numeric(Woningen_2)
  ) %>%
  filter(!is.na(year), year >= 2012) %>%
  select(muni_code, year, qtr, period_raw, dwellings_permitted)

cat(sprintf("  Observations: %d\n", nrow(permits)))
cat(sprintf("  Municipalities: %d\n", n_distinct(permits$muni_code)))
cat(sprintf("  Quarters: %d (%s - %s)\n",
            n_distinct(permits$period_raw),
            min(permits$period_raw), max(permits$period_raw)))

# ==============================================================================
# Step 3: Construct GIS Treatment Variables
# ==============================================================================
cat("\n=== Step 3: Construct GIS Treatment Variables ===\n")

# Load GIS data
cat("  Loading municipality boundaries...\n")
muni_raw <- st_read("../data/raw/municipality_boundaries.gpkg", quiet = TRUE)

cat("  Loading Natura 2000 sites...\n")
n2000_sf <- st_read("../data/raw/natura2000_nl.gpkg", quiet = TRUE)

# Ensure same CRS (EPSG:28992 RD New for Netherlands)
muni_raw <- st_transform(muni_raw, 28992)
n2000_sf <- st_transform(n2000_sf, 28992)

# Some municipalities have separate land and water polygons (water="JA").
# Dissolve all polygons per municipality to get one feature per code.
cat("  Dissolving municipality polygons (land + water)...\n")

# Preserve attributes from the land (non-water) rows
muni_attrs <- muni_raw %>%
  st_drop_geometry() %>%
  filter(water != "JA") %>%
  select(gemeentecode, gemeentenaam, aantalInwoners, woningvoorraad,
         gemiddeldeWoningwaarde)

# Dissolve geometries by gemeentecode using st_union via summarise
# sf's summarise method automatically unions geometries
muni_sf <- muni_raw %>%
  select(gemeentecode) %>%
  group_by(gemeentecode) %>%
  summarise(.groups = "drop") %>%
  left_join(muni_attrs, by = "gemeentecode")

cat(sprintf("  Municipalities (after dissolve): %d\n", nrow(muni_sf)))
cat(sprintf("  Natura 2000 sites: %d\n", nrow(n2000_sf)))

# --- 3a: Calculate Natura 2000 area share per municipality ---
cat("  Computing Natura 2000 area intersections...\n")

# Make geometries valid
muni_sf <- st_make_valid(muni_sf)
n2000_sf <- st_make_valid(n2000_sf)

# Dissolve all Natura 2000 into single multipolygon (avoids double-counting overlaps)
n2000_union <- st_union(n2000_sf)

# Intersection with municipalities
intersection <- st_intersection(muni_sf, n2000_union)
intersection$n2000_area_m2 <- as.numeric(st_area(intersection))

# Aggregate by municipality code
n2000_by_muni <- intersection %>%
  st_drop_geometry() %>%
  group_by(gemeentecode) %>%
  summarize(n2000_area_m2 = sum(n2000_area_m2), .groups = "drop")

# Municipality areas (full area including water, consistent with boundaries)
muni_sf$muni_area_m2 <- as.numeric(st_area(muni_sf))

# Merge
treatment_sf <- muni_sf %>%
  left_join(n2000_by_muni, by = "gemeentecode") %>%
  mutate(
    n2000_area_m2 = ifelse(is.na(n2000_area_m2), 0, n2000_area_m2),
    n2000_share = n2000_area_m2 / muni_area_m2
  )

# Sanity check: n2000_share should be in [0, 1]
if (any(treatment_sf$n2000_share > 1.01, na.rm = TRUE)) {
  cat(sprintf("  WARNING: %d municipalities have n2000_share > 1.0, capping at 1.0\n",
              sum(treatment_sf$n2000_share > 1.01, na.rm = TRUE)))
  treatment_sf$n2000_share <- pmin(treatment_sf$n2000_share, 1.0)
}

cat(sprintf("  Municipalities with any N2000 area: %d\n",
            sum(treatment_sf$n2000_share > 0)))

# --- 3b: Distance from centroid to nearest Natura 2000 boundary ---
cat("  Computing distances to nearest Natura 2000 site...\n")

centroids <- st_centroid(muni_sf)

# Compute distance from each centroid to nearest N2000 polygon
dist_to_n2000 <- st_distance(centroids, n2000_sf)
min_dist_m <- apply(dist_to_n2000, 1, min)

treatment_sf$dist_n2000_km <- as.numeric(min_dist_m) / 1000

# --- 3c: Binary and categorical treatment variables ---
cat("  Constructing treatment indicators...\n")

# Among municipalities WITH any N2000 presence, identify high-exposure
n2000_positive <- treatment_sf$n2000_share[treatment_sf$n2000_share > 0]
median_positive <- median(n2000_positive)

treatment_sf <- treatment_sf %>%
  mutate(
    n2000_high = n2000_share > median_positive,
    n2000_any = n2000_share > 0,
    n2000_near = dist_n2000_km < 5,
    n2000_tertile = ntile(n2000_share, 3)
  )

# Summary
cat(sprintf("\n  Treatment variable summary:\n"))
cat(sprintf("    N2000 share: mean=%.3f, sd=%.3f, median=%.3f\n",
            mean(treatment_sf$n2000_share), sd(treatment_sf$n2000_share),
            median(treatment_sf$n2000_share)))
cat(sprintf("    Median (among positive): %.3f\n", median_positive))
cat(sprintf("    N2000 high: %d municipalities\n", sum(treatment_sf$n2000_high)))
cat(sprintf("    N2000 any: %d municipalities\n", sum(treatment_sf$n2000_any)))
cat(sprintf("    N2000 near (<5km): %d municipalities\n", sum(treatment_sf$n2000_near)))
cat(sprintf("    Distance to N2000: mean=%.1f km, min=%.1f km, max=%.1f km\n",
            mean(treatment_sf$dist_n2000_km),
            min(treatment_sf$dist_n2000_km),
            max(treatment_sf$dist_n2000_km)))

# Quantile summary of n2000_share
qs <- quantile(treatment_sf$n2000_share, probs = c(0, 0.25, 0.50, 0.75, 1.0))
cat(sprintf("    N2000 share quantiles: p0=%.3f, p25=%.3f, p50=%.3f, p75=%.3f, p100=%.3f\n",
            qs[1], qs[2], qs[3], qs[4], qs[5]))

# Save treatment variables (cross-section, with geometry for maps)
treatment_vars <- treatment_sf %>%
  select(gemeentecode, gemeentenaam, muni_area_m2, n2000_area_m2,
         n2000_share, dist_n2000_km, n2000_high, n2000_any, n2000_near,
         n2000_tertile, aantalInwoners, woningvoorraad, gemiddeldeWoningwaarde)

# Save with geometry (for maps)
st_write(treatment_vars, "../data/processed/treatment_vars_geo.gpkg",
         delete_dsn = TRUE, quiet = TRUE)

# Save without geometry (for merging)
treatment_vars_df <- treatment_vars %>%
  st_drop_geometry() %>%
  rename(muni_code = gemeentecode)

saveRDS(treatment_vars_df, "../data/processed/treatment_vars.rds")
cat("  Saved: treatment_vars.rds + treatment_vars_geo.gpkg\n")

# ==============================================================================
# Step 4: Merge Everything — Price Panel
# ==============================================================================
cat("\n=== Step 4: Merge Panels ===\n")

# --- 4a: Price panel (municipality x year) ---
cat("  Building price panel...\n")

panel_prices <- prices %>%
  inner_join(treatment_vars_df, by = "muni_code") %>%
  mutate(
    post = as.integer(year >= 2019),
    # Event-time dummies (relative to 2019)
    rel_year = year - 2019,
    # Continuous treatment intensity x post
    treat_intensity = n2000_share * post,
    # Binary treatment x post
    treat_high = as.integer(n2000_high) * post,
    treat_any = as.integer(n2000_any) * post,
    treat_near = as.integer(n2000_near) * post
  )

cat(sprintf("  Panel prices: %d obs, %d municipalities, %d years\n",
            nrow(panel_prices), n_distinct(panel_prices$muni_code),
            n_distinct(panel_prices$year)))

# Check balance: how many munis observed in all years?
year_counts <- panel_prices %>%
  group_by(muni_code) %>%
  summarize(n_years = n_distinct(year), .groups = "drop")

cat(sprintf("  Municipalities with all %d years: %d\n",
            n_distinct(panel_prices$year),
            sum(year_counts$n_years == n_distinct(panel_prices$year))))

saveRDS(panel_prices, "../data/processed/panel_prices.rds")
cat("  Saved: panel_prices.rds\n")

# --- 4b: Permits panel (municipality x quarter) ---
cat("  Building permits panel...\n")

panel_permits <- permits %>%
  inner_join(treatment_vars_df, by = "muni_code") %>%
  mutate(
    post = as.integer(year > 2019 | (year == 2019 & qtr >= 2)),
    # Create year-quarter date for time FE
    yq = paste0(year, "Q", qtr),
    # Continuous treatment intensity x post
    treat_intensity = n2000_share * post,
    treat_high = as.integer(n2000_high) * post,
    treat_any = as.integer(n2000_any) * post,
    treat_near = as.integer(n2000_near) * post
  )

cat(sprintf("  Panel permits: %d obs, %d municipalities, %d quarters\n",
            nrow(panel_permits), n_distinct(panel_permits$muni_code),
            n_distinct(panel_permits$yq)))

saveRDS(panel_permits, "../data/processed/panel_permits.rds")
cat("  Saved: panel_permits.rds\n")

# --- 4c: National-level panel (for augmented SCM, backward compatibility) ---
cat("  Building national panel...\n")

fred_hpi <- readRDS("../data/raw/fred_hpi_all_countries.rds")

treatment_date <- ymd("2019-04-01")

# Analysis sample: 2010-2023
hpi_long <- fred_hpi %>%
  filter(date >= ymd("2010-01-01"), date <= ymd("2023-10-01")) %>%
  mutate(
    post = date >= treatment_date,
    treated = country == "Netherlands"
  )

# Time index
time_periods <- hpi_long %>%
  select(date) %>%
  distinct() %>%
  arrange(date) %>%
  mutate(time_id = row_number())

hpi_long <- hpi_long %>%
  left_join(time_periods, by = "date")

treatment_time_id <- time_periods %>%
  filter(date == treatment_date) %>%
  pull(time_id)

hpi_long <- hpi_long %>%
  mutate(rel_time = time_id - treatment_time_id)

# Normalize to 2010Q1 = 100
base_vals <- hpi_long %>%
  filter(date == ymd("2010-01-01")) %>%
  select(country, base_hpi = hpi)

hpi_long <- hpi_long %>%
  left_join(base_vals, by = "country") %>%
  mutate(hpi_norm = (hpi / base_hpi) * 100)

# Complete countries
complete_countries <- hpi_long %>%
  filter(!post) %>%
  group_by(country) %>%
  summarize(n_miss = sum(is.na(hpi_norm)), .groups = "drop") %>%
  filter(n_miss == 0) %>%
  pull(country)

analysis_data <- hpi_long %>% filter(country %in% complete_countries)

# Wide format for synthetic control
synth_wide <- analysis_data %>%
  select(country, time_id, hpi_norm) %>%
  pivot_wider(names_from = country, values_from = hpi_norm) %>%
  arrange(time_id) %>%
  left_join(time_periods, by = "time_id")

# Parameters (backward compatible with scripts 03-06)
donor_countries <- setdiff(complete_countries, "Netherlands")
params <- list(
  treatment_date = treatment_date,
  treatment_time_id = treatment_time_id,
  treated_country = "Netherlands",
  donor_countries = donor_countries,
  n_pre_periods = treatment_time_id - 1,
  n_post_periods = max(analysis_data$time_id) - treatment_time_id + 1
)

saveRDS(analysis_data, "../data/processed/analysis_data.rds")
saveRDS(synth_wide, "../data/processed/synth_wide.rds")
saveRDS(time_periods, "../data/processed/time_periods.rds")
saveRDS(params, "../data/processed/analysis_params.rds")
saveRDS(hpi_long, "../data/processed/hpi_long.rds")

hpi_wide <- analysis_data %>%
  select(country, date, year, quarter, hpi) %>%
  pivot_wider(names_from = country, values_from = hpi) %>%
  arrange(date) %>%
  mutate(post = date >= treatment_date, time_id = row_number())

saveRDS(hpi_wide, "../data/processed/hpi_wide.rds")

# National panel for augmented SCM
panel_national <- analysis_data %>%
  select(country, date, year, quarter, time_id, hpi, hpi_norm, post, treated, rel_time)

saveRDS(panel_national, "../data/processed/panel_national.rds")
cat(sprintf("  National panel: %d obs, %d countries, %d quarters\n",
            nrow(panel_national), n_distinct(panel_national$country),
            n_distinct(panel_national$date)))
cat("  Saved: analysis_data.rds, synth_wide.rds, time_periods.rds, analysis_params.rds,\n")
cat("         hpi_long.rds, hpi_wide.rds, panel_national.rds\n")

# ==============================================================================
# Step 5: Summary Statistics
# ==============================================================================
cat("\n=== Step 5: Summary Statistics ===\n")

cat("\n--- Municipality Price Panel ---\n")
cat(sprintf("  N municipalities: %d\n", n_distinct(panel_prices$muni_code)))
cat(sprintf("  N years: %d (%d-%d)\n",
            n_distinct(panel_prices$year), min(panel_prices$year), max(panel_prices$year)))
cat(sprintf("  N observations: %d\n", nrow(panel_prices)))

cat("\n--- Treatment Variable Distribution ---\n")
tv <- treatment_vars_df
cat(sprintf("  N2000 share:  mean=%.4f  sd=%.4f  p25=%.4f  p50=%.4f  p75=%.4f\n",
            mean(tv$n2000_share), sd(tv$n2000_share),
            quantile(tv$n2000_share, 0.25),
            quantile(tv$n2000_share, 0.50),
            quantile(tv$n2000_share, 0.75)))
cat(sprintf("  Distance (km): mean=%.2f  sd=%.2f  p25=%.2f  p50=%.2f  p75=%.2f\n",
            mean(tv$dist_n2000_km), sd(tv$dist_n2000_km),
            quantile(tv$dist_n2000_km, 0.25),
            quantile(tv$dist_n2000_km, 0.50),
            quantile(tv$dist_n2000_km, 0.75)))

cat("\n--- Pre/Post Price Means by Treatment Tertile ---\n")
price_by_tertile <- panel_prices %>%
  group_by(n2000_tertile, post) %>%
  summarize(
    mean_price = mean(price, na.rm = TRUE),
    mean_log_price = mean(log_price, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  arrange(n2000_tertile, post)

print(as.data.frame(price_by_tertile))

cat("\n--- Building Permits by Treatment ---\n")
permits_by_treat <- panel_permits %>%
  group_by(n2000_high, post) %>%
  summarize(
    mean_permits = mean(dwellings_permitted, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  )
print(as.data.frame(permits_by_treat))

# Save summary stats for tables
summary_stats <- list(
  n_municipalities = n_distinct(panel_prices$muni_code),
  n_years = n_distinct(panel_prices$year),
  n_obs_prices = nrow(panel_prices),
  n_obs_permits = nrow(panel_permits),
  treatment_distribution = summary(tv$n2000_share),
  price_by_tertile = price_by_tertile,
  permits_by_treatment = permits_by_treat
)
saveRDS(summary_stats, "../data/processed/summary_stats.rds")

# ==============================================================================
# File Summary
# ==============================================================================
cat("\n=== Processed Files ===\n")
data_files <- list.files("../data/processed", full.names = TRUE)
for (f in data_files) {
  info <- file.info(f)
  cat(sprintf("  %s: %.1f KB\n", basename(f), info$size / 1024))
}

# ==============================================================================
# Step 6: Create Province Lookup Table
# ==============================================================================
cat("\n=== Step 6: Create Province Lookup ===\n")

# Download municipality-to-province mapping from CBS regional classifications
# Table 84929NED: Regionale indelingen
region_data <- cbs_get_data("84929NED")

province_lookup <- region_data %>%
  transmute(
    muni_code = trimws(RegioS),
    province = trimws(Naam_27)
  ) %>%
  filter(grepl("^GM", muni_code), province != "")

# Add recently merged municipalities not yet in CBS classification table
new_munis <- data.frame(
  muni_code = c("GM1980", "GM1982", "GM1991", "GM1992"),
  province  = c("Noord-Holland", "Noord-Brabant", "Noord-Brabant", "Zuid-Holland"),
  stringsAsFactors = FALSE
)
province_lookup <- bind_rows(province_lookup, new_munis %>% filter(!muni_code %in% province_lookup$muni_code))

cat(sprintf("  Province lookup: %d municipalities, %d provinces\n",
            nrow(province_lookup), n_distinct(province_lookup$province)))
cat(sprintf("  Provinces: %s\n", paste(sort(unique(province_lookup$province)), collapse = ", ")))

# Check coverage: how many of our panel municipalities have a province match?
panel_munis <- unique(panel_prices$muni_code)
matched <- sum(panel_munis %in% province_lookup$muni_code)
cat(sprintf("  Panel municipalities matched: %d / %d\n", matched, length(panel_munis)))

if (matched < length(panel_munis)) {
  unmatched <- panel_munis[!panel_munis %in% province_lookup$muni_code]
  cat(sprintf("  WARNING: Unmatched: %s\n", paste(unmatched, collapse = ", ")))
}

saveRDS(province_lookup, "../data/processed/province_lookup.rds")
cat("  Saved: province_lookup.rds\n")

cat("\n=== Data cleaning complete ===\n")
