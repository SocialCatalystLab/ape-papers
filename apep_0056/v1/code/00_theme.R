# =============================================================================
# Paper 72: APEP Theme for Figures
# =============================================================================
# Publication-quality theme for all figures
# =============================================================================

library(ggplot2)

# APEP color palette
apep_colors <- c(
  "blue" = "#2166AC",
  "red" = "#B2182B",
  "gray" = "#636363",
  "light_blue" = "#92C5DE",
  "light_red" = "#F4A582",
  "dark_gray" = "#252525"
)

# Publication-ready theme
theme_apep <- function(base_size = 12, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Text elements
      plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0),
      plot.subtitle = element_text(size = rel(1.0), hjust = 0, color = "gray40"),
      plot.caption = element_text(size = rel(0.8), hjust = 0, color = "gray50"),

      # Axis elements
      axis.title = element_text(size = rel(1.0)),
      axis.text = element_text(size = rel(0.9)),
      axis.line = element_line(color = "gray30", linewidth = 0.4),
      axis.ticks = element_line(color = "gray30", linewidth = 0.3),

      # Panel elements
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9)),
      legend.text = element_text(size = rel(0.8)),
      legend.background = element_rect(fill = "white", color = NA),

      # Facets
      strip.text = element_text(face = "bold", size = rel(1.0)),
      strip.background = element_rect(fill = "gray95", color = NA),

      # Margins
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Set as default theme
theme_set(theme_apep())

cat("APEP theme loaded.\n")
