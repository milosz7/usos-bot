from fastapi import APIRouter, HTTPException, status
from fastapi.templating import Jinja2Templates
from fastapi import Request
from sqlalchemy.testing.suite.test_reflection import metadata

from backend.rag_model import RAGModel
from backend.models import MessageRequest, MessageResponse, UserThread, ChunkResponse
from typing import Annotated
from fastapi import Depends
from backend.db.helpers import get_session
from sqlmodel import Session, select
from uuid import uuid4, UUID

SessionDep = Annotated[Session, Depends(get_session)]

router = APIRouter()
model_graph = RAGModel()
templates = Jinja2Templates(directory="frontend/templates")

streams = {}


def get_chats_caption(session: SessionDep, user):
    user_threads = session.exec(
        select(UserThread.thread_id)
        .where(user["email"] == UserThread.user_id)
        .order_by(UserThread.create_date.desc())
    ).all()

    captions = [
        {
            "caption": (content[:9] + "..." if len(content) > 12 else content),
            "thread_id": thread_id,
        }
        for thread_id in user_threads
        if (content := model_graph.get_thread_caption(thread_id)["content"])
    ]

    return captions


@router.get("/")
def index(request: Request, session: SessionDep):
    user = request.session.get("user")
    if user:
        captions = get_chats_caption(session, user)
        return templates.TemplateResponse(
            name="index.html",
            context={"request": request, "user": user, "captions": captions},
        )

    return templates.TemplateResponse(name="login.html", context={"request": request})


@router.post("/chat")
async def chat(request: Request, session: SessionDep, body: MessageRequest):
    user = request.session.get("user")
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    thread_id = str(uuid4())
    try:
        # TODO: improve graph db cleanup
        model_graph.respond(body.message, thread_id)
        new_thread = UserThread(user_id=user["email"], thread_id=thread_id)
        session.add(new_thread)
        session.commit()
        session.refresh(new_thread)
    except Exception:
        session.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST)

    return {"response": thread_id}


@router.get("/chat/{thread_id}")
async def get_chat(request: Request, session: SessionDep, thread_id: str):
    user = request.session.get("user")
    if user is None:
        return templates.TemplateResponse(
            name="login.html", context={"request": request}
        )

    user_thread = session.exec(
        select(UserThread).where(thread_id == UserThread.thread_id)
    ).first()

    if user_thread is None:
        return templates.TemplateResponse(
            name="error.html", context={"request": request, "error": "Not found."}
        )

    if user["email"] != user_thread.user_id:
        return templates.TemplateResponse(
            name="error.html", context={"request": request, "error": "Unauthorized."}
        )

    history = model_graph.get_thread(thread_id)
    captions = get_chats_caption(session, user)

    return templates.TemplateResponse(
        name="index.html",
        context={
            "request": request,
            "messages": history,
            "user": user,
            "captions": captions,
        },
    )


@router.get("/chat/next/{thread_id}", response_model=ChunkResponse)
async def get_next_chunk(request: Request, session: SessionDep, thread_id: str):
    user = request.session.get("user")
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    user_stream = streams[thread_id]
    chunk = next(user_stream)
    msg, metadata = chunk

    if "finish_reason" in msg.response_metadata:
        print(msg.response_metadata["finish_reason"])
        for msg, _ in user_stream:
            print(msg.content, type(msg), "=" * 10)
            pass

        del streams[thread_id]
        return ChunkResponse(chunk="", is_finished=True)

    return ChunkResponse(chunk=msg.content, is_finished=False)


@router.post("/chat/{thread_id}", response_model=MessageResponse)
def ask_model(
    request: Request, session: SessionDep, body: MessageRequest, thread_id: str
):
    user = request.session.get("user")
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

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
    # response = model_graph.respond(message, thread_id)
    return MessageResponse(response="")
