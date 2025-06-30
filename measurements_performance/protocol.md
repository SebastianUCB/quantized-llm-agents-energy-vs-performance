# 1. Running the experiment
```bash
./run.sh -n 100 qwen3:0.6b-q4_K_M qwen3:0.6b-q8_0 qwen3:0.6b-fp16 
./run.sh -n 100 qwen3:8b-q4_K_M qwen3:8b-q8_0 qwen3:8b-fp16 
./run.sh -n 100 qwen3:30b-a3b-q4_K_M qwen3:30b-a3b-q8_0 qwen3:30b-a3b-fp16 
./run.sh -n 100 qwen3:32b-q4_K_M qwen3:32b-q8_0 qwen3:32b-fp16
```

# 2. Run Analysis
- Run `invalid_action_ratio.sql` 
