-- Advances SQL Project -- Spotify Datasets
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
	);

	select * from spotify
	limit 100;

-- EDA --

   select count(*) from spotify

   select count(distinct album) from spotify;
   select count(distinct artist) from spotify;
   select count(distinct album_type) from spotify;
   select count(distinct channel) from spotify;
   select distinct licensed from spotify;
   select distinct album_type from spotify;
   select distinct most_played_on from spotify;

   select  duration_min from spotify;
   select  avg(duration_min) from spotify;
   select  max(duration_min) from spotify;
   select  min(duration_min) from spotify;

   select * from spotify
   where duration_min =0;

   delete from spotify
   where duration_min =0;
    select * from spotify
   where duration_min =0;

/*
 -- --------------------------------
 -- Data analysis -- Easy category
 -- --------------------------------

Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

-- Q1 Retrieve the names of all tracks that have more than 1 billion streams.

select track from spotify
where stream>1000000000;

-- Q2 List all albums along with their respective artists.

select (album),artist from spotify
order by 1;
select distinct(album),artist from spotify;

-- Q3 Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as total_comments from spotify as total_comments
where licensed = 'true';

-- Q4 Find all tracks that belong to the album type single.

select track from spotify 
where album_type = 'single';

-- Q5 Count the total number of tracks by each artist.

select 
      artist,--1
	  count(*) as total_no_of_songs--2
from spotify
group by artist
order by 2 desc;

 /*
 -- ---------------------------------
 -- Data analysis -- Medium category
 -- ---------------------------------
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--Q6 Calculate the average danceability of tracks in each album.

select album,--1
avg(danceability) as average_danceability --2
from spotify
group by album
order by 2 desc;

--Q7 Find the top 5 tracks with the highest energy values.

select track,--1
       max(energy) as top_5_energy --2
from spotify
group by track
order by 2 desc
limit 5;

--Q8 List all tracks along with their views and likes where official_video = TRUE.

select track, --1
sum(views) as total_views,--2
sum(likes) as total_likes from spotify --3
where official_video = 'True'
group by 1
order by 2 desc;

--Q9 For each album, calculate the total views of all associated tracks.

select album,--1
track,--2
sum(views) as total_views--3
from spotify
group by 1,2
order by 3 desc;

--Q10 Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(select track,
       coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
	   coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_spotify
from spotify
group by 1
) AS TI
WHERE streamed_spotify > streamed_on_youtube
AND 
streamed_on_youtube<> 0 ;

/*
 -- ------------------------------------
 -- Data analysis -- ADVANCED category
 -- ------------------------------------
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

--Q11 Find the top 3 most-viewed tracks for each artist using window functions.

with ranking_artist as
(
select artist,
track,
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views)desc) as rank
from spotify
group by 1,2
order by 1,3 desc)
select * from ranking_artist
where rank <=3;

--Q12 Write a query to find tracks where the liveness score is above the average.

select track, artist,liveness from spotify
where liveness > (select avg(liveness) from spotify)
order by 3 desc;
 
--Q13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with T1 as 
(
select album,--1
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1)
select album,
highest_energy-lowest_energy as energy_diff
from T1
order by 2 desc;

--Q14 Find tracks where the energy-to-liveness ratio is greater than 1.2.

with T2 as
(with T1 as 
(select track, sum(energy) as sum_energy,
sum(liveness) as sum_liveness
from spotify
group by track)
select track, 
sum_energy/sum_liveness as ratio
from T1
order by 2 desc)
select track, ratio
from T2
where ratio > 1.2
order by 2;

--Q15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT
    track,
    views,
    SUM(likes) OVER (ORDER BY views desc) AS cumulative_likes
FROM
    spotify;

--Query optimization

explain analyze
Select 
artist,
track,
views
from spotify
where artist = 'Gorillaz'
and 
most_played_on = 'Youtube'
order by stream desc limit 25;

create index artist_index on spotify (artist);

