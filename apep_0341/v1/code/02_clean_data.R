## ============================================================================
## 02_clean_data.R — Detect rate changes, classify treatment, build DiD panel
## apep_0328: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 1. Load panels ----
panel_pc   <- readRDS(file.path(DATA, "panel_personal_care.rds"))
panel_em   <- readRDS(file.path(DATA, "panel_em_placebo.rds"))
panel_hcbs <- readRDS(file.path(DATA, "panel_hcbs_all.rds"))

## ---- 2. Detect rate changes from payment data ----
## For each state, identify the first month with a sustained ≥15% jump in
## average paid per claim for personal care codes. A rate change is "sustained"
## if avg_paid_per_claim remains elevated for ≥3 months after the jump.
cat("Detecting rate changes from payment data...\n")

detect_rate_change <- function(dt, threshold = 0.15, sustain_months = 3) {
  states <- unique(dt$state)
  results <- list()

  for (s in states) {
    sd <- dt[state == s][order(month_date)]

    ## Skip states with too few observations
    if (nrow(sd) < 12) next

    ## Compute rolling 3-month median to smooth noise
    sd[, rate_smooth := frollmean(avg_paid_per_claim, n = 3, align = "right", fill = NA)]

    ## Compute month-over-month change in smoothed rate
    sd[, rate_pct_change := (rate_smooth - shift(rate_smooth, 1)) / shift(rate_smooth, 1)]

    ## Find months with jump >= threshold
    jumps <- sd[!is.na(rate_pct_change) & rate_pct_change >= threshold]

    if (nrow(jumps) == 0) {
      results[[s]] <- data.table(state = s, treat_date = as.Date(NA),
                                 rate_before = NA_real_, rate_after = NA_real_,
                                 pct_change = NA_real_)
      next
    }

    ## Take the FIRST qualifying jump
    first_jump <- jumps[1]
    jump_date  <- first_jump$month_date

    ## Verify sustained: check that avg rate stays elevated for sustain_months
    post <- sd[month_date >= jump_date][1:min(sustain_months + 1, .N)]
    pre_rate <- sd[month_date < jump_date, mean(avg_paid_per_claim, na.rm = TRUE)]

    if (nrow(post) >= sustain_months) {
      post_rate <- mean(post$avg_paid_per_claim, na.rm = TRUE)
      sustained <- (post_rate / pre_rate - 1) >= threshold * 0.5
    } else {
      sustained <- FALSE
    }

    if (sustained) {
      rate_before <- sd[month_date < jump_date &
                        month_date >= jump_date - months(6),
                        mean(avg_paid_per_claim, na.rm = TRUE)]
      rate_after  <- sd[month_date >= jump_date &
                        month_date <= jump_date + months(6),
                        mean(avg_paid_per_claim, na.rm = TRUE)]
      results[[s]] <- data.table(
        state = s,
        treat_date = jump_date,
        rate_before = rate_before,
        rate_after  = rate_after,
        pct_change  = (rate_after / rate_before) - 1
      )
    } else {
      results[[s]] <- data.table(state = s, treat_date = as.Date(NA),
                                 rate_before = NA_real_, rate_after = NA_real_,
                                 pct_change = NA_real_)
    }
  }

  rbindlist(results)
}

rate_changes <- detect_rate_change(panel_pc, threshold = 0.15, sustain_months = 3)

## Post-filter: require the 6-month pre/post average change to also meet threshold
## This ensures internal consistency between detection and reported magnitudes
rate_changes[!is.na(treat_date) & (is.nan(pct_change) | pct_change < 0.15),
             `:=`(treat_date = as.Date(NA),
                  rate_before = NA_real_,
                  rate_after = NA_real_,
                  pct_change = NA_real_)]

## Classify states
rate_changes[, treated := !is.na(treat_date)]

n_treated <- sum(rate_changes$treated)
n_control <- sum(!rate_changes$treated)
cat(sprintf("Rate change detection: %d treated, %d never-treated\n",
            n_treated, n_control))

## Print treatment details
cat("\n--- Treated states ---\n")
print(rate_changes[treated == TRUE][order(treat_date)],
      nrows = 50, topn = 50)

cat("\n--- Never-treated states ---\n")
print(rate_changes[treated == FALSE], nrows = 50, topn = 50)

## ---- 3. Build DiD panel ----
## Create time variable (months since Jan 2018) for Callaway-Sant'Anna
## CS-DiD needs: panel id (state), time period (integer), first_treat (integer)

all_months <- sort(unique(panel_pc$month_date))
month_map  <- data.table(month_date = all_months, time_period = seq_along(all_months))

## Merge time periods
panel_pc <- merge(panel_pc, month_map, by = "month_date")

## Merge treatment info
panel_pc <- merge(panel_pc, rate_changes[, .(state, treat_date, pct_change, treated)],
                  by = "state", all.x = TRUE)

## Create first_treat for CS-DiD (0 = never-treated)
panel_pc <- merge(panel_pc,
                  month_map[, .(treat_date = month_date, first_treat = time_period)],
                  by = "treat_date", all.x = TRUE)
panel_pc[is.na(first_treat), first_treat := 0]

## State numeric ID
state_ids <- data.table(state = sort(unique(panel_pc$state)),
                        state_id = seq_along(sort(unique(panel_pc$state))))
panel_pc <- merge(panel_pc, state_ids, by = "state")

## Log outcomes
panel_pc[, log_providers := log(n_providers + 1)]
panel_pc[, log_claims    := log(total_claims + 1)]
panel_pc[, log_benes     := log(total_benes + 1)]
panel_pc[, log_paid      := log(total_paid + 1)]
panel_pc[, log_individual := log(n_individual + 1)]
panel_pc[, log_org        := log(n_org + 1)]
panel_pc[, log_sole_prop  := log(n_sole_prop + 1)]
panel_pc[, benes_per_provider := total_benes / n_providers]
panel_pc[, claims_per_provider := total_claims / n_providers]

setorder(panel_pc, state, time_period)

## ---- 4. Also build HCBS and placebo panels with treatment info ----
panel_hcbs <- merge(panel_hcbs, month_map, by = "month_date")
panel_hcbs <- merge(panel_hcbs, rate_changes[, .(state, treat_date, treated)],
                    by = "state", all.x = TRUE)
panel_hcbs <- merge(panel_hcbs,
                    month_map[, .(treat_date = month_date, first_treat = time_period)],
                    by = "treat_date", all.x = TRUE)
panel_hcbs[is.na(first_treat), first_treat := 0]
panel_hcbs <- merge(panel_hcbs, state_ids, by = "state")
panel_hcbs[, log_providers := log(n_providers + 1)]
panel_hcbs[, log_claims    := log(total_claims + 1)]
panel_hcbs[, log_benes     := log(total_benes + 1)]
setorder(panel_hcbs, state, time_period)

panel_em <- merge(panel_em, month_map, by = "month_date")
panel_em <- merge(panel_em, rate_changes[, .(state, treat_date, treated)],
                  by = "state", all.x = TRUE)
panel_em <- merge(panel_em,
                  month_map[, .(treat_date = month_date, first_treat = time_period)],
                  by = "treat_date", all.x = TRUE)
panel_em[is.na(first_treat), first_treat := 0]
panel_em <- merge(panel_em, state_ids, by = "state")
panel_em[, log_providers := log(n_providers + 1)]
panel_em[, log_claims    := log(total_claims + 1)]
panel_em[, log_benes     := log(total_benes + 1)]
setorder(panel_em, state, time_period)

## ---- 5. Fetch Census ACS population data for controls ----
cat("Fetching Census ACS state population data...\n")
api_key <- Sys.getenv("CENSUS_API_KEY")

pop_list <- list()
for (yr in 2018:2023) {
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
    yr, api_key
  )
  resp <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
  if (!is.null(resp)) {
    df <- as.data.table(resp[-1, , drop = FALSE])
    setnames(df, c("pop", "state_name", "state_fips"))
    df[, year := yr]
    df[, pop := as.numeric(pop)]
    pop_list[[as.character(yr)]] <- df
  }
}
pop_dt <- rbindlist(pop_list)

## Map FIPS to state abbreviations
fips_map <- data.table(
  state_fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,
                                  21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
                                  36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,
                                  53,54,55,56)),
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID",
            "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO",
            "MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA",
            "RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
)

pop_dt <- merge(pop_dt, fips_map, by = "state_fips")
pop_dt <- pop_dt[, .(state, year, pop)]

## ---- 6. Fetch FRED unemployment data ----
cat("Fetching state unemployment rates from FRED...\n")
fred_key <- Sys.getenv("FRED_API_KEY")

unemp_dt <- data.table()
if (nchar(fred_key) > 0) {
  ## State unemployment series IDs (LAUS program: STURxx)
  unemp_series <- data.table(
    state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID",
              "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO",
              "MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA",
              "RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
    series_id = paste0(c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA",
                          "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA",
                          "MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY",
                          "NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX",
                          "UT","VT","VA","WA","WV","WI","WY"), "UR")
  )

  unemp_list <- list()
  for (i in seq_len(nrow(unemp_series))) {
    sid <- unemp_series$series_id[i]
    st  <- unemp_series$state[i]
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2018-01-01&observation_end=2024-12-31",
      sid, fred_key
    )
    resp <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
    if (!is.null(resp) && !is.null(resp$observations)) {
      obs <- as.data.table(resp$observations)
      if (nrow(obs) > 0 && "date" %in% names(obs) && "value" %in% names(obs)) {
        obs[, `:=`(state = st,
                   month_date = as.Date(date),
                   unemp_rate = suppressWarnings(as.numeric(value)))]
        obs <- obs[!is.na(unemp_rate)]
        if (nrow(obs) > 0) unemp_list[[st]] <- obs[, .(state, month_date, unemp_rate)]
      }
    }
    Sys.sleep(0.15)
  }
  if (length(unemp_list) > 0) unemp_dt <- rbindlist(unemp_list)
}

if (nrow(unemp_dt) == 0) {
  cat("WARNING: FRED data unavailable. Proceeding without unemployment controls.\n")
}

## ---- 7. Merge controls into main panel ----
if (nrow(pop_dt) > 0) {
  panel_pc <- merge(panel_pc, pop_dt, by = c("state", "year"), all.x = TRUE)
  panel_pc[, providers_per_100k := n_providers / (pop / 1e5)]
  panel_pc[, benes_per_100k     := total_benes / (pop / 1e5)]
} else {
  panel_pc[, pop := NA_real_]
  panel_pc[, providers_per_100k := NA_real_]
  panel_pc[, benes_per_100k := NA_real_]
}

if (nrow(unemp_dt) > 0) {
  panel_pc <- merge(panel_pc, unemp_dt, by = c("state", "month_date"), all.x = TRUE)
} else {
  panel_pc[, unemp_rate := NA_real_]
}

## ---- 8. Save ----
saveRDS(panel_pc,      file.path(DATA, "did_panel_pc.rds"))
saveRDS(panel_hcbs,    file.path(DATA, "did_panel_hcbs.rds"))
saveRDS(panel_em,      file.path(DATA, "did_panel_em.rds"))
saveRDS(rate_changes,  file.path(DATA, "rate_changes.rds"))
saveRDS(month_map,     file.path(DATA, "month_map.rds"))
saveRDS(pop_dt,        file.path(DATA, "population.rds"))
saveRDS(unemp_dt,      file.path(DATA, "unemployment.rds"))

cat("\n=== Data cleaning complete ===\n")
cat(sprintf("DiD panel (personal care): %d obs, %d states, %d treated\n",
            nrow(panel_pc), uniqueN(panel_pc$state), n_treated))
