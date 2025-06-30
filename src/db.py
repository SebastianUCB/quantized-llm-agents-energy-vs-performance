import sqlite3
from datetime import datetime, timezone

DB_NAME = "sqlite.db"


def adapt_datetime(dt):
    return dt.isoformat()

def convert_datetime(s):
    return datetime.fromisoformat(s.decode())

sqlite3.register_adapter(datetime, adapt_datetime)
sqlite3.register_converter("TIMESTAMP", convert_datetime)

def init_db():
    conn = sqlite3.connect(DB_NAME, detect_types=sqlite3.PARSE_DECLTYPES)
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS session_details (
            turn INTEGER,
            langfuse_session_id TEXT,
            model TEXT,
            iteration INTEGER,
            start_time TIMESTAMP,
            end_time TIMESTAMP,
            fallback_reason_short TEXT,
            fallback_reason TEXT,
            function_call TEXT,
            function_argument TEXT
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS session_results (
            langfuse_session_id TEXT PRIMARY KEY,
            model TEXT,
            iteration INTEGER,
            win_rate_ai REAL,
            win_rate_bot REAL,
            start_time TIMESTAMP,
            end_time TIMESTAMP
        )
    ''')

    conn.commit()
    conn.close()

def insert_session_detail(turn, session_id, model, iteration, start_time, end_time, fallback_reason_short, fallback_reason, function_call, function_argument):
    conn = sqlite3.connect(DB_NAME, detect_types=sqlite3.PARSE_DECLTYPES)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO session_details (
            turn, langfuse_session_id, model, iteration, start_time, end_time,
            fallback_reason_short, fallback_reason, function_call, function_argument
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (turn, session_id, model, iteration, start_time, end_time, fallback_reason_short, fallback_reason, function_call, function_argument))
    conn.commit()
    conn.close()

def insert_session_result(session_id, model, iteration, win_rate_ai, win_rate_bot, start_time, end_time):
    conn = sqlite3.connect(DB_NAME, detect_types=sqlite3.PARSE_DECLTYPES)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT OR REPLACE INTO session_results (
            langfuse_session_id, model, iteration, win_rate_ai,
            win_rate_bot, start_time, end_time
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (session_id,model, iteration, win_rate_ai, win_rate_bot, start_time, end_time))
    conn.commit()
    conn.close()
