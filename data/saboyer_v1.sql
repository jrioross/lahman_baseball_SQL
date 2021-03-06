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


--Question 4
SELECT playerid, pos, 
CASE WHEN pos = 'OF' then 'Outfield'
WHEN pos = 'SS' or '1B' or '2B' or '3B' THEN 'Infield'
WHEN pos = 'P' or 'C' THEN 'Battery' ELSE 'No Position' END as Position
FROM fielding







SELECT * FROM appearances


