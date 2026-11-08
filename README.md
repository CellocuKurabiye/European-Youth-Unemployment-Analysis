# European Youth Unemployment Analysis

### A Comparative Statistical Study (2015-2025)

**Author:** Hamit Kaan Parlak  
**Field:** Statistics and Data Analysis  
**Tools:** R, dplyr, ggplot2, tidyr, Quarto  
**Data Source:** Eurostat

## About the Project

This project analyzes youth unemployment rates in five countries between 2015 and 2025 using R.

The selected countries are Germany, Spain, Italy, Poland, and Turkey.

The main goal is to compare unemployment trends and study differences between young women and men.

The project uses real data from Eurostat.

## Research Questions

1. How did youth unemployment rates change between 2015 and 2025?
2. Which countries had the highest and lowest unemployment rates?
3. How did unemployment rates differ between young women and men?
4. How did the gender gap change over time?

## Dataset

The data comes from Eurostat.

- Dataset code: `une_rt_a`
- Age group: 15-24 years
- Period: 2015-2025
- Countries: 5
- Observations: 165
- Gender groups: Female, Male, Total

Youth unemployment rates are measured as a percentage of the youth labor force.

The dataset was checked for missing values, duplicate records, and invalid unemployment rates.

## Methods

The analysis was completed using R.

The main steps included:

- Data collection from Eurostat
- Data cleaning and preparation
- Descriptive statistical analysis
- Comparison of unemployment rates
- Gender gap calculations
- Data visualization with ggplot2
- Data quality checks
- Research reporting with Quarto

The gender gap was calculated as:

Gender Gap = Female Rate - Male Rate

A positive value means that the unemployment rate is higher among young women.

## Main Findings

**1. Youth unemployment decreased**

All five countries had lower youth unemployment rates in 2025 compared with 2015.

Spain and Italy had the largest decreases.

**2. Germany had the lowest average rate**

Germany had the lowest average youth unemployment rate during the study period.

**3. Turkey had the largest average gender gap**

Turkey had an average female-male unemployment gap of 8.17 percentage points.

The gap increased from 5.7 percentage points in 2015 to 10.5 percentage points in 2025.

**4. Gender differences varied across countries**

In Germany, young men had higher unemployment rates throughout the study period.

In Turkey and Italy, young women had higher rates in every year.

## Visualizations

### Youth Unemployment Trends

![Youth Unemployment Trends](results/youth_unemployment_trends.png)

### Gender Gap Trends

![Gender Gap Trends](results/gender_gap_trends.png)

## Data Quality and Limitations

The analysis includes 165 observations.

Eurostat quality checks identified:

- 138 observations without quality flags
- 12 observations with time series break flags
- 15 observations with definition difference flags

These flags may affect comparisons between years and countries.

The project uses descriptive statistics and visualization. It does not test causal relationships.

## Project Files

- `analysis.R` - R code for data analysis
- `research_report.qmd` - Quarto research report
- `index.html` - HTML research report
- `data/` - Cleaned data
- `results/` - Tables, figures, and quality checks

## Data Source

Eurostat: Unemployment by sex and age - annual data.

Dataset: `une_rt_a`

https://doi.org/10.2908/une_rt_a

Data accessed: 8 November 2026.

## Author

**Hamit Kaan Parlak**

Statistics Student  
Ondokuz Mayis University  
Minor in Industrial Engineering