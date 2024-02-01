Use Covid19
Select * From ['Covid Deaths'] where Continent is Not Null order by 1, 2 ;
Select * From ['Covid Vaccinations'] order by 1, 2;


---Select Data that we are going to be using
use Covid19;
Select Location,date,total_cases,new_cases,total_deaths,Population From ['Covid Deaths'] order by 1,2 ;

---Looking at Total cases vs Total Deaths

Select Location,date,total_cases,total_deaths, 
Round (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100,3) AS deathpercentage
FROM ['Covid Deaths']
where location like '%India%' and Continent is Not Null
order by Date Desc;

---Now we are looking at Total Cases vs Population
---IT will show us what percentage of Population got COVID in India

Select Location,date,total_cases,population, 
Round (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)*100,3) AS deathpercentage
FROM ['Covid Deaths']
where location like '%India%' and Continent is Not Null
order by 1,2;


---We are Looking at the Countries with Highest Infection Rate compared to Population...

SELECT
    Location,
    population,
    MAX(total_cases) AS Highest_Infection_Count,
    ROUND(MAX(CAST(total_deaths AS FLOAT) / CAST(population AS FLOAT) * 100), 3) AS Percent_Infected_Population
FROM ['Covid Deaths']
GROUP BY Location, Population
ORDER BY Percent_Infected_Population DESC;

---Show Countries with the highest Deathcount per Population...

Select Location ,Max(Cast(Total_deaths as bigint)) as Total_Deaths_Count
From [dbo].['Covid Deaths']
Group By Location
Order By Total_Deaths_Count Desc

---Lets Check all new cases by Date. ---Lets do Percentage of New Deaths based on New Cases
 
 Select date, Sum(new_cases) as New_Cases, Sum(cast(new_deaths as bigint)) as New_Deaths,
 Round(Sum(Cast(new_deaths as bigint))/Sum(new_cases)*100, 3)as Death_Percentage
 From ['Covid Deaths']
 Where Continent is not NUll
 Group By Date
 Order By Death_Percentage desc

 ---lets see total total population and new vaccinations by date. and we have two joins

 Select dea.continent,dea.location, dea.date, vac.new_vaccinations as NEW_VACCINATIONS
 From ['Covid Deaths'] dea Join ['Covid Vaccinations'] Vac
 On dea.location = vac.location and dea.date= vac.date ---Connected two tables with two keys Date and loaction.
 Where dea.continent is not Null
 order by 2,3

 ---New Vaccinations per day and total vaccination for every day...;;

 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
 Sum(Convert(bigint,vac.new_vaccinations)) OVER
 (Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
 From ['Covid Deaths'] dea Join ['Covid Vaccinations'] Vac
 On dea.location = vac.location and dea.date= vac.date ---Connected two tables with two keys Date and loaction.
 Where dea.continent is not Null
 Order By 2,3

 ---After new vaccinations Total Vaccinations= New Vac+ New day vac.
 ---To See Percentage of new vaccinations by population.
 --- WE create CTE for that.

 With PopVsVac (Continent,Location,date,population,vaccinations,TOTAL_VACCINATIONS)
 AS
(
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
 Sum(Convert(bigint,vac.new_vaccinations)) OVER
 (Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
 From ['Covid Deaths'] dea Join ['Covid Vaccinations'] Vac
 On dea.location = vac.location and dea.date= vac.date ---Connected two tables with two keys Date and loaction.
 Where dea.continent is not Null
 )
 Select *, Round((TOTAL_VACCINATIONS/Population)*100,3)as VaccinationPercentage
 From PopVsVac

 ---Creating TEMP Taable.

 Create Table #Vaccination_Percentage
 (Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric,
 vaccinations numeric,
 TOTAL_VACCINATIONS numeric,
 )
 Insert into #Vaccination_Percentage
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
 Sum(Convert(bigint,vac.new_vaccinations)) OVER
 (Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
 From ['Covid Deaths'] dea Join ['Covid Vaccinations'] Vac
 On dea.location = vac.location and dea.date= vac.date ---Connected two tables with two keys Date and loaction.
 Where dea.continent is not Null

 Select *, Round((TOTAL_VACCINATIONS/Population)*100,3)as VaccinationPercentage
 From #Vaccination_Percentage


---Creating View to Soter data for later visualizations...

Create View Percentage_Population_Vaccinated As
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
 Sum(Convert(bigint,vac.new_vaccinations)) OVER
 (Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
 From ['Covid Deaths'] dea Join ['Covid Vaccinations'] Vac
 On dea.location = vac.location and dea.date= vac.date ---Connected two tables with two keys Date and loaction.
 Where dea.continent is not Null

 Select * From Percentage_Population_Vaccinated