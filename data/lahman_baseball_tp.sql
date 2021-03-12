--Question 1. 
--What range of years for baseball games played does the provided database cover? 
	--1871-2016
SELECT MIN(yearid), MAX(yearid) 
FROM TEAMS;

--Question 2. 
--Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played?
	--Eddie Gaedel played in 1 game for the St. Louis Browns
SELECT p.namelast, p.namefirst, p.height, a.teamid, a.g_all, t.franchname
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
LEFT JOIN teamsfranchises AS t
ON a.teamid = t.franchid
WHERE a.teamid = 'SLA'
ORDER BY P.height;

-- Question 3.
--Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary 
--they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?
	--David Price
	
--USE coalesce to move NULL values??

SELECT DISTINCT c.playerid, SUM(s.salary) as salary, p.namelast, p.namefirst, c.schoolid
FROM collegeplaying c
LEFT JOIN people p
ON p.playerid = c.playerid
LEFT JOIN salaries s
ON p.playerid = s.playerid
WHERE c.schoolid LIKE '%vand%'
GROUP BY c.playerid,p.namelast,p.namefirst,c.schoolid
ORDER BY SUM(s.salary) DESC;

--Question 4
--Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
--and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016

--Battery: 41424
--infield: 58934
--Outfield 29560

SELECT DISTINCT sub.position fielding_group, SUM(sub.putouts) total_putouts
FROM
	(SELECT pos, SUM(po) AS putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery' 
	END AS position
	FROM fielding
	WHERE yearid = 2016
	group by position, pos) as sub
GROUP BY position;

--Question 5.
--Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. 
--Do you see any trends?
--need homeruns

WITH d AS (
SELECT t.so as strike_outs, t.g AS games,
CASE WHEN yearid >= 1920 AND yearid <= 1929 THEN '1920s'
WHEN yearid >= 1930 AND yearid<= 1939 THEN '1930s'
WHEN yearid >= 1940 AND yearid<= 1949 THEN '1940S'
WHEN yearid >= 1950 AND yearid<= 1959 THEN '1950S'
WHEN yearid >= 1960 AND yearid<= 1969 THEN '1960s'
WHEN yearid >= 1970 AND yearid<= 1979 THEN '1970s'
WHEN yearid >= 1980 AND yearid<= 1989 THEN '1980s'
WHEN yearid >= 1990 AND yearid<= 1999 THEN '1990s'
WHEN yearid >= 2000 AND yearid<= 2009 THEN '2000s'
WHEN yearid >= 2010 AND yearid<= 2019 THEN '2010s'
WHEN yearid >= 2020 THEN '2020s'
ELSE 'before 1920'
END AS decade
FROM teams t
GROUP BY decade, t.so, t.g
)
SELECT DISTINCT decade, ROUND(CAST(SUM(d.strike_outs) AS numeric)/SUM(d.games),2) AS so_per_game
FROM d
WHERE decade <> 'before 1920'
GROUP BY decade
ORDER BY decade;

--QUESTION 6
--Find the player who had the most success stealing bases in 2016, 
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted at least 20 stolen bases.

WITH s AS(
SELECT DISTINCT playerid, 
sb-cs AS steals, sb+cs AS att_steals
FROM batting
WHERE yearid = 2016
AND sb+cs >=20
)
SELECT p.namelast, p.namefirst, s.steals, s.att_steals, 
ROUND(CAST(s.steals AS numeric)/s.att_steals*100,2) as percent_success
FROM s
LEFT JOIN people AS p
ON p.playerid = s.playerid
ORDER BY percent_success DESC;

--QUESTION 7
--From 1970 – 2016, what is the largest number of wins for a team that did 
--not win the world series? What is the smallest number of wins for a team that 
--did win the world series? Doing this will probably result in an unusually small 
--number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won 
--the world series? What percentage of the time?

-- seattle Mariners with 106 wins
--LA Dodgers with 63 wins 
	--'81 is called the split season because of a players strike. 
--remove 1981 and the 2006 St. Louis cardinals are the team that won the WS while 
--having the the least regular season wins 

-- inner join?

SELECT t.w, t.l, t.yearid, t.wswin, f.franchname
FROM teams as t
LEFT JOIN teamsfranchises as f
ON t.franchid = f.franchid
WHERE t.wswin = 'N'
AND yearid > 1970
ORDER BY t.w DESC;

SELECT t.w, t.l, t.yearid, t.wswin, f.franchname
FROM teams as t
LEFT JOIN teamsfranchises as f
ON t.franchid = f.franchid
WHERE t.wswin = 'Y'
AND yearid > 1970
AND yearid <> 1981
ORDER BY t.w; 

WITH team AS(
SELECT t.w, t.yearid,t.wswin
FROM teams AS t
WHERE t.wswin = 'N'
AND t.yearid > 1970)
SELECT team.w 
FROM team
ORDER BY team.w DESC;

SELECT
MAX(w) OVER(PARTITION BY yearid), wswin, yearid, teamid,
COUNT(wswin) OVER()
FROM teams
WHERE yearid >= 1970
AND wswin = 'Y'
ORDER BY yearid;

--Question 8.
--Using the attendance figures from the homegames table, find the teams and 
--parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games).
--Only consider parks where there were at least 10 games played. Report the park name, 
--team name, and average attendance. Repeat for the lowest 5 average attendance.

WITH a1 as(
SELECT park, team,
	CASE WHEN attendance = 0 THEN 0 ELSE attendance/games 
	END AS h_avg_att
FROM homegames
WHERE year = 2016
AND games >= 10
ORDER BY h_avg_att DESC
LIMIT 10
)
/*a2 as(
SELECT park, team,
	CASE WHEN attendance = 0 THEN 0 ELSE attendance/games 
	END AS l_avg_att
FROM homegames
WHERE year = 2016
AND games > 10
ORDER BY l_avg_att ASC
LIMIT 5
)
*/
SELECT p.park_name, h_avg_att
FROM parks AS p
INNER join a1
ON p.park = a1.park
--INNER JOIN a2
--ON p.park = a2.park
ORDER BY h_avg_att DESC;

--QUESTION 9.
--Which managers have won the TSN Manager of the Year award in both the National League (NL) 
--and the American League (AL)? Give their full name and the teams that they were managing 
--when they won the award.

WITH al AS(
SELECT DISTINCT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'AL'
)
nl AS(
SELECT DISTINCT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year')
AND lgid = 'NL'

