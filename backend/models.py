from sqlmodel import SQLModel, Field
from uuid import UUID
from pydantic import BaseModel


class UserThread(SQLModel, table=True):
    user_id: str = Field(primary_key=True, max_length=128)
    thread_id: str = Field(primary_key=True)


class MessageRequest(BaseModel):
    message: str


class MessageResponse(BaseModel):
    response: str


class ThreadIDResponse(BaseModel):
    thread_id: str
