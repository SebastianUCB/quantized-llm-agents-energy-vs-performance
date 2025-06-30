# Prepare Data
## Adding model size and quantization level
- run update.sql 

## Adding measurement data from Janitza
1. Replace the first and second row with: day_num;timestamp;avg_watt;min_watt;max_watt;
2. run `add_measurement_to_db.sh`

## Adding langfuse data to db
- run `langfuse_export.sh`

## Creating measurement_with_session
- run `measurement_with_session.sql`

## Creating session_analysis_base
- run `session_analysis_base.sql`


# Outlier Detection
In our analysis we implemented a purely SQL-based, non-parametric outlier detection procedure—applied independently to each combination of model size and quantization level—using the interquartile-range (IQR) rule.  Briefly:

1. **Quartile Approximation via Windowing**
   We used SQLite’s `NTILE(4)` window function to divide the 30 observed `totalTokens` values for each `(model_size, model_quantization_level)` pair into four equal-sized “buckets” ordered by `totalTokens`.  The first bucket (NTILE = 1) approximates the lowest 25 % of the distribution, and the fourth bucket (NTILE = 4) approximates the highest 25 %.

2. **Estimating Q1 and Q3**
   Within each group, we computed

   $$
     Q_1 = \mathrm{mean}\{\text{totalTokens} \mid \text{NTILE}=1\}, 
     \quad
     Q_3 = \mathrm{mean}\{\text{totalTokens} \mid \text{NTILE}=4\}.
   $$

   These bucket-means serve as robust proxies for the first and third empirical quartiles.

3. **Calculating IQR Fences**
   We then defined the interquartile range as

   $$
     \mathrm{IQR} = Q_3 - Q_1,
   $$

   and constructed the conventional 1.5×IQR fences:

   $$
     \text{lower\_fence} = Q_1 - 1.5\cdot\mathrm{IQR}, 
     \quad
     \text{upper\_fence} = Q_3 + 1.5\cdot\mathrm{IQR}.
   $$

4. **Outlier Flagging**
   Finally, each run in the base table was joined back to its group’s fences and labeled as an outlier whenever its `totalTokens` lay below the lower fence or above the upper fence.

## Filtered Outlier
- totalToken (100923 - Iteration 1 Model qwen3:0.6b-q8_0) -> replaced with: meidan of this group (33408.0)