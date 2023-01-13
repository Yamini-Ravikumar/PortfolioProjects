SELECT 
    *
FROM
    covid_death;

SELECT 
    *
FROM
    covid_vaccination;

-- selecting data 

SELECT 
    location,
    yeardate,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_death;

-- looking at total_cases vs total_deaths
-- shows the likelihood of dying if you contract covid in a given country
SELECT 
    location,
    yeardate,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    covid_death
WHERE
    location LIKE '%india%'
ORDER BY 2;


-- looking at total cases vs population
-- shows the percentage of population got covid
SELECT 
    location,
    yeardate,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    covid_death
WHERE
    location LIKE '%india%'
ORDER BY 2;

-- looking at countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS highInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    covid_death
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;

-- showing countries with highest death count per population

SELECT 
    location, MAX(total_deaths) AS TotalDeathCount
FROM
    covid_death
WHERE
    continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
 


-- BREAKING THINGS DOWN BY CONTINENT ---
 
SELECT 
    continent, MAX(total_deaths) AS TotalDeathCount
FROM
    covid_death
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS--	

SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_death,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM
    covid_death
WHERE
    continent IS NOT NULL;

-- looking at total population vd vaccinations

select cd.continent, cd.location, cd.yeardate, cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.yeardate) as RollingPeopleVaccinated
from covid_death cd
join covid_vaccination cv on cd.location = cv.location
and cd.yeardate = cv.yeardate
and cd.continent is not null
order by 2,3;

-- Use CTE

with PopvsVac (continent, location, yeardate, population, new_vaccinations, RollingPeopleVaccinated)
as 
( select cd.continent, cd.location, cd.yeardate, cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.yeardate) as RollingPeopleVaccinated
from covid_death cd
join covid_vaccination cv on cd.location = cv.location
and  cd.yeardate = cv.yeardate
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac;
 
 
 -- Temp Table
 
CREATE TABLE PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    yeardate DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);
 
insert into PercentPopulationVaccinated
select cd.continent, cd.location, cd.yeardate, cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.yeardate) as RollingPeopleVaccinated
from covid_death cd
join covid_vaccination cv on cd.location = cv.location
and  cd.yeardate = cv.yeardate;


SELECT 
    *, (RollingPeopleVaccinated / population) * 100
FROM
    PercentPopulationVaccinated;
 
 
 -- creating view to store  data for later visualization
 
 
create view PercentPopulationVaccinatedView as
select cd.continent, cd.location, cd.yeardate, cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.yeardate) as RollingPeopleVaccinated
from covid_death cd
join covid_vaccination cv on cd.location = cv.location
and  cd.yeardate = cv.yeardate
where cd.continent is not null;


SELECT 
    *
FROM
    PercentPopulationVaccinatedView;





 