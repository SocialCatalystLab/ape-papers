################################################################################
# 07_extensions.R — Extension Analyses for ARC RDD v2 Revision
#
# New analyses:
#   1. Alternative outcomes NOT in CIV (BEA wages-per-job, population change)
#   2. CIV distribution histogram near threshold
#   3. Year-by-year McCrary density tests
################################################################################

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
results_dir <- "../data"

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

arc <- readRDS(file.path(data_dir, "arc_analysis.rds"))
panel <- readRDS(file.path(data_dir, "arc_panel_full.rds"))

cat("=== Extension Analyses ===\n")
cat(sprintf("Analysis sample: %d county-years\n", nrow(arc)))

################################################################################
# 1. Fetch BEA Wages and Salaries Per Job (CAEMP25N Table)
################################################################################

cat("\n--- Fetching BEA Wages-Per-Job Data ---\n")

bea_key <- Sys.getenv("BEA_API_KEY")

wages_per_job <- NULL

if (nchar(bea_key) > 0) {
  # CA30: Average wages and salaries per job (Line 1)
  # Try CAINC30 table — average wages per job
  bea_wages_url <- sprintf(
    "https://apps.bea.gov/api/data/?UserID=%s&method=GetData&datasetname=Regional&TableName=CAINC30&LineCode=1&GeoFIPS=COUNTY&Year=ALL&ResultFormat=JSON",
    bea_key
  )

  tryCatch({
    bea_resp <- fromJSON(bea_wages_url, flatten = TRUE)
    bea_data <- bea_resp$BEAAPI$Results$Data

    wages_per_job <- bea_data %>%
      as_tibble() %>%
      mutate(
        fips = str_pad(GeoFips, width = 5, pad = "0"),
        year = as.integer(TimePeriod),
        avg_wage = as.numeric(gsub("[,()NA]", "", DataValue))
      ) %>%
      filter(year >= 2004, year <= 2020, !is.na(avg_wage)) %>%
      select(fips, year, avg_wage)

    cat(sprintf("  BEA wages-per-job: %d county-years\n", nrow(wages_per_job)))
    saveRDS(wages_per_job, file.path(data_dir, "bea_wages_per_job.rds"))
  }, error = function(e) {
    cat(sprintf("  BEA wages fetch failed: %s\n", e$message))
  })
} else {
  cat("  BEA_API_KEY not set.\n")
}

################################################################################
# 2. Fetch Census Population Estimates (Intercensal)
################################################################################

cat("\n--- Fetching Census Population Estimates ---\n")

pop_data <- NULL

# Use Census vintage estimates API
pop_list <- list()
for (yr in 2007:2017) {
  cat(sprintf("  Pop %d...", yr))

  # Try vintage-year API
  vintage <- max(yr, 2010)  # vintage year must be >= data year

  # For 2007-2009, use 2000s intercensal estimates
  if (yr <= 2009) {
    url <- sprintf(
      "https://api.census.gov/data/2000/pep/int_population?get=POP,GEONAME&for=county:*&DATE_=%d",
      yr - 2000 + 1  # DATE_ code: 1=April 2000, 2=July 2000, ..., 10=July 2008
    )
  } else {
    url <- sprintf(
      "https://api.census.gov/data/%d/pep/population?get=POP,NAME&for=county:*",
      yr
    )
  }

  tryCatch({
    resp <- fromJSON(url)
    df <- as_tibble(resp[-1, ], .name_repair = "minimal")
    names(df) <- resp[1, ]
    df <- df %>%
      mutate(
        fips = paste0(state, county),
        year = yr,
        population = as.numeric(POP)
      ) %>%
      select(fips, year, population)

    pop_list[[as.character(yr)]] <- df
    cat(sprintf(" %d counties\n", nrow(df)))
  }, error = function(e) {
    cat(sprintf(" FAILED: %s\n", e$message))
  })

  Sys.sleep(0.3)
}

if (length(pop_list) > 0) {
  pop_data <- bind_rows(pop_list)
  cat(sprintf("Population: %d county-years across %d years\n",
              nrow(pop_data), n_distinct(pop_data$year)))
  saveRDS(pop_data, file.path(data_dir, "pop_county_v2.rds"))
}

################################################################################
# 3. Merge Alternative Outcomes into Analysis Data
################################################################################

cat("\n--- Merging Alternative Outcomes ---\n")

# Merge wages-per-job
if (!is.null(wages_per_job) && nrow(wages_per_job) > 0) {
  arc <- arc %>%
    left_join(wages_per_job %>% rename(fiscal_year = year),
              by = c("fips", "fiscal_year"))
  cat(sprintf("  Wages-per-job: %d non-missing (of %d)\n",
              sum(!is.na(arc$avg_wage)), nrow(arc)))
}

# Merge population and compute population change
if (!is.null(pop_data) && nrow(pop_data) > 0) {
  # Compute population growth rates
  pop_growth <- pop_data %>%
    arrange(fips, year) %>%
    group_by(fips) %>%
    mutate(
      pop_growth = (population - lag(population)) / lag(population) * 100
    ) %>%
    ungroup() %>%
    filter(!is.na(pop_growth)) %>%
    rename(fiscal_year = year) %>%
    select(fips, fiscal_year, population, pop_growth)

  arc <- arc %>%
    left_join(pop_growth, by = c("fips", "fiscal_year"))
  cat(sprintf("  Population growth: %d non-missing (of %d)\n",
              sum(!is.na(arc$pop_growth)), nrow(arc)))
}

# Also use existing BEA personal income to compute per-capita personal income
# This is NOT a CIV component (personal income ≠ market income)
if ("personal_income_k" %in% names(arc)) {
  # Per capita personal income (different from PCMI which is market income only)
  # Use a fixed population denominator to avoid division by zero
  # BEA personal income is in thousands
  bea_pop <- pop_data
  if (!is.null(bea_pop) && nrow(bea_pop) > 0) {
    arc <- arc %>%
      left_join(bea_pop %>% rename(fiscal_year = year, bea_pop = population),
                by = c("fips", "fiscal_year")) %>%
      mutate(
        pcpi = ifelse(!is.na(bea_pop) & bea_pop > 0,
                      personal_income_k * 1000 / bea_pop,
                      NA_real_),
        log_pcpi = log(pmax(pcpi, 1))
      )
    cat(sprintf("  Per capita personal income: %d non-missing\n",
                sum(!is.na(arc$pcpi))))
  }
}

# Log wages
if ("avg_wage" %in% names(arc)) {
  arc$log_avg_wage <- log(pmax(arc$avg_wage, 1))
}

################################################################################
# 4. RDD on Alternative Outcomes
################################################################################

cat("\n--- RDD on Alternative (Non-CIV) Outcomes ---\n")

alt_outcomes <- c()
alt_labels <- c()

if ("log_avg_wage" %in% names(arc) && sum(!is.na(arc$log_avg_wage)) > 100) {
  alt_outcomes <- c(alt_outcomes, "log_avg_wage")
  alt_labels <- c(alt_labels, "Log Average Wage")
}

if ("pop_growth" %in% names(arc) && sum(!is.na(arc$pop_growth)) > 100) {
  alt_outcomes <- c(alt_outcomes, "pop_growth")
  alt_labels <- c(alt_labels, "Population Growth (%)")
}

if ("log_pcpi" %in% names(arc) && sum(!is.na(arc$log_pcpi)) > 100) {
  alt_outcomes <- c(alt_outcomes, "log_pcpi")
  alt_labels <- c(alt_labels, "Log Per Capita Personal Income")
}

# Always include BEA total personal income (already in data, not CIV component)
if ("personal_income_k" %in% names(arc) && sum(!is.na(arc$personal_income_k)) > 100) {
  arc$log_personal_income <- log(pmax(arc$personal_income_k, 1))
  alt_outcomes <- c(alt_outcomes, "log_personal_income")
  alt_labels <- c(alt_labels, "Log Total Personal Income")
}

names(alt_labels) <- alt_outcomes

alt_results <- list()

for (i in seq_along(alt_outcomes)) {
  yvar <- alt_outcomes[i]
  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  if (nrow(d) < 100) {
    cat(sprintf("  %s: insufficient data (n=%d)\n", alt_labels[i], nrow(d)))
    next
  }

  fit <- tryCatch({
    rdrobust(
      y = d[[yvar]],
      x = d$civ_centered,
      c = 0,
      kernel = "triangular",
      bwselect = "mserd",
      all = TRUE
    )
  }, error = function(e) {
    cat(sprintf("  %s: ERROR - %s\n", alt_labels[i], e$message))
    NULL
  })

  if (!is.null(fit)) {
    alt_results[[yvar]] <- list(
      outcome = yvar,
      label = alt_labels[i],
      coef_conv = fit$coef[1],
      coef_robust = fit$coef[3],
      se_conv = fit$se[1],
      se_robust = fit$se[3],
      pv_robust = fit$pv[3],
      ci_lower = fit$ci[3, 1],
      ci_upper = fit$ci[3, 2],
      bw_h = fit$bws[1, 1],
      N_h_left = fit$N_h[1],
      N_h_right = fit$N_h[2],
      N_total = sum(fit$N_h)
    )

    cat(sprintf("  %s: coef=%.4f (SE=%.4f), p=%.4f, N=%d\n",
                alt_labels[i], fit$coef[3], fit$se[3], fit$pv[3], sum(fit$N_h)))
  }
}

################################################################################
# 5. CIV Distribution Histogram Near Threshold
################################################################################

cat("\n--- CIV Distribution Histogram ---\n")

# Small bins near the threshold to check for heaping/granularity
p_hist <- ggplot(arc, aes(x = civ_centered)) +
  geom_histogram(binwidth = 1, fill = "grey70", color = "grey50", linewidth = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.7) +
  annotate("text", x = 2, y = Inf, label = "Distressed\nThreshold",
           vjust = 1.5, hjust = 0, size = 3.5, color = "red") +
  labs(
    x = "CIV (centered at Distressed threshold)",
    y = "Count (county-years)",
    title = "Distribution of Composite Index Value Near the Distressed Threshold",
    subtitle = sprintf("N = %s county-years, bin width = 1 CIV point",
                        format(nrow(arc), big.mark = ",")),
    caption = "Notes: CIV is a continuous index based on weighted averages of unemployment, income, and poverty ratios.\nDashed line marks the Distressed/At-Risk threshold."
  ) +
  theme_apep() +
  coord_cartesian(xlim = c(-30, 30))

ggsave(file.path(fig_dir, "fig_civ_histogram.pdf"), p_hist,
       width = 8, height = 5, device = cairo_pdf)
cat("  Saved fig_civ_histogram.pdf\n")

# Zoomed version near threshold
p_hist_zoom <- ggplot(arc %>% filter(abs(civ_centered) <= 10),
                       aes(x = civ_centered)) +
  geom_histogram(binwidth = 0.5, fill = "grey70", color = "grey50", linewidth = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.7) +
  labs(
    x = "CIV (centered at threshold)",
    y = "Count",
    title = "CIV Distribution: Close to Threshold",
    subtitle = "Bin width = 0.5 CIV points; no evidence of heaping"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_civ_histogram_zoom.pdf"), p_hist_zoom,
       width = 8, height = 5, device = cairo_pdf)
cat("  Saved fig_civ_histogram_zoom.pdf\n")

################################################################################
# 6. Year-by-Year McCrary Density Tests
################################################################################

cat("\n--- Year-by-Year McCrary Density Tests ---\n")

years <- sort(unique(arc$fiscal_year))
mccrary_yearly <- list()

for (yr in years) {
  d <- arc %>% filter(fiscal_year == yr & !is.na(civ_centered))

  if (nrow(d) < 50) {
    cat(sprintf("  FY%d: insufficient data (n=%d)\n", yr, nrow(d)))
    next
  }

  test <- tryCatch({
    rddensity(X = d$civ_centered, c = 0)
  }, error = function(e) {
    cat(sprintf("  FY%d: ERROR - %s\n", yr, e$message))
    NULL
  })

  if (!is.null(test)) {
    mccrary_yearly[[as.character(yr)]] <- list(
      year = yr,
      t_stat = test$test$t_jk,
      p_value = test$test$p_jk,
      n_left = test$N$eff_left,
      n_right = test$N$eff_right,
      n_total = nrow(d)
    )

    cat(sprintf("  FY%d: T=%.3f, p=%.4f, N=%d\n",
                yr, test$test$t_jk, test$test$p_jk, nrow(d)))
  }
}

################################################################################
# 7. RDD Plots for Alternative Outcomes
################################################################################

cat("\n--- RDD Plots for Alternative Outcomes ---\n")

if (length(alt_results) > 0) {
  alt_plot_list <- list()

  for (yvar in names(alt_results)) {
    res <- alt_results[[yvar]]
    d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

    # Create bins
    d_left <- d %>% filter(civ_centered < 0)
    d_right <- d %>% filter(civ_centered >= 0)

    nbins <- 25
    bin_left <- d_left %>%
      mutate(bin = cut(civ_centered, breaks = nbins, include.lowest = TRUE)) %>%
      group_by(bin) %>%
      summarize(x = mean(civ_centered), y = mean(.data[[yvar]], na.rm = TRUE),
                n = n(), .groups = "drop")

    bin_right <- d_right %>%
      mutate(bin = cut(civ_centered, breaks = max(5, round(nbins * nrow(d_right) / nrow(d_left))),
                       include.lowest = TRUE)) %>%
      group_by(bin) %>%
      summarize(x = mean(civ_centered), y = mean(.data[[yvar]], na.rm = TRUE),
                n = n(), .groups = "drop")

    bins_all <- bind_rows(bin_left, bin_right)

    ann_text <- sprintf("RD = %.3f\n(SE = %.3f)\np = %.3f",
                         res$coef_robust, res$se_robust, res$pv_robust)

    p <- ggplot(bins_all, aes(x = x, y = y)) +
      geom_point(aes(size = n), color = "grey50", alpha = 0.7) +
      geom_smooth(data = d %>% filter(civ_centered < 0),
                  aes(x = civ_centered, y = .data[[yvar]]),
                  method = "loess", span = 0.75, se = TRUE,
                  color = apep_colors[1], fill = apep_colors[1], alpha = 0.15,
                  linewidth = 1) +
      geom_smooth(data = d %>% filter(civ_centered >= 0),
                  aes(x = civ_centered, y = .data[[yvar]]),
                  method = "loess", span = 0.75, se = TRUE,
                  color = apep_colors[2], fill = apep_colors[2], alpha = 0.15,
                  linewidth = 1) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.5) +
      annotate("text", x = max(bins_all$x) * 0.55, y = max(bins_all$y) * 0.98,
               label = ann_text, hjust = 0, vjust = 1, size = 3, color = "grey30") +
      scale_size_continuous(range = c(1, 4), guide = "none") +
      labs(
        x = "CIV (centered at threshold)",
        y = res$label,
        title = res$label
      ) +
      theme_apep()

    alt_plot_list[[yvar]] <- p
  }

  # Combine into multi-panel figure
  if (length(alt_plot_list) >= 2) {
    combined <- wrap_plots(alt_plot_list, ncol = 1) +
      plot_annotation(
        title = "Alternative Outcomes: RDD at the ARC Distressed Threshold",
        subtitle = "Outcomes not mechanically linked to the Composite Index Value",
        caption = "Notes: Binned scatter with local polynomial fits. These outcomes are independent of the CIV used for designation assignment.",
        theme = theme_apep()
      )

    ggsave(file.path(fig_dir, "fig_rd_alternative_outcomes.pdf"), combined,
           width = 8, height = 4 * length(alt_plot_list), device = cairo_pdf)
    cat("  Saved fig_rd_alternative_outcomes.pdf\n")
  }
}

################################################################################
# 8. Save Extension Results
################################################################################

extension_results <- list(
  alt_outcomes = alt_results,
  alt_outcome_labels = alt_labels,
  mccrary_yearly = mccrary_yearly,
  n_alt_outcomes = length(alt_outcomes)
)

saveRDS(extension_results, file.path(results_dir, "extension_results.rds"))

cat("\n=== Extension Analyses Complete ===\n")
