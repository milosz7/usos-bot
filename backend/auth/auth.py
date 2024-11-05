from fastapi import FastAPI
from fastapi.templating import Jinja2Templates
from starlette.requests import Request
from starlette.responses import RedirectResponse
from starlette.middleware.sessions import SessionMiddleware
from authlib.integrations.starlette_client import OAuth, OAuthError
from fastapi.staticfiles import StaticFiles
from fastapi import APIRouter
from dotenv import load_dotenv, find_dotenv
import os

load_dotenv(find_dotenv())
# Replace these with your own values from the Google Developer Console
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = os.environ.get("GOOGLE_CLIENT_SECRET")

oauth = OAuth()
oauth.register(
    name="google",
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_id=GOOGLE_CLIENT_ID,
    client_secret=GOOGLE_CLIENT_SECRET,
    client_kwargs={
        "scope": "email openid profile",
        "redirect_url": "http://localhost:8000/auth",
    },
)
router = APIRouter()

templates = Jinja2Templates(directory="frontend/templates")


@router.get("/login")
async def login(request: Request):
    url = request.url_for("auth")
    return await oauth.google.authorize_redirect(request, url)


@router.get("/auth")
async def auth(request: Request):
    try:
        token = await oauth.google.authorize_access_token(request)
    except OAuthError as e:
        return templates.TemplateResponse(
            name="error.html", context={"request": request, "error": e.error}
        )
    user = token.get("userinfo")
    if user:
        request.session["user"] = dict(user)
    return RedirectResponse("/")


@router.get("/logout")
def logout(request: Request):
    request.session.pop("user")
    request.session.clear()
    return RedirectResponse("/")
