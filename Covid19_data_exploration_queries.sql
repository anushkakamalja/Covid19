Select * 
	from Covid19..CovidDeaths
	where continent is not null
	order by 3,4

--Select * 
--	from Covid19..CovidVaccinations
--	order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
	from Covid19..CovidDeaths
	where continent is not null
	order by 1,2

--Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in the states
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from Covid19..CovidDeaths
	where location like '%india%'
	and continent is not null
	order by 1,2

--Total cases vs Population
--Shows the percentage of population having covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
	from Covid19..CovidDeaths
--	where location like '%india%'
	where continent is not null
	order by 1,2

--Countries with Highest Infection Rate compared to Population
Select location, max(total_cases) as HighestInfectionCount, population, max((total_cases /population))*100 as InfectionPercentage
	from Covid19..CovidDeaths
	where continent is not null
	group by location, population
	order by 4 desc
	
--Countries with Highest Death Count as per Location
Select location, max(cast(total_deaths as int)) as TotalDeathCount
	from Covid19..CovidDeaths
	where continent is not null
	group by location
	order by TotalDeathCount desc

--Countries with Highest Death Count as per Continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount
	from Covid19..CovidDeaths
	where continent is null
	group by location
	order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases)as global_cases, SUM(cast(new_deaths as int)) as global_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPercentage
From Covid19..CovidDeaths
where continent is not null
group by date
order by 1,2


--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinationCount
	From Covid19..CovidDeaths dea
		Join Covid19..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null
	order by 1,2,3

--USE CTE
With PopVsVac (Continent, Location, Date, Population, NewVaccinations, CumulativeVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinationCount
	From Covid19..CovidDeaths dea
		Join Covid19..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null
	--order by 1,2,3
)
Select *, (CumulativeVaccinationCount/Population)*100 as VaccinationPercentage
From PopVsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinationCount
	From Covid19..CovidDeaths dea
		Join Covid19..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	--where dea.continent is not null
	--order by 1,2,3

Select *, (CumulativeVaccinationCount/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinationCount
	From Covid19..CovidDeaths dea
		Join Covid19..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null
	--order by 1,2,3

--Querying the created view
Select * 
From PercentPopulationVaccinated
