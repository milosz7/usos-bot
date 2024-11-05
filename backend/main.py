from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

from fastapi import FastAPI, Depends
from fastapi.staticfiles import StaticFiles
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from fastapi.templating import Jinja2Templates
from starlette.requests import Request
from backend.routers import chat
from backend.auth import auth
import os
from sqlmodel import SQLModel
from contextlib import asynccontextmanager
from backend.db.helpers import engine
from starlette.responses import RedirectResponse

os.environ["TOKENIZERS_PARALLELISM"] = "false"


@asynccontextmanager
async def lifespan(_: FastAPI):
    SQLModel.metadata.create_all(engine)
    yield


origins = ["http://localhost:20002", "http://127.0.0.1:20002"]
app = FastAPI(lifespan=lifespan)
app.add_middleware(SessionMiddleware, secret_key="add any string...")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/static", StaticFiles(directory="frontend/static"), name="static")

app.include_router(chat.router, tags=["chat"])
app.include_router(auth.router, tags=["auth"])

templates = Jinja2Templates(directory="frontend/templates")


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return RedirectResponse(url="/static/icons/favicon.ico")
