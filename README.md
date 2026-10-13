# Auto Transport Sales Dashboard

Interactive sales dashboard where every chart is driven by a real SQL query, executed directly in the browser.

The data is 736 vehicle shipping quote requests over 12 months (Oct 2025 to Sep 2026): agents, lead sources, routes, vehicle types, prices and outcomes. The dataset is generated to look like a real US auto transport brokerage.

**Live demo:** (https://teodor-ninkov.github.io/sales-dashboard/)

![Screenshot](screenshot.png)

## What it shows

- Revenue, quotes, won orders, conversion rate, average order and customer rating, with filters by period, agent and lead source
- Revenue and won orders by month
- Conversion rate by lead source
- Top routes by revenue
- Price per mile by distance band
- Agent leaderboard
- Revenue by vehicle type

Press **SQL** on any panel to see the exact query behind it. The SQL explorer at the bottom lets you run your own queries against the same table.

## How it works

1. `data/orders.csv` is loaded with `fetch` and inserted into an in-memory SQLite database created by [sql.js](https://github.com/sql-js/sql.js) (SQLite compiled to WebAssembly).
2. Filters are turned into a `WHERE` clause that is injected into each query in `sql/queries.sql`.
3. Query results are rendered with [Chart.js](https://www.chartjs.org/) and plain HTML tables.

No backend, no build step: a single `index.html`, a CSV and the SQL file.

## Tech stack

- SQL (SQLite dialect): aggregations, `CASE`, `GROUP BY`, string functions, window functions in the examples
- JavaScript, HTML, CSS
- sql.js, Chart.js

## Run locally

The page fetches the CSV, so it needs to be served over HTTP (opening the file directly will not work):

```bash
git clone https://github.com/teodor-ninkov/sales-dashboard.git
cd sales-dashboard
python -m http.server 8000
```

Open http://localhost:8000.

## Project structure

```
index.html          Dashboard: layout, queries, charts, SQL explorer
data/orders.csv     Sample dataset (736 rows)
sql/queries.sql     The queries used by the dashboard
```
