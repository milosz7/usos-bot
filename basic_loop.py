from langchain_pinecone import PineconeVectorStore
from langchain_groq import ChatGroq
from typing import Sequence
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import START, StateGraph
from langgraph.graph.message import add_messages
from typing_extensions import Annotated, TypedDict
from langchain_core.documents.base import Document
from dotenv import load_dotenv, find_dotenv
from langchain_huggingface import HuggingFaceEmbeddings
from pinecone import Pinecone
from langchain_core.runnables import RunnablePassthrough
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


def rag_loop(app):
    # hardcoded for now
    config = {"configurable": {"thread_id": "abc123"}}

    while True:
        user_input = input()
        result = app.invoke(dict(input=user_input), config=config)
        print(result["context"])
        print(result["answer"])


def main():
    llm = ChatGroq(model="llama-3.1-70b-versatile", temperature=0)

    print("Loading embeddings...")
    embeddings = HuggingFaceEmbeddings(model_name="jinaai/jina-embeddings-v3",
                                       model_kwargs={"trust_remote_code": True},
                                       encode_kwargs={"task": "retrieval.query"})

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

    rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)

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

    workflow = StateGraph(state_schema=State)
    workflow.add_edge(START, "model")
    workflow.add_node("model", call_model)

    memory = MemorySaver()
    app = workflow.compile(checkpointer=memory)
    print("Starting main loop...")

    rag_loop(app)


if __name__ == "__main__":
    os.environ["TOKENIZERS_PARALLELISM"] = "false"
    load_dotenv(find_dotenv())
    main()