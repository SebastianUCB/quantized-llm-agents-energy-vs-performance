#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Script to pull multiple Ollama models via Docker

# Define an array of model names
declare -a MODELS=(
  "qwen3:0.6b-q4_K_M"
  "qwen3:0.6b-q8_0"
  "qwen3:0.6b-fp16"

  "qwen3:8b-q4_K_M"
  "qwen3:8b-q8_0"
  "qwen3:8b-fp16"

  "qwen3:30b-a3b-q4_K_M"
  "qwen3:30b-a3b-q8_0"
  "qwen3:30b-a3b-fp16"

  "qwen3:32b-q4_K_M"
  "qwen3:32b-q8_0"
  "qwen3:32b-fp16"

)

# Iterate over each model and pull it
echo "Starting to pull Ollama models..."
for model in "${MODELS[@]}"; do
  echo "Pulling model: $model"
  if docker exec ollama ollama pull "$model"; then
    echo "Successfully pulled $model"
  else
    echo "Failed to pull $model" >&2
  fi

done

echo "All models processed."
