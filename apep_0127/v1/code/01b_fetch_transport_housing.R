# ============================================================================
# 01b_fetch_transport_housing.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Additional data: Car ownership and housing tenure
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. KOLADA API: Car ownership and housing tenure
# ============================================================================

cat("\n=== Fetching car ownership and housing data ===\n")

kolada_base <- "https://api.kolada.se/v2"

# New KPIs: car ownership and housing tenure
new_kpi_codes <- c(
  "N07935",  # Cars per 1000 inhabitants
  "N07936",  # Gasoline cars per 1000
  "N07937",  # Diesel cars per 1000
  "N07938",  # Electric cars per 1000
  "N07940",  # Plug-in hybrid cars per 1000
  "N07956",  # Rental housing share (%)
  "N07957",  # Cooperative housing share (%)
  "N07958"   # Owner-occupied share (%)
)

# Years to fetch
years <- 2010:2024

# Function to fetch Kolada data
fetch_kolada <- function(kpi, years) {
  year_str <- paste(years, collapse = ",")
  url <- paste0(kolada_base, "/data/kpi/", kpi, "/year/", year_str)

  cat("  Fetching", kpi, "...")

  tryCatch({
    resp <- request(url) |>
      req_headers(Accept = "application/json") |>
      req_perform()

    data <- resp_body_json(resp)

    if (length(data$values) == 0) {
      cat(" no data\n")
      return(NULL)
    }

    # Parse response
    df <- map_dfr(data$values, function(x) {
      tibble(
        municipality_id = x$municipality,
        year = x$period,
        kpi = kpi,
        value = x$values[[1]]$value %||% NA_real_,
        gender = x$values[[1]]$gender %||% "T"
      )
    })

    cat(" done (", nrow(df), " rows)\n")
    return(df)

  }, error = function(e) {
    cat(" ERROR:", e$message, "\n")
    return(NULL)
  })
}

# Fetch all new KPIs
new_data <- map_dfr(new_kpi_codes, ~fetch_kolada(.x, years))

cat("\nTotal rows fetched:", nrow(new_data), "\n")

# Summary by KPI and year
cat("\nData availability:\n")
new_data |>
  group_by(kpi, year) |>
  summarise(n = n(), .groups = "drop") |>
  pivot_wider(names_from = year, values_from = n, values_fill = 0) |>
  print(n = 20)

# Save long format
write_csv(new_data, "../data/raw/kolada_transport_housing_long.csv")

# Pivot to wide format (keep only T = total, or any if no T)
new_wide <- new_data |>
  group_by(municipality_id, year, kpi) |>
  summarise(
    value = value[gender == "T"][1] %||% value[1],
    .groups = "drop"
  ) |>
  pivot_wider(names_from = kpi, values_from = value)

# Rename columns
new_wide <- new_wide |>
  rename_with(~case_when(
    .x == "N07935" ~ "cars_per_1000",
    .x == "N07936" ~ "gasoline_cars_per_1000",
    .x == "N07937" ~ "diesel_cars_per_1000",
    .x == "N07938" ~ "electric_cars_per_1000",
    .x == "N07940" ~ "hybrid_cars_per_1000",
    .x == "N07956" ~ "rental_housing_pct",
    .x == "N07957" ~ "coop_housing_pct",
    .x == "N07958" ~ "owner_housing_pct",
    TRUE ~ .x
  ))

write_csv(new_wide, "../data/raw/kolada_transport_housing_wide.csv")

cat("\nSaved transport and housing data:\n")
cat("  Long format:", nrow(new_data), "rows\n")
cat("  Wide format:", nrow(new_wide), "rows\n")

# Check what years have good coverage
cat("\nYears with good data coverage (>200 municipalities):\n")
new_wide |>
  group_by(year) |>
  summarise(
    n_cars = sum(!is.na(cars_per_1000)),
    n_rental = sum(!is.na(rental_housing_pct)),
    .groups = "drop"
  ) |>
  filter(n_cars > 200 | n_rental > 200) |>
  print()

cat("\nData fetch complete.\n")
