SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
--Where location = 'world'
ORDER BY Location, date

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select data that we are going to be using
SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs. total deaths (%) based on location
-- Shows likelihood of dying if one gets Covid in a said country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percent
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2
-- Location code: 1. Where Location = 'Pakistan' 2. Where Location LIKE '%land%'

EXEC sp_help 'PortfolioProject..CovidDeaths'; -- Code to check datatype of a column

ALTER TABLE PortfolioProject..CovidDeaths -- Code to convert a column from one datatype to another
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float

-- Looking at total cases vs. population
-- Shows what percentage of population has gotten covid
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS ContractionPercent
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2

-- Shows countries with highest infection rate compared to population
SELECT Location, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestContractionPercent
FROM PortfolioProject.dbo.CovidDeaths
Group By Location, Population
ORDER BY HighestContractionPercent DESC

-- Visualization 4 -- Shows countries with their highest infection rate compared to population
SELECT Location, Date, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestContractionPercent
FROM PortfolioProject.dbo.CovidDeaths
Group By Location, Population, Date
ORDER BY HighestContractionPercent DESC

-- Shows countries with infection rate on a daily basis (w.r.t date) and compared to population
SELECT Location, Population, Date, new_cases AS HighestInfectionCount, (new_cases/population)*100 AS HighestContractionPercent
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location, date

-- Shows countries with highest death count per population
SELECT Location, population, MAX((total_deaths/population))*100 AS HighestDeathPercent, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY HighestDeathCount DESC

-- Let's break things down by Continent - Shows the death rate in each continent
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Shows the (top country with) highest death count in each continent
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Shows the Location in each continent with highest death count
SELECT Continent, Location, MAX(total_deaths) AS Highest_Death_Count, MAX((total_deaths/population))*100 AS Highest_Death_Percent
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY Location, continent
ORDER BY Highest_Death_Count DESC

-- Shows the continents with total death count
SELECT Location, MAX(total_deaths) AS Total_Death_Count--, MAX((total_deaths/population))*100 AS Highest_Death_Percent
FROM PortfolioProject.dbo.CovidDeaths
Where continent is null
and
location not in ('World', 'High income', 'Upper middle income', 'Low income', 'Lower middle income', 'European Union')
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Global Numbers
-- Show covid cases and deaths recorded globally on a daily basis 
SELECT date, SUM(new_cases) AS DailyCovidCases, SUM(new_deaths) AS DailyCovidDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
AND
new_cases != 0
Group by date
Order by date
 
 -- Shows total covid cases, deaths and overall death %
SELECT SUM(new_cases) AS TotalCovidCases, SUM(new_deaths) AS TotalCovidDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS OverallDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
AND
new_cases != 0
--Group by date
Order by 1,2

-- Shows Total Population Vs. Fully Vaccinated people
SELECT Vaccinations.Location, deaths.Population, MAX(cast(people_fully_vaccinated as int)) AS Vaccinations_Countrywide, (MAX(cast(people_fully_vaccinated as int))/Deaths.population)*100 AS PercentVaccinated
FROM PortfolioProject.dbo.CovidDeaths Deaths
Join PortfolioProject.dbo.CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where vaccinations.continent is not null
Group by Vaccinations.location, deaths.population
Order by Vaccinations_Countrywide DESC

-- Method 1: Use CTE
With PopvsVac (Continent, Location, Date, Population, Daily_new_vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total Population Vs. Vaccinations
SELECT Vaccinations.Continent, Vaccinations.Location, Vaccinations.Date, Deaths.Population, 
Convert (float, Vaccinations.new_vaccinations) AS Daily_new_vaccinations , SUM(Convert(float, Vaccinations.new_vaccinations)) 
OVER (Partition by Vaccinations.Location Order by Vaccinations.Location, Vaccinations.date) AS RollingPeopleVaccinated --Commulative addition
FROM PortfolioProject.dbo.CovidDeaths Deaths
Join PortfolioProject.dbo.CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where vaccinations.continent is not null
--Group by Vaccinations.location, deaths.population
--Order by location, date
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_People_Vaccinated
FROM PopvsVac

(--Method 2
--SELECT Vaccinations.Continent, Vaccinations.Location, Deaths.Population, SUM(Convert(float, Vaccinations.new_vaccinations)) AS Total_newly_vaccinated
--FROM PortfolioProject.dbo.CovidDeaths Deaths
--Join PortfolioProject.dbo.CovidVaccinations Vaccinations
--On Deaths.location = Vaccinations.location
--Where vaccinations.continent is not null
--Group by Vaccinations.Continent, Vaccinations.Location, Deaths.Population
--Order by Vaccinations.Location --Total_newly_vaccinated)

-- Shows the total number of people worldwide that have been vaccinated

-- Method 2: TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
Daily_new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT Vaccinations.Continent, Vaccinations.Location, Vaccinations.Date, Deaths.Population, 
Convert (float, Vaccinations.new_vaccinations) AS Daily_new_vaccinations , SUM(Convert(float, Vaccinations.new_vaccinations)) 
OVER (Partition by Vaccinations.Location Order by Vaccinations.Location, Vaccinations.date) AS RollingPeopleVaccinated --Commulative addition
FROM PortfolioProject.dbo.CovidDeaths Deaths
Join PortfolioProject.dbo.CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where vaccinations.continent is not null
--Group by Vaccinations.location, deaths.population
--Order by Continent, location, date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_People_Vaccinated
FROM #PercentPopulationVaccinated

Create View Population_Vaccinated
as
SELECT Vaccinations.Continent, Vaccinations.Location, Vaccinations.Date, Deaths.Population, 
Convert (float, Vaccinations.new_vaccinations) AS Daily_new_vaccinations , SUM(Convert(float, Vaccinations.new_vaccinations)) 
OVER (Partition by Vaccinations.Location Order by Vaccinations.Location, Vaccinations.date) AS RollingPeopleVaccinated --Commulative addition
FROM PortfolioProject.dbo.CovidDeaths Deaths
Join PortfolioProject.dbo.CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where vaccinations.continent is not null
--Group by Vaccinations.location, deaths.population
--Order by location, date

SELECT * 
FROM Population_Vaccinated