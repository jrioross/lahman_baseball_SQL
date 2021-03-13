--Q1------------------------------------------------------------------------------------------
SELECT MIN(year) AS starting_year,
		MAX(year) AS ending_year
FROM homegames;

--Q2------------------------------------------------------------------------------------------
SELECT p.namelast,
		p.namefirst,
		p.height,
		a.teamid
FROM people AS p
LEFT JOIN appearances AS a
USING (playerid)
WHERE p.height = (SELECT MIN(height) FROM people);

--Q3------------------------------------------------------------------------------------------
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

--Q4------------------------------------------------------------------------------------------
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

--Q5------------------------------------------------------------------------------------------

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

--Q6------------------------------------------------------------------------------------------

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

--Q7------------------------------------------------------------------------------------------

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
		ROUND(100*AVG(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END), 2) AS perc_max_is_champ
FROM max_ws_champ AS m
INNER JOIN teams AS t
ON m.yearid = t.yearid AND m.max_w = t.w
--Max is champ: 12 teams. Percent max is champ: 22.64%

--Q8------------------------------------------------------------------------------------------

--Top 5 Attendance in 2016
	SELECT team,
			name,
			park_name,
			hg.attendance/ hg.games AS avg_att
	FROM homegames AS hg
	LEFT JOIN parks
	USING (park)
	LEFT JOIN teams AS t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE year = 2016 AND games >= 10
	ORDER BY hg.attendance/hg.games DESC
	LIMIT 5

--Bottom 5 Attendance in 2016
	SELECT team,
			name,
			park_name,
			hg.attendance/ hg.games AS avg_att
	FROM homegames AS hg
	LEFT JOIN parks
	USING (park)
	LEFT JOIN teams AS t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE year = 2016 AND games >= 10
	ORDER BY hg.attendance/hg.games
	LIMIT 5
	
--Q9------------------------------------------------------------------------------------------
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

--Q10: Select which colleges in TN have players with the most games in the MLB-----------------

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

--Q11: Correlation between wins and team salary (after 2000)---------------------------------

--Solution using ranks
WITH ts AS(
	SELECT yearid,
			teamid,
			SUM(salary) AS team_salary
	FROM salaries
	GROUP BY yearid, teamid
	ORDER BY yearid, teamid
),
sal_w_rk AS(
	SELECT t.yearid,
		t.teamid,
		ts.team_salary,
		t.w,
		RANK() OVER(PARTITION BY t.yearid ORDER BY ts.team_salary DESC) AS team_sal_rk,
		RANK() OVER(PARTITION BY t.yearid ORDER BY t.w DESC) AS team_w_rk
FROM teams AS t
LEFT JOIN ts
USING (yearid, teamid)
WHERE t.yearid >= 2000
ORDER BY t.yearid, t.w DESC
	)
SELECT team_sal_rk,
		ROUND(AVG(team_w_rk), 1) AS avg_w_rk
FROM sal_w_rk
GROUP BY team_sal_rk
ORDER BY team_sal_rk
--Salary is correlated with wins, though the slope isn't as steep as I'd expect (till #1)

--Solution using correlation coefficient and regression slope
WITH ts AS(
	SELECT yearid,
			teamid,
			SUM(salary) AS team_salary
	FROM salaries
	GROUP BY yearid, teamid
	ORDER BY yearid, teamid
)
SELECT corr(t.w, ts.team_salary) AS r_value,
		regr_slope(t.w, ts.team_salary) * 10^7 AS w_per_ten_mil
FROM teams AS t
LEFT JOIN ts
USING (yearid, teamid)
WHERE t.yearid >= 2000
--Pretty high r-value considering the number of data values. About 1 win per 10 million dollars.

--Q12.i--------------------------------------------------------------------------------------

WITH w_att_rk AS (
SELECT yearid,
		teamid,
		w,
		attendance / ghome AS avg_h_att,
		RANK() OVER(PARTITION BY yearid ORDER BY w) AS w_rk,
		RANK() OVER(PARTITION BY yearid ORDER BY attendance / ghome) AS avg_h_att_rk
FROM teams
WHERE attendance / ghome IS NOT NULL
AND yearid >= 1961 						--MLB institutes 162 game season
ORDER BY yearid, teamid
)
SELECT avg_h_att_rk,
		ROUND(AVG(w_rk), 1) AS avg_w_rk
FROM w_att_rk
GROUP BY avg_h_att_rk
ORDER BY avg_h_att_rk
--Very strong correlation between wins and home game attendance.

--Q12.ii

--After World Series Win
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wswin = 'Y'
--Attendance improves, on average, by 267.1 people per home game.

--After Playoff Berth
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wcwin = 'Y' OR divwin = 'Y'
--Attendance improves, on average, by 561.9 people per home game.

--Q13----------------------------------------------------------------------------------------

--Relative frequency of L vs R pitchers
SELECT SUM(CASE WHEN throws = 'L' THEN 1 ELSE 0 END) AS ct_L,
		ROUND(AVG(CASE WHEN throws = 'L' THEN 1 ELSE 0 END), 4) AS perc_L,
		SUM(CASE WHEN throws = 'R' THEN 1 ELSE 0 END) AS ct_R,
		ROUND(AVG(CASE WHEN throws = 'R' THEN 1 ELSE 0 END), 4) AS perc_R
FROM people
LEFT JOIN (
	SELECT DISTINCT playerid
	FROM pitching
	) AS dist_pitch
USING (playerid)
--L: 19.12%, R: 75.76%

--Relative frequency of Cy Young Awards (relative to all and relative to group size)

WITH cy_young AS (
	SELECT *
	FROM awardsplayers
	WHERE awardid = 'Cy Young Award'
	),
left_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'L'
	),
right_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'R'
	)
SELECT ROUND(AVG(CASE WHEN p.throws = 'L' THEN 1
		  		WHEN p.throws = 'R' THEN 0 END), 4) AS perc_CY_L,
		ROUND(AVG(CASE WHEN p.throws = 'R' THEN 1
		  		WHEN p.throws = 'L' THEN 0 END), 4) AS perc_CY_R
FROM people AS p
INNER JOIN cy_young
USING (playerid)
--L: 33.04%, R: 66.96%

WITH cy_young AS (
	SELECT *
	FROM awardsplayers
	WHERE awardid = 'Cy Young Award'
	),
left_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'L'
	),
right_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'R'
	)
SELECT 'Left' AS Arm,
		ROUND(AVG(CASE WHEN awardid = 'Cy Young Award' THEN 1
		  				ELSE 0 END), 4) AS perc_CY
FROM left_pitchers AS l
LEFT JOIN cy_young
USING (playerid)
UNION
SELECT 'Right' AS Arm,
		ROUND(AVG(CASE WHEN awardid = 'Cy Young Award' THEN 1
		  				ELSE 0 END), 4) AS perc_CY
FROM right_pitchers AS r
LEFT JOIN cy_young
USING (playerid)
--1.49% of left handers win the Cy Young, while 1.13% of right handers win the Cy Young

--Relative frequency of HOF Induction
WITH hof_pitchers AS (
	SELECT *
	FROM halloffame
	INNER JOIN pitching
	USING (playerid)
	WHERE inducted = 'Y'
	)
SELECT ROUND(AVG(CASE WHEN throws = 'L' THEN 1
		  		ELSE 0 END), 4) AS perc_HOF_L_pitch,
		ROUND(AVG(CASE WHEN throws = 'R' THEN 1
		  		ELSE 0 END), 4) AS perc_HOF_R_pitch
FROM hof_pitchers
INNER JOIN people
USING (playerid)
--Percent of HOF pitchers who are lefty: 22.51%, righty: 77.49%
				
WITH hof_pitchers AS (
	SELECT *
	FROM halloffame
	INNER JOIN pitching
	USING (playerid)
	WHERE inducted = 'Y'
	),
left_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'L'
	),
right_pitchers AS (
	SELECT *
	FROM people
	WHERE playerid IN
		(SELECT DISTINCT playerid
		FROM pitching
		)
	AND throws = 'R'
	)
SELECT 'Left' AS Arm,
		ROUND(AVG(CASE WHEN inducted = 'Y' THEN 1
		  				ELSE 0 END), 4) AS perc_HOF
FROM left_pitchers AS l
LEFT JOIN hof_pitchers
USING (playerid)
UNION
SELECT 'Right' AS Arm,
		ROUND(AVG(CASE WHEN inducted = 'Y' THEN 1
		  				ELSE 0 END), 4) AS perc_HOF
FROM right_pitchers AS r
LEFT JOIN hof_pitchers
USING (playerid)
--Percent of lefty pitchers who enter HOF: 11.18%, Righties: 14.02%