1. 

SELECT video_id, COUNT(*) AS like_no FROM cats.like GROUP BY video_id ORDER BY like_no DESC LIMIT 10;

--Baseline: "Limit  (cost=42897.11..42897.14 rows=10 width=4)"

CREATE TABLE cats.C1 AS
SELECT video_id, COUNT(*) AS like_no FROM cats.like GROUP BY video_id ORDER BY like_no DESC LIMIT 10;

SELECT * FROM cats.C1;

--Final: "Seq Scan on c1  (cost=0.00..29.40 rows=1940 width=12)"


2. 

SELECT l.video_id, COUNT(*) AS like_no FROM cats.friend f, cats.like l
WHERE f.user_id=1 AND f.friend_id=l.user_id GROUP BY l.video_id ORDER BY like_no DESC LIMIT 10;

--Baseline: "Limit  (cost=107391.36..107391.39 rows=10 width=4)"

CREATE TABLE cats.C2 AS
SELECT l.video_id, COUNT(*) AS like_no FROM cats.friend f, cats.like l
WHERE f.user_id=1 AND f.friend_id=l.user_id GROUP BY l.video_id ORDER BY like_no DESC LIMIT 10;

SELECT * FROM cats.C2;

--Final: "Seq Scan on c2  (cost=0.00..29.40 rows=1940 width=12)"


3. 

SELECT l.video, COUNT(*)
FROM (SELECT l.video_id AS video, l.user_id AS user1 FROM cats.friend f, cats.like l WHERE f.user_id=1 AND f.friend_id=l.user_id 
UNION
SELECT l.video_id AS video, l.user_id AS user1 FROM cats.friend f, cats.friend ff, cats.like l WHERE f.user_id=1 AND f.friend_id=ff.user_id AND ff.user_id=l.user_id
) AS l
GROUP BY l.video
ORDER BY COUNT(*) DESC LIMIT 10;

--Baseline: "Limit  (cost=284830.76..284830.79 rows=10 width=4)"

CREATE TABLE cats.C3 AS
SELECT l.video, COUNT(*)
FROM (SELECT l.video_id AS video, l.user_id AS user1 FROM cats.friend f, cats.like l WHERE f.user_id=1 AND f.friend_id=l.user_id 
UNION
SELECT l.video_id AS video, l.user_id AS user1 FROM cats.friend f, cats.friend ff, cats.like l WHERE f.user_id=1 AND f.friend_id=ff.user_id AND ff.user_id=l.user_id
) AS l
GROUP BY l.video
ORDER BY COUNT(*) DESC LIMIT 10;

SELECT * FROM cats.C3;

--Final: "Seq Scan on c3  (cost=0.00..29.40 rows=1940 width=12)"


4. 

SELECT l.video_id, COUNT(*) FROM cats.like l
WHERE l.user_id IN (SELECT ly.user_id FROM cats.like lx, cats.like ly WHERE lx.user_id=1 AND lx.video_id=ly.video_id) GROUP BY l.video_id
ORDER BY COUNT(*) DESC LIMIT 10;

--Baseline: "Limit  (cost=214655.54..214655.57 rows=10 width=4)"

CREATE TABLE cats.C4 AS
SELECT l.video_id, COUNT(*) FROM cats.like l
WHERE l.user_id IN (SELECT ly.user_id FROM cats.like lx, cats.like ly WHERE lx.user_id=1 AND lx.video_id=ly.video_id) GROUP BY l.video_id
ORDER BY COUNT(*) DESC LIMIT 10;

SELECT * FROM cats.C4;

--Final: "Seq Scan on c4  (cost=0.00..29.40 rows=1940 width=12)"


5. 

WITH WeightOfUsers AS
(SELECT ly.user_id, LOG(1+COUNT(*)) AS weight FROM cats.like lx, cats.like ly
WHERE lx.user_id=1 AND lx.video_id=ly.video_id GROUP BY ly.user_id)
SELECT l.video_id, SUM(w.weight) AS sum_weight FROM cats.like l,  WeightOfUsers w
WHERE l.user_id=w.user_id GROUP BY l.video_id
ORDER BY sum_weight DESC LIMIT 10;

--Baseline: "Limit  (cost=256169.77..256169.80 rows=10 width=12)"

CREATE TABLE cats.C5 AS
WITH WeightOfUsers AS
(SELECT ly.user_id, LOG(1+COUNT(*)) AS weight FROM cats.like lx, cats.like ly
WHERE lx.user_id=1 AND lx.video_id=ly.video_id GROUP BY ly.user_id)
SELECT l.video_id, SUM(w.weight) AS sum_weight FROM cats.like l,  WeightOfUsers w
WHERE l.user_id=w.user_id GROUP BY l.video_id
ORDER BY sum_weight DESC LIMIT 10;

SELECT * FROM cats.C5;

--Final: "Seq Scan on c5  (cost=0.00..29.40 rows=1940 width=12)"


