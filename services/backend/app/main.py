from fastapi import FastAPI
from langfuse import Langfuse

# Инициализация Langfuse
langfuse = Langfuse(
    secret_key=os.getenv("LANGFUSE_SECRET_KEY"),
    public_key=os.getenv("LANGFUSE_PUBLIC_KEY"),
    host="http://langfuse-server:8080"  
)

# Пример трассировки
trace = langfuse.trace(
    name="test-trace",
    user_id="user-123",
)

# Логирование запроса/ответа модели
trace.generation(
    name="llm-call",
    input={"prompt": "Hello"},
    output={"response": "Hi there!"}
)

app = FastAPI()


@app.get("/")
def read_root():
    return {"message": "Hello from Backend!!!"}
