from sqlmodel import create_engine, Session
import os
from datetime import datetime


engine = create_engine(os.environ.get("DB_CONN_STR"))


def get_session():
    with Session(engine) as session:
        yield session


def current_timestamp():
    return datetime.now().replace(microsecond=0).isoformat()
