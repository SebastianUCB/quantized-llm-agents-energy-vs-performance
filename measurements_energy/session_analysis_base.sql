CREATE TABLE session_analysis_base AS
WITH lang_measure AS (SELECT * FROM langfuse_sessions as lang JOIN (
SELECT *,
  -- difference in whole seconds
  (strftime('%s', end_time)
   - strftime('%s', start_time)
  ) AS duration_seconds,
  -- formatted as HH:MM:SS (works if duration < 24h)
  time(
    strftime('%s', end_time)
    - strftime('%s', start_time),
    'unixepoch'
  ) AS duration_hms FROM measurement_with_session) as measure
  on lang.sessionId = measure.langfuse_session_id )
SELECT 
  session_results.langfuse_session_id,
  session_results.model,
  session_results.iteration,
  session_results.win_rate_ai,
  session_results.model_size,
  session_results.model_quantization_level,
  lang_measure.totalTokens,
  lang_measure.traces,
  lang_measure.start_time,
  lang_measure.end_time,
  lang_measure.avg_watt,
  lang_measure.max_watt,
  lang_measure.min_watt,
  lang_measure.duration_seconds,
  lang_measure.duration_hms
from session_results JOIN lang_measure on session_results.langfuse_session_id = lang_measure.langfuse_session_id