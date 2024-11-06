from langchain_pinecone import PineconeVectorStore
from langchain_groq import ChatGroq
from typing import Sequence
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.graph import START, StateGraph
from langgraph.graph.message import add_messages
from typing_extensions import Annotated, TypedDict
from langchain_core.documents.base import Document
from langchain_huggingface import HuggingFaceEmbeddings
from pinecone import Pinecone
from backend.db.DatabaseConnector import DatabaseConnector
import os


class State(TypedDict):
    input: str
    chat_history: Annotated[Sequence[BaseMessage], add_messages]
    context: str
    answer: str


def extract_text_from_retrieval(docs: list[Document]):
    for doc in docs:
        doc.page_content = doc.metadata["orig_text"]
    return docs


class RAGModel:
    def __init__(self):
        llm = ChatGroq(model="llama-3.1-70b-versatile", temperature=0, streaming=True)

        print("Loading embeddings...")
        embeddings = HuggingFaceEmbeddings(
            model_name="jinaai/jina-embeddings-v3",
            model_kwargs={"trust_remote_code": True},
            encode_kwargs={"task": "retrieval.query"},
        )

        print("Loading vector store...")
        pc = Pinecone(api_key=os.environ.get("PINECONE_API_KEY"))
        index = pc.Index(os.environ.get("INDEX_NAME"))

        vectorstore = PineconeVectorStore(index=index, embedding=embeddings)
        retriever = vectorstore.as_retriever(search_kwargs=dict(k=2))
        retriever = retriever | extract_text_from_retrieval

        print("Building app...")

        contextualize_q_system_prompt = (
            "Given a chat history and the latest user question "
            "which might reference context in the chat history, "
            "formulate a standalone question in Polish language which can be understood "
            "without the chat history. Do NOT answer the question, "
            "just reformulate it if needed and otherwise return it as is."
        )

        contextualize_q_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", contextualize_q_system_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )
        history_aware_retriever = create_history_aware_retriever(
            llm, retriever, contextualize_q_prompt
        )

        system_prompt = (
            "You are an assistant for question-answering tasks. "
            "Use the following pieces of retrieved context to answer "
            "the question. If you don't know the answer, say that you "
            "don't know. Keep the answer concise."
            "Always output only the final answer."
            "Always answer in polish language."
            "\n\n"
            "{context}"
        )

        qa_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", system_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )
        question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)

        rag_chain = create_retrieval_chain(
            history_aware_retriever, question_answer_chain
        )

        def call_model(state: State):
            response = rag_chain.invoke(state)
            return {
                "chat_history": [
                    HumanMessage(state["input"]),
                    AIMessage(response["answer"]),
                ],
                "context": response["context"],
                "answer": response["answer"],
            }

        self.connector = DatabaseConnector(os.environ.get("DB_CONN_STR"))
        self.connector.connect()
        self.checkpointer = self.connector.get_checkpointer()

        workflow = StateGraph(state_schema=State)
        workflow.add_edge(START, "model")
        workflow.add_node("model", call_model)

        self.app = workflow.compile(checkpointer=self.checkpointer)
        print("Starting main loop...")

    @staticmethod
    def _get_config(thread_id):
        return {"configurable": {"thread_id": thread_id}}

    def get_thread(self, thread_id):
        config = self._get_config(thread_id)
        checkpoint = self.checkpointer.get(config)
        chat_history = checkpoint["channel_values"]["chat_history"]
        chat_history = [
            {
                "author": "human" if isinstance(msg, HumanMessage) else "ai",
                "content": msg.content,
            }
            for msg in chat_history
        ]

        return chat_history

    def get_thread_caption(self, thread_id):
        config = self._get_config(thread_id)
        checkpoint = self.checkpointer.get(config)
        chat_history = checkpoint["channel_values"]["chat_history"]

        first_message = chat_history[0] if chat_history else None
        if first_message:
            first_message = {
                "author": "human" if isinstance(first_message, HumanMessage) else "ai",
                "content": first_message.content,
            }

        return first_message

    def respond(self, message, thread_id):
        config = self._get_config(thread_id)
        result = self.app.invoke(dict(input=message), config=config)
        return result["answer"]

    def respond_stream(self, message, thread_id):
        config = self._get_config(thread_id)
        stream = self.app.stream(
            dict(input=message), config=config, stream_mode="messages"
        )
        # TODO: Rewrite the RAG pipeline so this is not necessary. (one streaming, one synchronous)
        for msg, _ in stream:
            if "finish_reason" in msg.response_metadata:
                break
            pass
        return stream
