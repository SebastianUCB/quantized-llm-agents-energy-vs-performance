#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# run.sh
#
# Usage:
#   ./run.sh [-n N | --iterations=N] <MODEL1> [MODEL2 ...]
#
#   -n, --iterations N   how many times to execute src/main.py per model
#                        defaults to 30
#   MODEL*               one or more LLM model names (e.g. qwen3:0.6b)
# -----------------------------------------------------------------------------

# Default
ITERATIONS=30
SLEEP_AFTER_ITERATION=30
SLEEP_AFTER_MODEL_WARMUP=10

# Parse options (requires GNU getopt)
TEMP=$(getopt -o n: -l iterations: -n 'run.sh' -- "$@")
if [ $? != 0 ]; then
  echo "Usage: $0 [-n N | --iterations=N] <MODEL1> [MODEL2 ...]" >&2
  exit 1
fi
eval set -- "$TEMP"

while true; do
  case "$1" in
    -n|--iterations)
      ITERATIONS="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error while parsing options!" >&2
      exit 1
      ;;
  esac
done

# Validate ITERATIONS
if ! [[ "$ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: --iterations/-n must be a positive integer." >&2
  exit 1
fi

# At least one model name must remain
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [-n N | --iterations=N] <MODEL1> [MODEL2 ...]" >&2
  exit 1
fi
MODELS=("$@")

LOG_ROOT="logs"
mkdir -p "$LOG_ROOT"

echo "→ Iterations per model = $ITERATIONS"
echo "→ Models to run        = ${MODELS[*]}"
echo "→ Logs directory       = $LOG_ROOT/"
echo

for MODEL in "${MODELS[@]}"; do
  MODEL_SAFE=$(printf '%s' "$MODEL" | sed 's/[^[:alnum:]_-]/_/g')
  MODEL_LOG_DIR="$LOG_ROOT/$MODEL_SAFE"
  mkdir -p "$MODEL_LOG_DIR"

  export MODEL
  echo "Warmup Model $MODEL"
  ssh ollama "docker exec ollama ollama run $MODEL 'Just say hi'"
  echo "Warmup Model done - Sleeping $SLEEP_AFTER_MODEL_WARMUP s"
  sleep $SLEEP_AFTER_MODEL_WARMUP

  echo "==> Running model: $MODEL (logs in $MODEL_LOG_DIR/)"

  for i in $(seq 1 "$ITERATIONS"); do
    LANGFUSE_SESSION_ID="Iteration $i Model $MODEL"
    LANGFUSE_SESSION_ID_SAFE=$(printf '%s' "$LANGFUSE_SESSION_ID" | sed 's/[^[:alnum:]_-]/_/g')
    LOG_FILE="$MODEL_LOG_DIR/${LANGFUSE_SESSION_ID_SAFE}.log"

    echo "  • Iteration $i/$ITERATIONS → LANGFUSE_SESSION_ID=\"$LANGFUSE_SESSION_ID\""
    echo "    Logging to: $LOG_FILE"
    export LANGFUSE_SESSION_ID
    export ITERATION=$i

    pipenv run python src/main.py > "$LOG_FILE" 2>&1

    echo "    Sleeping $SLEEP_AFTER_ITERATION s before next iteration…"
    sleep $SLEEP_AFTER_ITERATION
  done

  echo "==> Done $ITERATIONS iterations for $MODEL"
  echo
done

echo "All iterations complete. Logs under $LOG_ROOT/"
