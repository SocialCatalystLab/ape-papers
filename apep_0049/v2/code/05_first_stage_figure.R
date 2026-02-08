# First Stage Figure: Funding Eligibility Discontinuity
# Shows the sharp statutory discontinuity in Section 5307 eligibility

library(tidyverse)
library(ggplot2)

# Set APEP theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = 14, hjust = 0),
      plot.subtitle = element_text(size = 11, color = "grey30", hjust = 0),
      plot.caption = element_text(size = 9, color = "grey50", hjust = 1),
      legend.position = "bottom",
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 9),
      strip.text = element_text(face = "bold", size = 11)
    )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

# Create data showing the first stage
# Section 5307 formula funding is approximately $30-50 per capita for eligible areas
# Areas below 50k get $0

population_grid <- seq(30000, 70000, by = 100)

funding_data <- tibble(
  population = population_grid,
  running_var = population - 50000,
  eligible = population >= 50000,
  # Formula funding: approximately $40 per capita (middle of $30-50 range)
  per_capita_funding = ifelse(population >= 50000, 40, 0),
  total_funding_millions = (per_capita_funding * population) / 1e6
)

# Create the first stage plot
p_first_stage <- ggplot(funding_data, aes(x = running_var / 1000, y = total_funding_millions)) +
  geom_line(aes(color = factor(eligible)), linewidth = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.8) +
  geom_point(data = funding_data %>% filter(population %in% c(49900, 50100)),
             aes(color = factor(eligible)), size = 4) +
  scale_color_manual(
    values = c("FALSE" = apep_colors[2], "TRUE" = apep_colors[1]),
    labels = c("FALSE" = "Ineligible", "TRUE" = "Eligible"),
    name = "Section 5307 Status"
  ) +
  scale_x_continuous(
    breaks = seq(-20, 20, by = 5),
    labels = function(x) paste0(ifelse(x >= 0, "+", ""), x, "k")
  ) +
  scale_y_continuous(
    labels = scales::dollar_format(prefix = "$", suffix = "M")
  ) +
  labs(
    title = "First Stage: Section 5307 Funding Eligibility",
    subtitle = "Sharp discontinuity at the 50,000 population threshold",
    x = "Population Relative to Threshold (thousands)",
    y = "Annual Formula Funding",
    caption = "Note: Funding calculated as ~$40 per capita. Areas below 50,000 receive $0 Section 5307 formula funding."
  ) +
  theme_apep() +
  annotate("text", x = -10, y = 0.5,
           label = "No Section 5307\nformula funding",
           color = apep_colors[2], size = 3.5, fontface = "italic") +
  annotate("text", x = 10, y = 3.5,
           label = "Eligible for\nformula funding",
           color = apep_colors[1], size = 3.5, fontface = "italic")

# Save
ggsave(
  "./figures/fig8_first_stage.png",
  plot = p_first_stage,
  width = 10, height = 7, dpi = 300,
  bg = "white"
)

cat("First stage figure saved to figures/fig8_first_stage.png\n")
