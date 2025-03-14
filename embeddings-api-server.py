from fastapi import FastAPI
from pydantic import BaseModel
from typing import Union
from sentence_transformers import SentenceTransformer

import logging
import logging.config
from logging import Logger
from LoggerConfig import LoggerConfig

logging.config.dictConfig(
    LoggerConfig.generate(log_file=None, stdout=True),
)
logger: Logger = logging.getLogger("embedding-api-server")
logger.setLevel(logging.INFO)

app = FastAPI()
model = SentenceTransformer("cl-nagoya/ruri-large")


class EmbeddingRequest(BaseModel):
    model: str
    input: Union[str, list[str]]


@app.post("/v1/embeddings")
def create_embedding(request: EmbeddingRequest):
    logger.info(f"Received request: {request}")
    texts = [request.input] if isinstance(request.input, str) else request.input
    embeddings = model.encode(texts, convert_to_numpy=True).tolist()
    data = []
    for idx, emb in enumerate(embeddings):
        data.append({"object": "embedding", "embedding": emb, "index": idx})
    res = {
        "object": "list",
        "data": data,
        "model": request.model,
        "usage": {"prompt_tokens": 0, "total_tokens": 0},
    }
    logger.debug(f"Response: {res}")
    return res
