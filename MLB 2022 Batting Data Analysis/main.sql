--===============================================================
--PROJECT NAME : MLB 2022 Batting Data Analysis
--DONE BY : Sanskar Shrivas
--Start Date and time : 06-03-2026 19:22
--===============================================================
--Steps 
--1. Data Loading
--===============================================================
--Dropping existing data table if any
DROP TABLE IF EXISTS mlb_bat_22 CASCADE;

--Creating data table
CREATE TABLE mlb_bat_22(
    Rk INTEGER,
    P_name varchar(25),
    Age INTEGER,
    Tm VARCHAR,
    Lg VARCHAR(3),
    G integer,
    PA integer,
    AB integer,
    R integer,
    H integer,
    B2 integer,
    B3 integer,
    HR integer,
    RBI integer,
    SB integer,
    CS integer,
    BB integer,
    SO integer,
    BA numeric,
    OBP numeric,
    SLC numeric,
    OPS numeric,
    OPSp int,
    TB int,
    GDP int,
    HBP int,
    SH int,
    SF int,
    IBB int
);

--Removing existing records
TRUNCATE mlb_bat_22;

COPY mlb_bat_22 (Rk,P_name,Age,Tm,Lg,G,PA,AB,R,H,B2,B3,HR,RBI,SB,CS,BB,SO,BA,OBP,SLC,OPS,OPSp,TB,GDP,HBP,SH,SF,IBB)
FROM 'D:\ds_learn\SQL\Main project\2022 MLB Player Stats - Batting.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM mlb_bat_22;

--data validation
SELECT p_name,count(p_name) FROM mlb_bat_22 GROUP BY p_name HAVING COUNT(p_name)>1 ORDER BY COUNT(p_name) desc;

--top 10 dangerous batters
SELECT p_name,Tm,G,RBI FROM mlb_bat_22 WHERE G>100 ORDER BY RBI desc LIMIT 10;

--top 5 teams with highest strikeouts
SELECT Tm,SUM(SO) from mlb_bat_22 WHERE Tm!='TOT' GROUP BY Tm ORDER BY SUM(SO) desc LIMIT 5;

--Categorizing Batters into Power hitters, Contact hitters and Role Players
SELECT BC,COUNT(*) as pc FROM (SELECT CASE
    WHEN SUM(HR)>=30 THEN 'Power Hitter'
    WHEN SUM(HR)>=10 and SUM(HR)<30 THEN 'Contact Hitter'
    ELSE 'Role Player'
END as BC from mlb_bat_22 WHERE PA>=50 AND Tm!='TOT' group BY p_name) as ir GROUP BY BC;

--Finding top 10 most efficient batters
SELECT p_name,Tm,HR,BA FROM mlb_bat_22 WHERE AB>300 and Tm!='TOT' GROUP BY p_name,BA,Tm,HR ORDER BY BA DESC LIMIT 10;

-- Performance evaluation report as per OBS
SELECT p_name,age,Tm,HR,RBI,BA,OPS,CASE
    WHEN OPS>=0.9 THEN 'Elite'
    WHEN OPS>=0.75 THEN 'Above average'
    WHEN OPS>=0.65 THEN 'Average'
    ELSE 'Below average'
    END as performance_label
    FROM mlb_bat_22 WHERE AB>=300 and Tm!='TOT' GROUP BY p_name,age,Tm,HR,RBI,BA,OPS ORDER BY OPS DESC LIMIT 15;

--Creation of views
CREATE OR REPLACE VIEW v_team_summary AS 
SELECT Tm,SUM(HR) as Total_HR,SUM(RBI) as Total_RBI,SUM(SO) as Total_SO,ROUND(AVG(BA),3) as Avg_BA,ROUND(AVG(OPS),3) as Avg_OPS
FROM mlb_bat_22 WHERE Tm!='TOT' GROUP BY Tm;

SELECT * FROM v_team_summary WHERE Avg_OPS>(SELECT AVG(Avg_OPS) FROM v_team_summary);
    