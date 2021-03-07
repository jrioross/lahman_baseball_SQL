--Question 1. 
--What range of years for baseball games played does the provided database cover? 
--1871-2016
SELECT MIN(yearid), MAX(yearid) 
FROM TEAMS;

--Question 2. 
--Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played?
SELECT p.namelast, p.namefirst, p.height, a.teamid, a.g_all, t.franchname
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
LEFT JOIN teamsfranchises AS t
ON a.teamid = t.franchid
WHERE a.teamid = 'SLA'
ORDER BY P.height;



--Eddie Gaedel played in 1 game for the St. Louis Browns