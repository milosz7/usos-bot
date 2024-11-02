from fastapi import APIRouter
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from fastapi import Request
from pydantic import BaseModel
from backend.routers.raq import response
from fastapi.staticfiles import StaticFiles

router = APIRouter()

templates = Jinja2Templates(directory="frontend/templates")

# Chat request and response models
class MessageRequest(BaseModel):
    thread_id: str
    message: str

class MessageResponse(BaseModel):
    response: str

# Load a sample chatbot model or use OpenAI's API (example)
@router.post("/chat", response_model=MessageResponse)
async def chat(message_request: MessageRequest):
    user_message = message_request.message
    thread_id = message_request.thread_id
    # Dummy response for demonstration purposes
    chatbot_response = response(user_message, thread_id)
    return MessageResponse(response=chatbot_response)


# Serve the HTML frontend
@router.get("/hi", response_class=HTMLResponse)
async def get_chat(request: Request):
    return templates.TemplateResponse(
        name="chat.html",
        context={"request": request}
    )