
-- selecting data for analysis
SELECT * 
FROM PortfolioProject.dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date,  population , total_cases, new_cases, total_deaths
FROM PortfolioProject.dbo.CovidDeath
ORDER BY 1,2


-- Datewise total deaths vs total cases in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeath
WHERE location LIKE '%India'
ORDER BY 1,2;


-- Countries with highest death percentage per population

SELECT location, population, MAX(total_deaths) as HighestDeathCount,  (MAX(cast(total_deaths as float))/population)*100 as PercentPopulationDead
FROM PortfolioProject.dbo.CovidDeath
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentPopulationDead DESC;

--total number of deaths — Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as death_percent
FROM PortfolioProject.dbo.CovidDeath
WHERE continent IS NOT NULL 
ORDER BY 1,2;

--total death rate per continent

SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM PortfolioProject.dbo.CovidDeath
WHERE continent IS NULL
AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
GROUP BY location
ORDER BY 2 DESC

--Percentage Infected Population per Location

SELECT location, population, MAX(cast (total_cases as bigint)) as highest_infection_Count,  Max((cast(total_cases as float)/cast(population as float)))*100 as percent_infected_population
FROM PortfolioProject.dbo.CovidDeath
GROUP BY location, population
ORDER BY percent_infected_population DESC

--Total Population vs amount of people vaccinated

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeath cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL ;

-- Determining the percentage of people vaccinated per country using CTE

WITH VacData (continent, location, date, population, new_vaccinations, rolling_people_vaccinated ) AS
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeath cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL)

SELECT *, (CONVERT(float,rolling_people_vaccinated)/population)*100 AS percent_population_vaccinated 
FROM VacData

--Creating a temporary table for vacciantions data obtained for further use

DROP TABLE IF EXISTS CovidVaccinationsData
CREATE TABLE CovidVaccinationsData
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO CovidVaccinationsData
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeath cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
SELECT *, (CONVERT(float,rolling_people_vaccinated)/population)*100 AS percent_population_vaccinated 
From CovidVaccinationsData

