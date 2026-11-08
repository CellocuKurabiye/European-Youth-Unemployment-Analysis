install.packages(c(
  "eurostat",
  "dplyr",
  "ggplot2",
  "readr"
))
library(eurostat)
library(dplyr)
library(ggplot2)
library(readr)

# European Youth Unemployment Analysis
# Data Source: Eurostat
# Dataset: une_rt_a
# Period: 2015-2025

youth_data <- get_eurostat(
  id = "une_rt_a",
  time_format = "raw",
  filters = list(
    freq = "A",
    age = "Y15-24",
    sex = c("T", "M", "F"),
    unit = "PC_ACT",
    geo = c("DE", "ES", "IT", "PL", "TR"),
    sinceTimePeriod = 2015,
    untilTimePeriod = 2025
  )
)

dim(youth_data)

names(youth_data)

head(youth_data, 10)


# STEP 2: Data Cleaning & Preparation

clean_data <- youth_data %>%
  mutate(
    country = recode(
      geo,
      "DE" = "Germany",
      "ES" = "Spain",
      "IT" = "Italy",
      "PL" = "Poland",
      "TR" = "Turkey" #Türkiye
    ),
    
    gender = recode(
      sex,
      "T" = "Total",
      "M" = "Male",
      "F" = "Female"
    ),
    
    year = as.integer(as.character(time)),
    
    unemployment_rate = as.numeric(values)
  ) %>%
  select(
    country,
    year,
    gender,
    unemployment_rate
  ) %>%
  arrange(country, year, gender)

# View the cleaned dataset
head(clean_data, 10)


# Check missing unemployment values

clean_data %>%
  summarise(
    total_observations = n(),
    missing_values = sum(is.na(unemployment_rate)),
    minimum_year = min(year),
    maximum_year = max(year)
  )


# Check observations by country and gender

clean_data %>%
  count(country, gender, name = "observations")

# STEP 3: Descriptive Statistics

# Select total youth unemployment rates

total_data <- clean_data %>%
  filter(gender == "Total") %>%
  arrange(country, year)

# Check the dataset
dim(total_data)
head(total_data, 10)

# Calculate descriptive statistics by country

country_summary <- total_data %>%
  group_by(country) %>%
  summarise(
    mean_rate = round(mean(unemployment_rate), 2),
    sd_rate = round(sd(unemployment_rate), 2),
    min_rate = min(unemployment_rate),
    max_rate = max(unemployment_rate),
    rate_2015 = unemployment_rate[year == 2015],
    rate_2025 = unemployment_rate[year == 2025],
    change_pp = round(rate_2025 - rate_2015, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_rate))

# Display results
print(country_summary, width = Inf)

# STEP 4: Data Visualization

# Youth unemployment trends by country

trend_plot <- ggplot(
  total_data,
  aes(
    x = year,
    y = unemployment_rate,
    color = country,
    group = country
  )
) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  scale_x_continuous(
    breaks = 2015:2025
  ) +
  labs(
    title = "Youth Unemployment Trends in Europe",
    subtitle = "Selected countries, 2015–2025",
    x = "Year",
    y = "Youth Unemployment Rate (%)",
    color = "Country",
    caption = "Source: Eurostat (une_rt_a)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Display the graph
print(trend_plot)

# Save the graph as a high-resolution PNG

ggsave(
  filename = "youth_unemployment_trends.png",
  plot = trend_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# STEP 5: Gender Gap Analysis

library(tidyr)

# Select female and male unemployment data

gender_data <- clean_data %>%
  filter(gender %in% c("Female", "Male")) %>%
  select(country, year, gender, unemployment_rate) %>%
  pivot_wider(
    names_from = gender,
    values_from = unemployment_rate
  ) %>%
  mutate(
    gender_gap = Female - Male
  ) %>%
  arrange(country, year)

# Display first observations

head(gender_data, 10)

# Calculate average gender gaps by country

gender_summary <- gender_data %>%
  group_by(country) %>%
  summarise(
    mean_female = round(mean(Female), 2),
    mean_male = round(mean(Male), 2),
    mean_gap = round(mean(gender_gap), 2),
    min_gap = round(min(gender_gap), 2),
    max_gap = round(max(gender_gap), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_gap))

print(gender_summary, width = Inf)

# STEP 6: Gender Gap Visualization

gender_gap_plot <- ggplot(
  gender_data,
  aes(
    x = year,
    y = gender_gap,
    color = country,
    group = country
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "grey40"
  ) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  scale_x_continuous(
    breaks = 2015:2025
  ) +
  labs(
    title = "Gender Gap in Youth Unemployment",
    subtitle = "Female minus male unemployment rates, 2015–2025",
    x = "Year",
    y = "Gender Gap (Percentage Points)",
    color = "Country",
    caption = "Source: Eurostat (une_rt_a)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 15
    ),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Display the graph
print(gender_gap_plot)

# Save the gender gap visualization

ggsave(
  filename = "gender_gap_trends.png",
  plot = gender_gap_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# STEP 7: Gender Gap Change Analysis

gender_change <- gender_data %>%
  group_by(country) %>%
  summarise(
    gap_2015 = gender_gap[year == 2015],
    gap_2025 = gender_gap[year == 2025],
    mean_gap = mean(gender_gap),
    female_higher_years = sum(gender_gap > 0),
    male_higher_years = sum(gender_gap < 0),
    equal_years = sum(gender_gap == 0),
    .groups = "drop"
  ) %>%
  mutate(
    change_pp = gap_2025 - gap_2015
  ) %>%
  mutate(
    across(
      c(gap_2015, gap_2025, mean_gap, change_pp),
      ~ round(.x, 2)
    )
  ) %>%
  arrange(desc(change_pp))

print(gender_change, width = Inf)

# STEP 8: Export Research Results

# Create a folder for research outputs
dir.create("results", showWarnings = FALSE)

# Export descriptive statistics
write_csv(
  country_summary,
  "results/country_summary.csv"
)

# Export average gender gaps
write_csv(
  gender_summary,
  "results/gender_summary.csv"
)

# Export gender gap changes
write_csv(
  gender_change,
  "results/gender_change.csv"
)

# Check exported files
list.files("results")

# Save research figures

ggsave(
  "results/youth_unemployment_trends.png",
  plot = trend_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  "results/gender_gap_trends.png",
  plot = gender_gap_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Check all research outputs
list.files("results")

# STEP 9: Data Validation

validation_summary <- clean_data %>%
  summarise(
    total_observations = n(),
    
    missing_values = sum(is.na(unemployment_rate)),
    
    duplicate_records = n() -
      n_distinct(country, year, gender),
    
    invalid_rates = sum(
      unemployment_rate < 0 |
        unemployment_rate > 100,
      na.rm = TRUE
    ),
    
    number_of_countries = n_distinct(country),
    
    number_of_years = n_distinct(year),
    
    gender_categories = n_distinct(gender)
  )

print(validation_summary, width = Inf)

# Create data directory
dir.create("data", showWarnings = FALSE)

# Save cleaned dataset
write_csv(
  clean_data,
  "data/youth_unemployment_clean_2015_2025.csv"
)

#---------------------------------------------------------
# Verify file
list.files("data")

# Recreate country summary with corrected country names

country_summary <- total_data %>%
  group_by(country) %>%
  summarise(
    mean_rate = round(mean(unemployment_rate), 2),
    sd_rate = round(sd(unemployment_rate), 2),
    min_rate = min(unemployment_rate),
    max_rate = max(unemployment_rate),
    rate_2015 = unemployment_rate[year == 2015],
    rate_2025 = unemployment_rate[year == 2025],
    change_pp = round(rate_2025 - rate_2015, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_rate))

# Check country names
print(country_summary$country)

# Overwrite the old CSV file
readr::write_csv(
  country_summary,
  "results/country_summary.csv"
)
#-----------------------------------------------------------

# STEP 13: Eurostat Data Quality Check

# Download original data with quality flags

flagged_data <- eurostat::get_eurostat(
  id = "une_rt_a",
  time_format = "raw",
  keepFlags = TRUE,
  stringsAsFactors = FALSE
)

# Check column names
names(flagged_data)

# View first observations
head(flagged_data, 3)

# STEP 13.2: Quality Flags Analysis

# Filter data for our study

study_flags <- flagged_data %>%
  filter(
    freq == "A",
    age == "Y15-24",
    unit == "PC_ACT",
    sex %in% c("T", "M", "F"),
    geo %in% c("DE", "ES", "IT", "PL", "TR"),
    as.integer(TIME_PERIOD) %in% 2015:2025
  ) %>%
  mutate(
    year = as.integer(TIME_PERIOD),
    flag_status = if_else(
      is.na(flags) | trimws(flags) == "",
      "no_flag",
      flags
    )
  )

# Check total observations
nrow(study_flags)

# Count quality flags
study_flags %>%
  count(flag_status, name = "observations")

# Display observations with quality flags

flagged_observations <- study_flags %>%
  filter(flag_status != "no_flag") %>%
  select(
    geo,
    year,
    sex,
    values,
    flags
  ) %>%
  arrange(geo, year, sex)

print(flagged_observations, n = 50)

# STEP 13.3: Quality Flags Summary

quality_notes <- flagged_observations %>%
  mutate(
    country = recode(
      geo,
      "DE" = "Germany",
      "ES" = "Spain",
      "IT" = "Italy",
      "PL" = "Poland",
      "TR" = "Turkey"
    ),
    flag_meaning = case_when(
      flags == "b" ~ "Break in time series",
      flags == "d" ~ "Definition differs",
      TRUE ~ "Other flag"
    )
  ) %>%
  distinct(country, year, flags, flag_meaning) %>%
  arrange(country, year)

# Display the summary
print(quality_notes, n = Inf)

# Save the summary
readr::write_csv(
  quality_notes,
  "results/quality_flags_summary.csv"
)

# STEP 14: GitHub Portfolio Preparation

# Check project files

files_to_check <- c(
  "analysis.R",
  "research_report.qmd",
  "data/youth_unemployment_clean_2015_2025.csv",
  "results/country_summary.csv",
  "results/gender_summary.csv",
  "results/gender_change.csv",
  "results/quality_flags_summary.csv",
  "results/youth_unemployment_trends.png",
  "results/gender_gap_trends.png"
)

file_check <- data.frame(
  file = files_to_check,
  exists = file.exists(files_to_check)
)

print(file_check, row.names = FALSE)