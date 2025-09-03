FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG FOS_USER_ID=fos
ARG FOS_USER_DIR=/opt/fos

# Install system dependencies
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt-get update && \
    apt-get install -y \
       python3 \
       python3-pip \
       python3-venv \
       curl \
       libsentencepiece0 \
       libprotobuf32 \
       libprotobuf-c1 && \
    apt-get clean

# Create user and directories
RUN useradd -u 1001 -s /bin/bash -d ${FOS_USER_DIR} ${FOS_USER_ID} && \
    mkdir -p ${FOS_USER_DIR} && \
    chown -R ${FOS_USER_ID}:${FOS_USER_ID} ${FOS_USER_DIR}

WORKDIR ${FOS_USER_DIR}
USER ${FOS_USER_ID}

# Create virtual environment and install dependencies
RUN python3 -m venv .venv
ENV PATH=${FOS_USER_DIR}/.venv/bin:${PATH}

# Install Python dependencies directly
RUN --mount=type=cache,target=${FOS_USER_DIR}/.cache,uid=1001,gid=1001 \
    pip install --cache-dir=${FOS_USER_DIR}/.cache \
        --trusted-host pypi.org \
        --trusted-host pypi.python.org \
        --trusted-host files.pythonhosted.org \
        fastapi>=0.115.8 \
        fugashi>=1.4.0 \
        protobuf>=5.29.2 \
        pydantic>=2.10.6 \
        sentence-transformers>=3.4.1 \
        sentencepiece>=0.2.0 \
        unidic-lite>=1.0.8 \
        uvicorn>=0.34.0

# Copy application files
COPY --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ./LoggerConfig.py \
    ./embeddings-api-server.py \
    ./reranker-api-server.py \
    ${FOS_USER_DIR}/

# Create entrypoint script
COPY --chown=${FOS_USER_ID}:${FOS_USER_ID} --chmod=755 \
    ./Docker/unified-server/entrypoint.sh \
    ${FOS_USER_DIR}/entrypoint.sh

# Prepare cache directory for models
RUN mkdir -p ${FOS_USER_DIR}/.cache/huggingface

EXPOSE 8081 8082

# Set default service (can be overridden with environment variable)
ENV SERVICE_TYPE=reranker
ENV HOST=0.0.0.0

# Set HuggingFace cache directory
ENV HF_HOME=${FOS_USER_DIR}/.cache/huggingface

ENTRYPOINT ["./entrypoint.sh"]