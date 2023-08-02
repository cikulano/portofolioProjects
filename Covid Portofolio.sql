select *
from portofolio..CovidDeaths$
where location like '%income%'
order by 3,4

--select *
--from portofolio..CovidVaccination$
--order by 3,4

-- Select data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from portofolio..CovidDeaths$
order by 1,2

-- Looking total cases vs total deaths
-- show a chance of dying if you contracted covid in your country

ALTER TABLE portofolio..CovidDeaths$
ALTER COLUMN total_cases float;

ALTER TABLE portofolio..CovidDeaths$
ALTER COLUMN total_deaths float;

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portofolio..CovidDeaths$
where location like '%Indo%'
order by 1,2

-- Looking at total caseses vs population
-- show how much population that got covid

Select location,date,population,total_cases, (total_cases/population)*100 as casePercentage
From portofolio..CovidDeaths$
Where location like '%Indo%'
Order by 1,2

-- Looking at countries with highest rate of infection compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From portofolio..CovidDeaths$
--Where location like '%Indo%'
Group By Location,Population
Order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select location, MAX(Total_deaths) as TotalDeathsCount
From portofolio..CovidDeaths$
--Where location like '%Indo%'
where continent is not null
Group By Location
Order by TotalDeathsCount desc

-- LET'S BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per Population

Select location, MAX(Total_deaths) as TotalDeathsCount
From portofolio..CovidDeaths$
--Where location like '%Indo%'
where continent is null 
and location not like '%income%'
Group By location
Order by TotalDeathsCount desc

-- GLOBAL NUMBER

Select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From portofolio..CovidDeaths$
--Where location like '%Indo%'
Where continent is not null 
--Group By date
Order by 1,2


-- Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location,dea.Date) as RollingPeopleVaccinate
From portofolio..CovidDeaths$ dea
Join portofolio..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- USE CTE

With PopVsVacc ( Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinate )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location,dea.Date) as RollingPeopleVaccinate
From portofolio..CovidDeaths$ dea
Join portofolio..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
 select * , (RollingPeopleVaccinate/population)*100
 from PopVsVacc
 where location like '%indo%'


 --Temp Table
 DROP table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent varchar(255),
 Location varchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinate numeric,
 )

 Insert Into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location,dea.Date) as RollingPeopleVaccinate
From portofolio..CovidDeaths$ dea
Join portofolio..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3
 select * , (RollingPeopleVaccinate/population)*100
 from #PercentPopulationVaccinated
 

-- Create View

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location,dea.Date) as RollingPeopleVaccinate
From portofolio..CovidDeaths$ dea
Join portofolio..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
from PercentPopulationVaccinated