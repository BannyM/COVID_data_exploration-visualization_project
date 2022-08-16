/* SQL Queries for tables to be used on Tableau dashboard.  
Visualizations can be viewed at https://public.tableau.com/app/profile/banny.munro/viz/covid_data_16588514334160/Dashboard1
*/

--Table 1 - Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases) AS DeathPercentage
FROM [Portfolio Project]..covid_deaths$
WHERE continent is not null 
ORDER BY 1,2

--Table 2 - Total Deaths per Continent
SELECT Location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project]..covid_deaths$
WHERE continent is null 
and Location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Table 3 - Percentage of Population Infected by Country
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/Population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Table 4 - Percentage of Population Infected 
SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/Population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths$
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC
