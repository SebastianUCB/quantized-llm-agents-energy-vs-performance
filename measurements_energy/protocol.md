
# 1. Running the experiment
```bash
./run.sh qwen3:0.6b-q4_K_M qwen3:0.6b-q8_0 qwen3:0.6b-fp16 qwen3:8b-q4_K_M qwen3:8b-q8_0 qwen3:8b-fp16 qwen3:30b-a3b-q4_K_M qwen3:30b-a3b-q8_0 qwen3:30b-a3b-fp16 qwen3:32b-q4_K_M qwen3:32b-q8_0 qwen3:32b-fp16 
```

# 2. Preparing Data
## Adding model details
To add model_size and model_qantization run `update.sql`

## Outlier_detection
For outlier detection we ran: `outlier_detection.sql`

## Energy Measurements
To add the energy measurement data, we did:
1. Extract data from Janitza device in csv format
2. Change HEADER (see README.md) of csv files.
3. Run `add_measurement_to_db.sh`
4. Create measurement_with_session table, run `measurement_with_session.sql`
  
## Adding langfuse data to database
To add langfuse data to the database run: `langfuse_export.sh`

## Create table for easier sql statements
In order to have easier sql statements druing analysis we created table session_analysis_base by running `session_analysis_base.sql`.

# 3. Analysis
For final anylsis we ran `analysis.sql`