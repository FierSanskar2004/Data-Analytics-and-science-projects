# 🛒 Online Platform Sales in Australia — Analytics

> *Analysis of 1039 sales orders across Australian states, customers, and account managers (2013–2017).*

---

## 👔 Project Overview

<table>
  <tr>
    <th>Field</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>Author</td>
    <td>Sanskar Shrivas</td>
  </tr>
  <tr>
    <td>Date</td>
    <td>6<sup>th</sup> March, 2026</td>
  </tr>
  <tr>
    <td>Database</td>
    <td>PostgreSQL 18</td>
  </tr>
  <tr>
    <td>Dataset</td>
    <td>Australian Sales Orders 2013–2017</td>
  </tr>
  <tr>
    <td>Records</td>
    <td>1039 rows</td>
  </tr>
</table>

---

## 📁 Directory Structure

```
GP-1/
│
├── data/
│   ├── Orders_ship_data.csv       # Main orders dataset (1039 rows)
│   ├── Sales_2016.csv             # Quarterly sales by account manager
│   └── Account_Managers.csv      # Account managers list
│
├── main.sql                       # All queries — setup to analysis
└── README.md                      # You are here
```

---

## ⚙️ How to Run

### Prerequisites
- PostgreSQL 18 installed
- pgAdmin 4 or `psql` CLI
- The following files placed in an accessible folder on your machine:
  - `Orders_ship_data.csv`
  - `Sales_2016.csv`

### Steps

**1. Create a new database**
```sql
CREATE DATABASE australia_sales;
```

**2. Update the file paths in `main.sql`**

The `COPY` commands use a local Windows path — update them to match your machine:
```sql
-- Find this in main.sql and replace with your own path:
FROM 'D:\ds_learn\SQL\GP1\data\Orders_ship_data.csv'

-- Example replacements:
-- Windows:  FROM 'C:\Users\YourName\data\Orders_ship_data.csv'
-- Mac/Linux: FROM '/home/yourname/data/Orders_ship_data.csv'
```

> ⚠️ **Note:** The `COPY` command requires the file to be accessible by the PostgreSQL **server process**, not just your user. If you hit a permissions error, use `\copy` instead (psql only) or import via pgAdmin's built-in import tool.

**3. Run `main.sql`**

Open `main.sql` in pgAdmin or psql and execute it. The script is divided into sections — you can run them all at once or section by section:

| Section | What it does |
|---------|-------------|
| Section 1 | Creates tables & imports CSV data |
| Section 2 | Data quality checks (nulls, duplicates) |
| Section 3 | Customer analysis |
| Section 4 | Geographic analysis |
| Section 5 | Manager performance analysis |
| Section 6 | Creates views for reuse |

**4. Query the views anytime**
```sql
SELECT * FROM v_customer_performance;
SELECT * FROM v_manager_performance_2016;
SELECT * FROM v_above_avg_managers;
```

---

## 🎯 Business Questions Answered

1. Who is our top customer by total spend?
2. Who placed the most orders?
3. Who purchased the most product units?
4. Which state generates the most revenue?
5. Which product category drives the most revenue in NSW?
6. Who is the best performing account manager?
7. How do managers perform quarterly vs overall in 2016?
8. How can we categorize manager performance?
9. Which managers exceed average 2016 performance?

---

## 🔍 Key Findings

> ### 1) No NULL values — all 1039 rows are clean

```sql
SELECT count(*) as no_of_null_orders 
FROM Orders 
WHERE NOT(order_id IS NULL OR address IS NULL OR city IS NULL OR customer_type IS NULL);
```

**Result:**

<table>
  <tr>
    <th>no_of_null_orders</th>
  </tr>
  <tr>
    <td>1039</td>
  </tr>
</table>

---

> ### 2) No true duplicates — same order ID, different products

```sql
SELECT order_id, count(order_id) as order_count 
FROM Orders 
GROUP BY order_id 
HAVING count(order_id) > 1;

SELECT * FROM Orders WHERE order_id IN ('6159-2','5768-2');
```

**Duplicate IDs found:**

<table>
  <tr>
    <th>order_id</th>
    <th>order_count</th>
  </tr>
  <tr>
    <td>5768-2</td>
    <td>2</td>
  </tr>
  <tr>
    <td>6159-2</td>
    <td>2</td>
  </tr>
</table>

**Investigation — different products confirm these are not true duplicates:**

<table>
  <tr>
    <th>order_id</th>
    <th>order_date</th>
    <th>customer_name</th>
    <th>address</th>
    <th>city</th>
    <th>stat3</th>
    <th>customer_type</th>
    <th>acc_manager</th>
    <th>priority</th>
    <th>prod_name</th>
    <th>prod_cat</th>
    <th>prod_container</th>
  </tr>
  <tr>
    <td>5768-2</td>
    <td>2015-01-22</td>
    <td>Bill Donatelli</td>
    <td>359 Crown Street, Surry Hills</td>
    <td>Sydney</td>
    <td>NSW</td>
    <td>Corporate</td>
    <td>Phoebe Gour</td>
    <td>Critical</td>
    <td>Artisan Flip-Chart Easel Binder, Black</td>
    <td>Office Supplies</td>
    <td>Small Box</td>
  </tr>
  <tr>
    <td>5768-2</td>
    <td>2015-01-22</td>
    <td>Bill Donatelli</td>
    <td>359 Crown Street, Surry Hills</td>
    <td>Sydney</td>
    <td>NSW</td>
    <td>Corporate</td>
    <td>Phoebe Gour</td>
    <td>Critical</td>
    <td>Beekin 105-Key Black Keyboard</td>
    <td>Technology</td>
    <td>Small Box</td>
  </tr>
  <tr>
    <td>6159-2</td>
    <td>2015-12-31</td>
    <td>Matt Collister</td>
    <td>99 Glebe Point Rd, Glebe</td>
    <td>Sydney</td>
    <td>NSW</td>
    <td>Home Office</td>
    <td>Natasha Song</td>
    <td>Medium</td>
    <td>Artisan 487 Labels</td>
    <td>Office Supplies</td>
    <td>Small Box</td>
  </tr>
  <tr>
    <td>6159-2</td>
    <td>2015-12-31</td>
    <td>Matt Collister</td>
    <td>99 Glebe Point Rd, Glebe</td>
    <td>Sydney</td>
    <td>NSW</td>
    <td>Home Office</td>
    <td>Natasha Song</td>
    <td>High</td>
    <td>DrawIt Colored Pencils</td>
    <td>Office Supplies</td>
    <td>Wrap Bag</td>
  </tr>
</table>

---

> ### 3) Clytie Kelty is the top customer by total spend — $42,396.94

```sql
SELECT customer_name, ROUND(sum(total)::numeric,2) as total 
FROM Orders 
GROUP BY customer_name 
ORDER BY sum(total) DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>customer_name</th>
    <th>total</th>
  </tr>
  <tr>
    <td>Clytie Kelty</td>
    <td>42396.94</td>
  </tr>
</table>

---

> ### 4) Patrick Jones placed the most orders

```sql
SELECT customer_name, COUNT(order_id) as no_of_orders 
FROM Orders 
GROUP BY customer_name 
ORDER BY no_of_orders DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>customer_name</th>
    <th>no_of_orders</th>
  </tr>
  <tr>
    <td>Patrick Jones</td>
    <td>13</td>
  </tr>
</table>

---

> ### 5) Mike Kennedy purchased the most units — 202 items

```sql
SELECT customer_name, SUM(quant) as no_of_items 
FROM Orders 
GROUP BY customer_name 
ORDER BY SUM(quant) DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>customer_name</th>
    <th>no_of_items</th>
  </tr>
  <tr>
    <td>Mike Kennedy</td>
    <td>202</td>
  </tr>
</table>

---

> ### 6) NSW generates the most revenue — $906,637.46

```sql
SELECT stat3, ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
GROUP BY stat3 
ORDER BY SUM(total) DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>stat3</th>
    <th>total</th>
  </tr>
  <tr>
    <td>NSW</td>
    <td>906637.46</td>
  </tr>
</table>

---

> ### 7) Technology is the top product category in NSW

```sql
SELECT prod_cat, ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
WHERE stat3 = 'NSW' 
GROUP BY prod_cat 
ORDER BY SUM(total) DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>prod_cat</th>
    <th>total</th>
  </tr>
  <tr>
    <td>Technology</td>
    <td>609164.51</td>
  </tr>
</table>

---

> ### 8) Yvette Biti is the top account manager by revenue

```sql
SELECT acc_manager, COUNT(order_id) as orders, SUM(quant) as items_count, 
       ROUND(SUM(total)::numeric,2) as total 
FROM Orders 
GROUP BY acc_manager 
ORDER BY SUM(total) DESC 
LIMIT 1;
```

<table>
  <tr>
    <th>acc_manager</th>
    <th>orders</th>
    <th>items_count</th>
    <th>total</th>
  </tr>
  <tr>
    <td>Yvette Biti</td>
    <td>128</td>
    <td>3434</td>
    <td>155654.53</td>
  </tr>
</table>

**Composite performance score (customers × avg spend):**

```sql
SELECT acc_manager,
    COUNT(customer_name) as no_of_customers,
    ROUND(avg(total)::numeric,2) as avg_spend,
    ROUND(COUNT(customer_name)*avg(total)::numeric,2) as composite_score 
FROM Orders 
GROUP BY acc_manager 
ORDER BY composite_score DESC;
```

<table>
  <tr>
    <th>acc_manager</th>
    <th>no_of_customers</th>
    <th>avg_spend</th>
    <th>composite_score</th>
  </tr>
  <tr><td>Yvette Biti</td><td>128</td><td>1216.05</td><td>155654.53</td></tr>
  <tr><td>Natasha Song</td><td>75</td><td>1711.65</td><td>128374.03</td></tr>
  <tr><td>Tina Carlton</td><td>137</td><td>924.17</td><td>126611.55</td></tr>
  <tr><td>Connor Betts</td><td>159</td><td>762.44</td><td>121227.79</td></tr>
  <tr><td>Mihael Khan</td><td>75</td><td>1210.72</td><td>90803.67</td></tr>
  <tr><td>Leighton Forrest</td><td>61</td><td>1485.50</td><td>90615.74</td></tr>
  <tr><td>Samantha Chairs</td><td>64</td><td>1336.71</td><td>85549.63</td></tr>
  <tr><td>Phoebe Gour</td><td>87</td><td>963.70</td><td>83842.12</td></tr>
  <tr><td>Charlie Bui</td><td>49</td><td>1656.06</td><td>81147.00</td></tr>
  <tr><td>Radhya Staples</td><td>21</td><td>3632.37</td><td>76279.83</td></tr>
  <tr><td>Aanya Zhang</td><td>70</td><td>1032.34</td><td>72263.83</td></tr>
  <tr><td>Nicholas Fernandes</td><td>65</td><td>1022.79</td><td>66481.58</td></tr>
  <tr><td>Preston Senome</td><td>39</td><td>504.41</td><td>19671.94</td></tr>
  <tr><td>Stevie Bacata</td><td>9</td><td>798.76</td><td>7188.81</td></tr>
</table>

---

> ### 9) Manager performance categorization (2016)

```sql
SELECT o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4,
    ROUND(sum(o.total)::numeric,2) as t_16,
    CASE
        WHEN ROUND(sum(o.total)::numeric,2) >= 30000 THEN 'Good'
        WHEN ROUND(sum(o.total)::numeric,2) >= 15000 THEN 'Average'
        ELSE 'Need Improvement'
    END as performance
FROM sales16 as s 
JOIN Orders as o ON o.acc_manager = s.acc_manager 
WHERE o.order_date BETWEEN '2016-01-01' AND '2016-12-31' 
GROUP BY o.acc_manager, s.qtr1, s.qtr2, s.qtr3, s.qtr4 
ORDER BY t_16 DESC;
```

**Performance tiers:**

<table>
  <tr>
    <th>Category</th>
    <th>Threshold</th>
  </tr>
  <tr>
    <td>✅ Good</td>
    <td>&gt;= $30,000</td>
  </tr>
  <tr>
    <td>🟡 Average</td>
    <td>$15,000 – $29,999</td>
  </tr>
  <tr>
    <td>🔴 Need Improvement</td>
    <td>&lt; $15,000</td>
  </tr>
</table>

**Full results:**

<table>
  <tr>
    <th>acc_manager</th>
    <th>qtr1</th>
    <th>qtr2</th>
    <th>qtr3</th>
    <th>qtr4</th>
    <th>t_16</th>
    <th>performance</th>
  </tr>
  <tr><td>Aanya Zhang</td><td>5187.9</td><td>7627.17</td><td>28867.26</td><td>742.53</td><td>42608.23</td><td>✅ Good</td></tr>
  <tr><td>Phoebe Gour</td><td>5117.84</td><td>12156.6</td><td>351.06</td><td>15653.93</td><td>33452.00</td><td>✅ Good</td></tr>
  <tr><td>Tina Carlton</td><td>17247.36</td><td>2512.24</td><td>7003.82</td><td>2952.73</td><td>29871.17</td><td>🟡 Average</td></tr>
  <tr><td>Connor Betts</td><td>854.08</td><td>20123.65</td><td>3050.18</td><td>4373.98</td><td>28560.62</td><td>🟡 Average</td></tr>
  <tr><td>Nicholas Fernandes</td><td>21787.86</td><td>1533.62</td><td>2191.42</td><td>2384.04</td><td>28057.22</td><td>🟡 Average</td></tr>
  <tr><td>Charlie Bui</td><td>24271.31</td><td>130.78</td><td>116.61</td><td>355.15</td><td>24932.23</td><td>🟡 Average</td></tr>
  <tr><td>Natasha Song</td><td>5080.74</td><td>6259.31</td><td>4265.86</td><td>4956.43</td><td>20668.96</td><td>🟡 Average</td></tr>
  <tr><td>Leighton Forrest</td><td>815.58</td><td>1129.69</td><td>327.02</td><td>16169.12</td><td>18522.06</td><td>🟡 Average</td></tr>
  <tr><td>Yvette Biti</td><td>2252.16</td><td>1476.92</td><td>3293.39</td><td>7731.78</td><td>14912.73</td><td>🔴 Need Improvement</td></tr>
  <tr><td>Samantha Chairs</td><td>2233.62</td><td>2005.7</td><td>1542.68</td><td>4921.92</td><td>10791.73</td><td>🔴 Need Improvement</td></tr>
  <tr><td>Radhya Staples</td><td>0</td><td>3.32</td><td>10373.59</td><td>206.16</td><td>10614.56</td><td>🔴 Need Improvement</td></tr>
  <tr><td>Preston Senome</td><td>1326.07</td><td>1415.98</td><td>2314.11</td><td>2817.6</td><td>7959.69</td><td>🔴 Need Improvement</td></tr>
  <tr><td>Mihael Khan</td><td>425.78</td><td>981.27</td><td>596.7</td><td>470.74</td><td>2518.01</td><td>🔴 Need Improvement</td></tr>
  <tr><td>Stevie Bacata</td><td>0</td><td>91.1</td><td>0</td><td>0</td><td>91.91</td><td>🔴 Need Improvement</td></tr>
</table>

---

> ### 10) Aanya Zhang exceeds the average 2016 yearly total ($42,424>~$36,277)

```sql
SELECT acc_manager, ROUND((qtr1+qtr2+qtr3+qtr4)::numeric,2) as yearly_total 
FROM sales16
WHERE (qtr1+qtr2+qtr3+qtr4) > (SELECT AVG(qtr1+qtr2+qtr3+qtr4) FROM Sales16);
```

<table>
  <tr>
    <th>acc_manager</th>
    <th>yearly_total</th>
  </tr>
  <tr><td>Aanya Zhang</td><td>42424.86</td></tr>
  <tr><td>Charlie Bui</td><td>24873.85</td></tr>
  <tr><td>Connor Betts</td><td>28401.89</td></tr>
  <tr><td>Natasha Song</td><td>20562.34</td></tr>
  <tr><td>Nicholas Fernandes</td><td>27896.94</td></tr>
  <tr><td>Phoebe Gour</td><td>33279.43</td></tr>
  <tr><td>Tina Carlton</td><td>29716.15</td></tr>
</table>

---

## 🗂️ Views Created

| View Name | Description |
|-----------|-------------|
| `v_customer_performance` | Total spend, orders, items, and avg order value per customer |
| `v_manager_performance_2016` | Manager revenue vs quarterly targets with performance category |
| `v_above_avg_managers` | Managers whose 2016 yearly total exceeds the group average |

---

*— End of README —*
