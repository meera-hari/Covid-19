Select * 
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
order by location,date;

Select * 
from [Data Analytics Project Portfolio- Covid 19]..Covid_Vaccinations
order by location,date;

--Selecting Data from CovidDeaths that we are going to use..

Select location,date,total_cases,new_cases,total_deaths,population
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
order by location,date;

--Looking at the total cases vs total deaths for each country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_death_vs_cases
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
order by location,date;

--Looking at the total cases vs total deaths for India
--The percentage shows the likelihood of a person with covid dying in India.

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_death_vs_cases
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
where location like 'India'
order by location,date;

--Looking at total cases vs population
--Finding out the percent of infected population

Select location,date,total_cases,population,round((total_cases/population)*100,2) as Percentage_cases_vs_population
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
where location like 'India'
order by location,date;

--****Looking for the highest infected country wrt to population******

Select location,population,Max(total_cases) as Highestcount,
Max(round((total_cases/population)*100,2)) as Percentage_cases_vs_population
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
GROUP BY LOCATION,population
order by Percentage_cases_vs_population desc;

--1) Seychelles has the highest percentage of population infected at 20.82%
--2) India has 2.4% of the population infected.

Select location, population, max((total_cases/population)*100) as percent_infected
from Covid_Deaths
where location like 'China'
group by location,population;

--3) China has as less as 0.006% of the population infected

--**** Looking for the country with the highest no of deaths recorded.*****

Select location,population, max(total_deaths)as Death_count
from Covid_Deaths
group by location,population
order by Death_count desc;
--Here, the death_count appears to be not correct due to the datatype nvarchar(255), so we will convert it into 
--int using CAST function. 

Select location,population, max(cast(total_deaths as int))as Death_count
from Covid_Deaths
group by location,population
order by Death_count desc;

--4) There have been 46,59,842 deaths around world so far.

--Also, we see that the continents have come under the location field. So while going through the column we see 
--that the wherever the values are null in continent, the location is the continent name. To correct this, we need 
--to select columns where continent is not null.

Select location, population, max(cast(total_deaths as int))as Death_count
from Covid_Deaths
where continent is not NULL
group by location,population
ORDER BY Death_count desc;

--5) USA has had the largest no of deaths at 6,66,607, followed by Brazil at 5,88,597
--followed by India at 4,43,928 deaths.

--Looking for death_counts as per continent

Select location, max(cast(Total_deaths as int)) as Death_count
from [Data Analytics Project Portfolio- Covid 19]..Covid_Deaths
where continent is null
group by location
order by Death_count desc;

--6) Europe is the continent with highest no of death count

--Let's try to see the evolve of the cases day by day

--Finding out the total population of the world:
with cte_population as
(select location, population as country_population
from Covid_Deaths
group by location, population)
select sum(country_population) from cte_population;

with cte_populationcount as
(select DISTINCT population as popln_count
from Covid_Deaths)
select sum(popln_count) from cte_populationcount;

--7) Using both the above methods the total population comes out to be 24 billion, which is not true.

--****Getting the total cases affected and total deaths recorded*****

Select date, sum(new_cases) as each_day_new_cases,sum(cast(new_deaths as int)) as each_day_new_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null
group by date
order by date asc;

Select sum(new_cases) as Totalcasesrecorded,sum(cast(new_deaths as int)) as Totaldeathsrecorded,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null;

--8) So far, taking the world population to be 7.9 billion the infected population is around 2.86% and 2.05% of the infected people died ie
--0.05% of the population died due to covid 19.

--****Taking the vaccination table*****

Select * from Covid_Vaccinations


--joining both tables

select * from Covid_Deaths cd
join Covid_Vaccinations cv
on cd.location=cv.location
and cd.date=cv.date;

--*****Looking at the Cummulative vaccinations day by day population*****

select continent, location, date, population, new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by location order by date ) 
as Cummulativevaccinations
from Covid_Vaccinations
where continent is not null
order by location, date;

--****Finding out the percentage of population vaccinated day by day****

--Let's create a temp table to keep a record of vaccinated count per day.

drop table if exists #Percent_populn_vaccinated
CREATE TABLE #Percent_populn_vaccinated 
(continent varchar(100),
location varchar(100),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_population_vaccinated numeric);

Insert into #Percent_populn_vaccinated
select continent, location, date, population, new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by location order by date ) 
as cummulative_population_vaccinated
from Covid_Vaccinations
where continent is not null
order by location,date;

select* from #Percent_populn_vaccinated

select *,(cummulative_population_vaccinated/population)*100
as population_percent_vaccinated
from #Percent_populn_vaccinated;

select location,date, population,(cummulative_population_vaccinated/population)*100 
from #Percent_populn_vaccinated
where location='Gibraltar'  
order by date;


--*****Getting the max vaccinated country******

select location, max((cummulative_population_vaccinated/population)*100 ) as population_percent_vaccinated
from #Percent_populn_vaccinated
group by location
order by population_percent_vaccinated desc;

--9) The country Gibraltar seems to have the highest percentage of population vaccinated eventhough the values seem to be wrong.

--**** Creating fast views****

CREATE View population_percent_vaccinated as
select continent, location, date, population, new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by location order by date ) 
as cummulative_population_vaccinated
from Covid_Vaccinations
where continent is not null;

select * from population_percent_vaccinated
















 
