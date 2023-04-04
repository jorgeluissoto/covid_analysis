-- Data pulled on 4/4/2023

SELECT *
FROM covid_death
ORDER BY 3,str_to_date(date, '%d-%m-%y');

SELECT *
FROM covid_vax
ORDER BY 3,str_to_date(date, '%d-%m-%y');

/* First problem is the format of the date its currently 1/3/20 and when I ORDER BY the date field its returns
1/3/20
1/3/21
Which is not what we want. So I when back into Excel and formatted the date column to 1/3/2021 */

/* That still did not work so I am using the str_to_date(date, '%d-%m-%y') to get the dates to order correctly */

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2;

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
    location LIKE '%states%'
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
    location LIKE '%states%'
ORDER BY STR_TO_DATE(date, '%d-%m-%y');
