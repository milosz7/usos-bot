from fastapi import APIRouter, HTTPException, status
from backend.rag_model import RAGModel
from typing import Annotated
from fastapi import Depends
from backend.db.helpers import get_session
from sqlmodel import Session, select
from backend.auth import verify_token
from backend.models import (
    MessageRequest,
    UserThread,
    ChunkResponse,
    CaptionResponse,
    HistoryResponse,
    ThreadIdResponse,
)
from typing import List
from uuid import uuid4

SessionDep = Annotated[Session, Depends(get_session)]

router = APIRouter()
model_graph = RAGModel()

streams = {}


@router.get("/chat/captions", response_model=List[CaptionResponse])
async def get_captions(session: SessionDep, user=Depends(verify_token)):
    # noinspection PyTypeChecker
    user_threads = session.exec(
        select(UserThread.thread_id)
        .where(user.get("email") == UserThread.user_id)
        .order_by(UserThread.create_date.desc())
    ).all()

    captions = [
        {
            "caption": content,
            "thread_id": thread_id,
        }
        for thread_id in user_threads
        if (content := model_graph.get_thread_caption(thread_id)["content"])
    ]

    return captions


@router.get("/chat/{thread_id}", response_model=List[HistoryResponse])
async def get_chat_history(
    session: SessionDep, thread_id: str, user=Depends(verify_token)
):
    # noinspection PyTypeChecker
    user_thread = session.exec(
        select(UserThread).where(thread_id == UserThread.thread_id)
    ).first()

    if user_thread is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if user.get("email") != user_thread.user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    history = model_graph.get_thread(thread_id)

    return history


@router.post("/chat", response_model=ThreadIdResponse)
async def init_chat(
    session: SessionDep, body: MessageRequest, user=Depends(verify_token)
):
    thread_id = str(uuid4())
    try:
        # TODO: improve graph db cleanup
        new_thread = UserThread(user_id=user["email"], thread_id=thread_id)
        session.add(new_thread)
        session.commit()
        session.refresh(new_thread)

        message = body.message
        stream = model_graph.init_respond_stream(message, thread_id)
        streams[thread_id] = stream
    except Exception:
        session.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return ThreadIdResponse(thread_id=thread_id)


@router.post("/chat/{thread_id}")
async def ask_model(
    session: SessionDep,
    thread_id: str,
    body: MessageRequest,
    user=Depends(verify_token),
):
    # noinspection PyTypeChecker
    user_thread = session.exec(
        select(UserThread).where(thread_id == UserThread.thread_id)
    ).first()

    if user_thread is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if user["email"] != user_thread.user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    message = body.message
    stream = model_graph.respond_stream(message, thread_id)
    streams[thread_id] = stream

    return


@router.get("/chat/next/{thread_id}", response_model=ChunkResponse)
async def get_message_chunk(
    session: SessionDep, thread_id: str, user=Depends(verify_token)
):
    # noinspection PyTypeChecker
    user_thread = session.exec(
        select(UserThread).where(thread_id == UserThread.thread_id)
    ).first()

    if user_thread is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if user.get("email") != user_thread.user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    user_stream = streams[thread_id]
    chunk = next(user_stream)
    msg, _ = chunk

    if "finish_reason" in msg.response_metadata:
        for msg, _ in user_stream:
            pass

        del streams[thread_id]
        return ChunkResponse(chunk="", is_finished=True)

    return ChunkResponse(chunk=msg.content, is_finished=False)
