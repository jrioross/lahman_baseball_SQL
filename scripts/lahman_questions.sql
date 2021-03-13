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

----------------

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

----------------

/*3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? */

Select p.namefirst, p.namelast, s.schoolname, SUM(salary.salary) AS total_earned
FROM people as p
LEFT JOIN collegeplaying as c
	ON p.playerid=c.playerid
LEFT JOIN schools as s
	ON c.schoolid=s.schoolid
LEFT JOIN salaries as salary
	ON p.playerid=salary.playerid
WHERE s.schoolname='Vanderbilt University'
GROUP BY p.namefirst, p.namelast, s.schoolname
ORDER BY total_earned DESC;

----------------

/*4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/

WITH player_groups AS
(	SELECT playerid,
		(CASE WHEN fielding.pos = 'OF' THEN 'Outfield'
		WHEN fielding.pos IN('SS','1B','2B','3B') THEN 'Infield'
		WHEN fielding.pos IN('P','C') THEN 'Battery'
		ELSE 'Unknown'
		END) AS position_group_2016
	FROM fielding
	WHERE yearid=2016 )
SELECT position_group_2016, SUM(po)
FROM fielding
LEFT JOIN player_groups
	ON player_groups.playerid=fielding.playerid
WHERE fielding.yearid=2016
GROUP BY position_group_2016;

----------------

/* 5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? */

--strikeouts
WITH decades AS 
(SELECT CAST(g, so,
 (CASE WHEN yearid IN(1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929) THEN '1920s'
	WHEN yearid IN(1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939) THEN '1930s'
	WHEN yearid IN(1940, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 1949) THEN '1940s'
	WHEN yearid IN(1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959) THEN '1950s'
	WHEN yearid IN(1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969) THEN '1960s'
	WHEN yearid IN(1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979) THEN '1970s'
	WHEN yearid IN(1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989) THEN '1980s'
	WHEN yearid IN(1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999) THEN '1990s'
	WHEN yearid IN(2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009) THEN '2000s'
	WHEN yearid IN(2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019) THEN '2010s' 
  ELSE 'Unknown' END) as decade
	FROM teams)
SELECT ROUND(SUM(so*1.0000)/SUM(g),2) as avg_strikeouts_per_game, decade
FROM decades
GROUP BY decade
ORDER BY decade ASC;
--The average number of strikeouts per game is increasing each decade.

--homeruns
WITH decades AS 
(SELECT g, hr,
 (CASE WHEN yearid IN(1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929) THEN '1920s'
	WHEN yearid IN(1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939) THEN '1930s'
	WHEN yearid IN(1940, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 1949) THEN '1940s'
	WHEN yearid IN(1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959) THEN '1950s'
	WHEN yearid IN(1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969) THEN '1960s'
	WHEN yearid IN(1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979) THEN '1970s'
	WHEN yearid IN(1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989) THEN '1980s'
	WHEN yearid IN(1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999) THEN '1990s'
	WHEN yearid IN(2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009) THEN '2000s'
	WHEN yearid IN(2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019) THEN '2010s' 
  ELSE 'Unknown' END) as decade
	FROM teams)
SELECT ROUND(SUM(hr*1.00)/SUM(g),2) as avg_homeruns_per_game, decade
FROM decades
GROUP BY decade
ORDER BY decade ASC;
--The average number of homeruns per game per decade is trending with an increase but is not as clear as the average number of strikeouts per game per decade.

----------------
 
/* 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen 
base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.*/

WITH total_steal_attempts AS
 (SELECT playerid, yearid, CAST(sb AS numeric), cs, (sb + cs) as total_attempts
  FROM batting) 
SELECT p.namefirst || ' ' || p.namelast, t.playerid, t.sb, t.cs, ROUND(((t.sb / t.total_attempts)*100),2) as percent_stolen
 FROM total_steal_attempts as t
 INNER JOIN people as p
 	ON p.playerid=t.playerid
 WHERE t.total_attempts >=20
 AND t.yearid=2016
 ORDER BY percent_stolen DESC
 LIMIT 10;
 --Chris Owings, who sucessfully stole 91% of their attempted steals in 2016.

----------------
 
/* 7a. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? */
 
SELECT teamid, sub.yearid, most_wins
FROM teams AS t
INNER JOIN
(	 SELECT yearid, MAX(w) as most_wins
 	FROM teams 
	 WHERE wswin = 'N'
	 AND yearid BETWEEN 1970 AND 2016
 	GROUP BY yearid) AS sub
ON t.yearid=sub.yearid AND sub.most_wins=t.w
	--JOINing on two columns ^^ seems to be the trick to persisting that one max win per year from the INNER JOIN (the INNER JOIN is needed because otherwise I would get all max wins per year per team)
ORDER BY most_wins DESC
LIMIT 1; --To get the team with the most most_wins;
/*SEA won 116 games in 2001, which is the most number of wins attributed to a team which did not win the world series that same year.*/
 
 
/* 7b. What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
Then redo your query, excluding the problem year. */
SELECT teamid, yearid, MIN(w) AS least_wins
FROM teams 
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
AND yearid != 1981
GROUP BY teamid, yearid
ORDER BY least_wins ASC
LIMIT 1;
/*LAN won 63 games in 1981 and went on to win the world series.  It is the lowest number of wins attributed to a team who won the world series in that same year.
 Additional research indicates that there was a player's strike in 1981 which led to a fewer total number of games that year, which could explain why the number of 
 wins for LAN this year was considerably lower than what we see for other years where the team has gone on to win the world series. */

/* 7c.  How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time? */
WITH max_wins AS
 (SELECT yearid, MAX(w) as most_wins
 	FROM teams 
	WHERE yearid BETWEEN 1970 AND 2016
 	GROUP BY yearid
  )
SELECT 
 	SUM(CASE WHEN wswin='Y' THEN 1 ELSE 0 END) AS most_wins_and_ws_win,
 	ROUND((AVG(CASE WHEN wswin='Y' THEN 1 ELSE 0 END)*100),2) AS percent_time_with_most_wins_and_ws_wins
FROM max_wins AS m
INNER JOIN teams AS t
ON m.yearid=t.yearid AND m.most_wins=t.w
/* Only 12 times has the team that won the most games during the season also won the world series.  Between 1970 and 2016, that is 22.64% of the time.*/

-------------
 
 /* 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance 
 per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks 
 where there were at least 10 games played. 
 Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/
 
 ---------NOTE: CANNOT GET FULL TEAM NAMES FORM FRANCHISES BECAUSE TEAM IDS ARE DIFFERENT ACROSS TABLES
 --Top 5/highest average attendance
 SELECT 
	 p.park_name,t.franchname, h.team,
 	(attendance / games) as avg_attendance
 FROM homegames AS h
 LEFT JOIN parks AS p
	ON h.park=p.park
 LEFT JOIN teamsfranchises as t
 	ON h.team=t.franchid
 WHERE h.games >= 10
 AND h.year=2016
 ORDER BY avg_attendance DESC
 LIMIT 5;

 --Bottom 5/lowest average attendance
 SELECT 
	 p.park_name,t.franchname, h.team,
 	(attendance / games) as avg_attendance
 FROM homegames AS h
 LEFT JOIN parks AS p
 	ON h.park=p.park
 LEFT JOIN teamsfranchises as t
 	ON h.team=t.franchid
 WHERE h.games >= 10
 AND h.year=2016
 ORDER BY avg_attendance ASC
 LIMIT 5;
 
 ----------------
 
 /* 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the 
 American League (AL)? Give their full name and the teams that they were managing when they won the award.*/
 
WITH am_lg AS
 (	SELECT playerid
 	FROM awardsmanagers
   	WHERE awardid='TSN Manager of the Year'
  	AND lgid = 'AL'
 ),
 nl_lg AS
 (	SELECT playerid
 	FROM awardsmanagers
   	WHERE awardid='TSN Manager of the Year'
  	AND lgid = 'NL'
 )
SELECT DISTINCT a.awardid, a.lgid, p.namefirst ||' '|| p.namelast as full_name, a.yearid, m.teamid AS team
 FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid=p.playerid 
INNER JOIN managers AS m
 ON a.yearid=m.yearid AND a.playerid=m.playerid
WHERE p.playerid IN (SELECT playerid
	FROM am_lg
	INTERSECT
	SELECT playerid
	 FROM nl_lg)
AND a.awardid='TSN Manager of the Year'
 ORDER BY full_name, a.yearid ASC

/* This returns six results, composed of two managers: Jim Leyland and Davey Johnson. */
 
