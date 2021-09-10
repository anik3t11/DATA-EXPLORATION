


select * from portfolio_project..covideaths
where continent is not null
order by 3,4

--select * from portfolio_project..covidvaccination
--order by 3,4

--select data that are going to be used

select Location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..covideaths
order by 1,2


--Looking at total cases vs total deaths
--show likelihood of dying if you contrac covid in your country


select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project..covideaths
where location like '%india%'
order by 1,2

--total cases vs population
--percentage of population got covid
select Location,date,total_cases,population,(total_cases/population)*100 as casePercentage
from portfolio_project..covideaths
--where location like '%india%'
order by 1,2

--country with highest infection rate compared to population
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from portfolio_project..covideaths
--where location like '%india%'
where continent is not null
Group by location,population
order by PercentPopulationInfected desc


--LETS'S BREAK THINGS DOWN BY CONTINENT

--contint with highest death count
select location,MAX(cast(total_deaths as int))as TotalDeathCount
from portfolio_project..covideaths
--where location like '%india%'
where continent is  null
Group by location
order by TotalDeathCount desc


select continent,MAX(cast(total_deaths as int))as TotalDeathCount
from portfolio_project..covideaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Continent with highest death count per million
select continent,MAX(cast(total_deaths as int))as TotalDeathCount
from portfolio_project..covideaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Golobal Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio_project..covideaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

--loking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
	order by dea.location,dea.date) as RollingPeopleVaccinated--,(RollingPeoplevaccinated/population)*100
from portfolio_project..covideaths dea
join portfolio_project..covidvaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac (Continent,Location,Date,Population,New_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
	order by dea.location,dea.date) as RollingPeopleVaccinated--,(RollingPeoplevaccinated/population)*100
from portfolio_project..covideaths dea
join portfolio_project..covidvaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100 as PercentofPeopleVaccinated
from PopvsVac

--Temp TABLE
DROP Table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
	order by dea.location,dea.date) as RollingPeopleVaccinated--,(RollingPeoplevaccinated/population)*100
from portfolio_project..covideaths dea
join portfolio_project..covidvaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select * ,( RollingPeopleVacinated /Population)*100 as PercentofPeopleVaccinated
from #PercentPopulationVaccinated


--Creating view to store data for later visualization 
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
	order by dea.location,dea.date) as RollingPeopleVaccinated --,(RollingPeoplevaccinated/population)*100
from portfolio_project..covideaths dea
join portfolio_project..covidvaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated