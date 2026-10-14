-- Queries used by the dashboard. The app replaces {where} with the active filters.
-- A "won" order is one with status Booked, In transit or Delivered.

-- KPI strip
SELECT
  COUNT(*) AS quotes,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) AS won,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN quote_price ELSE 0 END) AS revenue,
  ROUND(100.0 * SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct,
  ROUND(AVG(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN quote_price END)) AS avg_order,
  ROUND(AVG(customer_rating), 2) AS avg_rating
FROM orders
{where};

-- Revenue and won orders by month
SELECT
  strftime('%Y-%m', order_date) AS month,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN quote_price ELSE 0 END) AS revenue,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) AS won
FROM orders
{where}
GROUP BY month
ORDER BY month;

-- Conversion rate by lead source
SELECT
  lead_source,
  COUNT(*) AS quotes,
  ROUND(100.0 * SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct
FROM orders
{where}
GROUP BY lead_source
ORDER BY conversion_pct DESC;

-- Top routes by revenue
SELECT
  origin_state || ' to ' || destination_state AS route,
  COUNT(*) AS won,
  SUM(quote_price) AS revenue
FROM orders
{where} AND status IN ('Booked', 'In transit', 'Delivered')
GROUP BY route
ORDER BY revenue DESC
LIMIT 8;

-- Revenue by vehicle type
SELECT
  vehicle_type,
  SUM(quote_price) AS revenue
FROM orders
{where} AND status IN ('Booked', 'In transit', 'Delivered')
GROUP BY vehicle_type
ORDER BY revenue DESC;

-- Average price per mile by distance band
SELECT
  CASE
    WHEN distance_miles < 500 THEN 'Under 500 mi'
    WHEN distance_miles < 1000 THEN '500 to 999 mi'
    WHEN distance_miles < 1500 THEN '1,000 to 1,499 mi'
    WHEN distance_miles < 2000 THEN '1,500 to 1,999 mi'
    ELSE '2,000+ mi'
  END AS band,
  MIN(distance_miles) AS sort_key,
  COUNT(*) AS won,
  ROUND(AVG(quote_price * 1.0 / distance_miles), 2) AS price_per_mile
FROM orders
{where} AND status IN ('Booked', 'In transit', 'Delivered')
GROUP BY band
ORDER BY sort_key;

-- Agent leaderboard
SELECT
  agent,
  COUNT(*) AS quotes,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) AS won,
  ROUND(100.0 * SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct,
  SUM(CASE WHEN status IN ('Booked', 'In transit', 'Delivered') THEN quote_price ELSE 0 END) AS revenue,
  ROUND(AVG(customer_rating), 2) AS avg_rating
FROM orders
{where}
GROUP BY agent
ORDER BY revenue DESC;

-- Explorer examples that use the agents table

-- Revenue by team
SELECT a.team,
  COUNT(o.order_id) AS won,
  SUM(o.quote_price) AS revenue
FROM orders o
JOIN agents a ON a.agent = o.agent
WHERE o.status IN ('Booked', 'In transit', 'Delivered')
GROUP BY a.team
ORDER BY revenue DESC;

-- How many months each agent hit their target
WITH monthly AS (
  SELECT agent, strftime('%Y-%m', order_date) AS month,
    SUM(quote_price) AS revenue
  FROM orders
  WHERE status IN ('Booked', 'In transit', 'Delivered')
  GROUP BY agent, month
)
SELECT m.agent, a.monthly_target,
  ROUND(AVG(m.revenue)) AS avg_month,
  SUM(CASE WHEN m.revenue >= a.monthly_target THEN 1 ELSE 0 END) AS months_on_target
FROM monthly m
JOIN agents a ON a.agent = m.agent
GROUP BY m.agent
ORDER BY months_on_target DESC;
