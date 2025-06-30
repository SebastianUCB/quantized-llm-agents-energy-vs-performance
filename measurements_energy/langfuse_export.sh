#export ENPOINT="/api/public/projects"
#export ENPOINT="/api/public/traces"
#curl -u pk-lf-2b8dd325-f20c-4aaf-ade9-9a25220e09e1:sk-lf-a62ad5b3-0e54-4b98-9ebe-96e0070879e3 \
#  "http://localhost:3000${ENPOINT}?limit=1" \
#  -H "Accept: application/json" | jq .data > traces.json 

# MORE HERE https://langfuse.com/docs/analytics/metrics-api


curl -u pk-lf-2b8dd325-f20c-4aaf-ade9-9a25220e09e1:sk-lf-a62ad5b3-0e54-4b98-9ebe-96e0070879e3 \
  -G "http://localhost:3000/api/public/metrics" \
  --data-urlencode 'query={
    "view":"traces",
    "dimensions":[{"field":"sessionId"}],
    "metrics":[{"measure":"totalTokens","aggregation":"sum"},{"measure":"count","aggregation":"count"}],
    "fromTimestamp":"2025-06-01T00:00:00Z",
    "toTimestamp":"2025-06-18T23:59:59Z"
  }'| jq .data > sessions.json 

jq -r '(.[0] | keys_unsorted) as $keys
       | $keys,
         map([.[ $keys[] ]])[]
       | @csv' sessions.json > data.csv

sqlite3 sqlite.db \
      -cmd ".mode csv" \
      -cmd ".separator ','" \
      -cmd ".headers on" \
      ".import data.csv langfuse_sessions"

rm sessions.json 
rm data.csv

sqlite3 sqlite.db \
"SELECT
  CAST(sum_totalTokens AS INTEGER)     AS sum_totalTokens_int
FROM langfuse_sessions;

ALTER TABLE langfuse_sessions ADD COLUMN totalTokens INTEGER;

UPDATE langfuse_sessions
  SET totalTokens = CAST(sum_totalTokens AS INTEGER);

ALTER TABLE langfuse_sessions DROP COLUMN sum_totalTokens;

ALTER TABLE langfuse_sessions ADD COLUMN traces INTEGER;

UPDATE langfuse_sessions
  SET traces = CAST(count_count AS INTEGER);

ALTER TABLE langfuse_sessions DROP COLUMN count_count;"
# Add the table langfuse to sqlite.db