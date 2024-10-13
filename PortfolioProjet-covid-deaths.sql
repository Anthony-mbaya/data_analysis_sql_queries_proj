select * from PortfolioProject..Covid_Deaths order by 3, 4

--ORDER BY - values selected form 3rd and 4th column

select * from PortfolioProject..Covid_Deaths order by 3, 4


--PRIMARY DATA TO BE MANIPULATED
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths
order by 1, 2

--TOTAL CASES VS TOTAL DEATHS - % - RATE OF DEATHS
select location, date, total_cases, total_deaths, 
		cast((cast(total_deaths as decimal(15, 2))
		/nullif(cast(total_cases as decimal(15, 2)), 0))
		*100 as decimal(15, 2)) as rate_percentage
from PortfolioProject..Covid_Deaths
order by 5 asc

--RATE OF DEATHS IN AFRICA
select location, date, total_cases, total_deaths,
	cast(
	(cast(total_deaths as decimal(15, 2))
	/
	cast(nullif(total_cases, 0) as decimal(15, 2)))
	*100 as decimal(15, 2)) as Africa_rates
from PortfolioProject..Covid_Deaths
where location = 'Africa'
order by Africa_rates desc

--TOTAL CASES VS POPULATION
	--% POPULATION GOT COVID
select location, date, total_cases, population,
	cast(
	(cast(total_cases as decimal(15, 2))
	/
	cast(nullif(population, 0) as decimal(15, 2)))
	*100 as decimal(15, 2)) as population_rates
from PortfolioProject..Covid_Deaths
where location = 'Kenya'
order by population_rates desc

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
select location, population, 
	max(total_cases) as high_cases,
	max(cast(
	(cast(population as decimal(15, 2))
	/
	cast(nullif(population, 0) as decimal(15, 2)))
	*100 as decimal(15, 2))) as populationInfected
from PortfolioProject..Covid_Deaths  
group by location, population
order by populationInfected desc

--GROUP BY - GROUP ROWS THAT HAVE SAME VALUES, CALCULATE FUNCTON FOR EACH GROPU EG MAX


--COUNTRIES WITH HIGHEST TOTAL DEATH COUNTS
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
where continent is not null
group by location
order by TotalDeathCount desc

--CONTINENTS WITH HIGHEST TOTAL DEATH COUNTS
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
where continent is not null
group by continent
order by TotalDeathCount desc

--AGGREGATION - SUM
--FIND SUM  OF NEW CASES AND DEATHS IN A DATE
select date, sum(new_cases) as sum_new_cases,
	sum(cast(new_deaths as int)) as sum_new_deaths
from PortfolioProject..Covid_Deaths
where continent is not null
group by date
order by 1, 2 desc

--DEATH PERCENTAGE OVERALL THE WORLD
select sum(new_cases) as sum_new_cases,
	sum(cast(new_deaths as int)) as sum_new_deaths,
	(cast(sum(cast(new_deaths as decimal(15, 2)))
	/
	sum(cast(new_cases as decimal(15, 2)))
	*100 as decimal(15, 2))) as WorldPercentageDeath
	from PortfolioProject..Covid_Deaths
where continent is not null 
order by 1, 2 desc



--JOINING --- COVID VACCINATION TABLE --- --- ---
--DISPLAYING VACCINATION IN DIFFERENYT LOCATIONS
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from
PortfolioProject..Covid_Deaths dea
join
PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null
order by 2, 3

--CUMULATIVE VACCINATIONS TOTALS IN DIFFERENT LOCATIONS --- BY LOCATION --
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) 
	over 
	(partition by dea.location order by dea.location, dea.date)
	as PeopleVaccinated
from
PortfolioProject..Covid_Deaths dea
join
PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null
order by 2, 3 desc

--WANNA REUSE PEOPLEVACCINATED COLUMN -- USE CTE --
with populationVacc(
continent, location, date, population, new_vaccinations, PeopleVaccinated)
as(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) 
	over 
	(partition by dea.location order by dea.location, dea.date)
	as PeopleVaccinated
from
PortfolioProject..Covid_Deaths dea
join
PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null 
)
 
