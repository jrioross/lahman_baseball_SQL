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

--Strikeouts per game
WITH teams_grouped AS (
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
			so,
			hr
	FROM teams
)
SELECT decade,
		SUM(so) AS total_strikeouts,
		SUM(g) AS total_games,
		SUM(hr) AS total_hr,
		ROUND(2*CAST(SUM(so) AS numeric)/ SUM(g),2) AS so_per_game,
		ROUND(2*CAST(SUM(hr) AS numeric)/ SUM(g),2) AS hr_per_game
FROM teams_grouped
GROUP BY decade
ORDER BY decade;

--Q6
WITH b AS (
	SELECT playerid,
			yearid,
			sb,
			cs
	FROM batting
	WHERE (sb+cs) >= 20
	AND yearid = 2016
)
SELECT b.playerid,
		namefirst,
		namelast,
		ROUND(1.00*sb/(sb+cs) * 100, 2) AS sb_perc
FROM b
INNER JOIN people AS p
USING (playerid)
WHERE 1.00*sb/(sb+cs) = (SELECT MAX(1.00*sb/(sb+cs)) FROM b)

--Q7

WITH ws_champ AS (
	SELECT yearid,
			g,
			teamid,
			w
	FROM teams
	WHERE wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016
	)
SELECT yearid,
		g,
		teamid,
		w
FROM ws_champ
WHERE w = (SELECT MAX(w) FROM ws_champ);
--Max Wins: 2001 Seattle Mariners with 116 wins

WITH ws_champ AS (
	SELECT yearid,
			g,
			teamid,
			w
	FROM teams
	WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	)
SELECT yearid,
		g,
		teamid,
		w
FROM ws_champ
WHERE w = (SELECT MIN(w) FROM ws_champ)
--Min wins for shortened (lockout) season: 1981 LA Dodgers with 63 wins

WITH ws_champ AS (
	SELECT yearid,
			g,
			teamid,
			w
	FROM teams
	WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
	)
SELECT yearid,
		g,
		teamid,
		w
FROM ws_champ
WHERE w = (SELECT MIN(w) FROM ws_champ)
--Min wins excluding 1981: 2006 St. Louis Cardinals with 83 wins

WITH max_ws_champ AS (
	SELECT yearid,
			MAX(w) AS max_w
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	)
SELECT SUM(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) AS ct_max_is_champ,
		AVG(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) AS perc_max_is_champ
FROM max_ws_champ AS m
INNER JOIN teams AS t
ON m.yearid = t.yearid AND m.max_w = t.w
--Max is champ: 12 teams. Percent max is champ: 22.6%

--Q8

--Top 5 Attendance in 2016
	SELECT franchname,
			park_name,
			attendance/games AS avg_att
	FROM homegames
	INNER JOIN parks
	USING (park)
	INNER JOIN teamsfranchises AS tf
	ON homegames.team = tf.franchid
	WHERE year = 2016 AND games > 10
	ORDER BY attendance/games DESC
	LIMIT 5

--Bottom 5 Attendance in 2016
	SELECT franchname,
			park_name,
			attendance/games AS avg_att
	FROM homegames
	INNER JOIN parks
	USING (park)
	INNER JOIN teamsfranchises AS tf
	ON homegames.team = tf.franchid
	WHERE year = 2016 AND games > 10
	ORDER BY attendance/games
	LIMIT 5
	
--Q9
WITH NL_TSN AS (
	SELECT playerid
	FROM awardsmanagers AS aw
	WHERE awardid LIKE 'TSN %'
	AND lgid = 'NL'
	),
AL_TSN AS(
	SELECT playerid
	FROM awardsmanagers AS aw
	WHERE awardid LIKE 'TSN %'
	AND lgid = 'AL'
)
SELECT DISTINCT am.playerid,
		p.namefirst,
		p.namelast,
		am.lgid,
		am.yearid,
		tf.franchname
FROM awardsmanagers AS am
LEFT JOIN managers AS m
USING (playerid, yearid)
LEFT JOIN teamsfranchises AS tf
ON m.teamid = tf.franchid
LEFT JOIN people AS p
USING (playerid)
WHERE playerid IN
	(SELECT *
	FROM NL_TSN
	INTERSECT
	SELECT *
	FROM AL_TSN)
ORDER BY namelast, yearid;

--Open-Ended Questions-----------------------------------------------------------------------------------------

--Q10: Select which colleges in TN have players with the most games in the MLB

SELECT DISTINCT schoolname,
		playerid, namefirst, namelast,
		SUM(g_all) OVER(PARTITION BY playerid) AS g_total_player,
		SUM(g_all) OVER(PARTITION BY schoolname) AS g_total_school
FROM appearances AS a
INNER JOIN people AS p
USING (playerid)
INNER JOIN collegeplaying AS cp
USING (playerid)
INNER JOIN schools
USING (schoolid)
WHERE schoolstate = 'TN'
ORDER BY g_total_school DESC, g_total_player DESC;

--Q11: Correlation between wins and team salary (after 2000)

SELECT 