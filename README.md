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
```