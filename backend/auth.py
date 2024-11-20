from dotenv import load_dotenv, find_dotenv
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi import Depends, status, HTTPException
import firebase_admin
from firebase_admin import credentials, auth
import os

load_dotenv(find_dotenv())
# TODO: extract firebase config filename to .env (secrets folder?)
config_path = os.path.join(os.getcwd(), "usos-bot-firebase-adminsdk.json")
creds = credentials.Certificate(config_path)
firebase_admin.initialize_app(creds)

security = HTTPBearer()


def verify_token(auth_credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = auth_credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=e)
