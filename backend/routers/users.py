from fastapi import APIRouter

router = APIRouter()

@router.get("/users")
async def get_users():
    return {"message": "List of users"}

@router.post("/users")
async def create_user(user: dict):
    return {"message": "User created", "user": user}