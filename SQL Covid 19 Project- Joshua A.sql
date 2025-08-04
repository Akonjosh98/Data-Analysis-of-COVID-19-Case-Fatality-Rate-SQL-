/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select*
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
Where continent is not null 
order by 3,4

Select *
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
Where continent is not null 
order by 3,4

Select *
From [SQL DA PROJECTJOSH]..[CovidVaccinations NEW]
Where continent is not null 
order by 3,4

-- The Real starts from Here, doesnt mean the above part is not significant, ha ha

-- 1. Select Data that we are going to be using/starting with

Select Location, date, total_cases, total_deaths, population
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
Where continent is not null 
order by 1,2


-- 2. LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
where location like '%states%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
and continent is not null
order by 1,2

 --3. LOOKING AT TOTAL CASES VS POPULATION 
 -- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVIS(OR WEHERE AFFECTED BY COVID)
 Select Location, date,population, total_cases, (total_cases/population)* 100 as PresentPopulationInfected
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
where location like '%India%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
--Where continent is not null
order by 1,2

-- 4. Countries with Highest Infection Rate compared to Population

 Select Location,population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)* 100 as PresentPopulationInfected
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
--where location like '%states%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
Group by location, Population
order by PresentPopulationInfected desc 

-- 5.Showing Countries with Highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount -- To convert [new_deaths] (nvarchar(255), null to readable integer we are using 'CAST'  and inside the bracket we are using Max(cast(total_deaths as int)) for to complete converting the data type
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
--where location like '%states%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- 6. LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Continents with Highest death count as population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount -- To convert [new_deaths] (nvarchar(255), null to readable integer we are using 'CAST'  and inside the bracket we are using Max(cast(total_deaths as int)) for to complete converting the data type
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
--where location like '%states%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- 7. GLOBAL NUMBERS
--To calculate everything across the entire world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$]
--where location like '%states%' -- to check in specific DEATH PERCENTAGE Data based on the Location we us this where location '%location name%'
where continent is not null
--Group By date
order by 1,2

-- 8. Looking st Total populayion vs Vaccinations
-- Shows Percentage of Population thatt has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$] dea
Join[SQL DA PROJECTJOSH]..[CovidVaccinations NEW] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

  With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

  as
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$] dea
Join[SQL DA PROJECTJOSH]..[CovidVaccinations NEW] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$] dea
Join[SQL DA PROJECTJOSH]..[CovidVaccinations NEW] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Createview PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL DA PROJECTJOSH]..[CovidDeaths LAT$] dea
Join[SQL DA PROJECTJOSH]..[CovidVaccinations NEW] vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

-- Creating View to store data for later visualizations

GO
CREATE OR ALTER VIEW dbo.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  [SQL DA PROJECTJOSH]..[CovidDeaths LAT$] dea
JOIN  [SQL DA PROJECTJOSH]..[CovidVaccinations NEW] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null



















