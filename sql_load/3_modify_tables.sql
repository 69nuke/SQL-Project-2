copy company_dim
FROM '/private/tmp/CSV files - sql_course/company_dim.csv'
DELIMITER ',' CSV HEADER;

copy job_postings_fact
FROM '/private/tmp/CSV files - sql_course/job_postings_fact.csv'
DELIMITER ',' CSV HEADER;

copy skills_dim
FROM '/private/tmp/CSV files - sql_course/skills_dim.csv'
DELIMITER ',' CSV HEADER;

copy skills_job_dim
FROM '/private/tmp/CSV files - sql_course/skills_job_dim.csv'
DELIMITER ',' CSV HEADER;

SELECT * 
from company_dim
LIMIT 15;

SELECT *
from job_postings_fact
LIMIT 100;

SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

SELECT
   job_title_short,
    job_location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time
FROM
    job_postings_fact;

SELECT
	job_title_short,
	job_location,
	EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
	EXTRACT(YEAR FROM job_posted_date) AS job_posted_year
FROM
	job_postings_fact;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month
FROM
	job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    job_posted_month
ORDER BY
    job_posted_count DESC;

-- For January
CREATE TABLE january_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- For February
CREATE TABLE february_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- For March
CREATE TABLE march_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;

SELECT job_posted_date
FROM january_jobs;




SELECT 
	COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category
ORDER BY    
    number_of_jobs DESC;


/* 
Temporary table of January jobs 
*/
SELECT *
FROM ( --Subquery starts here--
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;
     --Subquery ends here--


/* 
CTE
*/
WITH january_jobs AS ( --CTE definition starts here--
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)   --CTE definition ends here--




SELECT *
FROM january_jobs
WHERE company_id IN (--Subquery starts here--
        SELECT company_id
        FROM job_postings_fact
        WHERE job_no_degree_mention = true
); --Subquery ends here--




SELECT name AS company_name
FROM company_dim
WHERE company_id IN (--Subquery starts here--
        SELECT company_id
        FROM job_postings_fact
        WHERE job_no_degree_mention = true
); --Subquery ends here--







/*
Look at companies that don’t require a degree 
- Degree requirements are in the job_posting_fact table
- Use subquery to filter this in the company_dim table for company_names
- Order by the company name alphabetically
*/
SELECT
    company_id,
    name AS company_name 
FROM 
    company_dim
WHERE company_id IN (
    SELECT 
            company_id
    FROM 
            job_postings_fact 
    WHERE 
            job_no_degree_mention = true
    ORDER BY
            company_id
)
ORDER BY
    name ASC





/*
Find the companies that have the most job openings. 
- Get the total number of job postings per company id (job_posting_fact)
- Return the total number of jobs with the company name (company_dim)
*/

WITH company_job_count AS (
    SELECT 
            company_id,
            COUNT(*) AS total_jobs
    FROM 
            job_postings_fact 
    GROUP BY
            company_id
)

SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM 
    company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    total_jobs DESC;



WITH company_job_count AS (
    SELECT 
            company_id,
            COUNT(*) AS total_jobs
    FROM 
            job_postings_fact 
    GROUP BY
            company_id)
SELECT name 
FROM company_dim A
LEFT JOIN company_job_count B ON B.company_id = A.company_id



/*
Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/
WITH remote_job_skills AS (
    SELECT 
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True AND
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT 
    skills.skill_id,
    skills AS skill_name,
    skill_count  
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;



WITH remote_jobs_skills AS(
SELECT skill_id, COUNT(*) as skill_count
FROM skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS JP ON JP.job_id=skills_to_job.job_id
WHERE JP.job_work_from_home = True
GROUP BY skill_id
)
SELECT skills.skill_id, skills AS skill_name, skill_count
FROM remote_jobs_skills
INNER JOIN skills_dim AS skills ON skills.skill_id=remote_jobs_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5;



WITH remote_jobs_skills AS(
SELECT skill_id, COUNT(*) as skill_count
FROM skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS JP ON JP.job_id=skills_to_job.job_id
WHERE JP.job_work_from_home = True AND
      JP.job_title_short = 'Data Analyst'
GROUP BY skill_id
)
SELECT skills.skill_id, skills AS skill_name, skill_count
FROM remote_jobs_skills
INNER JOIN skills_dim AS skills ON skills.skill_id=remote_jobs_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5;


SELECT * FROM january_jobs;
SELECT * FROM february_jobs;
SELECT * FROM march_jobs;

-- Getting jobs, companies and location for Jan jobs - 
SELECT job_title_short, company_id, job_location
FROM january_jobs
UNION ALL
-- Getting jobs, companies and location for Feb jobs - 
SELECT job_title_short, company_id, job_location
FROM february_jobs
UNION ALL
-- Getting jobs, companies and location for Mar jobs - 
SELECT job_title_short, company_id, job_location
FROM march_jobs;






/*
Find job postings from the first quarter that have a salary greater than $70K
- Combine job posting tables from the first quarter of 2023 (Jan-Mar)
- Gets job postings with an average yearly salary > $70,000 
- Filter for Data Analyst Jobs and order by salary
*/

SELECT
	job_title_short,
	job_location,
	job_via,
	job_posted_date::DATE,
    salary_year_avg
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC





SELECT job_title_short,
	   job_location,
	   job_via,
	   job_posted_date::DATE,
       salary_year_avg
FROM(
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
) AS quarter1_job_postings
WHERE salary_year_avg>70000 AND 
      job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;

