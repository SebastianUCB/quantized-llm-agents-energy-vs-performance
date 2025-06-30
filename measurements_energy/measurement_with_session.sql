CREATE TABLE measurement_with_session AS
WITH session as (
SELECT langfuse_session_id, datetime(start_time, '+2 hours') as start_time, datetime(end_time, '+2 hours') AS end_time FROM session_results
)
SELECT langfuse_session_id,min(ts) as start_time, max(ts) as end_time, avg(avg_watt) as avg_watt , min(max_watt) as min_watt , max(max_watt) as max_watt from measurement as m JOIN session as s on m.ts BETWEEN
       s.start_time
    AND s.end_time
    GROUP BY langfuse_session_id
