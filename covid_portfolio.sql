use `Portfolio Project`;
SELECT 
    *
FROM
    `Portfolio Project`.coviddeaths
ORDER BY 3 , 4;

SELECT 
    *
FROM
    `Portfolio Project`.covidvaccinations
ORDER BY 3 , 4;

-- Select data that we are going to be using
SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    `Portfolio Project`.coviddeaths
ORDER BY 1 , 2;

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as DeathPercentage
FROM
    `Portfolio Project`.coviddeaths
WHERE
	location like '%state%'
ORDER BY 1 , 2;


-- Looking at total cases vs population
-- shows what percentage of population got covid

SELECT 
    Location,
    date,
    population,
    total_cases,
    (total_cases/Population)*100 as DeathPercentage
FROM
    `Portfolio Project`.coviddeaths
WHERE
	Location like '%states%'
ORDER BY 1 , 2;


-- Look at Countries with highest infection rate compared to population
SELECT 
    Location,
    population,
    MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/Population))*100 as DeathPercentage
FROM
    `Portfolio Project`.coviddeaths
-- WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY DeathPercentage desc;

-- showing countries with the highest death count per Population
-- cast function doesn't seem to work
SELECT 
    Location, MAX(total_deaths) AS TotalDeathCount
FROM
    `Portfolio Project`.coviddeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Lets break things down by continent 
SELECT 
    Location, cast(total_deaths as DECIMAL)
FROM
    `Portfolio Project`.coviddeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- global 
USE `Portfolio Project`
SELECT
	date,
    SUM(new_cases),
    SUM(new_deaths)
FROM
    `Portfolio Project`.coviddeaths
group by date
ORDER BY 1,2




-- joining tables on location 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
FROM
    `Portfolio Project`.coviddeaths dea
        JOIN
    `Portfolio Project`.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
FROM
    `Portfolio Project`.coviddeaths dea
        JOIN
    `Portfolio Project`.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
)

Select *,  (RollingPeopleVaccinated/Population)*100
from PopvsVac




-- create temp table
DROP TABLE if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
FROM
    `Portfolio Project`.coviddeaths dea
        JOIN
    `Portfolio Project`.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null

Select *,  (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Creating view to store data for later visualization
DROP VIEW IF EXISTS HighestDeathRate
CREATE VIEW HighestDeathRate as
SELECT 
    Location, total_deaths AS TotalDeathCount
FROM
    `Portfolio Project`.coviddeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC;

