select * from CovidDeaths
where continent iS NOT null
order by 1,2

Select location ,date,total_cases,new_cases,total_deaths, population
from CovidDeaths
order by 1,2

--Total cases vs Total Deaths

Select location ,date,total_cases,new_cases,total_deaths,(Total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
--where location = 'India'
where continent iS NOT null
ORDER BY 1,2

--Total cases Vs Population

Select location ,date,population,total_cases,(Total_cases/population)*100 as PopulationInfected_Percentage
from CovidDeaths
--where location = 'India'
ORDER BY 1,2

--country with highest infection rate compared to population

Select location ,population,MAX(total_cases) as HighestInfected_count,MAX((Total_deaths/total_cases))*100 as PopulationInfected_Percentage
from CovidDeaths
--where location = 'India'
GROUP BY location,population
ORDER BY PopulationInfected_Percentage desc 

--country with highest death count per population

select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location = 'India'
where continent iS NOT null
GROUP BY location
ORDER BY TotalDeathCount desc 

--showing continents with high death count

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location = 'India'
where continent iS not null
GROUP BY continent
ORDER BY TotalDeathCount desc 

--GLOBAL NUMBERS
	
Select date, SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as Death_Percentage
from CovidDeaths
--where location = 'India'
where continent iS NOT null
GROUP BY date
ORDER BY 1,2

--joining TABLES

Select * from CovidVaccinations vac
join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date

----Total population vs vaccination(total amt of people in world vaccinated)

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from CovidVaccinations vac
join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2,3

-- New vaccinations per day

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location Order by dea.location,
dea.date) as  RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 
from CovidVaccinations vac
join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2,3
--Using CTE
With PopVsVac(continent,location,date,population,new_vaccinations,RollingCount_Vaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location Order by dea.location,
dea.date) as  RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 
from CovidVaccinations vac
join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
--Select * from PopVsVac
Select *, (RollingCount_Vaccinated/population)*100 --HOW MANY PEOPLE ARE VACCINATED
from PopVsVac

--View For Visualization

create view PopVsVac as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location Order by dea.location,
dea.date) as  RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 
from CovidVaccinations vac
join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3
select * from PopVsVac
-------------------------------------------------------------------------


--Queries For Tableu Visualization

--1)GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--where location = 'India'
where continent is not null 
--Group By date
order by 1,2

--2)DEATH COUNT PER CONTINENT
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location = 'India'
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income'
Group by location
order by TotalDeathCount desc

--3)PERCENT POPULATION INFECTED PER COUNTRY
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states'
Group by Location, Population
order by PercentPopulationInfected desc

--4)PERCENT POPULATION INFECTED
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states'
Group by Location, Population, date
order by PercentPopulationInfected desc