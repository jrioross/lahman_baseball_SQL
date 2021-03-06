--Q1
SELECT MIN(year) AS starting_year,
		MAX(year) AS ending_year
FROM homegames;

--Q2
SELECT p.namelast,
		p.namefirst,
		p.height,
		a.teamid
FROM people AS p
LEFT JOIN appearances AS a
USING (playerid)
WHERE p.height = (SELECT MIN(height) FROM people);

--Q3
SELECT p.namefirst,
		p.namelast,
		SUM(COALESCE(s.salary,0)) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS cp
USING (playerid)
LEFT JOIN schools AS sch
USING (schoolid)
LEFT JOIN salaries AS s
USING (playerid)
WHERE sch.schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;

--Q4
WITH fielding_grouped AS (
	SELECT playerid,
		yearid,
		pos,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery' END AS pos_group,
		po
	FROM fielding
	)
SELECT pos_group,
		SUM(po)
FROM fielding_grouped
WHERE yearid = 1996
GROUP BY pos_group;

--Q5
WITH pitching_grouped AS (
	SELECT yearid,
			CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
			WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid >= 2010 THEN '2010s' END AS decade,
			g,
			so
	FROM pitching
)
SELECT decade,
		SUM(so),
		SUM(g)
FROM pitching_grouped
GROUP BY decade