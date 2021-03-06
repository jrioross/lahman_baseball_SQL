/* 1. What range of years for baseball games played does the provided database cover? */
Select MIN(debut) from people;
--1871
Select MIN(yearid) from fielding;
--1871
Select MAX(debut) from people;
--2017 -but the question is about years for baseball games...
Select MAX(yearid) from fielding;
--2016
Select MAX(yearid) from teams;
--2016
/*This dataset covers baseball games from 1871-2016 */

/* 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played? */
SELECT namefirst, namelast, height 
FROM people
WHERE height IN 
	(Select MIN(height) FROM people);
--playerid=gaedeed01 Eddie Gaedel, debut game 1951-08-19, final game 1951-08-19
SELECT a.playerid, a.g_all, t.name
FROM appearances AS a
INNER JOIN teams AS t
ON a.teamid=t.teamid
WHERE a.playerid='gaedeed01'
GROUP BY a.playerid, a.g_all, t.name;
/* Eddie Gaedel is the shortest player in the dataset, at 43 inches.  He played in 1 game as a pinch hitter for the St. Louis Browns. */


/*Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? */
Select DISTINCT(p.namefirst), p.namelast, s.schoolname, salary.salary
FROM people as p
LeFT JOIN collegeplaying as c
ON p.playerid=c.playerid
LEFT JOIN schools as s
ON c.schoolid=s.schoolid
LEFT JOIN salaries as salary
ON p.playerid=salary.playerid
WHERE s.schoolname='Vanderbilt University'
GROUP BY p.namefirst, p.namelast, s.schoolname, salary.salary
ORDER BY salary.salary DESC;

/*This query does not capture the players with NULL salaries*/
Select p.namefirst, p.namelast, s.schoolname, SUM(salary.salary) AS total_earned
FROM people as p
INNER JOIN collegeplaying as c
ON p.playerid=c.playerid
INNER JOIN schools as s
ON c.schoolid=s.schoolid
INNER JOIN salaries as salary
ON p.playerid=salary.playerid
WHERE s.schoolname='Vanderbilt University'
GROUP BY p.namefirst, p.namelast, s.schoolname
ORDER BY total_earned DESC;