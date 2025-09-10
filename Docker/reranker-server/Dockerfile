FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04 AS builder

ARG FOS_USER_ID=fos
ARG FOS_USER_DIR=/opt/fos

ENV PATH=${FOS_USER_DIR}/.cargo/bin:${FOS_USER_DIR}/.local/bin:${PATH}

# curl: uvのインストール
# その他: sentencepieceのビルド
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt-get update \
    && apt-get install -y \
       curl \
       build-essential \
       cmake pkg-config \
       libprotobuf-dev \
       libsentencepiece-dev

RUN useradd -u 1001 -s /bin/bash -d ${FOS_USER_DIR} ${FOS_USER_ID} && \
    mkdir -p ${FOS_USER_DIR} && \
    chown -R ${FOS_USER_ID}:${FOS_USER_ID} ${FOS_USER_DIR}

WORKDIR ${FOS_USER_DIR}
USER ${FOS_USER_ID}
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc

COPY --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ./pyproject.toml \
    ./uv.lock \
    ./.python-version \
    ./README.md \
    ${FOS_USER_DIR}/

RUN --mount=type=cache,target=${FOS_USER_DIR}/.cache,uid=1001,gid=1001 \
    ~/.local/bin/uv sync


#-----------
# Reranker Server
#-----------
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG FOS_USER_ID=fos
ARG FOS_USER_DIR=/opt/fos

ENV PATH=${FOS_USER_DIR}/.cargo/bin:${FOS_USER_DIR}/.local/bin:${PATH}

# sentencepieceの利用に必要なものをインストール
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt-get update \
    && apt-get install -y libsentencepiece0 libprotobuf23 libprotobuf-c1

RUN useradd -u 1001 -s /bin/bash -d ${FOS_USER_DIR} ${FOS_USER_ID} && \
    mkdir -p ${FOS_USER_DIR} && \
    chown -R ${FOS_USER_ID}:${FOS_USER_ID} ${FOS_USER_DIR}

WORKDIR ${FOS_USER_DIR}
USER ${FOS_USER_ID}

# Copy built environment from builder stage
COPY --from=builder --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ${FOS_USER_DIR}/.local \
    ${FOS_USER_DIR}/.local

COPY --from=builder --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ${FOS_USER_DIR}/.venv \
    ${FOS_USER_DIR}/.venv

COPY --from=builder --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ${FOS_USER_DIR}/.config \
    ${FOS_USER_DIR}/.config

COPY --from=builder --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ${FOS_USER_DIR}/pyproject.toml \
    ${FOS_USER_DIR}/uv.lock \
    ${FOS_USER_DIR}/.python-version \
    ${FOS_USER_DIR}/

# Copy reranker application files
COPY --chown=${FOS_USER_ID}:${FOS_USER_ID} \
    ./LoggerConfig.py \
    ./reranker-api-server.py \
    ${FOS_USER_DIR}/

RUN mkdir -p ${FOS_USER_DIR}/.cache

EXPOSE 8082

CMD ["uv", "run", "uvicorn", "reranker-api-server:app", "--host", "0.0.0.0", "--port", "8082"]
