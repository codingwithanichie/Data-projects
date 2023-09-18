CREATE DATABASE projects;

USE projects;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE null
END;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT termdate FROM hr;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate = '';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

SELECT birthdate, age FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*)
FROM hr
WHERE age < 18;


-- 1. What is the gender breakdown of employees int the company?
SELECT gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY gender;

-- 2. What is the race/ethinicity breakdown 0of employees in the company?
SELECT race, count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '');

SELECT
	CASE
		WHEN age >= 18 AND  age <= 24 THEN '18-24'
        WHEN age >= 25 AND  age <= 34 THEN '25-34'
        WHEN age >= 35 AND  age <= 44 THEN '35-44'
        WHEN age >= 45 AND  age <= 54 THEN '45-54'
        WHEN age >= 55 AND  age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY age_group
ORDER BY age_group;

SELECT
	CASE
		WHEN age >= 18 AND  age <= 24 THEN '18-24'
        WHEN age >= 25 AND  age <= 34 THEN '25-34'
        WHEN age >= 35 AND  age <= 44 THEN '35-44'
        WHEN age >= 45 AND  age <= 54 THEN '45-54'
        WHEN age >= 55 AND  age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender, count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquaters versus remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT
	round(avg(datediff(termdate,hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND (termdate IS NOT NULL OR termdate <> '') AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle,count(*) AS count
FROM hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT 
	department,
    total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    sum(CASE WHEN termdate IS NOT NULL OR termdate <> '' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, count(*) AS count
From hr
WHERE age >= 18 AND (termdate IS NULL OR termdate = '')
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100,2) AS net_change_percent
FROM(
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN (termdate IS NOT NULL OR termdate <> '') AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY year;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND (termdate IS NOT NULL OR termdate != '') AND age >= 18
GROUP BY department;




