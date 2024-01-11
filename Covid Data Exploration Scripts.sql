SELECT *
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null
--to remove continent names from location column

-- Shows death percentage and likelihood of death if one contracts covid in their country 
Select location, date, total_deaths, total_cases, (convert(decimal(15,3), total_deaths)/convert(decimal(15,3),total_cases))*100 as DeathPercentage
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null


-- Looking at Total Cases vs Population
-- Shows what percentage of population has gotten covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM LatestPortfolioProj..CovidDeaths2023
where location like '%kenya%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null
GROUP BY location, population
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- Shows total cases, total deaths and death percentage in the world daily
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null
GROUP BY date
ORDER BY 1
--NULLIF to avoid divide by zero error 

--Shows the total cases and deaths and death percentage worldly
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM LatestPortfolioProj..CovidDeaths2023
where continent is not null

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM LatestPortfolioProj..CovidDeaths2023 dea
JOIN LatestPortfolioProj..CovidVaccinations2023 vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


--Creating a rolling column for infections
SELECT continent, location, date, population, new_cases, 
SUM(new_cases) OVER (PARTITION BY location ORDER BY date) as RollingPeopleInfected
FROM LatestPortfolioProj..CovidDeaths2023  
	where continent is not null
--order by 2,3

--Using CTE to perform calculation on Partition By in previous query
;With Infections(continent, location, date, population, new_cases, RollingPeopleInfected)
AS
(
SELECT continent, location, date, population, new_cases, 
SUM(new_cases) OVER (PARTITION BY location ORDER BY date) as RollingPeopleInfected
FROM LatestPortfolioProj..CovidDeaths2023  
	where continent is not null 
)

Select *, (RollingPeopleInfected/population)*100 as PercentInfected
FROM Infections


--USING TEMP TABLE
DROP Table IF EXISTS PercentPopulationInfected
Create Table PercentPopulationInfected
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_cases numeric,
RollingPeopleInfected numeric
)

Insert Into PercentPopulationInfected
SELECT continent, location, date, population, new_cases, 
SUM(new_cases) OVER (PARTITION BY location ORDER BY date) as RollingPeopleInfected
FROM LatestPortfolioProj..CovidDeaths2023  
	where continent is not null 

Select *, (RollingPeopleInfected/population)*100 as PercentInfected
FROM PercentPopulationInfected


--Create View (Views are Permanent unlike Temp Tables and CTEs)
--Can be used for data visualization
Create View InfectionsView as
SELECT continent, location, date, population, new_cases, 
SUM(new_cases) OVER (PARTITION BY location ORDER BY date) as RollingPeopleInfected
FROM LatestPortfolioProj..CovidDeaths2023  
	where continent is not null 

Select *
FROM InfectionsView


