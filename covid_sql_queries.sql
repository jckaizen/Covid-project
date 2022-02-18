SELECT *
FROM covid_death 
order by 1,2;


SELECT location,date, total_cases, new_cases, total_deaths, population
FROM covid_death 
order by 1,2;

-- Looking at Death Rate of dying from covid
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases::float)*100 as DeathPercentage
FROM covid_death
WHERE location ilike '%state%'
order by 1,2;

-- Shows what percentage of population got covid
SELECT location,date, total_cases, population, (total_cases/population::float)*100 as PopulationPercentage
FROM covid_death
WHERE location ilike '%state%'
order by 1,2;


-- Looking at countries with highest infection rate 
-- Can't get rid of null in calculated columns since you can't put aggrevate function in where statements
SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population::float))*100 as PopulationPercentage
FROM covid_death
group by location, population
order by PopulationPercentage DESC;

-- Death count by continent
-- Also filters out groupings that deal with income
SELECT location,MAX(total_deaths) as TotalDeathCount
FROM covid_death
WHERE continent is NULL AND location NOT ILIKE '%income'
group by location
order by TotalDeathCount DESC;


-- Showing highest death count
-- WHERE statement filter out whole contient and world groupings
SELECT location,MAX(total_deaths) as TotalDeathCount
FROM covid_death
WHERE continent is not NULL
group by location
order by TotalDeathCount DESC;

-- shows death count per day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)::float)*100 as DeathPercentage
FROM covid_death
where continent is not null
group by date
order by 1,2;


-- So it seems like the partition part, we're making our own total_vaccination. If you
-- didn't have the order by it doesn't show the slow increment to the total each day; it just shows you the straight up total for that location
-- WITH CTE (common table expressions)
WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM covid_death dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Creating view to store data for later visuzlations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM covid_death dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3; 
