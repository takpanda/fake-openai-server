# DEPRECATED: This Dockerfile is deprecated.
# Please use Docker/unified-server/Dockerfile for the new unified approach.  
# See README.md for migration instructions.

FROM fake-openai-server/base-server:latest

COPY --chown=fos:fos \
    ./LoggerConfig.py \
    ./reranker-api-server.py /opt/fos/

USER fos
CMD ["uv", "run", "uvicorn", "reranker-api-server:app", "--host", "0.0.0.0", "--port", "8082"]
