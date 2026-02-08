# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 07_figures.R - Publication-Quality Figure Suite (12+ figures)
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# Every figure uses theme_apep(), saved as both PDF and PNG.
# Each figure wrapped in tryCatch so failures do not cascade.
# ==============================================================================

source("code/00_packages.R")

cat("=== 07_figures.R: Generating Publication-Quality Figures ===\n")
cat(sprintf("  Timestamp: %s\n", Sys.time()))

# ==============================================================================
# LOAD DATA
# ==============================================================================

# --- Core analysis panel (required) ---
if (!file.exists("data/analysis_panel.parquet")) {
  stop("FATAL: data/analysis_panel.parquet not found. Run 02_clean_data.R first.")
}
analysis <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Loaded analysis_panel: %d rows, %d places\n",
            nrow(analysis), n_distinct(analysis$place_id)))

# --- Ensure key derived variables exist ---
if (!"universalism_index" %in% names(analysis)) {
  # Construct from raw foundations if missing
  if (all(c("individualizing", "binding") %in% names(analysis))) {
    analysis <- analysis %>%
      mutate(universalism_index = individualizing - binding)
    cat("  Computed universalism_index = individualizing - binding\n")
  } else if (all(c("care_p", "fairness_p", "loyalty_p", "authority_p", "sanctity_p") %in% names(analysis))) {
    analysis <- analysis %>%
      mutate(
        individualizing = (care_p + fairness_p) / 2,
        binding = (loyalty_p + authority_p + sanctity_p) / 3,
        universalism_index = individualizing - binding
      )
    cat("  Computed individualizing, binding, and universalism_index from raw foundations\n")
  }
}

# --- Event study data ---
es_data <- NULL
if (file.exists("data/event_study_data.csv")) {
  es_data <- read_csv("data/event_study_data.csv", show_col_types = FALSE)
  # Normalize column names from 04_main_analysis.R output
  if ("event_time" %in% names(es_data) && !"time" %in% names(es_data)) {
    es_data <- es_data %>% rename(time = event_time)
  }
  # Normalize outcome labels to title case for figure matching
  es_data <- es_data %>%
    mutate(outcome = tools::toTitleCase(outcome))
  cat(sprintf("  Loaded event_study_data: %d rows, outcomes: %s\n",
              nrow(es_data), paste(unique(es_data$outcome), collapse = ", ")))
} else {
  cat("  WARNING: data/event_study_data.csv not found. Event study figures will be skipped.\n")
}

# --- Descriptive trends ---
desc_trends <- NULL
if (file.exists("data/descriptive_trends.csv")) {
  desc_trends <- read_csv("data/descriptive_trends.csv", show_col_types = FALSE)
  cat(sprintf("  Loaded descriptive_trends: %d rows\n", nrow(desc_trends)))
} else {
  cat("  WARNING: data/descriptive_trends.csv not found. Will compute trends from analysis panel.\n")
}

# --- Heterogeneity by partisanship event study ---
het_partisan_es <- NULL
if (file.exists("data/het_partisanship_es.csv")) {
  het_partisan_es <- read_csv("data/het_partisanship_es.csv", show_col_types = FALSE)
  # Normalize column names from 06_heterogeneity.R
  if ("event_time" %in% names(het_partisan_es) && !"time" %in% names(het_partisan_es)) {
    het_partisan_es <- het_partisan_es %>% rename(time = event_time)
  }
  if ("subgroup" %in% names(het_partisan_es) && !"group" %in% names(het_partisan_es)) {
    het_partisan_es <- het_partisan_es %>% rename(group = subgroup)
  }
  cat(sprintf("  Loaded het_partisanship_es: %d rows\n", nrow(het_partisan_es)))
} else {
  cat("  WARNING: data/het_partisanship_es.csv not found. Partisanship heterogeneity figure skipped.\n")
}

# --- HonestDiD results ---
honestdid_loaded <- FALSE
if (file.exists("data/honestdid_results.RData")) {
  load("data/honestdid_results.RData")
  honestdid_loaded <- TRUE
  cat("  Loaded honestdid_results.RData\n")
} else {
  cat("  WARNING: data/honestdid_results.RData not found. HonestDiD figure skipped.\n")
}

# --- Spatial data ---
states_sf <- NULL
places_sf <- NULL
if (file.exists("data/states_sf.rds")) {
  states_sf <- readRDS("data/states_sf.rds")
  cat(sprintf("  Loaded states_sf: %d features\n", nrow(states_sf)))
} else {
  cat("  WARNING: data/states_sf.rds not found. Will attempt tigris download.\n")
}

if (file.exists("data/places_sf.rds")) {
  places_sf <- readRDS("data/places_sf.rds")
  cat(sprintf("  Loaded places_sf: %d features\n", nrow(places_sf)))
} else {
  cat("  WARNING: data/places_sf.rds not found. Place-level map figures skipped.\n")
}

# --- Main results table ---
main_results <- NULL
if (file.exists("tables/main_results.csv")) {
  main_results <- read_csv("tables/main_results.csv", show_col_types = FALSE)
  # Normalize: 04_main_analysis.R saves as lowercase 'outcome', figures expect 'Outcome'
  if ("outcome" %in% names(main_results) && !"Outcome" %in% names(main_results)) {
    main_results <- main_results %>%
      rename(Outcome = outcome) %>%
      mutate(Outcome = tools::toTitleCase(Outcome))
  }
  cat(sprintf("  Loaded main_results: %d rows\n", nrow(main_results)))
} else {
  cat("  WARNING: tables/main_results.csv not found.\n")
}

# --- MDE results ---
mde_results <- NULL
if (file.exists("tables/mde_results.csv")) {
  mde_results <- read_csv("tables/mde_results.csv", show_col_types = FALSE)
  cat(sprintf("  Loaded mde_results: %d rows\n", nrow(mde_results)))
} else {
  cat("  WARNING: tables/mde_results.csv not found. MDE figure will use main_results.\n")
}

# --- CS results (R objects) ---
cs_loaded <- FALSE
if (file.exists("data/cs_results.RData")) {
  load("data/cs_results.RData")
  cs_loaded <- TRUE
  cat("  Loaded cs_results.RData\n")
} else {
  cat("  WARNING: data/cs_results.RData not found. Some appendix figures skipped.\n")
}

# --- Ensure figures/ directory exists ---
dir.create("figures", showWarnings = FALSE)

cat("\n=== Beginning Figure Generation ===\n\n")

# ==============================================================================
# HELPER: Dual-format save
# ==============================================================================

save_figure <- function(plot, filename, w = fig_width, h = fig_height) {
  ggsave(paste0("figures/", filename, ".pdf"), plot, width = w, height = h)
  ggsave(paste0("figures/", filename, ".png"), plot, width = w, height = h, dpi = fig_dpi)
  cat(sprintf("    Saved: figures/%s.pdf + .png\n", filename))
}


# ==============================================================================
# FIGURE 1: Geographic Distribution of Moral Universalism (Choropleth Map)
# ==============================================================================

cat("Generating Figure 1: Geographic Distribution of Moral Universalism...\n")

tryCatch({

  # Compute state-level mean universalism for a clean choropleth
  state_means <- analysis %>%
    group_by(state_fips) %>%
    summarise(
      mean_univ = mean(universalism_index, na.rm = TRUE),
      n_places  = n_distinct(place_id),
      .groups   = "drop"
    )

  # Get state shapefile: use cached or download
  if (is.null(states_sf)) {
    states_sf <- tigris::states(cb = TRUE, year = 2019)
    cat("    Downloaded states shapefile via tigris\n")
  }

  # Exclude AK, HI, territories for contiguous US
  states_map <- states_sf %>%
    filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%
    left_join(state_means, by = c("STATEFP" = "state_fips"))

  # Diverging midpoint: zero (universalism_index = individualizing - binding)
  mid_val <- 0

  fig01 <- ggplot(states_map) +
    geom_sf(aes(fill = mean_univ), color = "grey70", linewidth = 0.25) +
    scale_fill_gradient2(
      low      = "#B2182B",
      mid      = "white",
      high     = "#2166AC",
      midpoint = mid_val,
      name     = "Universalism Index",
      na.value = "grey90",
      labels   = scales::number_format(accuracy = 0.001)
    ) +
    # Overlay place-level points if shapefile available
    {
      if (!is.null(places_sf)) {
        place_means <- analysis %>%
          group_by(place_id) %>%
          summarise(mean_univ = mean(universalism_index, na.rm = TRUE),
                    state_fips = first(state_fips), place_fips = first(place_fips),
                    .groups = "drop") %>%
          mutate(st_fips_join = paste0(state_fips, place_fips))

        places_plot <- places_sf %>%
          mutate(st_fips_join = paste0(STATEFP, PLACEFP)) %>%
          inner_join(place_means, by = "st_fips_join") %>%
          filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"))

        # Centroid dots for places
        geom_sf(
          data = sf::st_centroid(places_plot),
          aes(color = mean_univ), size = 0.3, alpha = 0.5, show.legend = FALSE
        )
      }
    } +
    scale_color_gradient2(
      low = "#B2182B", mid = "white", high = "#2166AC", midpoint = mid_val
    ) +
    labs(
      title    = "Geographic Distribution of Moral Universalism in Local Government Speech",
      subtitle = "State-level mean of (Individualizing - Binding) moral foundation scores",
      caption  = "Source: LocalView corpus of U.S. local government meeting transcripts.\nBlue = universalist (individualizing > binding). Red = communalist (binding > individualizing)."
    ) +
    theme_void() +
    theme(
      legend.position  = "bottom",
      legend.key.width = unit(2.5, "cm"),
      legend.key.height = unit(0.4, "cm"),
      plot.title       = element_text(size = 13, face = "bold", hjust = 0.5),
      plot.subtitle    = element_text(size = 10, color = "grey40", hjust = 0.5),
      plot.caption     = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin      = margin(10, 10, 10, 10)
    )

  save_figure(fig01, "fig01_universalism_map", w = 10, h = 7)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 2: Broadband Treatment Timing Map
# ==============================================================================

cat("Generating Figure 2: Broadband Treatment Timing Map...\n")

tryCatch({

  # Compute treatment timing by state (mean first treatment year)
  state_timing <- analysis %>%
    group_by(state_fips) %>%
    summarise(
      mean_treat_year = mean(treat_year[treated], na.rm = TRUE),
      n_treated       = sum(treated & year == min(year[treated], na.rm = TRUE), na.rm = TRUE),
      pct_treated     = mean(treated, na.rm = TRUE) * 100,
      .groups         = "drop"
    )

  if (is.null(states_sf)) {
    states_sf <- tigris::states(cb = TRUE, year = 2019)
  }

  states_timing <- states_sf %>%
    filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%
    left_join(state_timing, by = c("STATEFP" = "state_fips"))

  fig02 <- ggplot(states_timing) +
    geom_sf(aes(fill = mean_treat_year), color = "white", linewidth = 0.25) +
    scale_fill_viridis_c(
      name      = "Mean Treatment Year",
      option    = "viridis",
      direction = -1,
      na.value  = "grey85",
      breaks    = seq(2013, 2022, by = 2)
    ) +
    labs(
      title    = "Broadband Treatment Timing: Year of Crossing 70% Subscription Threshold",
      subtitle = "Mean first-crossing year by state; grey = no treated places in sample",
      caption  = "Source: ACS 5-year broadband subscription data. Treatment = first year >= 70% HH broadband rate."
    ) +
    theme_void() +
    theme(
      legend.position   = "bottom",
      legend.key.width  = unit(2.5, "cm"),
      legend.key.height = unit(0.4, "cm"),
      plot.title        = element_text(size = 13, face = "bold", hjust = 0.5),
      plot.subtitle     = element_text(size = 10, color = "grey40", hjust = 0.5),
      plot.caption      = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin       = margin(10, 10, 10, 10)
    )

  save_figure(fig02, "fig02_treatment_timing_map", w = 10, h = 7)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 3: Broadband Adoption Trends (Two-Panel)
# ==============================================================================

cat("Generating Figure 3: Broadband Adoption Trends...\n")

tryCatch({

  # Panel A: Mean broadband rate over time by treatment group
  trend_data <- analysis %>%
    mutate(group = ifelse(treated, "Eventually Treated", "Never Treated")) %>%
    group_by(year, group) %>%
    summarise(
      mean_bb = mean(broadband_rate, na.rm = TRUE),
      se_bb   = sd(broadband_rate, na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )

  fig03a <- ggplot(trend_data, aes(x = year, y = mean_bb, color = group, fill = group)) +
    geom_ribbon(aes(ymin = mean_bb - 1.96 * se_bb,
                    ymax = mean_bb + 1.96 * se_bb),
                alpha = 0.15, color = NA) +
    geom_line(linewidth = 1) +
    geom_point(size = 2.5) +
    geom_hline(yintercept = 0.70, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    annotate("text", x = min(trend_data$year) + 0.3, y = 0.715,
             label = "70% treatment threshold", size = 3, hjust = 0, color = "grey40") +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_color_manual(values = c("Eventually Treated" = apep_colors["treated"],
                                  "Never Treated"      = apep_colors["control"]),
                       name = "") +
    scale_fill_manual(values = c("Eventually Treated" = apep_colors["treated"],
                                 "Never Treated"      = apep_colors["control"]),
                      name = "") +
    labs(
      subtitle = "A. Mean Household Broadband Subscription Rate",
      x = "Year",
      y = "Broadband Rate"
    ) +
    theme_apep() +
    theme(legend.position = c(0.25, 0.85))

  # Panel B: Treatment cohort sizes
  cohort_sizes <- analysis %>%
    filter(treated) %>%
    group_by(treat_year) %>%
    summarise(n_places = n_distinct(place_id), .groups = "drop")

  fig03b <- ggplot(cohort_sizes, aes(x = treat_year, y = n_places)) +
    geom_col(aes(fill = as.factor(treat_year)), width = 0.7, show.legend = FALSE) +
    geom_text(aes(label = n_places), vjust = -0.5, size = 3.2, fontface = "bold") +
    scale_fill_viridis_d(option = "viridis", direction = -1) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(
      subtitle = "B. Number of Places Crossing 70% Threshold by Year",
      x = "Treatment Cohort Year",
      y = "Number of Places"
    ) +
    theme_apep() +
    theme(panel.grid.major.x = element_blank())

  fig03 <- fig03a / fig03b +
    plot_annotation(
      title   = "Broadband Internet Adoption in U.S. Local Governments",
      caption = "Note: Panel A shows mean broadband subscription rates by eventual treatment status with 95% CIs.\nPanel B shows the number of places crossing the 70% threshold each year."
    ) &
    theme(plot.title = element_text(size = 13, face = "bold"))

  save_figure(fig03, "fig03_broadband_trends", w = fig_width, h = 9)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 4: Moral Foundations Distributions (Kernel Density)
# ==============================================================================

cat("Generating Figure 4: Moral Foundations Distributions...\n")

tryCatch({

  # Define treatment status and period
  dist_data <- analysis %>%
    mutate(
      group = case_when(
        treated & post  ~ "Treated, Post",
        treated & !post ~ "Treated, Pre",
        !treated & year >= median(analysis$year[analysis$treated]) ~ "Never Treated, Post",
        TRUE ~ "Never Treated, Pre"
      ),
      group = factor(group, levels = c("Treated, Pre", "Treated, Post",
                                       "Never Treated, Pre", "Never Treated, Post"))
    ) %>%
    filter(!is.na(universalism_index), is.finite(universalism_index))

  group_colors <- c(
    "Treated, Pre"       = alpha("#2166AC", 0.6),
    "Treated, Post"      = "#2166AC",
    "Never Treated, Pre" = alpha("#D55E00", 0.6),
    "Never Treated, Post"= "#D55E00"
  )
  group_linetypes <- c(
    "Treated, Pre"        = "dashed",
    "Treated, Post"       = "solid",
    "Never Treated, Pre"  = "dashed",
    "Never Treated, Post" = "solid"
  )

  fig04 <- ggplot(dist_data, aes(x = universalism_index, color = group, linetype = group)) +
    geom_density(linewidth = 0.9, adjust = 1.2) +
    geom_vline(xintercept = 0, linetype = "dotted", color = "grey50", linewidth = 0.4) +
    scale_color_manual(values = c(
      "Treated, Pre"        = "#4393C3",
      "Treated, Post"       = "#2166AC",
      "Never Treated, Pre"  = "#E08B6A",
      "Never Treated, Post" = "#D55E00"
    ), name = "") +
    scale_linetype_manual(values = group_linetypes, name = "") +
    annotate("text", x = 0.02, y = Inf, label = "Universalist -->",
             hjust = 0, vjust = 2, size = 3, color = "#2166AC", fontface = "italic") +
    annotate("text", x = -0.02, y = Inf, label = "<-- Communalist",
             hjust = 1, vjust = 2, size = 3, color = "#B2182B", fontface = "italic") +
    labs(
      title    = "Distribution of Moral Universalism by Treatment Status and Period",
      subtitle = "Universalism index = Individualizing - Binding foundation scores",
      x        = "Universalism Index (Individualizing - Binding)",
      y        = "Density",
      caption  = "Note: Kernel density estimates. Dashed = pre-treatment period, solid = post-treatment.\nZero line marks equal individualizing and binding scores."
    ) +
    theme_apep() +
    theme(legend.position = c(0.82, 0.80))

  save_figure(fig04, "fig04_distributions", w = 9, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# HELPER: Event study plot function (reused for Figures 5-8, A1-A4)
# ==============================================================================

plot_event_study <- function(es_df, outcome_label, color_main = apep_colors["treated"],
                             color_pre = es_colors["pre"],
                             title_text = NULL, subtitle_text = NULL,
                             ylab_text = NULL, att_label = NULL) {
  # Expects data frame with columns: time, att, se
  es_df <- es_df %>%
    mutate(
      ci_lo   = att - 1.96 * se,
      ci_hi   = att + 1.96 * se,
      period  = ifelse(time < 0, "Pre-treatment", "Post-treatment")
    )

  if (is.null(title_text)) {
    title_text <- sprintf("Event Study: Effect of Broadband on %s", outcome_label)
  }
  if (is.null(subtitle_text)) {
    subtitle_text <- "Callaway-Sant'Anna (2021) estimator with never-treated control group"
  }
  if (is.null(ylab_text)) {
    ylab_text <- sprintf("ATT (%s)", outcome_label)
  }

  p <- ggplot(es_df, aes(x = time, y = att)) +
    # CI bars
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi, color = period),
                  width = 0.2, linewidth = 0.5) +
    # Points colored by period
    geom_point(aes(color = period), size = 2.5) +
    # Connecting line
    geom_line(color = "grey40", linewidth = 0.4, alpha = 0.5) +
    # Reference lines
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.6) +
    # Colors
    scale_color_manual(
      values = c("Pre-treatment" = as.character(color_pre),
                 "Post-treatment" = as.character(color_main)),
      name = ""
    ) +
    # Annotations
    annotate("text", x = min(es_df$time) + 0.2,
             y = max(es_df$ci_hi, na.rm = TRUE) * 0.95,
             label = "Pre-treatment", hjust = 0, size = 3, color = "grey50") +
    annotate("text", x = max(es_df$time) - 0.2,
             y = max(es_df$ci_hi, na.rm = TRUE) * 0.95,
             label = "Post-treatment", hjust = 1, size = 3, color = "grey50") +
    scale_x_continuous(breaks = seq(floor(min(es_df$time)), ceiling(max(es_df$time)), 1)) +
    labs(
      title    = title_text,
      subtitle = subtitle_text,
      x        = "Years Relative to Treatment",
      y        = ylab_text,
      caption  = "Note: Bars show 95% confidence intervals. Standard errors clustered at state level.\nTreatment = first year place crosses 70% broadband threshold."
    ) +
    theme_apep() +
    theme(legend.position = "none")

  # Add ATT annotation if provided
  if (!is.null(att_label)) {
    p <- p + annotate("text", x = max(es_df$time) - 0.2,
                      y = min(es_df$ci_lo, na.rm = TRUE) * 1.1,
                      label = att_label, hjust = 1, vjust = 1,
                      size = 3.2, fontface = "italic", color = "grey30")
  }

  return(p)
}


# ==============================================================================
# FIGURE 5: Event Study -- Individualizing Foundations (C-S)
# ==============================================================================

cat("Generating Figure 5: Event Study -- Individualizing Foundations...\n")

tryCatch({

  if (is.null(es_data)) stop("Event study data not loaded.")

  es_ind <- es_data %>% filter(outcome == "Individualizing")
  if (nrow(es_ind) == 0) stop("No 'Individualizing' rows in event_study_data.csv")

  # Get ATT from main_results if available
  att_label <- NULL
  if (!is.null(main_results)) {
    mr_ind <- main_results %>% filter(grepl("Individualizing", Outcome, ignore.case = TRUE))
    if (nrow(mr_ind) > 0) {
      att_label <- sprintf("ATT = %.4f (SE = %.4f, p = %.3f)",
                           mr_ind$ATT[1], mr_ind$SE[1],
                           ifelse("p_value" %in% names(mr_ind), mr_ind$p_value[1],
                                  2 * pnorm(-abs(mr_ind$ATT[1] / mr_ind$SE[1]))))
    }
  }

  fig05 <- plot_event_study(
    es_ind,
    outcome_label = "Individualizing Score",
    color_main    = mf_colors["Individualizing"],
    title_text    = "Event Study: Effect of Broadband on Individualizing Moral Foundations",
    ylab_text     = "ATT (Individualizing Score)",
    att_label     = att_label
  )

  save_figure(fig05, "fig05_es_individualizing", w = 9, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 6: Event Study -- Binding Foundations (C-S)
# ==============================================================================

cat("Generating Figure 6: Event Study -- Binding Foundations...\n")

tryCatch({

  if (is.null(es_data)) stop("Event study data not loaded.")

  es_bind <- es_data %>% filter(outcome == "Binding")
  if (nrow(es_bind) == 0) stop("No 'Binding' rows in event_study_data.csv")

  att_label <- NULL
  if (!is.null(main_results)) {
    mr_bind <- main_results %>% filter(grepl("Binding", Outcome, ignore.case = TRUE))
    if (nrow(mr_bind) > 0) {
      att_label <- sprintf("ATT = %.4f (SE = %.4f, p = %.3f)",
                           mr_bind$ATT[1], mr_bind$SE[1],
                           ifelse("p_value" %in% names(mr_bind), mr_bind$p_value[1],
                                  2 * pnorm(-abs(mr_bind$ATT[1] / mr_bind$SE[1]))))
    }
  }

  fig06 <- plot_event_study(
    es_bind,
    outcome_label = "Binding Score",
    color_main    = mf_colors["Binding"],
    color_pre     = "#E08B6A",
    title_text    = "Event Study: Effect of Broadband on Binding Moral Foundations",
    ylab_text     = "ATT (Binding Score)",
    att_label     = att_label
  )

  save_figure(fig06, "fig06_es_binding", w = 9, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 7: Event Study -- Universalism Index (C-S)
# ==============================================================================

cat("Generating Figure 7: Event Study -- Universalism Index...\n")

tryCatch({

  if (is.null(es_data)) stop("Event study data not loaded.")

  # Try multiple possible outcome labels
  es_univ <- es_data %>% filter(outcome %in% c("Log Univ/Comm", "Universalism", "universalism_index",
                                                "Universalism_index", "Log_univ_comm"))
  if (nrow(es_univ) == 0) stop("No universalism/ratio rows in event_study_data.csv")

  att_label <- NULL
  if (!is.null(main_results)) {
    mr_univ <- main_results %>% filter(grepl("Univ|Ratio|universalism", Outcome, ignore.case = TRUE))
    if (nrow(mr_univ) > 0) {
      att_label <- sprintf("ATT = %.4f (SE = %.4f, p = %.3f)",
                           mr_univ$ATT[1], mr_univ$SE[1],
                           ifelse("p_value" %in% names(mr_univ), mr_univ$p_value[1],
                                  2 * pnorm(-abs(mr_univ$ATT[1] / mr_univ$SE[1]))))
    }
  }

  fig07 <- plot_event_study(
    es_univ,
    outcome_label = "Universalism Index",
    color_main    = "#7B3294",
    color_pre     = "#C2A5CF",
    title_text    = "Event Study: Effect of Broadband on Universalism-Communalism Balance",
    subtitle_text = "Log(Individualizing) - Log(Binding); positive = more universalist",
    ylab_text     = "ATT (Log Universalism/Communalism Ratio)",
    att_label     = att_label
  )

  save_figure(fig07, "fig07_es_universalism", w = 9, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 8: Heterogeneity by Baseline Partisanship (Two-Panel Event Study)
# ==============================================================================

cat("Generating Figure 8: Heterogeneity by Baseline Partisanship...\n")

tryCatch({

  if (is.null(het_partisan_es)) stop("Partisanship heterogeneity ES data not loaded.")

  # Expect columns: time, att, se, group (e.g., "Republican" / "Democratic")
  # Adapt to actual column names
  group_col <- intersect(c("group", "partisan_group", "partisanship"), names(het_partisan_es))
  if (length(group_col) == 0) stop("No group column found in het_partisanship_es.csv")
  group_col <- group_col[1]

  het_partisan_es <- het_partisan_es %>% rename(group_var = !!sym(group_col))

  groups <- unique(het_partisan_es$group_var)
  rep_label <- groups[grepl("[Rr]ep", groups)][1]
  dem_label <- groups[grepl("[Dd]em", groups)][1]

  if (is.na(rep_label) || is.na(dem_label)) {
    # Fallback: use first two groups
    rep_label <- groups[1]
    dem_label <- groups[2]
  }

  # Common y-axis range
  y_range <- range(c(het_partisan_es$att - 1.96 * het_partisan_es$se,
                      het_partisan_es$att + 1.96 * het_partisan_es$se), na.rm = TRUE)

  fig08a <- plot_event_study(
    het_partisan_es %>% filter(group_var == rep_label),
    outcome_label  = "Universalism Index",
    color_main     = "#B2182B",
    color_pre      = "#D6604D",
    title_text     = paste0("A. ", rep_label, "-Leaning Counties"),
    subtitle_text  = "",
    ylab_text      = "ATT"
  ) + coord_cartesian(ylim = y_range)

  fig08b <- plot_event_study(
    het_partisan_es %>% filter(group_var == dem_label),
    outcome_label  = "Universalism Index",
    color_main     = "#2166AC",
    color_pre      = "#4393C3",
    title_text     = paste0("B. ", dem_label, "-Leaning Counties"),
    subtitle_text  = "",
    ylab_text      = "ATT"
  ) + coord_cartesian(ylim = y_range)

  fig08 <- fig08a + fig08b +
    plot_annotation(
      title   = "Heterogeneous Effects by Baseline Partisanship",
      caption = "Note: Counties classified by 2016 presidential vote share. Same y-axis scale for comparison.\nCallaway-Sant'Anna estimator with state-clustered standard errors."
    ) &
    theme(plot.title = element_text(size = 13, face = "bold"))

  save_figure(fig08, "fig08_het_partisanship", w = 12, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 9: Residualized Binscatter -- Broadband vs Moral Language
# ==============================================================================

cat("Generating Figure 9: Residualized Binscatter...\n")

tryCatch({

  # Residualize both broadband_rate and universalism_index against place + year FE
  # place_id should already exist; create numeric version if needed
  if (!"place_id" %in% names(analysis)) {
    analysis <- analysis %>% mutate(place_id = as.numeric(factor(paste0(state_fips, place_fips))))
  }

  # Run residualization regressions
  resid_bb   <- feols(broadband_rate ~ 1 | place_id + year, data = analysis)
  resid_univ <- feols(universalism_index ~ 1 | place_id + year, data = analysis)

  resid_df <- tibble(
    resid_broadband    = resid(resid_bb),
    resid_universalism = resid(resid_univ)
  ) %>%
    filter(is.finite(resid_broadband), is.finite(resid_universalism))

  # Create 20 bins
  n_bins <- 20
  resid_df <- resid_df %>%
    mutate(bin = ntile(resid_broadband, n_bins))

  bin_means <- resid_df %>%
    group_by(bin) %>%
    summarise(
      mean_bb   = mean(resid_broadband),
      mean_univ = mean(resid_universalism),
      se_univ   = sd(resid_universalism) / sqrt(n()),
      n         = n(),
      .groups   = "drop"
    )

  # OLS slope on residualized data
  ols_fit <- lm(resid_universalism ~ resid_broadband, data = resid_df)
  slope   <- coef(ols_fit)[2]
  slope_se <- summary(ols_fit)$coefficients[2, 2]

  fig09 <- ggplot(bin_means, aes(x = mean_bb, y = mean_univ)) +
    geom_errorbar(aes(ymin = mean_univ - 1.96 * se_univ,
                      ymax = mean_univ + 1.96 * se_univ),
                  width = 0, color = "grey70", linewidth = 0.4) +
    geom_point(color = apep_colors["treated"], size = 3) +
    geom_smooth(data = resid_df, aes(x = resid_broadband, y = resid_universalism),
                method = "lm", se = FALSE, color = "#D55E00",
                linewidth = 0.8, linetype = "solid") +
    annotate("text",
             x = max(bin_means$mean_bb) * 0.6,
             y = max(bin_means$mean_univ + 1.96 * bin_means$se_univ) * 0.9,
             label = sprintf("Slope = %.4f (SE = %.4f)", slope, slope_se),
             size = 3.5, hjust = 0, fontface = "italic", color = "grey30") +
    labs(
      title    = "Residualized Relationship: Broadband Adoption and Moral Universalism",
      subtitle = "Both variables residualized against place and year fixed effects",
      x        = "Residualized Broadband Rate",
      y        = "Residualized Universalism Index",
      caption  = "Note: 20 equal-sized bins. Points show bin means with 95% CIs.\nLine shows OLS fit on underlying residualized data."
    ) +
    theme_apep()

  save_figure(fig09, "fig09_binscatter", w = 8, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 10: HonestDiD Sensitivity Plot
# ==============================================================================

cat("Generating Figure 10: HonestDiD Sensitivity...\n")

tryCatch({

  if (!honestdid_loaded) stop("HonestDiD results not loaded.")

  # Expect honestdid_results (data frame or list with M, lb, ub columns)
  # Adapt to whatever structure was saved by 05_robustness.R
  # Common structures:
  #   data.frame with columns: M (or Mbar), lb, ub, method
  #   list with $OriginalResults, $SensitivityResults

  # Try to find the right object
  hd_obj <- NULL
  for (obj_name in c("honestdid_results", "honest_individual", "honest_results",
                      "honest_universalism")) {
    if (exists(obj_name)) {
      hd_obj <- get(obj_name)
      break
    }
  }

  if (is.null(hd_obj)) stop("No recognized HonestDiD results object found.")

  # honestdid_results from 05_robustness.R is a named list (one element per outcome)
  # Each element is either NULL or a data.frame from HonestDiD::createSensitivityResults()
  # We want the first non-NULL element
  if (is.list(hd_obj) && !is.data.frame(hd_obj)) {
    # Check for named outcome elements
    non_null <- Filter(Negate(is.null), hd_obj)
    if (length(non_null) > 0) {
      hd_df <- non_null[[1]]
      if (!is.data.frame(hd_df)) hd_df <- as.data.frame(hd_df)
    } else if ("SensitivityResults" %in% names(hd_obj)) {
      hd_df <- hd_obj$SensitivityResults
    } else {
      stop("HonestDiD results list has no non-NULL elements.")
    }
  } else if (is.data.frame(hd_obj)) {
    hd_df <- hd_obj
  } else {
    hd_df <- as.data.frame(hd_obj)
  }

  # Standardize column names
  if ("Mbar" %in% names(hd_df)) hd_df <- hd_df %>% rename(M = Mbar)
  if (!("lb" %in% names(hd_df)) && "CI_lower" %in% names(hd_df)) {
    hd_df <- hd_df %>% rename(lb = CI_lower, ub = CI_upper)
  }

  # Ensure required columns
  if (!all(c("M", "lb", "ub") %in% names(hd_df))) {
    # Last resort: check for numbered columns
    if (ncol(hd_df) >= 3) {
      names(hd_df)[1:3] <- c("M", "lb", "ub")
    } else {
      stop("Cannot parse HonestDiD results structure.")
    }
  }

  # Filter to smoothness-based results if method column exists
  if ("method" %in% names(hd_df)) {
    hd_smooth <- hd_df %>% filter(grepl("smooth|C", method, ignore.case = TRUE))
    if (nrow(hd_smooth) > 0) hd_df <- hd_smooth
  }

  fig10 <- ggplot(hd_df, aes(x = M)) +
    geom_ribbon(aes(ymin = lb, ymax = ub), fill = "#2166AC", alpha = 0.2) +
    geom_line(aes(y = lb), color = "#2166AC", linewidth = 0.8) +
    geom_line(aes(y = ub), color = "#2166AC", linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    # Shade region where CI crosses zero
    geom_rect(
      data = hd_df %>% filter(lb <= 0 & ub >= 0),
      aes(xmin = M - diff(range(hd_df$M)) / (2 * nrow(hd_df)),
          xmax = M + diff(range(hd_df$M)) / (2 * nrow(hd_df)),
          ymin = -Inf, ymax = Inf),
      fill = "red", alpha = 0.05, inherit.aes = FALSE
    ) +
    labs(
      title    = "Sensitivity to Parallel Trends Violations (HonestDiD)",
      subtitle = expression(paste("95% CI bounds as a function of ", bar(M), " (maximum violation of parallel trends)")),
      x        = expression(bar(M) ~ " (bound on parallel trends violation)"),
      y        = "95% CI Bounds for ATT",
      caption  = "Note: Blue region = 95% robust confidence set. Includes zero = cannot reject null.\nRed shading marks where CI includes zero (breakdown region)."
    ) +
    theme_apep()

  save_figure(fig10, "fig10_honestdid", w = 8, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 11: MDE and Equivalence Visualization
# ==============================================================================

cat("Generating Figure 11: MDE and Equivalence Visualization...\n")

tryCatch({

  # Get ATT and SE for universalism index
  att_val <- 0
  se_val  <- 0.01
  mde_val <- 0.05

  if (!is.null(main_results)) {
    mr_main <- main_results %>%
      filter(grepl("Univ|Ratio|Individual", Outcome, ignore.case = TRUE))
    if (nrow(mr_main) > 0) {
      att_val <- mr_main$ATT[1]
      se_val  <- mr_main$SE[1]
    }
  }

  if (!is.null(mde_results)) {
    mde_row <- mde_results %>% filter(row_number() == 1)
    if ("mde" %in% names(mde_row)) {
      mde_val <- mde_row$mde[1]
    } else if ("MDE" %in% names(mde_row)) {
      mde_val <- mde_row$MDE[1]
    }
  } else {
    # Compute MDE = 2.8 * SE (80% power, 5% significance)
    mde_val <- 2.8 * se_val
  }

  ci_lo <- att_val - 1.96 * se_val
  ci_hi <- att_val + 1.96 * se_val

  # Enke (2020) reference: 1 SD universalism ~ 0.10-0.15 shift in policy preferences
  enke_effect <- 0.12

  # Build the number-line figure
  fig11_data <- tibble(y = 0)

  fig11 <- ggplot(fig11_data, aes(y = y)) +
    # Our 95% CI as thick bar
    geom_rect(aes(xmin = ci_lo, xmax = ci_hi, ymin = -0.15, ymax = 0.15),
              fill = "#2166AC", alpha = 0.4) +
    geom_point(aes(x = att_val), size = 4, color = "#2166AC") +
    # MDE bounds
    geom_vline(xintercept = c(-mde_val, mde_val),
               linetype = "dashed", color = "#D55E00", linewidth = 0.7) +
    # Zero line
    geom_vline(xintercept = 0, linetype = "solid", color = "grey30", linewidth = 0.5) +
    # Enke reference
    geom_vline(xintercept = c(-enke_effect, enke_effect),
               linetype = "dotdash", color = "#009E73", linewidth = 0.6) +
    # Annotations
    annotate("text", x = att_val, y = 0.25,
             label = sprintf("ATT = %.4f\n95%% CI: [%.4f, %.4f]", att_val, ci_lo, ci_hi),
             size = 3.2, color = "#2166AC", fontface = "bold") +
    annotate("text", x = mde_val, y = -0.30,
             label = sprintf("MDE = %.4f", mde_val),
             size = 3, color = "#D55E00", hjust = -0.1) +
    annotate("text", x = -mde_val, y = -0.30,
             label = sprintf("MDE = -%.4f", mde_val),
             size = 3, color = "#D55E00", hjust = 1.1) +
    annotate("text", x = enke_effect, y = 0.35,
             label = "Enke (2020)\nreference",
             size = 2.8, color = "#009E73", hjust = -0.1) +
    annotate("text", x = 0, y = -0.42,
             label = "Our null rules out effects larger than the MDE in either direction",
             size = 3, color = "grey40", fontface = "italic") +
    # Scales
    coord_cartesian(ylim = c(-0.5, 0.45)) +
    scale_y_continuous(breaks = NULL) +
    labs(
      title    = "Minimum Detectable Effect and Equivalence Assessment",
      subtitle = "Can we rule out economically meaningful effects?",
      x        = "Effect Size (Universalism Index)",
      y        = "",
      caption  = "Note: Blue bar = 95% CI of our ATT estimate. Orange dashed = MDE (80% power).\nGreen dash-dot = reference effect from Enke (2020 JPE) cross-sectional universalism gradient."
    ) +
    theme_apep() +
    theme(
      axis.line.y  = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid   = element_blank()
    )

  save_figure(fig11, "fig11_mde_equivalence", w = 9, h = 5)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# FIGURE 12: Moral Foundation Composition (Stacked Area)
# ==============================================================================

cat("Generating Figure 12: Moral Foundation Composition...\n")

tryCatch({

  # Compute annual mean share of each foundation by treatment group
  comp_data <- analysis %>%
    mutate(group = ifelse(treated, "Eventually Treated", "Never Treated")) %>%
    group_by(year, group) %>%
    summarise(
      Care      = mean(care_p, na.rm = TRUE),
      Fairness  = mean(fairness_p, na.rm = TRUE),
      Loyalty   = mean(loyalty_p, na.rm = TRUE),
      Authority = mean(authority_p, na.rm = TRUE),
      Sanctity  = mean(sanctity_p, na.rm = TRUE),
      .groups   = "drop"
    ) %>%
    # Normalize to sum to 1 within each year-group
    mutate(
      total = Care + Fairness + Loyalty + Authority + Sanctity,
      Care      = Care / total,
      Fairness  = Fairness / total,
      Loyalty   = Loyalty / total,
      Authority = Authority / total,
      Sanctity  = Sanctity / total
    ) %>%
    select(-total) %>%
    pivot_longer(cols = c(Care, Fairness, Loyalty, Authority, Sanctity),
                 names_to = "Foundation", values_to = "Share") %>%
    mutate(
      Foundation = factor(Foundation,
                          levels = c("Sanctity", "Authority", "Loyalty", "Fairness", "Care"))
    )

  fig12 <- ggplot(comp_data, aes(x = year, y = Share, fill = Foundation)) +
    geom_area(alpha = 0.85, color = "white", linewidth = 0.2) +
    facet_wrap(~group, ncol = 2) +
    scale_fill_manual(values = mf_colors[c("Sanctity", "Authority", "Loyalty", "Fairness", "Care")]) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                       expand = c(0, 0)) +
    scale_x_continuous(expand = c(0, 0)) +
    labs(
      title    = "Moral Foundation Composition Over Time",
      subtitle = "Share of each foundation in local government moral language",
      x        = "Year",
      y        = "Share of Moral Language",
      fill     = "Foundation",
      caption  = "Note: Shares normalized to sum to 100% within each year-group.\nBlue shades = individualizing (Care, Fairness). Red shades = binding (Loyalty, Authority, Sanctity)."
    ) +
    theme_apep() +
    theme(
      strip.text     = element_text(face = "bold", size = 11),
      legend.position = "bottom",
      panel.spacing  = unit(1.5, "lines")
    )

  save_figure(fig12, "fig12_composition", w = 12, h = 6)

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# APPENDIX FIGURE A1: Individual Foundation Event Studies (5-panel)
# ==============================================================================

cat("Generating Figure A1: Individual Foundation Event Studies...\n")

tryCatch({

  if (!cs_loaded) stop("cs_results.RData not loaded. Need foundation_es object.")
  if (!exists("foundation_es")) stop("foundation_es object not found.")

  foundation_names <- c("care_p" = "Care", "fairness_p" = "Fairness",
                        "loyalty_p" = "Loyalty", "authority_p" = "Authority",
                        "sanctity_p" = "Sanctity")

  panels <- list()

  for (fnd in names(foundation_names)) {
    label <- foundation_names[[fnd]]

    if (!is.null(foundation_es[[fnd]])) {
      es_obj <- foundation_es[[fnd]]
      es_df <- data.frame(
        time = es_obj$egt,
        att  = es_obj$att.egt,
        se   = es_obj$se.egt
      ) %>%
        filter(!is.na(att), !is.na(se))

      if (nrow(es_df) == 0) next

      color_use <- mf_colors[[label]]

      panels[[label]] <- ggplot(es_df, aes(x = time, y = att)) +
        geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                      width = 0.2, color = color_use, alpha = 0.6) +
        geom_point(color = color_use, size = 2) +
        geom_line(color = "grey50", linewidth = 0.3) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.3) +
        geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.4) +
        scale_x_continuous(breaks = seq(-8, 8, 2)) +
        labs(
          subtitle = label,
          x = "Years Relative to Treatment",
          y = "ATT"
        ) +
        theme_apep(base_size = 10) +
        theme(
          plot.subtitle = element_text(face = "bold", color = color_use),
          axis.title.x  = element_text(size = 8),
          axis.title.y  = element_text(size = 8)
        )
    }
  }

  if (length(panels) >= 2) {
    figA1 <- wrap_plots(panels, ncol = 3) +
      plot_annotation(
        title   = "Event Studies for Individual Moral Foundations",
        caption = "Note: Each panel shows the C-S event study for one moral foundation.\nBars = 95% CIs, state-clustered SEs."
      ) &
      theme(plot.title = element_text(size = 13, face = "bold"))

    save_figure(figA1, "figA1_individual_foundations", w = 12, h = 8)
  } else {
    cat("    WARNING: Fewer than 2 foundation event studies available. Skipping.\n")
  }

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# APPENDIX FIGURE A2: Alternative Thresholds (Event Studies)
# ==============================================================================

cat("Generating Figure A2: Alternative Threshold Event Studies...\n")

tryCatch({

  if (!cs_loaded) stop("cs_results.RData not loaded.")

  # Check if alternative threshold ES data exists
  alt_thresholds <- c(60, 65, 75, 80)
  alt_panels <- list()

  for (thresh in alt_thresholds) {
    # Look for saved event study data for alternative thresholds
    fname <- sprintf("data/es_threshold_%d.csv", thresh)
    if (file.exists(fname)) {
      es_alt <- read_csv(fname, show_col_types = FALSE)
    } else {
      next
    }

    alt_panels[[as.character(thresh)]] <- ggplot(es_alt, aes(x = time, y = att)) +
      geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                    width = 0.2, color = "#7B3294", alpha = 0.6) +
      geom_point(color = "#7B3294", size = 2) +
      geom_line(color = "grey50", linewidth = 0.3) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
      scale_x_continuous(breaks = seq(-8, 8, 2)) +
      labs(subtitle = sprintf("%d%% Threshold", thresh), x = "", y = "ATT") +
      theme_apep(base_size = 10)
  }

  if (length(alt_panels) == 0) {
    # Fallback: run alternative thresholds on the fly if did_data can be constructed
    cat("    No pre-computed alternative threshold ES files found.\n")
    cat("    Attempting on-the-fly computation...\n")

    did_data <- analysis %>%
      filter(!is.na(log_income)) %>%
      mutate(id = as.numeric(factor(place_id)))

    for (thresh_pct in alt_thresholds) {
      thresh_dec <- thresh_pct / 100

      treat_timing_alt <- analysis %>%
        filter(broadband_rate >= thresh_dec) %>%
        group_by(place_id) %>%
        summarise(treat_year_alt = min(year), .groups = "drop")

      df_alt <- did_data %>%
        left_join(treat_timing_alt, by = "place_id") %>%
        mutate(gname_alt = as.numeric(ifelse(!is.na(treat_year_alt), treat_year_alt, 0)))

      # Need sufficient treated and control units
      n_treat <- sum(df_alt$gname_alt > 0) / n_distinct(df_alt$year)
      if (n_treat < 20) {
        cat(sprintf("    %d%% threshold: too few treated (%d). Skipping.\n", thresh_pct, round(n_treat)))
        next
      }

      cs_alt <- tryCatch({
        att_gt(
          yname = ifelse("universalism_index" %in% names(df_alt),
                         "universalism_index", "log_univ_comm"),
          tname = "year",
          idname = "id",
          gname = "gname_alt",
          data = df_alt,
          control_group = "notyettreated",
          anticipation = 0,
          est_method = "reg",
          clustervars = "state_fips",
          bstrap = TRUE,
          biters = 200,
          print_details = FALSE
        )
      }, error = function(e) NULL)

      if (is.null(cs_alt)) next

      es_alt_obj <- tryCatch(aggte(cs_alt, type = "dynamic", na.rm = TRUE), error = function(e) NULL)
      if (is.null(es_alt_obj)) next

      es_alt_df <- data.frame(
        time = es_alt_obj$egt,
        att  = es_alt_obj$att.egt,
        se   = es_alt_obj$se.egt
      ) %>% filter(!is.na(att))

      alt_panels[[as.character(thresh_pct)]] <- ggplot(es_alt_df, aes(x = time, y = att)) +
        geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                      width = 0.2, color = "#7B3294", alpha = 0.6) +
        geom_point(color = "#7B3294", size = 2) +
        geom_line(color = "grey50", linewidth = 0.3) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
        geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
        scale_x_continuous(breaks = seq(-8, 8, 2)) +
        labs(subtitle = sprintf("%d%% Threshold", thresh_pct), x = "", y = "ATT") +
        theme_apep(base_size = 10)
    }
  }

  if (length(alt_panels) >= 2) {
    figA2 <- wrap_plots(alt_panels, ncol = 2) +
      plot_annotation(
        title   = "Robustness: Alternative Broadband Treatment Thresholds",
        caption = "Note: Event studies for the universalism index under alternative threshold definitions.\nC-S estimator, state-clustered SEs."
      ) &
      theme(plot.title = element_text(size = 13, face = "bold"))

    save_figure(figA2, "figA2_alt_thresholds", w = 10, h = 8)
  } else {
    cat("    WARNING: Fewer than 2 threshold panels available. Skipping Figure A2.\n")
  }

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# APPENDIX FIGURE A3: Heterogeneity by Rurality
# ==============================================================================

cat("Generating Figure A3: Heterogeneity by Rurality...\n")

tryCatch({

  # Check for pre-computed heterogeneity ES data
  het_rural_es <- NULL
  if (file.exists("data/het_rurality_es.csv")) {
    het_rural_es <- read_csv("data/het_rurality_es.csv", show_col_types = FALSE)
  }

  if (!is.null(het_rural_es)) {
    # Expect columns: time, att, se, group (metro/non-metro)
    group_col <- intersect(c("group", "rural_group", "rurality"), names(het_rural_es))
    if (length(group_col) == 0) stop("No group column in het_rurality_es.csv")
    het_rural_es <- het_rural_es %>% rename(group_var = !!sym(group_col[1]))

    groups <- unique(het_rural_es$group_var)

    y_range <- range(c(het_rural_es$att - 1.96 * het_rural_es$se,
                        het_rural_es$att + 1.96 * het_rural_es$se), na.rm = TRUE)

    figA3a <- plot_event_study(
      het_rural_es %>% filter(group_var == groups[1]),
      outcome_label = "Universalism",
      color_main    = "#2166AC",
      title_text    = paste0("A. ", groups[1]),
      subtitle_text = "",
      ylab_text     = "ATT"
    ) + coord_cartesian(ylim = y_range)

    figA3b <- plot_event_study(
      het_rural_es %>% filter(group_var == groups[2]),
      outcome_label = "Universalism",
      color_main    = "#009E73",
      title_text    = paste0("B. ", groups[2]),
      subtitle_text = "",
      ylab_text     = "ATT"
    ) + coord_cartesian(ylim = y_range)

    figA3 <- figA3a + figA3b +
      plot_annotation(
        title   = "Heterogeneous Effects by Rurality",
        caption = "Note: Metro/non-metro classification based on Census urban-rural codes.\nSame y-axis scale. C-S estimator, state-clustered SEs."
      ) &
      theme(plot.title = element_text(size = 13, face = "bold"))

    save_figure(figA3, "figA3_het_rurality", w = 12, h = 6)

  } else {
    # Attempt on-the-fly if population data available
    if ("population" %in% names(analysis)) {
      cat("    No pre-computed rurality ES. Computing from population median split...\n")

      pop_median <- median(analysis$population, na.rm = TRUE)
      analysis <- analysis %>%
        mutate(
          rural_group = ifelse(population <= pop_median, "Smaller Places", "Larger Places"),
          id = as.numeric(factor(place_id))
        )

      rural_panels <- list()
      y_vals <- c()

      for (grp in c("Smaller Places", "Larger Places")) {
        df_sub <- analysis %>%
          filter(rural_group == grp, !is.na(log_income)) %>%
          mutate(gname = as.numeric(ifelse(treated, treat_year, 0)))

        cs_sub <- tryCatch({
          att_gt(
            yname   = ifelse("universalism_index" %in% names(df_sub),
                             "universalism_index", "log_univ_comm"),
            tname   = "year",
            idname  = "id",
            gname   = "gname",
            data    = df_sub,
            control_group = "notyettreated",
            anticipation  = 0,
            est_method    = "reg",
            clustervars   = "state_fips",
            bstrap  = TRUE,
            biters  = 200,
            print_details = FALSE
          )
        }, error = function(e) NULL)

        if (is.null(cs_sub)) next
        es_sub <- tryCatch(aggte(cs_sub, type = "dynamic", na.rm = TRUE), error = function(e) NULL)
        if (is.null(es_sub)) next

        es_df <- data.frame(time = es_sub$egt, att = es_sub$att.egt, se = es_sub$se.egt) %>%
          filter(!is.na(att))
        y_vals <- c(y_vals, es_df$att - 1.96 * es_df$se, es_df$att + 1.96 * es_df$se)

        rural_panels[[grp]] <- es_df
      }

      if (length(rural_panels) == 2) {
        y_range <- range(y_vals, na.rm = TRUE)
        grp_names <- names(rural_panels)

        pA <- plot_event_study(rural_panels[[1]], "Universalism", "#2166AC",
                               title_text = paste0("A. ", grp_names[1]),
                               subtitle_text = "", ylab_text = "ATT") +
          coord_cartesian(ylim = y_range)
        pB <- plot_event_study(rural_panels[[2]], "Universalism", "#009E73",
                               title_text = paste0("B. ", grp_names[2]),
                               subtitle_text = "", ylab_text = "ATT") +
          coord_cartesian(ylim = y_range)

        figA3 <- pA + pB +
          plot_annotation(
            title   = "Heterogeneous Effects by Place Size",
            caption = "Note: Median split on population. Same y-axis. C-S estimator, state-clustered SEs."
          ) &
          theme(plot.title = element_text(size = 13, face = "bold"))

        save_figure(figA3, "figA3_het_rurality", w = 12, h = 6)
      }
    } else {
      cat("    WARNING: No rurality data available. Skipping Figure A3.\n")
    }
  }

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# APPENDIX FIGURE A4: Placebo Outcomes
# ==============================================================================

cat("Generating Figure A4: Placebo Outcomes...\n")

tryCatch({

  # Check for pre-computed placebo ES data
  placebo_es <- NULL
  if (file.exists("data/placebo_es.csv")) {
    placebo_es <- read_csv("data/placebo_es.csv", show_col_types = FALSE)
  }

  if (!is.null(placebo_es)) {
    # Expect columns: time, att, se, outcome
    outcomes <- unique(placebo_es$outcome)

    placebo_panels <- list()
    for (oc in outcomes) {
      es_sub <- placebo_es %>% filter(outcome == oc)
      placebo_panels[[oc]] <- plot_event_study(
        es_sub,
        outcome_label = oc,
        color_main    = "grey50",
        color_pre     = "grey70",
        title_text    = oc,
        subtitle_text = "",
        ylab_text     = "ATT"
      )
    }

    figA4 <- wrap_plots(placebo_panels, ncol = 2) +
      plot_annotation(
        title   = "Placebo Outcomes: Variables That Should Not Be Affected",
        caption = "Note: If broadband affects these outcomes, it suggests confounding.\nC-S estimator, state-clustered SEs."
      ) &
      theme(plot.title = element_text(size = 13, face = "bold"))

    save_figure(figA4, "figA4_placebo", w = 12, h = 6)

  } else {
    # Compute on the fly for n_total_words and n_meetings
    cat("    No pre-computed placebo ES. Computing on the fly...\n")

    placebo_outcomes <- c("n_total_words", "n_meetings")
    placebo_outcomes <- placebo_outcomes[placebo_outcomes %in% names(analysis)]

    if (length(placebo_outcomes) == 0) {
      stop("No placebo outcome variables found in analysis data.")
    }

    did_data <- analysis %>%
      filter(!is.na(log_income)) %>%
      mutate(
        gname = as.numeric(ifelse(treated, treat_year, 0)),
        id    = as.numeric(factor(place_id))
      )

    placebo_panels <- list()
    for (oc in placebo_outcomes) {
      cs_plac <- tryCatch({
        att_gt(
          yname   = oc,
          tname   = "year",
          idname  = "id",
          gname   = "gname",
          data    = did_data,
          control_group = "notyettreated",
          anticipation  = 0,
          est_method    = "reg",
          clustervars   = "state_fips",
          bstrap  = TRUE,
          biters  = 200,
          print_details = FALSE
        )
      }, error = function(e) NULL)

      if (is.null(cs_plac)) next
      es_plac <- tryCatch(aggte(cs_plac, type = "dynamic", na.rm = TRUE), error = function(e) NULL)
      if (is.null(es_plac)) next

      es_df <- data.frame(time = es_plac$egt, att = es_plac$att.egt, se = es_plac$se.egt) %>%
        filter(!is.na(att))

      nice_label <- gsub("_", " ", gsub("^n_", "", oc))
      nice_label <- tools::toTitleCase(nice_label)

      placebo_panels[[oc]] <- plot_event_study(
        es_df,
        outcome_label = nice_label,
        color_main    = "grey50",
        color_pre     = "grey70",
        title_text    = nice_label,
        subtitle_text = "",
        ylab_text     = "ATT"
      )
    }

    if (length(placebo_panels) >= 1) {
      figA4 <- wrap_plots(placebo_panels, ncol = 2) +
        plot_annotation(
          title   = "Placebo Outcomes: Variables That Should Not Be Affected by Broadband",
          caption = "Note: If broadband affects meeting frequency or length, it suggests confounding.\nC-S estimator, state-clustered SEs."
        ) &
        theme(plot.title = element_text(size = 13, face = "bold"))

      save_figure(figA4, "figA4_placebo", w = 12, h = 6)
    } else {
      cat("    WARNING: No placebo event studies computed. Skipping.\n")
    }
  }

}, error = function(e) {
  cat(sprintf("    FAILED: %s\n", e$message))
})


# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n")
cat("================================================================\n")
cat("  07_figures.R: Figure Generation Complete\n")
cat("================================================================\n\n")

# List all generated figures
fig_files <- list.files("figures/", pattern = "\\.(pdf|png)$", full.names = FALSE)
if (length(fig_files) > 0) {
  cat("  Generated figures:\n")
  for (f in sort(fig_files)) {
    cat(sprintf("    %s\n", f))
  }
} else {
  cat("  WARNING: No figures were generated. Check error messages above.\n")
}

cat(sprintf("\n  Total: %d files (%d unique figures)\n",
            length(fig_files),
            length(unique(gsub("\\.(pdf|png)$", "", fig_files)))))
cat(sprintf("  Timestamp: %s\n", Sys.time()))
cat("================================================================\n")
