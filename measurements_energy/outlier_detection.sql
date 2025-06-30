WITH partitioned AS (
  SELECT
    model_size,
    model_quantization_level,
    totalTokens,
    NTILE(4) OVER (
      PARTITION BY model_size, model_quantization_level
      ORDER BY totalTokens
    ) AS qtile
  FROM session_analysis_base
),

qstats AS (
  -- Approximate Q1 = avg(totalTokens) in the lowest 25% bucket;
  --           Q3 = avg(totalTokens) in the highest 25% bucket
  SELECT
    model_size,
    model_quantization_level,
    AVG(CASE WHEN qtile = 1 THEN totalTokens END) AS q1,
    AVG(CASE WHEN qtile = 4 THEN totalTokens END) AS q3
  FROM partitioned
  GROUP BY model_size, model_quantization_level
),

thresholds AS (
  SELECT
    model_size,
    model_quantization_level,
    q1,
    q3,
    (q3 - q1) * 1.5        AS iqr,
    q1 - (q3 - q1) * 1.5   AS lower_fence,
    q3 + (q3 - q1) * 1.5   AS upper_fence
  FROM qstats
),
result AS (SELECT
  r.*,
  CASE
    WHEN r.totalTokens < t.lower_fence
      OR r.totalTokens > t.upper_fence
    THEN 1 ELSE 0
  END AS is_outlier
FROM session_analysis_base AS r
JOIN thresholds AS t
  ON r.model_size = t.model_size
 AND r.model_quantization_level = t.model_quantization_level
ORDER BY
  r.model_size,
  r.model_quantization_level,
  r.totalTokens
)
SELECT * from result where is_outlier


WITH 
-- 1. Compute the mean per group
mean_stats AS (
  SELECT
    model_size,
    model_quantization_level,
    AVG(totalTokens) AS mean_totalTokens
  FROM session_analysis_base
  GROUP BY
    model_size,
    model_quantization_level
),

-- 2. Order each group's values and count them
ordered AS (
  SELECT
    model_size,
    model_quantization_level,
    totalTokens,
    ROW_NUMBER() OVER (
      PARTITION BY model_size, model_quantization_level
      ORDER BY totalTokens
    ) AS rn,
    COUNT(*) OVER (
      PARTITION BY model_size, model_quantization_level
    ) AS cnt
  FROM session_analysis_base
),

-- 3. Pick out the middle row(s) to compute the median per group
median_stats AS (
  SELECT
    model_size,
    model_quantization_level,
    AVG(totalTokens) AS median_totalTokens
  FROM ordered
  WHERE rn IN (
    (cnt + 1) / 2,      -- middle if odd
    (cnt + 2) / 2       -- and the next one if even
  )
  GROUP BY
    model_size,
    model_quantization_level
)

-- 4. Join mean and median together
SELECT
  m.model_size,
  m.model_quantization_level,
  m.mean_totalTokens,
  med.median_totalTokens
FROM mean_stats AS m
JOIN median_stats AS med
  USING (model_size, model_quantization_level)
ORDER BY
  m.model_size,
  m.model_quantization_level;
