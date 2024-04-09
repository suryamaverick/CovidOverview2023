Use [Covid-2020];
select @@SERVERNAME

--Overall Data
select * from dbo.Covidvaccination$ order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from dbo.coviddeaths$ order by 1,2;

select *
from dbo.coviddeaths$ where continent is not null order by 1,2;

--Total Cases Vs Total Deaths
select count(total_cases) as Total_Cases,count(total_deaths) as Total_Deaths from coviddeaths$

--Death Percentages
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage 
from dbo.coviddeaths$ 
where location like '%India%' order by 1,2;

--Total Cases Vs Population
select location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 as [Population Percentage]
from dbo.coviddeaths$ 
Order by 1,2

--Countries with Highest Infection Rate
select location ,population,max(total_cases) as Highest_Case_Count,Max((total_cases/population)*100) as Population_Percentage
from dbo.coviddeaths$ 
group by location,population
order by Population_Percentage desc;

--Countries with Highest Death Count Per Population
--select location,population,max(total_deaths) as Death_Count 
--from dbo.coviddeaths$ 
--group by location,population having population>100000000
--order by 1,2

--Countries with Highest Death Count Per Population
select location,cast(max(total_deaths) as int) as Death_Count ,max(population) as Overall_Population
from dbo.coviddeaths$ where continent is not null
group by location,population
order by Death_Count desc

--Grouping By Continents by HighestTotal_Cases
select location,max(cast(total_cases as int)) as Total_cases
from coviddeaths$
where continent is null 
group by location
order by Total_cases desc

--Grouping By Continents by highest Death Rates
select continent,max(cast(total_deaths as int)) as Total_Deaths 
from coviddeaths$
where continent is not null
group by continent Order by Total_Deaths

--Global Numbers
select date ,sum(cast(new_cases as int)) as New_Cases,sum(cast(new_deaths as int)) as Death_Cases, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.coviddeaths$ 
where continent is not null 
group by date
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------
--Joining two Tables
--Total Population vs Total newly Vaccinated
select cdea.continent,cdea.location,cdea.date,cdea.population,cvac.new_vaccinations 
from  coviddeaths$ cdea
join Covidvaccination$ cvac
	on cdea.location=cvac.location
	and cdea.date = cvac.date
	and cdea.iso_code=cvac.iso_code
where cdea.continent is not null and cvac.new_vaccinations is not null
order by 2,3

--Partitioning the function
with Calloff(Continent,Location,Date,Population,Vaccinated,Total_Vaccinated)
as
(
select cdea.continent,cdea.location,cdea.date,cdea.population,cvac.new_vaccinations, 
sum(convert(bigint,cvac.new_vaccinations)) over(partition by cdea.location order by cdea.location,cdea.date) as Total_VaccinatedSum
--,max(Total_VaccinatedSum) over(partition by cdea.location)
from  coviddeaths$ cdea
join Covidvaccination$ cvac
	on cdea.location=cvac.location
	and cdea.date = cvac.date
--	and cdea.iso_code=cvac.iso_code
where cdea.continent is not null--and cvac.new_vaccinations is not null
)
select *,max(Total_Vaccinated) over(partition by Location)
from Calloff

--Creating Temporary Table
drop table if exists #PeopleVaccinatedOver 
create table #PeopleVaccinatedOver  (
Continent varchar(100),
Location varchar(100),
Date date,
Population bigint,
Vaccinated bigint,
Total_Vaccinated bigint
)

insert into #PeopleVaccinatedOver 
select cdea.continent,cdea.location,cdea.date,cdea.population,cvac.new_vaccinations, 
sum(convert(bigint,cvac.new_vaccinations)) over(partition by cdea.location order by cdea.location,cdea.date) as Total_VaccinatedSum
--,max(Total_VaccinatedSum) over(partition by cdea.location)
from  coviddeaths$ cdea
join Covidvaccination$ cvac
	on cdea.location=cvac.location
	and cdea.date = cvac.date
--	and cdea.iso_code=cvac.iso_code
--where cdea.continent is not null--and cvac.new_vaccinations is not null

select * from #PeopleVaccinatedOver 

--Creating Views
create view PeopleVaccinatedOverAll as
select cdea.continent,cdea.location,cdea.date,cdea.population,cvac.new_vaccinations, 
sum(convert(bigint,cvac.new_vaccinations)) over(partition by cdea.location order by cdea.location,cdea.date) as Total_VaccinatedSum
--,max(Total_VaccinatedSum) over(partition by cdea.location)
from  coviddeaths$ cdea
join Covidvaccination$ cvac
	on cdea.location=cvac.location
	and cdea.date = cvac.date
--	and cdea.iso_code=cvac.iso_code
where cdea.continent is not null--and cvac.new_vaccinations is not null

