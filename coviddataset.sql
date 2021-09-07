SELECT *
FROM PortfolioProject..CovidDeaths


SELECT *
FROM PortfolioProject..CovidVaccinations


-- South Asia data for tableau visualization
WITH south_asia_merged_data AS
(
 SELECT d.location AS location, population, CAST(d.date AS DATE) AS date, CAST(ISNULL(d.new_cases, 0) AS INT) AS new_cases,
		CAST(ISNULL(d.total_deaths, 0) AS INT) AS total_deaths, CAST(ISNULL(d.new_deaths, 0) AS INT) AS new_deaths,
		CAST(ISNULL(v.new_vaccinations, 0) AS INT) AS new_vaccinations
 FROM PortfolioProject..CovidDeaths AS d
 JOIN PortfolioProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
 WHERE d.location = 'Sri Lanka'
	OR d.location = 'Afghanistan'
	OR d.location = 'Nepal'
	OR d.location = 'Bhutan'
	OR d.location = 'Pakistan'
	OR d.location = 'India'
	OR d.location = 'Bangladesh'
	OR d.location = 'Maldives'
 GROUP BY d.location, d.date, d.population, d.new_cases, d.total_deaths, d.new_deaths,
	v.new_vaccinations
)
SELECT location, population, date, new_cases, total_deaths, new_deaths,
		new_vaccinations, (new_deaths/population)*100 AS deaths_as_pct_of_population,
		(new_cases/population)*100 AS cases_as_pct_of_population,
		(new_vaccinations/population)*100 AS vaccinations_as_pct_of_population
FROM south_asia_merged_data


-- Sri Lanka
SELECT d.location AS location, CAST(d.date AS DATE) AS date, ISNULL(d.new_cases, 0) AS new_cases, ISNULL(d.total_deaths, 0) AS total_deaths, ISNULL(d.new_deaths, 0) AS new_deaths,
		ISNULL(v.new_vaccinations, 0) AS new_vaccinations
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location = 'Sri Lanka'
GROUP BY d.location, d.date, new_cases, total_deaths, new_deaths, new_vaccinations


-- Percentage of covid infections in Sri Lanka
WITH no_null AS
-- Turn NULL values into 0
(SELECT location, ISNULL(new_cases, 0) AS new_cases_update, ISNULL(new_deaths, 0) AS new_deaths_update, population
 FROM PortfolioProject..CovidDeaths
)
-- CAST used to convert varchar columns to int type columns in order to do calculations
SELECT location, SUM(CAST(new_cases_update AS INT)) AS total_new_cases_update , SUM(CAST(new_deaths_update AS INT)) AS total_new_deaths_update,
	population, (SUM(CAST(new_deaths_update AS INT))/population)*100 AS percentage_of_deaths
FROM no_null
WHERE location = 'Sri Lanka'
GROUP BY location, population
ORDER BY total_new_deaths_update DESC


-- List of countries as percentage of deaths from respective total populations
WITH no_null AS
(SELECT location, ISNULL(new_cases, 0) AS new_cases_update, ISNULL(new_deaths, 0) AS new_deaths_update, population, continent
 FROM PortfolioProject..CovidDeaths
)
SELECT location, SUM(CAST(new_cases_update AS INT)) AS total_new_cases_update , SUM(CAST(new_deaths_update AS INT)) AS total_new_deaths_update,
	population, SUM(CAST(new_deaths_update AS INT))/population*100 AS percentage_of_deaths
FROM no_null
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_of_deaths DESC


-- Total death count by each continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	AND location <> 'World'
	AND location <> 'European Union'
GROUP BY location
ORDER BY total_death_count DESC


-- Total deaths compared with gdp per capita and population density
SELECT v.location AS country, v.gdp_per_capita AS gdp_per_capita, v.population_density AS pop_density,
	SUM(CAST(d.new_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidVaccinations AS v
JOIN PortfolioProject..CovidDeaths AS d
	ON v.location = d.location
	AND v.date = d.date
WHERE d.continent IS NOT NULL
GROUP BY v.location, v.gdp_per_capita, v.population_density
ORDER BY pop_density DESC


-- Total
SELECT v.location AS country,
	SUM(CAST(d.new_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidVaccinations AS v
JOIN PortfolioProject..CovidDeaths AS d
	ON v.location = d.location
	AND v.date = d.date
WHERE d.continent IS NOT NULL
GROUP BY v.location
ORDER BY total_death_count DESC