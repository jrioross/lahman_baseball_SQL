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
Select MIN(height) from people;
--43
Select * from people where height=43;
--playerid=gaedeed01 Eddie Gaedel, debut game 1951-08-19, final game 1951-08-19
Select * from appearances where playerid='gaedeed01';
Select * from teams where teamid='SLA';
/* Eddie Gaedel is the shortest player in the dataset, at 43 inches.  He played in 1 game as a pinch hitter for the St. Louis Browns. */

/*Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? */
