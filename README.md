# Security Incident Analysis (SQL)

An advanced SQL project in MySQL that answers 6 analytical questions about security incidents, organisations, systems and network activity: which organisations have the most incidents, how incidents change month to month, and which operating systems are involved most.

## Dataset

- Source: [SQL Practice Dataset 3 (Hard Queries)](https://www.kaggle.com/datasets/nudratabbas/sql-practice-dataset-3-hard-queries) on Kaggle by Nudrat Abbas
- 7 related tables: `organizations` (120), `security_incidents` (500), `incident_systems` (500), `systems` (600), `users` (1,500), `network_events` (5,000) and `login_logs` (6,000)
- Incidents were discovered from 1 January 2023 to 15 May 2024, and network events cover the same period
- My six queries use five of the tables: `organizations`, `security_incidents`, `incident_systems`, `systems` and `network_events`. The `users` and `login_logs` tables are not used yet.
- The data is synthetic. For example, the organisation of a system does not always match the organisation of the incident linked to it, so I treated the tables as a practice dataset and did not draw real-world conclusions.
- Tool: MySQL Workbench

## Questions answered

1. Which organisations have more than 3 security incidents, and how many of them are Critical or High?
2. On which days did network activity go above its 7-day moving average, and how did each day compare with the previous day?
3. How many incidents were recorded each month, how does each month compare with the previous and next month, and is the trend increasing or decreasing?
4. For each operating system, what is the monthly incident count, the running total, its share of all incidents and its rank?
5. Which organisations have more incidents than the average organisation that has at least one incident?
6. Which organisations have never recorded a security incident?

The full question text is written as a comment above each query in `security_incident_analysis.sql`.

## SQL concepts used

- Multiple chained CTEs
- Window functions: `LAG`, `LEAD`, a 7-day moving average (`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`), a cumulative `SUM() OVER (PARTITION BY ...)`, `SUM() OVER ()` for share of total, and `DENSE_RANK`
- Subquery inside `HAVING` (derived table with an average)
- Anti-join (`LEFT JOIN ... IS NULL`)
- `CASE WHEN` inside `COUNT` and for classifying trends
- Joins across four tables, `GROUP BY`, `HAVING`, `COUNT(DISTINCT ...)`, `DATE_FORMAT`

## What I found

- 67 of the 119 organisations that have incidents had more than 3. **ORG079** (Finance, USA) had the most incidents (12), 6 of them Critical or High, followed by ORG082 (11) and ORG110 (10).
- The average organisation with at least one incident had about 4.2 incidents, and 46 organisations were above that average. Only **one organisation (ORG034)** had no incidents.
- **November 2023** had the most incidents in a month (38) and February 2023 the fewest in a full month (18). May 2024 shows only 11 because the data stops on 15 May.
- Windows systems were linked to the most incidents (190, 38%), then Mac (156, 31.2%) and Linux (154, 30.8%).
- Network activity was above its 7-day moving average on 233 of the 501 days with events.

## Files

| File | What it is |
|---|---|
| `security_incident_analysis.sql` | my 6 queries in one script, with the question above each one |
| `organizations.csv`, `security_incidents.csv`, `incident_systems.csv`, `systems.csv`, `users.csv`, `network_events.csv`, `login_logs.csv` | the Kaggle dataset |
| `README.md` | this summary |

## How to run

Create a database in MySQL, import the CSV files as tables with the same names as the files, select the database with `USE`, and run `security_incident_analysis.sql`.

## Limitations and next steps

The data is synthetic, and the tables do not always agree with each other, so the findings are for practising the analysis. Next I plan to add questions that use the `users` and `login_logs` tables.

## Author

Akash Saraswat
[LinkedIn](https://www.linkedin.com/in/akash-saraswat-085533273/) | saraswatakash785@gmail.com
