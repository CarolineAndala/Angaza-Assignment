SELECT * FROM [dbo].[accounts]
SELECT * FROM [dbo].[billings]
SELECT * FROM [dbo].[payments]
SELECT * FROM [dbo].[reciepts]


--using CTE to creat virtual tables

--joining accounts and billings table to create billing_details table
WITH billing_details AS (
  SELECT [dbo].[accounts].*, [dbo].[billings].PRICE_UNLOCK, [dbo].[billings].DOWN_PAYMENT_PERIOD, [dbo].[billings].PRICE_UPFRONT
  FROM [dbo].[accounts]
  JOIN [dbo].[billings] ON [dbo].[accounts].BILLING_ID = [dbo].[billings].ID
),
--Joining payments and reciepts tables to create payments_detalis table
payment_details AS (
  SELECT [dbo].[payments].ID AS PAYMENT_ID, [dbo].[reciepts].ID AS RECIEPTS_ID, [dbo].[payments].ACCOUNT_ID, [dbo].[reciepts].AMOUNT, [dbo].[reciepts].EFFECTIVE_WHEN
  FROM [dbo].[payments]
  JOIN [dbo].[reciepts] ON [dbo].[payments].ID = [dbo].[reciepts].ID
),
--Joining the above two virtual tables to create account_detail table
account_details AS (
  SELECT *
  FROM billing_details
  JOIN payment_details ON billing_details.ID = payment_details.ACCOUNT_ID
)
SELECT *, 
DATEADD(MONTH, CAST(JSON_VALUE(DOWN_PAYMENT_PERIOD, '$.days') AS int), CAST(REGISTRATION_DATE AS date)) AS DATE_OF_EXPECTED_PAYMENT,
DATEDIFF(day, DATEADD(MONTH, CAST(JSON_VALUE(DOWN_PAYMENT_PERIOD, '$.days') AS int), CAST(REGISTRATION_DATE AS date)), EFFECTIVE_WHEN) AS DATE_DIFFERENCE,
(PRICE_UPFRONT + AMOUNT) AS TOTAL_AMOUNT_PAID,
(CAST(PRICE_UNLOCK AS float)/ (CAST(JSON_VALUE(NOMINAL_TERM, '$.days') AS int))) AS AMOUNT_DUE
FROM account_details;




