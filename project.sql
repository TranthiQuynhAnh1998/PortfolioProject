select * 
	from PortfolioProject..CovidDeaths$
		order by 3,4


--select * 
--	from PortfolioProject..CovidVaccinations
--		order by 3,4

--select Data that we are going to be using


		

-- Looking at Total cases vs Total Deaths 
-- show likelihood of dying if you contract covid in your country 
select a.location, a.date, a.Tota_case, a.total_death, (a.total_death/ a.Tota_case)*100 as DeathPercentage
from
(select  CONVERT(float,total_cases) as Tota_case , CONVERT(float,total_deaths) as total_death, location, date
	from PortfolioProject..CovidDeaths$
		--where total_cases is not null and total_deaths is not null
		) a
where a.location like '%states%'
order by 1,2

-- looking at Total Cases vs Population
select a.location,a.date, a.population,a.total_case, (a.total_case/a.population)*100 as PercentagePopulationInfact
from
(select CONVERT(Float,total_cases) as total_case, population, location, date
	from PortfolioProject..CovidDeaths$) a
	where a.location like '%states%' and total_case is not null
order by 1,2
--Looking at countries Highset Infection Rate compared to population 

select a.location, a.population,Max(a.total_case) as HighestInfectioncout, Max((a.total_case/a.population))*100 as PercentagePopulationInfact
from
(select CONVERT(Float,total_cases) as total_case, population, location, date
	from PortfolioProject..CovidDeaths$) a
	--where a.location like '%Andorra%' and total_case is not null
	Group by a.location, a.population
order by PercentagePopulationInfact desc


--LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing contintents with the highest  death count per population

Select continent, max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null 
group by continent
order by TotalDeathCount desc

--	GLOBAL NUMBERS

select  sum(a.new_cases) as total_cases, sum(a.new_death) as total_deaths,
sum(a.new_death)/ sum(a.new_cases) as DeathsPercentage
from
(select date, new_cases, convert(float,new_deaths) as new_death
	from PortfolioProject..CovidDeaths$
		where continent is not null and new_cases <> 0 and new_deaths <> 0) a
--group by a.date

--Looking at total Population and Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeoplevaccinated
	from PortfolioProject..CovidVaccinations vac
		join PortfolioProject..CovidDeaths$ dea
		on vac.location = dea.location and vac.date = dea.date
	where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac ( continent, Location, Date, Population,new_vaccinations ,RollingPeoplevaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeoplevaccinated
	from PortfolioProject..CovidVaccinations vac
		join PortfolioProject..CovidDeaths$ dea
		on vac.location = dea.location and vac.date = dea.date
	where dea.continent is not null
--order by 2,3
)
select *,(RollingPeoplevaccinated/Population)*100
from PopvsVac

--TEM TABLE 
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location varchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)
insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeoplevaccinated
	from PortfolioProject..CovidVaccinations vac
		join PortfolioProject..CovidDeaths$ dea
		on vac.location = dea.location and vac.date = dea.date
	--where dea.continent is not null
--order by 2,3

select *, (RollingPeoplevaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for late visualizations 

Create view PercentPopulationVaccinated as 