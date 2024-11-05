from sqlmodel import create_engine, Session
import os

engine = create_engine(os.environ.get("DB_CONN_STR"))


def get_session():
    with Session(engine) as session:
        yield session
