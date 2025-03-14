FROM fake-openai-server/base-server:latest

COPY --chown=fos:fos \
    ./LoggerConfig.py \
    ./embeddings-api-server.py /opt/fos/


CMD ["uv", "run", "uvicorn", "embeddings-api-server:app", "--host", "0.0.0.0", "--port", "8081"]
