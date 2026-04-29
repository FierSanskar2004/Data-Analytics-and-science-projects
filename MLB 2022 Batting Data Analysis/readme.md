# 🏟️ MLB 2022 Batting Data Analysis

**Author:** Sanskar Shrivas

**Date:** 06-03-2026

**Tool:** PostgreSQL 18 | pgAdmin 4

---

## 📌 Project Overview

An end-to-end SQL analytics project analyzing **992 real-world batting records** from the 2022 Major League Baseball season using PostgreSQL.

Starting from raw CSV data, the project covers database design, data validation, exploratory analysis and performance reporting — answering business questions a sports analyst would face on the job.

---

## 📂 Dataset

| Property | Detail |
|---|---|
| Source | 2022 MLB Player Batting Statistics |
| Records | 992 rows |
| Columns | 29 batting metrics |
| Format | CSV (semicolon delimited, latin1 encoded) |

**Key Columns:**

| Column | Description |
|---|---|
| `P_name` | Player name |
| `Tm` | Team code |
| `Age` | Player age |
| `G` | Games played |
| `AB` | At bats |
| `HR` | Home runs |
| `RBI` | Runs batted in |
| `BA` | Batting average |
| `OPS` | On-base plus slugging percentage |
| `SO` | Strikeouts |

> **Note:** Players traded mid-season appear multiple times with individual team rows and a combined `TOT` row. `TOT` rows are excluded from team-level analysis to avoid double counting.

---

## 🎯 Business Questions Answered

| # | Business Question | Concept Used |
|---|---|---|
| 1 | Who were the most dangerous RBI producers in 2022? | WHERE, ORDER BY, LIMIT |
| 2 | Which teams had the most strikeouts? | SUM, GROUP BY, WHERE |
| 3 | How are players distributed across hitting categories? | CASE, Subquery, COUNT |
| 4 | Who were the most efficient contact hitters? | WHERE, ORDER BY |
| 5 | How do top players rank by overall performance? | CASE, GROUP BY, ORDER BY |
| 6 | Which teams performed above average in OPS? | VIEW, Subquery, AVG |

---

## 🔍 Key Findings

- 🏆 **Top RBI Producer** → Aaron Judge & Pete Alonso (131 RBIs each)
- ⚡ **Most Strikeouts** → LAA, ATL, PIT, MIL (top 4 teams)
- 💪 **Power Hitters (30+ HR)** → Only 23 players qualified — showing how rare true power is
- 🎯 **Most Efficient Hitter** → Jeff McNeil (BA: 0.326)
- 🌟 **Elite OPS Performers** → Aaron Judge leading at 1.111 — one of the greatest MLB seasons in history
- 📊 **Above Average OPS Teams** → 16 out of 30 teams exceeded the group average

---

## 🛠️ SQL Concepts Applied

| Concept | Usage |
|---|---|
| `CREATE TABLE` / `COPY` | Database setup & data import |
| `WHERE` / `HAVING` | Filtering rows and groups |
| `GROUP BY` / `ORDER BY` | Aggregation and sorting |
| `SUM` / `COUNT` / `AVG` / `ROUND` | Aggregate calculations |
| `CASE` | Player & team performance categorization |
| Subqueries | Finding above-average performers |
| `CREATE VIEW` | Reusable team summary report |
| `CASCADE` | Dependency management |
| `!=` / `IN` | Excluding invalid rows (TOT) |

---

## ⚙️ Setup Instructions

1. Clone this repository
2. Open pgAdmin and connect to your PostgreSQL server
3. Open `main.sql`
4. Update the file path on the `COPY` line to match your local machine:
```sql
FROM 'YOUR_PATH/2022 MLB Player Stats - Batting.csv'
```
5. Run `main.sql`

---

## 📁 Repository Structure

```
MLB-2022-Batting-Analysis/
│
├── main.sql                            # Full project SQL script
├── 2022_MLB_Player_Stats_Batting.csv   # Source dataset
└── README.md                           # Project documentation
```

---

## 💡 Notable Insight

> Aaron Judge's 2022 season was historically elite — ranking **#1 in Home Runs (62)** and **#6 in Batting Average (0.311)** simultaneously. He broke the American League home run record while also being one of the most efficient contact hitters in the league. A true outlier in the data.

---

*Part of my Data Analytics & Science Portfolio →* [GitHub](https://github.com/FierSanskar2004/Data-Analytics-and-science-projects)
