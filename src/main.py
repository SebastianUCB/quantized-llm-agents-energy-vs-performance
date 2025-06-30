from db import insert_session_result, init_db
from bot import MaxDamagePlayer
from agent import OpenAIAgent
from team_config import TEAM
from datetime import datetime, timezone
import os
import re

import asyncio

from poke_env import AccountConfiguration, LocalhostServerConfiguration

def convert_and_extract(s: str) -> str:
    """
    1. Replace the first ':' with '.'
    2. Remove any other '.' in the remainder of that segment
    3. If there’s a '-' segment, pull out the first run of digits from it and append
    """
    s = s.replace("-a3b","")
    # Split off any tail after '-'
    head, *tail = s.split('-', 1)
    # 1 & 2: split head at ':' then rebuild with a single '.'
    before_colon, after_colon = head.split(':', 1)
    # remove any '.' in the after-colon part
    cleaned = after_colon.replace('.', '')
    new_head = before_colon + '.' + cleaned

    # 3: if there was a tail, grab the first group of digits
    suffix = ''
    if tail:
        m = re.search(r'\d+', tail[0])
        if m:
            suffix = m.group()
    return new_head + suffix

def convert_string(s):
    to_remove = ":.-_"
    table = str.maketrans('', '', to_remove)
    return s.translate(table)

# AI (LLM) Agent
ai_agent = OpenAIAgent(
        account_configuration=AccountConfiguration(f"{convert_and_extract(os.getenv("MODEL"))}", None),
        battle_format="gen1ou",
        server_configuration=LocalhostServerConfiguration,
        max_concurrent_battles=10,
        save_replays="pokemon_showdown",
        team= TEAM,
    )

# Baseline Bot
bot = MaxDamagePlayer(
    account_configuration=AccountConfiguration(f"Bot{convert_and_extract(os.getenv("MODEL"))}", None),
    battle_format="gen1ou",
    server_configuration=LocalhostServerConfiguration,
    max_concurrent_battles=10,
    team= TEAM,
    )

async def run_battle():
    init_db()
    
    start_time = datetime.now(timezone.utc).astimezone()
    await ai_agent.battle_against(bot)
    end_time = datetime.now(timezone.utc).astimezone()
    print(ai_agent.win_rate)
    print(bot.win_rate)
    
    if bot.win_rate > 0:
        print("Bot Won")
    else:
        print("AI Agent Won")
    
    insert_session_result(
        session_id=os.getenv("LANGFUSE_SESSION_ID","No Session ID found"),
        model=os.getenv("MODEL"),
        iteration=os.getenv("ITERATION", 0),
        win_rate_ai=ai_agent.win_rate,
        win_rate_bot=bot.win_rate,
        start_time=start_time,
        end_time=end_time,
        )

asyncio.run(run_battle())
