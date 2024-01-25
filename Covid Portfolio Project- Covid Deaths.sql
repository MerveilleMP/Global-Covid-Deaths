
--Worked on this guided project as part of my SQL learing and practicing journey. 
--Guided project was directed by Alex the Analyst on Youtube.com. 
--Make some personal changes to the queries, to focus on factors I was interested in seeing.


--Making sure the dataset was imported correctly.
Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select the Data that we're going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--We'll be looking at the Total Cases vs Total Deaths
-- this query shows the likelihood of dying if covid is contracted by countries
Select Location, date, total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%benin%'
and continent is not null
order by 1,2


-- Looking at the total cases vs Population to show what percentage of the population got covid
Select Location, date,Population,total_cases, (Total_cases/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%benin%'
and continent is not null

order by 1,2


--looking to see what country has the highest infection rate compared to population.
 
 Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%benin%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Looking at the countries with the highest death count per population

 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%benin%'
Where continent is not null
Group by Location, population
order by TotalDeathCount desc

--Looking at the data from a wider lens, continents.

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%benin%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Looking at global numbers

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int))as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%benin%'
where continent is not null
Group by date
order by 1,2

-- Joining covid deaths and vaccinations to see at the total population vs vaccinations. 

Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, Cvac.new_vaccinations
, SUM(CONVERT(int,Cvac.new_vaccinations)) OVER (Partition by CDeath.location Order by Cdeath.location, CDeath.date) 
--as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CDeath
Join PortfolioProject..CovidVaccinations Cvac
	On CDeath.location = Cvac.location
	and CDeath.date = Cvac.date
Where CDeath.continent is not null
Order by 2,3


--Creating a CTE to view the data together 

With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, Cvac.new_vaccinations
, SUM(CONVERT(int,Cvac.new_vaccinations)) OVER (Partition by CDeath.Location Order by CDeath.Location,CDeath.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CDeath
Join PortfolioProject..CovidVaccinations Cvac
	On CDeath.location = Cvac.location
	and CDeath.date = Cvac.date
Where CDeath.continent is not null
--Order by 2,3 
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Creating a Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, Cvac.new_vaccinations
, SUM(CONVERT(int,Cvac.new_vaccinations)) OVER (Partition by CDeath.Location Order by CDeath.Location,CDeath.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CDeath
Join PortfolioProject..CovidVaccinations Cvac
	On CDeath.location = Cvac.location
	and CDeath.date = Cvac.date
Where CDeath.continent is not null
--Order by 2,3 

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating the view to store the data for later visualizations

Create View PercentPopulationVaccinated as
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, Cvac.new_vaccinations
, SUM(CONVERT(int,Cvac.new_vaccinations)) OVER (Partition by CDeath.Location Order by CDeath.Location,CDeath.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CDeath
Join PortfolioProject..CovidVaccinations Cvac
	On CDeath.location = Cvac.location
	and CDeath.date = Cvac.date
Where CDeath.continent is not null
--Order by 2,3 

--verifing that the table is coming up correctly.
Select*
From PercentPopulationVaccinated
