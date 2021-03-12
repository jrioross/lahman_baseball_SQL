SELECT * FROM battingpost

SELECT * FROM allstarfull

--Question 1
SELECT MIN(DATE_PART('year', span_first)), MAX(DATE_PART('year', span_last))  FROM homegames



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

--SO
WITH decade AS(
SELECT g, SO,
(CASE WHEN yearID BETWEEN '1920' and '1929' THEN '1920s'
WHEN yearID BETWEEN '1930' AND '1939' THEN '1930s'
WHEN yearID BETWEEN '1940' AND '1940' THEN '1940s'
WHEN yearID BETWEEN '1950' AND '1950' THEN '1950s'
WHEN yearID BETWEEN '1960' AND '1960' THEN '1960s'
WHEN yearID BETWEEN '1970' AND '1970' THEN '1970s'
WHEN yearID BETWEEN '1980' AND '1980' THEN '1980s'
WHEN yearID BETWEEN '1990' AND '1990' THEN '1990s'
WHEN yearID BETWEEN '2000' AND '2000' THEN '2000s'
WHEN yearID BETWEEN '2010' AND '2020' THEN '2010s' END) as decade
FROM teams)
SELECT ROUND(SUM(SO*1.00)/SUM(g),2) as avg_SO_per_game, decade
FROM decade
GROUP BY decade
ORDER BY decade DESC
--HR
WITH decade AS(
SELECT g, HR,
(CASE WHEN yearID BETWEEN '1920' and '1929' THEN '1920s'
WHEN yearID BETWEEN '1930' AND '1939' THEN '1930s'
WHEN yearID BETWEEN '1940' AND '1940' THEN '1940s'
WHEN yearID BETWEEN '1950' AND '1950' THEN '1950s'
WHEN yearID BETWEEN '1960' AND '1960' THEN '1960s'
WHEN yearID BETWEEN '1970' AND '1970' THEN '1970s'
WHEN yearID BETWEEN '1980' AND '1980' THEN '1980s'
WHEN yearID BETWEEN '1990' AND '1990' THEN '1990s'
WHEN yearID BETWEEN '2000' AND '2000' THEN '2000s'
WHEN yearID BETWEEN '2010' AND '2020' THEN '2010s' END) as decade
FROM teams)
SELECT ROUND(SUM(HR*1.00)/SUM(g),2) as avg_HR_per_game, decade
FROM decade
GROUP BY decade
ORDER BY decade DESC



--Question 6 Chris Owings 91%
WITH bases as (
	SELECT yearID, SB, CS, playerid
FROM batting
WHERE yearID = '2016')
SELECT p.namefirst, p.namelast, p.playerid, SUM(SB+CS) as total_attempts, SUM(SB) as stolen, ROUND(SUM(SB*1.00)/SUM(SB+CS),2) as perc_success from people as p
JOIN bases ON bases.playerid = p.playerid
GROUP BY p.playerid
HAVING SUM(SB+CS) <> 0 and SUM(SB+CS) >= 20
ORDER BY perc_success DESC

--Question 7  2001 SEATTLE Mariners, 116 wins, did not win world series
SELECT teamID, yearID, wswin, MAX(W) from teams
WHERE wswin = 'N' and yearID BETWEEN '1970' AND '2016'
GROUP BY teamID, yearID, wswin
ORDER BY MAX(W) DESC

--1981 Toronto, 37 wins no world series win....1981 season had a players strike
SELECT teamID, yearID, wswin, SUM(W) from teams
WHERE wswin = 'Y' and yearID BETWEEN '1970' AND '2016' 
GROUP BY teamID, yearID, wswin
ORDER BY SUM(W) DESC

--With 1981 Toronto removed, 2006 SLN is next lowest with 83 wins
SELECT teamID, yearID, wswin, SUM(W) from teams
WHERE wswin = 'Y' and yearID BETWEEN '1970' AND '2016' AND yearID <> '1981'
GROUP BY teamID, yearID, wswin
ORDER BY SUM(W) DESC


--How often was it the case that the team with the most wins won the world series?
WITH ws_loss as (
SELECT (CASE WHEN wswin = 'Y' THEN COUNT(*) END) as sumyes, SUM(sumyes) FROM teams
GROUP BY wswin

SELECT ((CASE WHEN wswin = 'N' THEN COUNT(*) END)/COUNT(*))*100 FROM teams
GROUP BY wswin
	
WITH ws_loss as (
SELECT (CASE WHEN wswin = 'Y' THEN COUNT (*) END) FROM teams)
SELECT wswin, MAX(W), COUNT(*) OVER() from teams
WHERE yearID BETWEEN '1970' AND '2016'
GROUP BY teamID, yearID, wswin
ORDER BY MAX(W) DESC

WITH ws_loss as (
SELECT COUNT(*) as Total_games, wswin, w, yearID FROM teams
GROUP BY wswin, w, yearID)
SELECT wswin, MAX(w) from ws_loss
WHERE yearID BETWEEN '1970' AND '2016'
GROUP BY yearID, wswin
ORDER BY MAX(w) DESC	
	

--END of 7 "Heartbreak"	answer
WITH ws_games as (
SELECT (CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) as wins, (CASE WHEN wswin = 'Y' or 'N' THEN COUNT(*) END) as total_games from teams
GROUP by wswin)
SELECT wins/total_games*100 from ws_games


	
	
SELECT * from teamsfranchises
	
	
--Question 8 
--Top 5
SELECT h.attendance, h.games, SUM(h.attendance/h.games) as avg_attendance, h.team, h.year, p.park_name, h.park, p.park from homegames as h 
LEFT JOIN parks as p 
ON p.park = h.park
WHERE h.year = 2016 and h.games >=10
Group BY p.park_name, h.attendance, h.games, h.team, h.year, p.park_name, h.park, p.park_alias, p.park
Order by avg_attendance DESC
LIMIT 5

--Bottom 5
SELECT h.attendance, h.games, SUM(h.attendance/h.games) as avg_attendance, h.team, h.year, p.park_name, h.park, p.park from homegames as h 
LEFT JOIN parks as p 
ON p.park = h.park
WHERE h.year = 2016 and h.games >=10
Group BY p.park_name, h.attendance, h.games, h.team, h.year, p.park_name, h.park, p.park_alias, p.park
Order by avg_attendance
LIMIT 5

	
WHERE year = 2016


--Question 9	
WITH player_name AS (
SELECT namefirst, namelast, playerid from people),
team_managing AS (
SELECT name, lgid, teamid from teams),
add_managing as (
SELECT playerid, yearid, teamid from managershalf)
select a.playerid, a.awardid, a.yearid, a.lgid, team_managing.name from awardsmanagers as a
JOIN player_name on player_name.playerid = a.playerid
JOIN team_managing on team_managing.lgid = a.lgid
JOIN add_managing on add_managing.teamid = team_managing.teamid and add_managing.playerid = player_name.playerid
WHERE a.awardid = 'TSN Manager of the Year' and a.lgid = 'NL'



WITH player_name AS (
SELECT namefirst, namelast, playerid from people),
team_managing AS (
SELECT name, lgid, teamid, yearid from teams)
select DISTINCT(a.playerid), player_name.namefirst, player_name.namelast, a.awardid, a.yearid, team_managing.lgid from awardsmanagers as a
JOIN player_name on player_name.playerid = a.playerid
JOIN team_managing on team_managing.yearid = a.yearid
WHERE a.awardid = 'TSN Manager of the Year'
GROUP BY team_managing.lgid, a.playerid, player_name.namefirst, player_name.namelast, a.awardid, a.yearid
ORDER BY a.yearid DESC

--Original
WITH player_name AS (
SELECT namefirst, namelast, playerid from people),
team_managing AS (
SELECT name, lgid, teamid, yearid from teams)
select DISTINCT(a.playerid), player_name.namefirst, player_name.namelast, a.awardid, a.yearid from awardsmanagers as a
JOIN player_name on player_name.playerid = a.playerid
JOIN team_managing on team_managing.yearid = a.yearid
WHERE a.awardid = 'TSN Manager of the Year' and team_managing.lgid = 'AL'
ORDER BY a.playerid

WITH player_name AS (
SELECT namefirst, namelast, playerid from people),
team_managing AS (
SELECT name, lgid, teamid, yearid from teams)
select DISTINCT(a.playerid), player_name.namefirst, player_name.namelast, a.awardid, a.yearid, team_managing.lgid from awardsmanagers as a
JOIN player_name on player_name.playerid = a.playerid
JOIN team_managing on team_managing.yearid = a.yearid
WHERE a.awardid = 'TSN Manager of the Year'
ORDER BY a.yearid










Select m.playerid 
from managers as m
WHERE plyrmgr

select * from managers




SELECT p.playerid, m.teamid from people as p
JOIN managers as m
ON m.playerid = p.playerid
where m.playerid = 'blackbu02'
UNION
SELECT a.playerid, a.awardid
from awardsmanagers as a
where a.playerid = 'blackbu02'

SELECT m.playerid, a.awardid, m.yearid from managers as m
Join awardsmanagers as a 
on a.playerid = m.playerid
UNION
SELECT p.playerid from people as p


SELECT p.playerid, m.teamid from people as p
JOIN managers as m
ON m.playerid = p.playerid
where m.playerid = 'blackbu02'
UNION
SELECT a.playerid, a.awardid
from awardsmanagers as a
where a.playerid = 'blackbu02'



JOIN awardsmanagers as a
ON a.playerID = p.playerID
GROUP BY p.playerid, m.teamid, a.awardid, a.yearid
Order by p.playerid DESC


WITH awards as (
SELECT awardid, playerid from awardsmanagers)
SELECT m.playerid, awards.awardid from managers as m
JOIN awards ON awards.playerid = m.playerid
UNION ALL
SELECT a.playerid from awardsmanagers as a


select * from awardsmanagers

(select awardid
from awardsmanagers
where awardid = 'TSN Manager of the Year')




SELECT playerid, awardid, yearid
FROM awardsmanagers
WHERE playerid in
(select p.playerid
from people as p)

SELECT playerid, awardid, yearid
FROM awardsmanagers
WHERE playerid in
(select m.playerid
from managers as m)


select * from managers
	
--Question 10
WITH played_in_college as (
SELECT playerid, schoolid from collegeplaying),
vandy_players as (
SELECT schoolid, schoolname, schoolstate from schools),
money as (
SELECT salary, playerid from salaries)
SELECT COALESCE(SUM(money.salary),0) as salary, vandy_players.schoolname, COUNT(DISTINCT p.playerid), SUM(salary)/COUNT(DISTINCT p.playerid) from people as p
LEFT JOIN played_in_college 
on played_in_college.playerid = p.playerid
LEFT JOIN vandy_players
on played_in_college.schoolid = vandy_players.schoolid
LEFT JOIN money
on money.playerid = p.playerid
WHERE salary <> 0 and schoolstate = 'TN'
GROUP By vandy_players.schoolname
ORDER BY SUM(salary) DESC, schoolname 
