WITH hits as (
	SELECT h, playerid from batting
	where h >= '200'),
	managers as (
	SELECT playerid, teamid from managershalf),
	team_name as (
	SELECT teamid from teams)
		SELECT p.namefirst, p.namelast, SUM(h) from people as p
	JOIN hits 
	on p.playerid = hits.playerid
	JOIN managersE