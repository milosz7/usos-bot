from datetime import datetime

from sqlmodel import SQLModel, Field, DateTime
from pydantic import BaseModel, PastDate
from backend.db.helpers import current_timestamp
from datetime import datetime


class UserThread(SQLModel, table=True):
    user_id: str = Field(primary_key=True, max_length=128)
    thread_id: str = Field(primary_key=True)
    create_date: datetime = Field(default_factory=current_timestamp)

    class Config:
        from_attributes = True


class MessageRequest(BaseModel):
    message: str


class MessageResponse(BaseModel):
    response: str


class ThreadIDResponse(BaseModel):
    thread_id: str


class ChunkResponse(BaseModel):
    chunk: str
    is_finished: bool
