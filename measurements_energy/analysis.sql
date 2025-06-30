-- Creat advanced analysis base
WITH base as(
SELECT 
 model, 
 iteration,
 win_rate_ai,
 model_size,
 model_quantization_level,
 totalTokens,
 traces,
 avg_watt,
 max_watt,
 min_watt,
 duration_seconds,
 duration_hms
FROM session_analysis_base
)
SELECT 
 model_size,
 model_quantization_level,
 ROUND(avg(avg_watt)),
 sum(win_rate_ai),
 sum(totalTokens)
FROM base 
GROUP BY 
 model_size,
 model_quantization_level 