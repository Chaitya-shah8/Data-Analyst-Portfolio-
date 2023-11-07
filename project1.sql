/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
--Select *
--From CovidDeaths$
--Where continent is not null 
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Count 
Select Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as Death_Ratio
from CovidDeaths$
Where continent is not null
order by 1,2

-- Showing total population and vaccinated population
Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
Sum(Convert(int,v.new_vaccinations))OVER (Partition by d.location order by d.location,d.date) as Summation_Of_People_Vaccinated
from CovidDeaths$ as d
Join CovidVaccinations$ as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3 desc

With PopVsVacc (Continent,Locations,date,Population,new_vaccinations,Summation_Of_People_Vaccinated) as
(
Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
Sum(Convert(int,v.new_vaccinations))OVER (Partition by d.location order by d.location,d.date) as Summation_Of_People_Vaccinated
from CovidDeaths$ as d
Join CovidVaccinations$ as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3 desc
)
Select*, (Summation_Of_People_Vaccinated/Population)*100
From PopVsVacc


------ Creating Temp Table


drop Table if exists #percentpopulationVaccinated
Create Table #percentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Summation_Of_People_Vaccinated numeric
)

Insert into #percentpopulationVaccinated

Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
Sum(Convert(int,v.new_vaccinations))OVER (Partition by d.location order by d.location,d.date) as Summation_Of_People_Vaccinated
from CovidDeaths$ as d
Join CovidVaccinations$ as v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
----order by 2,3 desc

Select*, (Summation_Of_People_Vaccinated/Population)*100
From #percentpopulationVaccinated

-- Creating a View 
GO
-- add GO to solve "Create View must be the only batch statement solution"

Create view Summation_Of_People_Vaccinated_View as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
Sum(Convert(int,v.new_vaccinations))OVER (Partition by d.location order by d.location,d.date) as Summation_Of_People_Vaccinated
from CovidDeaths$ as d
Join CovidVaccinations$ as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3 desc
