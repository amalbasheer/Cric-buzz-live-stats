--updating fetched tables as required
alter table matches_recent
add column start_ts timestamp with time zone,
add column end_ts timestamp with time zone;

alter table matches
add column start_ts timestamp with time zone,
add column end_ts timestamp with time zone;

create table venue (Stadium_Name text, City text, 
                    Country text, Capacity integer, 
					Match_Type text);

create table role (player_name text, role text);

create table batting (Player text, Team text, Type text, Match integer,	Inn	integer,
                      not_out integer, Runs integer, Highest_Score integer, bat_Avg decimal,
					  Balls_Faced integer, Strick_Rate decimal,	four integer, six integer, 
					  fifty integer, century integer, two_hun integer);

create table series (Match_ID integer, Match_Name text, Series_ID integer,	
                     Series_Name text, Match_Date date, Match_Format text, Team1_ID	integer,
					 Team1_Name	text, Team1_Captain	text, Team1_Runs integer, Team1_Wickets integer,	
					 Team1_Extras integer, Team2_ID integer, Team2_Name text, Team2_Captain	text,
					 Team2_Runs integer, Team2_Wickets integer, Team2_Extras text, 
					 Venue Text, Venue_City text, Venue_Country text,Umpire1 text, Umpire2 text,	
					 Referee text, Toss_Winner text, Toss_Winner_Choice	text, Winner text,	
					 Match_Result Text);

create table bowling (Player text, Team	text, Type text, Matches integer, Inn integer,
                      Bowls integer, Runs integer, Wkts integer, Econ decimal, bowl_Avg	decimal,
					  Strike_rate decimal, five_Wkt integer, ten_Wkt integer);

copy series (Match_ID,	Match_Name,	Series_ID,	Series_Name, Match_Date, Match_Format,
             Team1_ID, Team1_Name, Team1_Captain, Team1_Runs, Team1_Wickets, Team1_Extras,
			 Team2_ID, Team2_Name, Team2_Captain, Team2_Runs, Team2_Wickets, Team2_Extras,
			 Venue, Venue_City, Venue_Country, Umpire1, Umpire2, Referee, Toss_Winner,	
			 Toss_Winner_Choice, Winner, Match_Result)	
from 'C:/Program Files/PostgreSQL/17/data/DATASETS/odi_Matches_Data.csv'
with (format csv, header true, delimiter ',');
					 
copy batting (Player, Team, Type, Match, Inn,not_out, Runs, Highest_Score, bat_Avg,
					  Balls_Faced, Strick_Rate, four, six, fifty, century, two_hun)
from 'C:/Program Files/PostgreSQL/17/data/DATASETS/bat.csv'
with (format csv, header true, delimiter ',');

copy venue (Stadium_Name, City, Country, Capacity, Match_Type) 
from 'C:/Program Files/PostgreSQL/17/data/DATASETS/venue.csv'
with (delimiter ',', format csv, header true);

copy bowling (Player, Team, Type, Matches, Inn, Bowls, Runs, Wkts, Econ, bowl_Avg,
              strike_rate, five_Wkt, ten_Wkt)
from 'C:/Program Files/PostgreSQL/17/data/DATASETS/bowl.csv'
with (delimiter ',', format csv, header true);

copy role (player_name,role)
from 'C:/Program Files/PostgreSQL/17/data/DATASETS/player role.csv'
with (delimiter ',', format csv, header true);

alter table matches_recent
drop column start_date_ms, 
drop column end_date_ms;

alter table matches_recent
add column start_date_ms bigint, 
add column end_date_ms bigint;

update matches_recent
set start_ts=to_timestamp(start_date_ms/1000.0),
end_ts=to_timestamp(end_date_ms/1000.0);

update matches
set start_ts=to_timestamp(start_date_ms/1000.0),
end_ts=to_timestamp(end_date_ms/1000.0);

select start_ts,start_ts at time zone 'UTC'
from matches_recent limit 5;


--EXECUTING PRACTICE SQL QUERIES
-- 1. Indian players
select*from players_india;

-- 2. Last 30 days matches
select*from matches_recent
where start_ts>= current_date - interval '30day'
order by start_ts desc;

-- 3. top 10 players
select*from top10_players;

-- 4. team wins
select winning_team_name,count(*) from 
      (SELECT match_status, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won by') AS winning_team_name
FROM
  matches_recent
WHERE
  match_status LIKE '%won by%')
  group by 1
  order by 2 desc;

-- 5. count of playing role
select role, count(role)
from players_india
group by 1
order by 2 desc;

-- 6. recent number of matches played in each venue
select venue_id, venue_name, count(*)
from matches_recent
group by 1,2
order by 3 desc;

-- 7. venue with capacity greater than 50000
select distinct stadium_name, city, country, capacity from venue
where capacity>=50000;

-- 8. highest individual batting score in each match format
select type, max(runs) as highest_score
from batting
group by 1;

-- 9. cricket series started in the year 2024
select series_name, venue_country, match_format,match_date,count(match_id) as number_matches
from series
where extract(year from match_date)=2024
group by 1,2,3,4;

-- 10. players with score >1000 and wiket >50 among all rounders
select a.player,a.type,a.runs,b.wkts
from batting as a
join bowling as b
on a.player=b.player
join role as c
on b.player=c.player_name
where c.role='Allrounder' and a.runs>1000 and b.wkts>50;

-- 11. last 20 completed match
select match_description, team1_name, team2_name,SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won') AS winner, 
       venue_name, substring(match_status from '([0-9]+)') as victory_margin, 
	   substring (match_status from 'by [0-9]+ ([a-zA-Z]+)') as victory_type,start_ts
from matches
where match_state='Complete' and start_ts>=current_date - interval '20 days'
union all
select match_description, team1_name, team2_name,SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won') AS winner, 
       venue_name, substring(match_status from '([0-9]+)') as victory_margin, 
	   substring (match_status from 'by [0-9]+ ([a-zA-Z]+)') as victory_type,start_ts
from matches_recent
where match_state='Complete' and start_ts >=current_date- interval '20 days'
order by start_ts desc
limit 20;

-- 12. player performance with batting average who played more than 2 match format
select player,type, runs, bat_avg 
from batting
where (select count(type) from batting)>=2;

-- 13. Team performance based on international and domestic matches
select team1_name,count(match_id)as win from
(select match_id,team1_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches 
where match_type='International')
where team1_name=winner
group by 1
union all
select team2_name,count(match_id)as win from
(select match_id,team2_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches
where match_type='International')
where team2_name=winner
group by 1
union all
select team1_name,count(match_id)as win from
(select match_id,team1_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches_recent
where match_type='International')
where team1_name=winner
group by 1
union all
select team2_name,count(match_id) as win from
(select match_id,team2_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches_recent
where match_type='International')
where team2_name=winner
group by 1)
group by 1;
select team1_name as team,sum(win) as domestic_wins from
(select team1_name,count(match_id)as win from
(select match_id,team1_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches 
where match_type='Domestic')
where team1_name=winner
group by 1
union all
select team2_name,count(match_id)as win from
(select match_id,team2_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches
where match_type='Domestic')
where team2_name=winner
group by 1
union all
select team1_name,count(match_id)as win from
(select match_id,team1_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches_recent
where match_type='Domestic')
where team1_name=winner
group by 1
union all
select team2_name,count(match_id) as win from
(select match_id,team2_name, SUBSTRING(match_status FROM '^([A-Za-z0-9 ]+) won')
AS winner
from matches_recent
where match_type='Domestic')
where team2_name=winner
group by 1) 
group by 1;

-- 14. partnership score>100
select innings_id, bat1_name,bat1_runs,bat2_name,bat2_runs,total_runs
from partnerships
where total_runs>=100;

--15. close match performance
select match_id as close_matches from
(select match_id,substring(match_status from '([0-9]+)')::int as victory_margin,
        substring (match_status from 'by [0-9]+ ([a-zA-Z]+)') as victory_type
from matches_recent)
where victory_margin<50 and victory_type='runs' or victory_margin<5 and victory_type='wkts';

--16. bowler perfomance
select player,team,type,matches,wkts as total_wickets,econ as economy_avg 
from bowling
where bowls>=24;

--17. relation of winning a Match after toss wins based on toss decision
select*from series;
with total as(select team1_name as team, sum(count) as total_matches from
(select team1_name,count(team1_name) as count from series group by 1
union all
select team2_name,count(team2_name) from series group by 1)
group by 1)
select a.winner, a.toss_winner_choice,a.wins, b.total_matches, round((a.wins/b.total_matches)*100,2) as percentage_wins from
(select winner, toss_winner_choice,count(winner) as wins from series
where toss_winner=winner
group by 1,2)as a
join total as b
on a.winner=b.team;

--18.economical players in limited over cricket
select player,type,wkts,econ from bowling
where matches>10 and bowls>12 and type='ODI' OR type='T20';

--19. batting and bowling points
select player,type,batting_points,dense_rank()over(partition by type order by batting_points desc)
from
(select player,type,((runs*0.01)+(bat_avg*0.5)+(Strick_Rate*0.3)) as batting_points
from batting);
select player,type,bowling_points,dense_rank()over(partition by type order by bowling_points desc)
from
(select player,type,((wkts*2)+(50-bowl_avg)+((6-econ)*2)) as bowling_points
from bowling);

--20. batting average per match format
with tot as(select player, sum(match) as matches 
from batting
group by 1)
select a.player,a.type,a.match,a.bat_avg from batting as a
join tot as b
on a.player=b.player
where b.matches>=20
order by 1;
