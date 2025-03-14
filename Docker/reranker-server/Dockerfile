FROM fake-openai-server/base-server:latest

COPY --chown=fos:fos \
    ./LoggerConfig.py \
    ./reranker-api-server.py /opt/fos/

USER fos
CMD ["uv", "run", "uvicorn", "reranker-api-server:app", "--host", "0.0.0.0", "--port", "8082"]
