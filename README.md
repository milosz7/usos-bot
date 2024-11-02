### USOS-bot
This repository contains code used to build a RAG powered assistant for answering questions related to USOS platform. 
Project is built using Python 3.12.

#### Basic setup

1. Run ```pip install -r requirements.txt```.
2. Create `.env` file in the project root folder using the following template:

```
GROQ_API_KEY=<groq api key>
PINECONE_API_KEY=<pinecone api>
INDEX_NAME=<knowledge base index name in Pinecone>
GOOGLE_CLIENT_ID=<google client id api key console.cloud.google.com>
GOOGLE_CLIENT_SECRET=<google client secret api key console.cloud.google.com>
```

### Fast api Start

1. Run ```uvicorn backend.main:app --reload```


### PostgreSQL

1. Install PostgreSql ```apt install postgresql```
2. Change user ```sudo -i -u postgres```
3. Create database ```createdb usos_bot_db```
4. Enter database ```psql -d usos_bot_db```
5. Check connection info ```\conninfo```
   1. You should get ```You are connected to database "usos_bot_db" as user "postgres" via socket in "/var/run/postgresql" at port "5432".```
6. Create root user ```CREATE USER root WITH PASSWORD 'root';```
7. Add privileges ```GRANT ALL PRIVILEGES ON DATABASE usos_bot_db TO root;```

### Tailwind

1. Install NPM ```sudo apt install npm```
2. Install tailwind ```npm install -D tailwindcss```
3. Run ```npx tailwindcss -i ./frontend/static/css/input.css -o ./frontend/static/css/output.css --watch```