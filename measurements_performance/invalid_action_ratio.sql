
WITH base AS(
SELECT 
model,
IIF(fallback_reason_short IS NOT NULL, 'invalid', NULL) as fallback_reason_short,
function_call,
function_argument
FROM session_details
),
overview AS(
SELECT count(*) as action_count, fallback_reason_short, model FROM base GROUP BY fallback_reason_short, model
),
valid_actions AS(
SELECT * FROM overview WHERE fallback_reason_short is NULL
),
invalid_actions AS(
SELECT * FROM overview WHERE fallback_reason_short is NOT NULL
)
SELECT 
*,
ROUND((b.action_count + 0.0 ) / (a.action_count + b.action_count),4)
 as ratio
FROM 
valid_actions as a JOIN invalid_actions as b on a.model=b.model