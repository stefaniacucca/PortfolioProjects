Select * 
from PortfolioProjects..CovidDeaths
order by 3, 4

Select * 
from PortfolioProjects..CovidVaccinations
order by 3, 4

-- -- Total Cases vs Total Deaths: how likely you are to die from covid in your country?

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
Where location like '%Italy%' and continent is not null
order by 1,2

-- Total Cases vs population: percentages of population infected 
	
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is not null
order by 1,2

-- Countries with highest infection rate compared to their population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is not null
group by population, location
order by PercentPopulationInfected DESC

-- Countries with highest death count compared to their population
	
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is not null
group by location
order by TotalDeathCount DESC

-- Analyze by continent
-- Continents with the highest death rate per population
-- incorrect
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is not null
group by continent
order by TotalDeathCount DESC
-- incorrect
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is null
group by location
order by TotalDeathCount DESC
	
-- correct
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global numbers

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%' 
where continent is not null
group by date
order by 1, 2

	-- withouth date to visualize better
Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--Where location like '%Italy%' 
where continent is not null
--group by date
order by 1, 2

-- VACCINATIONS
-- Percentage of population who got at least one dose of vaccine 
	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

	-- Perform calculation on Partition by: RollingPeopleVaccinated
	-- Option 1: CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

	-- Option 2: Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Create VIEW to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated
