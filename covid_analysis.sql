-- Data pulled on 4/4/2023

SELECT 
    *
FROM
    covid_death
WHERE
    continent IS NOT NULL
ORDER BY STR_TO_DATE(date, '%d-%m-%y') , 3;

SELECT 
    *
FROM
    covid_vax
WHERE
    continent IS NOT NULL
ORDER BY STR_TO_DATE(date, '%d-%m-%y') , 3;

/* First problem is the format of the date its currently 1/3/20 and when I ORDER BY the date field its returns
1/3/20
1/3/21
Which is not what we want. So I when back into Excel and formatted the date column to 1/3/2021 */

/* That still did not work so I am using the str_to_date(date, '%d-%m-%y') to get the dates to order correctly */

-- Select data that we are going to be using
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_death
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Looking at TOTAL CASES vs TOTAL DEATHS
-- Showing the likelihood of dying if you contract covid in your country 
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    covid_death
WHERE
    location LIKE '%states%' AND continent IS NOT NULL
ORDER BY STR_TO_DATE(date, '%d-%m-%y');

-- Looking at TOTAL CASES vs Population
-- Shows what percentage of population got covid 
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentOfPopulationWithCOVID
FROM
    covid_death
WHERE
    location LIKE '%states%' AND continent IS NOT NULL
ORDER BY STR_TO_DATE(date, '%d-%m-%y');

-- Looking at Country with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentOfPopulationInfected
FROM
    covid_death
GROUP BY 1,2
ORDER BY PercentOfPopulationInfected DESC;

-- Look at the same results as above but only for countries with 50M or higher population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentOfPopulationInfected
FROM
    covid_death
WHERE
    population > 50000000
GROUP BY 1 , 2
ORDER BY PercentOfPopulationInfected DESC;

-- Showing continents with Highest Death Count per population
SELECT 
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covid_death
WHERE
    continent IS NOT NULL
GROUP BY 1
ORDER BY TotalDeathCount DESC;

-- In order to run the statement above I needed to change total_death from a Text data type to an INT 
/* This statement updates all rows in the covid_death table where the total_deaths column contains an 
empty string and sets the value to 0.

After modifying the existing data, you can execute the ALTER TABLE statement again to change the column definition: */

SET SQL_SAFE_UPDATES = 0;

UPDATE `covid19`.`covid_death` SET `total_deaths` = 0 WHERE `total_deaths` = '';

ALTER TABLE `covid19`.`covid_death` 
CHANGE COLUMN `total_deaths` `total_deaths` INT NULL DEFAULT 0;

-- GLOBAL NUMBERS
SELECT 
    date,
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM
    covid_death
WHERE
	continent IS NOT NULL
GROUP BY date
ORDER BY STR_TO_DATE(date, '%d-%m-%y'),2;

-- Overall Numbers
SELECT 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM
    covid_death
WHERE
	continent IS NOT NULL
ORDER BY STR_TO_DATE(date, '%d-%m-%y'),2; 

-- JOIN onto VAX table
-- Looking at Total POpulation vs Vaccination 
UPDATE `covid19`.`covid_vax` SET `new_vaccinations` = 0 WHERE `new_vaccinations` = '';
ALTER TABLE `covid19`.`covid_vax` 
CHANGE COLUMN `new_vaccinations` `new_vaccinations` INT NULL DEFAULT 0;

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM
    covid_death dea
        JOIN
    covid_vax vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY STR_TO_DATE(dea.date, '%d-%m-%y'),3;

-- USE CTE: to be able to use RollingPeopleVaccinated to get the % of population vaccinated
WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM
    covid_death dea
        JOIN
    covid_vax vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
-- ORDER BY STR_TO_DATE(dea.date, '%d-%m-%y'),3
)
SELECT *, (RollingPeopleVaccinated/ population) *100
FROM PopvsVac;
