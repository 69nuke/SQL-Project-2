# Introduction 

 Data job market analysis.
 Focusing on data analyst roles, this project explores top-paying jobs, in-demand skills, and where high demand meets high salary in data analytics.

 SQL queries are stored in [project_sql folder](/project_sql/) .


# Background 

 Driven by a quest to navigate the data analyst job market more effectively, this project was born from a desire to pinpoint top-paid and in-demand skills, streamlining others work to find optimal jobs.

 Data was kindly made available by Luke Barousse (www.lukebarousse.com), and was collected from: https://drive.google.com/drive/folders/1moeWYoUtUklJO6NJdWo9OV8zWjRn0rjN

 We performed 5 SQL queries in order to answer the following questions: 

 1) What are the top-paying data analyst jobs?
 2) What skills are required for these top-paying jobs?
 3) What skills are most in demand for data analysts?
 4) Which skills are associated with higher salaries?
 5) What are the most optimal skills to learn?




# Tools
- **SQL**
- **PostgreSQL**
- **Visual Studio Code**
- **Git** & **GitHub**

# Analysis 


### 1. Top Paying Data Analyst Jobs

Top 10 remote Data Analyst jobs have salaries ranging from 184k to a whopping 650k per year! Most of these are related to management/director positions though.

![Top Paying Roles](assets/query1_plot.png)

```sql
SELECT	
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```

### 2. Skills for Top Paying Jobs

SQL, Python consistently feature within the top sought-after skills most of the top-paid remote Data Analyst positions. 
R, Tableau and, PowerBI are also pretty relevant, along with the rest.

![Skills for Top Paying Jobs](assets/query2_plot.png)

```sql
WITH top_paying_jobs AS (
    SELECT	
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```


### 3. In-Demand Skills for Data Analysts

Top 5 skills requested for Data Analysts are SQL, Excel, Python, Tableau, PowerBI.

![Top In-Demand Skills for Data Analysts](assets/query3_plot.png)

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```




### 4. Skills Based on Salary
Pyspark, Bitbucket and Couchbase are the top three skills associated to the highest average yearly remote Data Analysts salaries.
The three skills linked to the lower yearly average salaries are PostgreSQL, GCP and Microstrategy.

![Skills Based on Salary](assets/query4_plot.png)

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```




### 5. Top Paying Data Analyst Jobs
Insights for skill development by comining combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries.
- Python/R and Tableau are the most sought-after skills, associated with some high average salaries (a programming language and a Business Intelligence/ Data Visualization tool are hence much appreciated),
- Cloud Tools and Big Data Technologies are highly valuable (GO, Azure, Snowflake, BigQuery, Hadoop...),
- also database technologies (SQL Server, Oracle, NoSQL...) are associated to high average salaries.

![Skills Based on Salary](assets/query5_plot.png)

```sql
-- Identifies skills in high demand for Data Analyst roles
-- Use Query #3
WITH skills_demand AS (
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True 
    GROUP BY
        skills_dim.skill_id
), 
-- Skills with high average salaries for Data Analyst roles
-- Use Query #4
average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True 
    GROUP BY
        skills_job_dim.skill_id
)
-- Return high demand and high salaries for 10 skills 
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM
    skills_demand
INNER JOIN  average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE  
    demand_count > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```



# What I have learnt 
Dealing with advanced, complex SQL queries in order to effectively draw valuable insights for data.
This project allowed me to:
- handle real-time data, store it into a PostgreSQL server, connect to it using VSCode as an Integrated Development Environment;
- refresh my SQL skills and use the data onto getting some valuable insights from data; 
- use advances SQL concepts as GROUP BY, COUNT() and AVG() clauses, subqueries, along with familiarizing with Common Table Expressions (CTEs);
- push and pull data and changes to the project to and from my GitHub account.


# Conclusions
Insights:

- **Top-Paying Data Analyst Jobs**: The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
- **Skills for Top-Paying Jobs**: High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
- **Most In-Demand Skills**: SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
- **Skills with Higher Salaries**: Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
- **Optimal Skills for Job Market Value**: SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.

---- --



