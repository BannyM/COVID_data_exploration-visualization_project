/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM [Portfolio Project]..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
	FROM [Portfolio Project]..covid_vaccinations$
	WHERE continent IS NOT NULL
	ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM [Portfolio Project]..covid_deaths$
	order by 1,2

-- Total Cases vs Total Deaths in U.S.
-- Shows likelihood of dying if you contract COVID in U.S.
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
	FROM [Portfolio Project]..covid_deaths$
	WHERE location like '%states%'
	ORDER BY 1,2

-- Total Cases vs Population in U.S.
-- Shows what percentage of population U.S. got COVID
SELECT Location, date, total_cases, population,(total_cases/population)*100 AS PercentPopulationInfection
	FROM [Portfolio Project]..covid_deaths$
	WHERE location like '%states%'
	ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfection
	FROM [Portfolio Project]..covid_deaths$
	--WHERE location like '%states%'
	GROUP BY location, population
	ORDER BY PercentPopulationInfection DESC
	



-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
	FROM [Portfolio Project]..covid_deaths$
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY TotalDeathCount desc
	
-- Breaking stats down by continent and showing countries with highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
	FROM [Portfolio Project]..covid_deaths$
	WHERE continent IS NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT))AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
	FROM [Portfolio Project]..covid_deaths$
	WHERE continent IS NOT NULL
	--GROUP BY date
	ORDER BY 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
JOIN [Portfolio Project]..covid_vaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac(continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
JOIN [Portfolio Project]..covid_vaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
JOIN [Portfolio Project]..covid_vaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store date for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
JOIN [Portfolio Project]..covid_vaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
