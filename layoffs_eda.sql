
-- 1. Total Layoffs Between 2020 and 2023
SELECT SUM(total_laid_off) AS total_layoffs_2020_2023
FROM layoffs_cleaned
WHERE YEAR(`date`) BETWEEN 2020 AND 2023;

-- 2. Industry With the Highest Layoff Impact
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 3. Layoffs by Country — Global Impact View
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY country
ORDER BY total_layoffs DESC;

-- 4. Annual Layoff Trend — Year Over Year
SELECT YEAR(`date`) AS layoff_year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY layoff_year
ORDER BY layoff_year DESC;

-- 5. Monthly Layoffs With Cumulative Trend
WITH monthly_layoffs AS (
  SELECT SUBSTRING(`date`, 1, 7) AS layoff_month,
         SUM(total_laid_off) AS monthly_total
  FROM layoffs_cleaned
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY layoff_month
  ORDER BY layoff_month ASC
)
SELECT layoff_month, monthly_total,
       SUM(monthly_total) OVER (ORDER BY layoff_month) AS cumulative_total
FROM monthly_layoffs;

-- 6. Top Companies With Most Layoffs Per Year
WITH yearly_company_layoffs AS (
  SELECT SUBSTRING(`date`, 1, 4) AS layoff_year,
         company,
         SUM(total_laid_off) AS total_layoffs
  FROM layoffs_cleaned
  WHERE `date` IS NOT NULL
  GROUP BY layoff_year, company
),
ranked_company_layoffs AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY layoff_year ORDER BY total_layoffs DESC) AS rank_in_year
  FROM yearly_company_layoffs
)
SELECT *
FROM ranked_company_layoffs
ORDER BY layoff_year, rank_in_year;

-- 7. Funding vs Shutdown — Companies With Highest Capital But Still Failed
SELECT company, total_laid_off, funds_raised_millions
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 10;

-- 8. Layoffs by Funding Stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY stage
ORDER BY total_layoffs DESC;
