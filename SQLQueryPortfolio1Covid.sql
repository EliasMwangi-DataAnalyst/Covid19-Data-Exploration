
  Select *
  From CovidDeaths$
  where continent is not Null
  order by 1,2

  --looking at total cases vs total deaths

   Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  From CovidDeaths$
  where location like '%kenya%'
  order by 1,2

  --Looking at total cases vs Population
  --What population of people got Covid

 Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  From CovidDeaths$
  --where location like '%kenya%'
  order by 1,2

--looking at countires with highest infection rate compared to Population

Select location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
  From CovidDeaths$
  --where location like '%kenya%'
  Group by location, population
  order by PercentagePopulationInfected desc
  
  --BREAK THINGS BY CONTINENT 

--showing countries with highest death count per population

Select continent, Max(cast(total_deaths as int)) as totaldeathcount
From CovidDeaths$ 
  where continent is not Null
 Group by continent
  order by totaldeathcount desc

--global numbers 

 Select date, SUM(new_cases) AS TOTALCASES, SUM(CAST(new_deaths AS INT) ) AS TOTALDEATHS,
 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DEATHPERCENTAGE*100 as DeathPercentage
  From CovidDeaths$
  --where location like '%kenya%'
  WHERE continent IS NOT NULL
  GROUP BY date
  order by 1,2

  --TOTAL CASES
   Select SUM(new_cases) AS TOTALCASES, SUM(CAST(new_deaths AS INT) ) AS TOTALDEATHS,
 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DEATHPERCENTAGE  
  From CovidDeaths$
  --where location like '%kenya%'
  WHERE continent IS NOT NULL
  --GROUP BY date
  order by 1,2

  --Looking at Total Population vs Vacination 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 From CovidDeaths$ dea
  Join CovidVaccinations$ vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RolingPeaopleVaccinated
 From CovidDeaths$ dea
  Join CovidVaccinations$ vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  -- Use CTE to get percentage of people vaccinated 
  With PopvsVac (Continent, Location,Date, Population, new_vaccinations, RolingPeopleVaccinated)
  as 
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
 From CovidDeaths$ dea
  Join CovidVaccinations$ vac
  on dea.location = vac.location 
  and dea.date = vac.date
 where dea.continent is not null
 -- order by 2,3
  )
  Select *, (RolingPeopleVaccinated/Population)*100  
  From PopvsVac

 -- Use Temp table to get percentage of people vaccinated 
 Drop table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent varchar(255),
 Location varchar (255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RolingPeopleVaccinated numeric
 )

 Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
 From CovidDeaths$ dea
  Join CovidVaccinations$ vac
  on dea.location = vac.location 
  and dea.date = vac.date
 --where dea.continent is not null
 Select *, (RolingPeopleVaccinated/Population)*100  
  From #PercentPopulationVaccinated

 -- Creating view to store data visualization
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
 From CovidDeaths$ dea
  Join CovidVaccinations$ vac
  on dea.location = vac.location 
  and dea.date = vac.date
 where dea.continent is not null