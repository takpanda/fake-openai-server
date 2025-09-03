FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG FOS_USER_ID=fos
ARG FOS_USER_DIR=/opt/fos

ENV PATH=${FOS_USER_DIR}/.local/bin:${PATH}

# Install system dependencies
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt-get update && \
    apt-get install -y \
       curl \
       build-essential \
       cmake pkg-config \
       libprotobuf-dev \
       libsentencepiece-dev \
       libsentencepiece0 \
       libprotobuf32 \
       libprotobuf-c1

# Create user and directories
RUN useradd -u 1001 -s /bin/bash -d ${FOS_USER_DIR} ${FOS_USER_ID} && \
    mkdir -p ${FOS_USER_DIR} && \
    chown -R ${FOS_USER_ID}:${FOS_USER_ID} ${FOS_USER_DIR}

WORKDIR ${FOS_USER_DIR}
USER ${FOS_USER_ID}

# Install uv - use pip as fallback if network issues occur
RUN curl -LsSf https://astral.sh/uv/install.sh | sh || \
    (python3 -m pip install --user uv && ln -sf ~/.local/bin/uv ~/.local/bin/uv)

# Copy Python project files
COPY --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ./pyproject.toml \
    ./uv.lock \
    ./.python-version \
    ./README.md \
    ${FOS_USER_DIR}/

# Install Python dependencies
RUN --mount=type=cache,target=${FOS_USER_DIR}/.cache,uid=1001,gid=1001 \
    ~/.local/bin/uv sync

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

# Prepare cache directory
RUN mkdir -p ${FOS_USER_DIR}/.cache

EXPOSE 8081 8082

# Set default service (can be overridden with environment variable)
ENV SERVICE_TYPE=reranker
ENV HOST=0.0.0.0

ENTRYPOINT ["./entrypoint.sh"]