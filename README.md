
# Evaluating the Energy–Performance Trade-Offs of Quantized LLM Agents  
_A Replication Package for “Evaluating the Energy-Performance Trade-Offs of Quantized Large Language Model Agents: A Case Study Using Pokémon Battles”_

---

## Table of Contents
 1. [Overview](#overview)
 2. [Repository Structure](#repository-structure)
 3. [Getting Started](#getting-started)
 4. [Architecture](#architecture)
 5. [Usage](#usage)
 6. [Measurements \& Data](#measurements--data)
 7. [Replication Guide](#replication-guide)
 8. [License](#license)
 9. [Acknowledgments](#acknowledgments)

---

## Overview  
This repository contains all code, scripts, and measurement data needed to reproduce the experiments from the above paper. We evaluate energy consumption vs. model performance across various quantization schemes by using a Pokémon battle–based LLM agent.

---

## Repository Structure  
```

.
├── measurements_energy/            # Data & scripts for enerergy measurements
│   ├── pokemon_showdown/           # Contains all replays of the battles in html format 
│   ├── protocol.md                 # Describes what script to execute
│   ├── sqlite.db                   # SQLite Database with experiment data
│   └── …                           # For the rest see protocol.md
├── measurements_performance/       # Data & scripts for performance measurements
│   ├── pokemon_showdown/           # Contains all replays of the battles in html format 
│   ├── protocol.md                 # Describes what script to execute
│   ├── sqlite.db                   # SQLite Database with experiment data
│   └── …                           # For the rest see protocol.md
├── src/                            # Sourcode 
│   ├── agent.py                    # Implementation of Agents logic
│   ├── bot.py                      # Max Damage Bot Opponent 
│   ├── db.py                       # SQLite db configs and controll
│   ├── main.py                     # Script to start a battle
│   └── team_config.py              # Pokemon Shodown Team configuration
├── .env.example                    # Example environment variables
├── .gitignore              
├── Pipfile
├── Pipfile.lock
├── pull_models.sh                  # Script to pull models on LLM Server
├── README.md                       # This file
└── run.sh                          # Main experiment launcher

```

---

## Getting Started  

### Prerequisites  
- **Docker & Docker Compose** (for Langfuse)  
- **Node.js ≥ 22** and **npm** (for PokéShowdown server)  
- **Python 3.12.6** (managed via `pyenv`)  
- **pipenv** or **venv** for Python dependencies
- **Running Ollama Server** (for [run.sh](#running-the-experiments) )
- **SQLite installed** # (Prerequisit) Utility Server



### Environment Setup  

1. **Clone & enter repo**  
    ```bash
    git clone git@gitlab.rlp.net:green-software-engineering/quantized-llm-agents-energy-vs-performance.git
    cd quantized-llm-agents-energy-vs-performance
    ```

2. **Copy & edit `.env`**

   ```bash
   cp .env.example .env
   # then fill in your LANGFUSE_* and MODEL values
   ```
3. **Install Python deps**

   ```bash
   pipenv install
   ```
4. **Install and start PokéShowdown**

   ```bash
   # Install
   git clone https://github.com/smogon/pokemon-showdown.git pokemon-showdown
   cd pokemon-showdown
   npm install
   cp config/config-example.js config/config.js

   # Start
   node pokemon-showdown start --no-security
   ```

   **Pokemon-Shodown**

   Create a Team: Teambuilder - https://localhost.psim.us/teambuilder
   Pokedex: https://www.bisafans.de/pokedex/001.php#attacken

   **Poke-Env**

   Docs: https://poke-env.readthedocs.io/en/stable/

   Repository: https://github.com/hsahovic/poke-env
   
5. **Install and start Langfuse**

   ```bash
   git clone https://github.com/langfuse/langfuse.git
   cd langfuse
   docker compose up -d   
   ```
6. **Install SQLite for later analysis**
   ```bash
   sudo apt install sqlite3 libsqlite3-dev 
   pyenv uninstall 3.12.6
   pyenv install 3.12.6
   ```
---

## Architecture

1. **Agent** (`agent/agent.py`): wraps Ollama LLMs, quantizes models, interfaces with Pokémon battles via `poke-env`.
2. **Benchmark Harness** (`run.sh`): launches multiple agents for different quantization schemes, orchestrates measurement logging.
3. **Monitoring**: power readings collected via `gridvis` and stored into SQLite & CSV for post-processing.

---

## Usage

### Langfuse Config
1. Create a new Langfuse project.
2. Create a new API key and copy it into the .env (see below)

### Configuration

Edit your `.env` with:

| Variable              | Description                                        |
| --------------------- | -------------------------------------------------- |
| `LANGFUSE_PUBLIC_KEY` | Your Langfuse public API key                       |
| `LANGFUSE_SECRET_KEY` | Your Langfuse secret API key                       |
| `LANGFUSE_HOST`       | Langfuse endpoint (e.g., `http://localhost:3000`)  |
| `LANGFUSE_SESSION_ID` | A unique session ID for this experiment            |
| `MODEL`               | Ollama model identifier (e.g., `qwen3:32b-q4_K_M`) |

### Running the Experiments with run.sh

```bash
# Basic run:
./run.sh

# Specify models & number of battles:
./run.sh -n 100 \
  qwen3:0.6b-q4_K_M \
  qwen3:0.6b-q8_0 \
  qwen3:0.6b-fp16 \
  …

# Example remote exec on Ollama server:
ssh ollama "docker exec ollama ollama run \$MODEL 'Just say hi'"
```

---

## Measurements & Data

### Collecting Measurements

1. Launch `run.sh` (see above).
2. After completion, create a new folder e.g. `measurements/`
3. Copy the following dirs and files into it:

   * `logs/`
   * `pokemon_showdown/`
   * `sqlite.sql`

#### Janitza measurement data
1. Copy the measurement CSV from the Janitza Server to `measruements/`
2. Change the header of the CSV to:
```
day_num;timestamp;avg_watt;min_watt;max_watt;
```

### Script for analysis
For analysis see the `protocol.md` in `measurements_energy` and `measurements_performance`



---

## Replication Guide

1. **Ensure** all prerequisites & servers are up.
2. **Configure** `.env` as above.
3. **Run** `./run.sh` with your desired quantization configs.
4. **Collect** measurement outputs into `measurements/`.
5. **Analyze** with the provided analysis scripts.

---

## License

This replication package is released under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgments

This project was funded by German Federal Ministry for the Environment, Nature Conservation, Nuclear Safety, and Consumer Protection (BMUV) project ”KIRA” under Grant 67KI32013. Parts of the text have been enhanced and linguistically revised using AI tools.
