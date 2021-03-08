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

SELECT DISTINCT c.playerid, SUM(s.salary), p.namelast, p.namefirst, c.schoolid
FROM collegeplaying c
JOIN people p
ON p.playerid = c.playerid
JOIN salaries s
ON p.playerid = s.playerid
WHERE c.schoolid LIKE '%vand%'
GROUP BY c.playerid,p.namelast,p.namefirst,c.schoolid
ORDER BY SUM(s.salary) DESC;

--Question 4
--Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
--and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016
SELECT DISTINCT sub.position fielding_group, SUM(sub.putouts) total_putouts
FROM
	(SELECT pos, SUM(po) AS putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery' 
	END AS position
	FROM fielding
	WHERE yearid = 2016
	group by position,pos) as sub
GROUP BY position;

--Question 5.
--Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. 
--Do you see any trends?

SELECT COUNT(so)
FROM batting
WHERE yearid > 1920;
