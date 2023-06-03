SELECT*
FROM  PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM  PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, new_cases, total_deaths, (Total_deaths/total_cases) *100 as DeathPercentage
FROM  PortfolioProject..CovidDeaths$
Where Location like '%Malaysia%'
ORDER BY 1,2


--Looking at total cases vs Population
--Shows what percentage of population got covid
SELECT Location, date, total_cases, Population, (total_cases/Population) *100 as CovidPercentage
FROM  PortfolioProject..CovidDeaths$
Where Location like '%Malaysia%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX (Total_cases) as HighestInfectionCount, MAX ((total_cases/Population)) *100 as PopulationInfectedPercents
FROM  PortfolioProject..CovidDeaths$
--Where Location like '%Malaysia%'
GROUP BY Location, Population
ORDER BY PopulationInfectedPercents DESC


--Showing Countries with Highest Death Count per Population
SELECT Location, MAX (cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
--Where Location like '%Malaysia%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
--Where Location like '%Malaysia%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing the continents with the highest death count per population
SELECT continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
--Where Location like '%Malaysia%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/sum(new_cases)*100  as DeathPercentage
FROM  PortfolioProject..CovidDeaths$
--Where Location like '%Malaysia%'
where continent is not null
--Group by date
ORDER BY 1,2





--Looking at Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea. location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join  PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join  PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVAC

--TEMP TABLE

DROP table IF EXISTS #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join  PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--Creating view to store data for alter visualization
Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join  PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select*
From PercentagePopulationVaccinated