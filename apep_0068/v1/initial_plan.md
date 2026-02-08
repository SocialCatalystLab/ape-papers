# Initial Research Plan

## Paper Title
**Credit Markets, Social Networks, and America's Divided Geography: The Anatomy of Elite Clustering and Political Polarization**

## Research Question
How do credit access patterns, cross-class social networks (economic connectedness), and elite institution concentration interact geographically across U.S. counties? Are these economic and social divides correlated with political polarization?

## Motivation
The United States appears increasingly divided—economically, socially, and politically. This paper provides a comprehensive descriptive portrait of how three fundamental aspects of American opportunity—access to credit, social connections across class boundaries, and proximity to elite institutions—cluster geographically. We then examine whether these patterns correlate with political polarization.

Understanding these patterns matters for policy because:
1. Credit access shapes entrepreneurship, homeownership, and wealth building
2. Social networks determine job opportunities and information flows
3. Elite institution access drives intergenerational mobility
4. Political polarization affects policy-making capacity

## Identification Strategy
This is a **descriptive and correlational study**, not a causal analysis. We make no causal claims. Instead, we provide:
1. Rich visual documentation of geographic patterns
2. Correlation matrices showing relationships between variables
3. Regression analysis controlling for observable confounders
4. Geographic clustering analysis

## Primary Data Sources

### Credit Access (Opportunity Insights)
- Credit scores by county (2020)
- Student loan balances by county
- Mortgage balances by county
- Auto loan balances by county
- Credit card balances by county
- Delinquency rates by county

### Social Capital (Chetty et al. 2022)
- Economic connectedness (EC): share of high-SES friends among low-SES individuals
- Friending bias: tendency to befriend own-SES after controlling for exposure
- Clustering: density of friend networks
- 100×100 SES friendship matrix

### Elite Institutions (Chetty et al. 2023)
- Attendance rates at 139 selective colleges by parental income percentile
- Geographic distribution of elite college students

### County Covariates
- Demographics (race, education, income)
- Employment rates
- Housing characteristics
- Urban/rural classification

### Political Data
- County presidential vote shares 2016, 2020, 2024
- Vote share changes (polarization measure)
- Turnout rates

## Key Variables

### Outcome Variables (Part 2)
- GOP vote share 2020
- Change in GOP vote share 2016-2020, 2020-2024
- Absolute change (polarization intensity)

### Explanatory Variables
- Credit score (standardized)
- Economic connectedness (standardized)
- Elite college exposure index
- Delinquency rate
- Student loan burden

### Control Variables
- Median household income
- Education (% college)
- Demographics (% white, % black, % Hispanic)
- Urban/rural indicator
- Employment rate
- Population density

## Planned Exhibits

### Part 1: Descriptive Geography (Figures 1-5)

**Figure 1: The Credit Score Map of America**
- Choropleth: County-level average credit scores
- Highlights regional patterns (Northeast vs. South, urban vs. rural)

**Figure 2: The Social Capital Map of America**
- Choropleth: Economic connectedness by county
- Shows where cross-class friendships are common vs. rare

**Figure 3: Elite Institution Geography**
- Map showing where students at top 139 colleges come from
- Reveals concentration in certain metro areas and counties

**Figure 4: The Friendship Matrix**
- Heatmap of 100×100 SES friending probabilities
- Visual demonstration of class segregation in social networks

**Figure 5: Correlation Structure**
- Scatter plot matrix showing credit-social capital-elite relationships
- Demonstrates how these dimensions co-vary

### Part 2: Political Correlations (Figures 6-10)

**Figure 6: Political Geography Baseline**
- Choropleth: GOP vote share 2020
- Establishes geographic political variation

**Figure 7: Polarization Trends**
- Choropleth: Change in GOP vote share 2016-2024
- Shows which areas became more/less Republican

**Figure 8: Credit and Politics**
- Scatter plot: Credit score vs. vote share
- Binscatter with controls

**Figure 9: Social Capital and Politics**
- Scatter plot: Economic connectedness vs. vote share
- Key relationship of paper

**Figure 10: Multidimensional Clustering**
- Geographic clusters based on credit-social-political patterns
- Identifies "types" of American counties

### Appendix (A1-A10)

A1-A5: Individual credit metric maps (student loans, mortgages, etc.)
A6: Regional breakdowns
A7: Urban/rural decomposition
A8: Robustness to alternative specifications
A9: Time series analysis
A10: Data quality diagnostics

## Table Structure

**Table 1: Summary Statistics**
- All key variables, N, mean, SD, min, max by data source

**Table 2: Correlation Matrix**
- Credit variables, social capital, politics

**Table 3: OLS Regressions—Credit and Politics**
- DV: GOP vote share 2020
- Progressively add controls

**Table 4: OLS Regressions—Social Capital and Politics**
- DV: GOP vote share 2020
- Focus on economic connectedness

**Table 5: Combined Model**
- All explanatory variables together
- Which relationships persist after controlling for others?

**Table 6: Polarization Analysis**
- DV: Change in vote share
- What predicts which counties became more partisan?

## Analysis Plan

### Step 1: Data Assembly
1. Merge all Chetty datasets by county FIPS
2. Merge voting data by county FIPS
3. Create standardized variables
4. Handle missing data (document)

### Step 2: Descriptive Statistics
1. Generate Table 1
2. Check distributions, outliers
3. Create correlation matrix (Table 2)

### Step 3: Mapping
1. Create all choropleth maps (Figures 1-3, 6-7)
2. Ensure consistent color scales
3. Add state boundaries, labels

### Step 4: Visualization
1. Friendship matrix heatmap (Figure 4)
2. Scatter plots with fit lines (Figures 5, 8-9)
3. Clustering visualization (Figure 10)

### Step 5: Regression Analysis
1. Run OLS specifications for Tables 3-6
2. Check robustness to different specifications
3. Generate coefficient plots

### Step 6: Write Paper
1. Introduction: Motivation and preview
2. Data: Description of all sources
3. Part 1: Descriptive findings
4. Part 2: Political correlations
5. Discussion: Implications, limitations
6. Conclusion

## Expected Findings (Hypotheses)

1. **Credit geography mirrors social geography**: High-credit areas likely have higher economic connectedness
2. **Elite concentration is geographically narrow**: A small number of counties produce most elite college students
3. **Credit divides correlate with political divides**: Lower credit areas may lean Republican
4. **Social capital correlates with political moderation**: Higher economic connectedness may predict less polarization
5. **These relationships persist after controls**: Economic and social factors matter beyond demographics

## Limitations (To Acknowledge)

1. **Correlation, not causation**: We cannot claim credit causes political behavior or vice versa
2. **Ecological fallacy**: County-level patterns don't necessarily apply to individuals
3. **Missing variables**: Many potential confounders unobserved
4. **Measurement**: Credit scores and social capital are imperfect proxies
5. **Timing**: Credit data from 2020, social capital from 2022, voting from 2016-2024

## Timeline
1. Data assembly and cleaning: Day 1
2. Descriptive statistics and correlations: Day 1
3. All maps and visualizations: Day 1-2
4. Regression analysis: Day 2
5. Paper writing: Day 2-3
6. Review and revision: Day 3

## Software
- **R** for all analysis
- **Packages**: tidyverse, sf, ggplot2, modelsummary, fixest, viridis
