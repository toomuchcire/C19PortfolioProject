SELECT * FROM dbo.CovidDeaths
ORDER BY 3,4

SELECT * FROM dbo.CovidVaccinations
ORDER BY 3,4

----Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2


----Looking at total cases vs total deaths
----Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%united states%'
ORDER BY 1,2


----Looking at total cases vs population
----Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageOfPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%united states%'
ORDER BY 1,2


----Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC



----Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


----Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Joining covid deaths with covid vaccinations table
--Looking at total population vs vacconations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Creating view to store data for later visualizations

CREATE VIEW PopvsVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3