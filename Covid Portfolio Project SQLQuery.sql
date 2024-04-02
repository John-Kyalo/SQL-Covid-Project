SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%Africa%'
AND continent IS NOT NULL
ORDER BY 1, 2

SELECT location, date, total_cases,  population, (total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
ORDER BY 1, 2


SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc



SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM dbo.CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount desc

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM dbo.CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

 --Temp Table
 DROP TABLE if EXISTS #PercentPopulationVaccinated
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
 SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--VIEWS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated