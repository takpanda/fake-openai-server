from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from sentence_transformers import CrossEncoder
import logging
import logging.config
from logging import Logger
from LoggerConfig import LoggerConfig

logging.config.dictConfig(
    LoggerConfig.generate(log_file=None, stdout=True),
)
logger: Logger = logging.getLogger("rerank-api-server")
logger.setLevel(logging.INFO)

app = FastAPI()
reranker = CrossEncoder("cl-nagoya/ruri-reranker-large")


class ReRankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]


@app.post("/v1/rerank")
def rerank(request: ReRankRequest):
    logger.info(f"Received request: {request}")
    pairs = [(request.query, doc) for doc in request.documents]
    scores = reranker.predict(pairs)
    ranked = sorted(
        zip(request.documents, scores, range(len(scores))),
        key=lambda x: x[1],
        reverse=True,
    )
    results = []
    for doc, score, idx in ranked:
        results.append(
            {
                "index": idx,
                "document": {"text": doc},
                "relevance_score": float(score),
            }
        )
    res = {
        "results": results,
        "model": request.model,
        "usage": {"total_tokens": 0},
    }
    logger.debug(f"Response: {res}")
    return res
