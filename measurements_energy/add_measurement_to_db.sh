awk '{ sub(/;$/, ""); print }' measurement_monday.csv \
  | sqlite3 sqlite.db \
      -cmd ".mode csv" \
      -cmd ".separator ';'" \
      -cmd ".headers on" \
      ".import /dev/stdin measurement"

awk '{ sub(/;$/, ""); print }' measurement_tuesday.csv \
  | sqlite3 sqlite.db \
      -cmd ".mode csv" \
      -cmd ".separator ';'" \
      -cmd ".headers on" \
      ".import /dev/stdin measurement"

awk '{ sub(/;$/, ""); print }' measurement_wednesday.csv \
  | sqlite3 sqlite.db \
      -cmd ".mode csv" \
      -cmd ".separator ';'" \
      -cmd ".headers on" \
      ".import /dev/stdin measurement"

sqlite3 sqlite.db \
"ALTER TABLE measurement ADD COLUMN ts DATETIME;
 UPDATE measurement
 SET ts = datetime(
    '20' || substr(timestamp,7,2) || '-' ||
    substr(timestamp,4,2)       || '-' ||
    substr(timestamp,1,2)       || ' ' ||
    substr(timestamp,11)
 );
 ALTER TABLE measurement RENAME COLUMN avg_watt TO avg_watt_str;
 ALTER TABLE measurement RENAME COLUMN min_watt TO min_watt_str;
 ALTER TABLE measurement RENAME COLUMN max_watt TO max_watt_str;
 
 ALTER TABLE measurement ADD COLUMN avg_watt REAL;
 ALTER TABLE measurement ADD COLUMN min_watt REAL;
 ALTER TABLE measurement ADD COLUMN max_watt REAL;
 
 UPDATE measurement SET avg_watt = CAST(REPLACE(avg_watt_str,',','') AS REAL)/1000;
 UPDATE measurement SET min_watt = CAST(REPLACE(min_watt_str,',','') AS REAL)/1000;
 UPDATE measurement SET max_watt = CAST(REPLACE(max_watt_str,',','') AS REAL)/1000;"