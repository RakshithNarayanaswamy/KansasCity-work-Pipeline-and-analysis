----------1. Service Requests Over Time:-----------
SELECT
  YEAR(TRY_CONVERT(date, [creation_date], 101)) AS [Year],
  COUNT(*) AS Requests
FROM dbo.KansasCity
WHERE TRY_CONVERT(date, [creation_date ], 101) BETWEEN '2018-01-01' AND '2021-12-31'
GROUP BY YEAR(TRY_CONVERT(date, [creation_date], 101))
ORDER BY [Year];

SELECT
  CONVERT(char(7), TRY_CONVERT(date, [creation_date], 101), 126) AS [YearMonth], -- e.g. 2019-04
  COUNT(*) AS Requests
FROM dbo.KansasCity
WHERE TRY_CONVERT(date, [creation_date], 101) BETWEEN '2018-01-01' AND '2021-12-31'
GROUP BY CONVERT(char(7), TRY_CONVERT(date, [creation_date], 101), 126)
ORDER BY [YearMonth];


----------2. Volume of service requests received from different sources:----------

SELECT source, COUNT(*) AS requests_per_source
FROM KansasCity
GROUP BY source
ORDER BY requests_per_source DESC;

----------3. Volume of service requests received by Department:-----------

SELECT department, COUNT(*) AS requests_per_department
FROM KansasCity
GROUP BY department
ORDER BY requests_per_department DESC;

----------4. Top-10 Fastest Response Times-----------

SELECT TOP (10)
  category1,
  [type],
  case_id,
  creation_date,
  closed_date,
  TRY_CONVERT(float, days_to_close) AS days_to_close_num
FROM dbo.KansasCity
WHERE
  closed_date IS NOT NULL
  AND TRY_CONVERT(float, days_to_close) IS NOT NULL
  AND TRY_CONVERT(float, days_to_close) >= 0
ORDER BY
  TRY_CONVERT(float, days_to_close) ASC,
  creation_date ASC;

----------5. Geographical Visualization: -----------

--zip_code--

SELECT TOP (10) zip_code, COUNT(*) AS zip_requests
FROM KansasCity
GROUP BY zip_code
ORDER BY zip_requests DESC;

--street_address--

SELECT TOP(10) street_address, COUNT(*) AS street_request
FROM KansasCity  
GROUP BY street_address
ORDER BY street_request DESC

--latitude & longitude--

SELECT TOP (10)
  latitude,
  longitude,
  COUNT(*) AS requests
FROM KansasCity
WHERE latitude IS NOT NULL AND longitude IS NOT NULL
GROUP BY latitude, longitude
ORDER BY requests DESC;


----------6. Departmental Workload Comparison: -----------

SELECT department, work_group, COUNT(*) AS requests
FROM KansasCity
GROUP BY department, work_group
ORDER BY Requests DESC, department ;


----------7. Response Time Analysis: -----------
--
SELECT
  department,
  COUNT(*) AS Requests,
  AVG(TRY_CONVERT(float, days_to_close)) AS AvgDays,
  MIN(TRY_CONVERT(float, days_to_close)) AS MinDays,
  MAX(TRY_CONVERT(float, days_to_close)) AS MaxDays
FROM dbo.KansasCity
WHERE TRY_CONVERT(float, days_to_close) IS NOT NULL
  AND TRY_CONVERT(float, days_to_close) >= 0
GROUP BY department
ORDER BY department;



----------8. Service Request Status Composition: -----------

-- Composition by status (overall) --
SELECT [status], COUNT(*) AS Requests
FROM KansasCity
GROUP BY [status]
ORDER BY Requests DESC;

-- composition changed over the years 2018-2021 --
SELECT [status], COUNT(*) AS requests
FROM KansasCity
WHERE TRY_CONVERT(date, [creation_date ], 101) BETWEEN '2018-01-01' AND '2021-12-31'
GROUP BY [status]
ORDER BY requests DESC;


-----------9. Time to Closure Analysis: -----------

SELECT TOP (10)
  category1,
  COUNT(*) AS Requests,
  AVG(TRY_CONVERT(float, days_to_close)) AS AvgDaysToClose
FROM KansasCity
WHERE TRY_CONVERT(float, days_to_close) IS NOT NULL
  AND TRY_CONVERT(float, days_to_close) >= 0
GROUP BY category1
ORDER BY AvgDaysToClose DESC;


-----------10. Workload Efficiency: -----------

SELECT department, COUNT(*) AS requests, AVG(TRY_CONVERT(float, days_to_close)) AS AvgDaysToClose
FROM KansasCity
GROUP BY department
ORDER BY requests DESC

-----------ROW COUNT -----------

SELECT COUNT(*) AS [RowCount]
FROM KansasCity;
