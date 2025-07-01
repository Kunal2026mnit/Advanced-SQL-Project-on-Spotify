# Spotify Advanced SQL Project and Query Optimization

![Spotify Logo][(https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)](https://github.com/Kunal2026mnit/Advanced-SQL-Project-on-Spotify/blob/106b4dfcf7c53afce67634b09d2e8f2fae02e91c/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
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
```
## Project Steps

### Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

**Easy Level**
1. **Retrieve the names of all tracks that have more than 1 billion streams.**
   ```sql
   select track from spotify
   where stream>1000000000;
    ```
2. **List all albums along with their respective artists.**
      ```sql
      select (album),artist from spotify
      order by 1;
      select distinct(album),artist from spotify;
      ```
3. **Get the total number of comments for tracks where `licensed = TRUE`.**
      ```sql
      select sum(comments) as total_comments from spotify as total_comments
      where licensed = 'true';
      ```
4. **Find all tracks that belong to the album type `single`.**
      ```sql
      select track from spotify 
      where album_type = 'single';
      ```
5. **Count the total number of tracks by each artist.**
   ```sql
       select 
      artist,--1
      count(*) as total_no_of_songs--2
      from spotify
      group by artist
      order by 2 desc;
   ```

**Medium Level**
1. **Calculate the average danceability of tracks in each album.**
      ```sql
      select album,--1
      avg(danceability) as average_danceability --2
      from spotify
      group by album
      order by 2 desc;
      ```
2. **Find the top 5 tracks with the highest energy values.**
      ```sql
      select track,--1
       max(energy) as top_5_energy --2
      from spotify
      group by track
      order by 2 desc
      limit 5;
      ```
3. **List all tracks along with their views and likes where `official_video = TRUE`.**
      ```sql
      select track, --1
      sum(views) as total_views,--2
      sum(likes) as total_likes from spotify --3
      where official_video = 'True'
      group by 1
      order by 2 desc;
      ```
4. **For each album, calculate the total views of all associated tracks.**
      ```sql
      select album,--1
      track,--2
      sum(views) as total_views--3
      from spotify
      group by 1,2
      order by 3 desc;
      ```
5. **Retrieve the track names that have been streamed on Spotify more than YouTube.**
```sql
       SELECT * FROM
       (select track,
       coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
	   coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_spotify
       from spotify
       group by 1
       ) AS TI
       WHERE streamed_spotify > streamed_on_youtube
       AND 
       streamed_on_youtube<> 0;
```

**Advanced Level**
1. **Find the top 3 most-viewed tracks for each artist using window functions.**
      ```sql
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
      ```
2. **Write a query to find tracks where the liveness score is above the average.**
```sql
      select track, artist,liveness from spotify
where liveness > (select avg(liveness) from spotify)
order by 3 desc;
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
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
```   
4. **Find tracks where the energy-to-liveness ratio is greater than 1.2.**
```sql
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
```
5. **Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**
```sql
      SELECT
    track,
    views,
    SUM(likes) OVER (ORDER BY views desc) AS cumulative_likes
FROM
    spotify;
```



## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4, PostgreSQL (via Homebrew, Docker, or direct installation)



---

## Contributing
If you would like to contribute to this project, feel free to fork the repository, submit pull requests, or raise issues.

---

