select * from PortfolioProject..covid_deaths
order by 3,4

--select * from PortfolioProject..covid_vaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..covid_deaths
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2


select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
--where location like '%india%'
order by 1,2

select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/Sum(New_Cases) *100 as DeathPercentage 
from PortfolioProject..covid_deaths 
--where location like '%states%'
where continent is not null
group by date
--order by 1,2


select * 
from  PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

With PopvsVac(Continent,Location, Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from  PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from  PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
on dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--CREATING VIE TO STORE DATA FOR 

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from  PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated 