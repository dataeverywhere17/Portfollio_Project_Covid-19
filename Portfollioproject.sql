select *
from [Portfollio Project]..coviddeath$
order by 3,4


--select *
--from..covidvaccination$
--order by 3,4

-- this is done to check the data is entered right

-- Select data we are going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
from [Portfollio Project]..coviddeath$
order by 1,2

-- looking at percentage of death in India
Select Location, Date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [Portfollio Project]..coviddeath$
where location = 'India'
order by 1,2

-- looking at percentage of infection in India
Select Location, Date, Population, total_cases, new_cases,total_deaths, (total_cases/population)*100 as Infectedpercentage
from [Portfollio Project]..coviddeath$
where location='India'
order by 1,2

--looking at countries with highest infection rate 
Select Location, population, Max(total_cases) as Highest_infection_count, Max((total_cases/population))*100 as percentage_population_infected
from [Portfollio Project]..coviddeath$
group by population, location
order by percentage_population_infected desc

--looking at countries with the highest death rate.
Select Location, Max(cast(total_deaths as int))  as Total_death_count
from [Portfollio Project]..coviddeath$
where continent is not null -- the location column had columns and other unrelated info
group by location
order by Total_death_count desc

--Seeing the same contintent vise
Select continent, Max(cast(total_deaths as int))  as Total_death_count
from [Portfollio Project]..coviddeath$
where continent is not null-- the location column had columns and other unrelated info
group by continent
order by Total_death_count desc

--Global numbers
Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
from [Portfollio Project]..coviddeath$
where continent is not null
order by 1,2


Select*
from [Portfollio Project].. covidvaccination$

--joining the two tables
Select*
from [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date

--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Looking at the total number of population which has been vaccinated.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--now to have a column to display the rolling  count of vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_vacination_number
From [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with popvsvac (Continent, Location, Date, population, new_vaccinations, Rolling_vacination_number)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_vacination_number
From [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (Rolling_vacination_number/population)*100
From popvsvac

--Creating view for vissualisations
drop view Populationvsvaccination
Create view Populationvsvaccination
as Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_vacination_number
From [Portfollio Project].. coviddeath$ dea
Join [Portfollio Project]..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

--opening view
select * from Populationvsvaccination