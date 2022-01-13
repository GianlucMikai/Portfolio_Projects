SELECT
*
FROM
Portfolio_Project..Covid_Deaths_Data
ORDER BY 
3,4


--TABLE SUMMARY
SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM
Portfolio_Project..Covid_Deaths_Data
ORDER BY
1,2


--Look at total cases vs Total Deaths
--likelihood of dying to covid
SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS Death_Percentage
FROM
Portfolio_Project..Covid_Deaths_Data
ORDER BY
1,2


-- likelihood for death by covid in Trinidad and Tobago (Home Country)
SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS Death_Percentage
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
location = 'Trinidad and Tobago'
ORDER BY
1,2


--Look at total cases vs population
--Shows percentage of population which got covid
SELECT 
location, date, population, total_cases, (total_cases/population) *100 AS Percent_Population_Infected
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
location = 'Trinidad and Tobago'
ORDER BY
1,2


--TABLE 3 --Countries with highest infection rate compared to population
SELECT 
location, population, MAX(total_cases) AS Max_infection_count, MAX((total_cases/population)) *100 AS Percent_Population_Infected
FROM
Portfolio_Project..Covid_Deaths_Data
GROUP BY 
location, population
ORDER BY
Percent_Population_Infected DESC

--Table 4 -
SELECT 
location, population, date, MAX(total_cases) AS Max_infection_count, MAX((total_cases/population)) *100 AS Percent_Population_Infected
FROM
Portfolio_Project..Covid_Deaths_Data
GROUP BY 
location, population, date
ORDER BY
Percent_Population_Infected DESC


--Breaking down continents with highest death counts 
--where continent is null 

--SELECT 
--continent, MAX(CAST(total_deaths as int)) AS Total_Death_Count
--FROM
--Portfolio_Project..Covid_Deaths_Data
--WHERE
--continent is not null 
--GROUP BY 
--continent
--ORDER BY
--Total_Death_Count DESC (NOT SHOWING ACCURATE VALUES)

--TABLE 2 -- total death count by region
SELECT 
location, MAX(CAST(total_deaths as int)) AS Total_Death_Count
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
continent is null AND location NOT IN ('Upper middle income', 'High income', 'Lower middle income', 'Low income', 'International', 'European Union')
GROUP BY 
location
ORDER BY
Total_Death_Count DESC



--Countries with the highest death count per population
--where continent is not null as some coloumns have asia there but others have it in location.
SELECT 
location, MAX(CAST(total_deaths as int)) AS Total_Death_Count
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
continent is not null
GROUP BY 
location
ORDER BY
Total_Death_Count DESC



--GLOBAL NUMBERS (by date): new cases and deaths by day
SELECT 
date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
continent is not null
GROUP BY
date
ORDER BY
1,2

-- TABLE 1  --The Entire world total cases and deaths and death percentage.
SELECT 
SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM
Portfolio_Project..Covid_Deaths_Data
WHERE
continent is not null
ORDER BY
1,2


--Joining table.
--look at total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..Covid_Deaths_Data dea
JOIN Portfolio_Project..Covid_Vaccinations_Data vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is not null
ORDER BY
2, 3


--rolling count of vaccinations for country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count_Vaccinated
FROM Portfolio_Project..Covid_Deaths_Data dea
JOIN Portfolio_Project..Covid_Vaccinations_Data vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is not null
ORDER BY
2, 3

--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Count_Vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count_Vaccinated
FROM Portfolio_Project..Covid_Deaths_Data dea
JOIN Portfolio_Project..Covid_Vaccinations_Data vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is not null
)
SELECT *, (Rolling_Count_Vaccinated/population)*100 AS Rolling_Count_Percentage
FROM PopvsVac


--Temp Table
DROP Table if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Count_Vaccinated numeric
)
INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count_Vaccinated
FROM Portfolio_Project..Covid_Deaths_Data dea
JOIN Portfolio_Project..Covid_Vaccinations_Data vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is not null
SELECT *, (Rolling_Count_Vaccinated/population)*100 AS Rolling_Count_Percentage
FROM #Percent_Population_Vaccinated


--Create View to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count_Vaccinated
FROM Portfolio_Project..Covid_Deaths_Data dea
JOIN Portfolio_Project..Covid_Vaccinations_Data vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is not null



--Create views for all tables above to use tableau later on