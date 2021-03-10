SELECT * FROM battingpost

SELECT * FROM allstarfull

--Question 1
SELECT MIN(DATE_PART('year', span_first)), MAX(DATE_PART('year', span_last)),  FROM homegames



--Question 2 Edward Gaedel 43 1 game SLA

select MIN(p.height), p.namegiven, a.g_all, a.teamid, p.namelast from people as p 
JOIN appearances as a
ON p.playerid = a.playerid
Group by p.namegiven, a.g_all, a.teamid, p.namelast
HAVING MIN(p.height) IS NOT NULL
ORDER BY MIN(p.height)


--Question 3
SELECT p.namefirst, p.namelast, s.schoolid, s.schoolname, SUM(sa.salary) from collegeplaying as c
LEFT JOIN people as p
on p.playerid = c.playerid
LEFT JOIN schools as s
ON c.schoolid = s.schoolid
LEFT JOIN salaries as sa
ON p.playerid = sa.playerid
WHERE s.schoolname = 'Vanderbilt University'
GROUP BY c.playerid, p.namefirst, p.namelast, s.schoolid, s.schoolname, sa.salary




--Question 3: David Price earned the most
WITH played_in_college as (
SELECT playerid, schoolid from collegeplaying),
vandy_players as (
SELECT schoolid, schoolname from schools
WHERE schoolname = 'Vanderbilt University'),
money as (
SELECT salary, playerid from salaries)
SELECT p.playerid, p.namefirst, p.namelast, COALESCE(SUM(money.salary),0) as salary, vandy_players.schoolname from people as p
LEFT JOIN played_in_college 
on played_in_college.playerid = p.playerid
LEFT JOIN vandy_players
on played_in_college.schoolid = vandy_players.schoolid
LEFT JOIN money
on money.playerid = p.playerid
WHERE salary <> 0 and schoolname = 'Vanderbilt University'
GROUP By p.playerid, vandy_players.schoolname
ORDER BY salary DESC



--Question 4 "Q: Is there a more consise way to list the positions in CASE WHEN?"
SELECT yearID, SUM(PO) as putouts,
CASE WHEN pos = 'OF' then 'Outfield'
WHEN pos = 'SS' THEN 'Infield'
WHEN pos = '1B' THEN 'Infield'
WHEN pos = '2B' THEN 'Infield'
WHEN pos = '3B' THEN 'Infield'
WHEN pos = 'P' THEN 'Battery'
WHEN pos = 'C' THEN 'Battery'
ELSE 'No Position' END as Position
FROM fielding
WHERE yearID = '2016' AND PO <> 0
GROUP BY yearID, position
ORDER by putouts DESC

--Question 5 Both SO and HR trended up with SO having a more pronounced trend up
SELECT ROUND(AVG(SO),2) as avg_so, ROUND(AVG(HR),2) as avg_hr, 
CASE WHEN yearID BETWEEN '1920' and '1929' THEN '1920s'
WHEN yearID BETWEEN '1930' AND '1939' THEN '1930s'
WHEN yearID BETWEEN '1940' AND '1940' THEN '1940s'
WHEN yearID BETWEEN '1950' AND '1950' THEN '1950s'
WHEN yearID BETWEEN '1960' AND '1960' THEN '1960s'
WHEN yearID BETWEEN '1970' AND '1970' THEN '1970s'
WHEN yearID BETWEEN '1980' AND '1980' THEN '1980s'
WHEN yearID BETWEEN '1990' AND '1990' THEN '1990s'
WHEN yearID BETWEEN '2000' AND '2000' THEN '2000s'
WHEN yearID BETWEEN '2010' AND '2020' THEN '2010s' END
FROM teams
GROUP BY yearID
ORDER BY yearID DESC

--Question 6 Can't get the % calc to work here
WITH bases as (
	SELECT yearID, SB, CS, playerid
FROM batting
WHERE yearID = '2016')
SELECT p.namefirst, p.namelast, p.playerid, SUM(SB+CS) as total_attempts, SUM(SB) as stolen, SUM(SB)/SUM(SB+CS)*100 as perc_success from people as p
JOIN bases ON bases.playerid = p.playerid
GROUP BY p.playerid
HAVING SUM(SB+CS) <> 0 and SUM(SB) >= 20
ORDER BY SUM(SB+CS) DESC

--Question 7  2001 SEATTLE Mariners, 116 wins, did not win world series
SELECT teamID, yearID, wswin, MAX(W) from teams
WHERE wswin = 'N' and yearID BETWEEN '1970' AND '2016'
GROUP BY teamID, yearID, wswin
ORDER BY MAX(W) DESC

--1981 Toronto, 37 wins no world series win....1981 season had a players strike
SELECT teamID, yearID, wswin, SUM(W) from teams
WHERE wswin = 'Y' and yearID BETWEEN '1970' AND '2016' AND yearID <> '1981'
GROUP BY teamID, yearID, wswin
ORDER BY SUM(W) DESC


--How often was it the case that the team with the most wins won the world series?
SELECT teamID, yearID, wswin, COUNT(*), COALESCE(MAX(W),0) from teams
WHERE wswin <> 'null' and yearID BETWEEN '1970' AND '2016' AND yearID <> '1981'
GROUP BY teamID, yearID, wswin
ORDER BY yearID DESC

SELECT teamID, yearID, wswin, MAX(W) from teams
WHERE wswin = 'Y' and yearID BETWEEN '1970' AND '2016' AND yearID <> '1981'
GROUP BY teamID, yearID, wswin
ORDER BY yearID DESC

--Question 8 
SELECT attendance, team, CAST(year as string) from homegames
WHERE yearID = '2016'

select * from homegames