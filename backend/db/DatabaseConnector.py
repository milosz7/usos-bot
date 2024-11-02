from psycopg_pool import ConnectionPool
from langgraph.checkpoint.postgres import PostgresSaver


class DatabaseConnector:
    def __init__(self, db_uri):
        self.db_uri = db_uri
        self.connection_kwargs = {
            "autocommit": True,
            "prepare_threshold": 0,
        }
        self.pool = None
        self.checkpointer = None

    def __del__(self):
        if self.pool:
            self.pool.close()

    def connect(self):
        self.pool = ConnectionPool(
            conninfo=self.db_uri,
            max_size=10,
            kwargs=self.connection_kwargs,
        )

        self.checkpointer = PostgresSaver(self.pool)
        self.checkpointer.setup()

    def get_checkpointer(self):
        return self.checkpointer
