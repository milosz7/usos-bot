### USOS-bot

This repository contains code used to build a RAG powered assistant for
answering questions related to USOS platform. Project is built using Python
3.12.

#### Basic setup

1. Run `pip install -r requirements.txt`.
2. Create `.env` file in the project root folder using the following template:

```
GROQ_API_KEY=<groq api key>
PINECONE_API_KEY=<pinecone api>
INDEX_NAME=<knowledge base index name in Pinecone>
GOOGLE_CLIENT_ID=<google client id api key console.cloud.google.com>
GOOGLE_CLIENT_SECRET=<google client secret api key console.cloud.google.com>
DB_CONN_STR="postgresql://[user]:[password]@[address]:[port]/postgres?sslmode=disable"
```

### Fast api Start

1. Run `uvicorn backend.main:app --reload`

### PostgreSQL

1. Install PostgreSql `apt install postgresql`
2. Change user `sudo -i -u postgres`
3. Create database `createdb usos_bot_db`
4. Enter database `psql -d usos_bot_db`
5. Check connection info `\conninfo`
   1. You should get
      `You are connected to database "usos_bot_db" as user "postgres" via socket in "/var/run/postgresql" at port "5432".`
6. Create root user `CREATE USER root WITH PASSWORD 'root';`
7. Add privileges `GRANT ALL PRIVILEGES ON DATABASE usos_bot_db TO root;`

### Tailwind

1. Install NPM `sudo apt install npm`
2. Install tailwind `npm install -D tailwindcss`
3. Run
   `npx tailwindcss -i ./frontend/static/css/input.css -o ./frontend/static/css/output.css --watch`

### Flutter Firebase

1. Install
   [Google Firebase CLI](https://firebase.google.com/docs/cli?authuser=0&hl=pl#setup_update_cli).
2. Enable Google login for your project on the Firebase Cloud.
3. Configure allowed URI for the oAuth in the Google Cloud console.
4. Setup Google Firebase for the project
   [(setup)](https://firebase.google.com/docs/flutter/setup?authuser=0&hl=pl&platform=ios).
5. In the flutter project root run `flutter pub add firebase_auth`

You should have the following files generated in the root directory:
```
google-services.json
GoogleService-Info.plist
firebase.json
firebase_options.dart
```

### FastApi Firebase

1. Do all the steps in the previous point.
2. Enter [Firebase Service Account](https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk)
3. Select previously created project
4. Generate new private key
5. Copy content of the downloaded file to the "usos-bot-firebase-adminsdk.json" file

### TODO
- clean up flutter post-compilation files