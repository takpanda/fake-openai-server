from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Union
from sentence_transformers import SentenceTransformer
import logging
import logging.config
from logging import Logger
from LoggerConfig import LoggerConfig

logging.config.dictConfig(
    LoggerConfig.generate(log_file=None, stdout=True),
)
logger: Logger = logging.getLogger("embeddings-api-server")
logger.setLevel(logging.INFO)

app = FastAPI()
embedder = SentenceTransformer("cl-nagoya/ruri-large")


class EmbeddingRequest(BaseModel):
    model: str
    input: Union[str, List[str]]
    encoding_format: str = "float"


@app.post("/v1/embeddings")
def embeddings(request: EmbeddingRequest):
    logger.info(f"Received request: {request}")
    
    # Ensure input is a list
    if isinstance(request.input, str):
        texts = [request.input]
    else:
        texts = request.input
    
    # Generate embeddings
    embeddings = embedder.encode(texts, convert_to_tensor=False)
    
    # Format response according to OpenAI API
    data = []
    for i, embedding in enumerate(embeddings):
        data.append({
            "object": "embedding",
            "index": i,
            "embedding": embedding.tolist()
        })
    
    res = {
        "object": "list",
        "data": data,
        "model": request.model,
        "usage": {
            "prompt_tokens": sum(len(text.split()) for text in texts),
            "total_tokens": sum(len(text.split()) for text in texts)
        }
    }
    
    logger.debug(f"Response: {res}")
    return res