# fake-openai-server

fake-openai-server is a Python application that provides OpenAI API-compatible Text embeddings and Rerank services using Japanese language models. It serves two endpoints: Text embeddings (port 8081) using `cl-nagoya/ruri-large` and Rerank (port 8082) using `cl-nagoya/ruri-reranker-large`.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap Dependencies and Build
**CRITICAL: Internet access required** - Models must be downloaded from HuggingFace on first run.

#### System Dependencies Installation
```bash
sudo apt update
sudo apt install -y build-essential cmake pkg-config libprotobuf-dev libsentencepiece-dev
```

#### Python Package Manager Setup
Install uv (Python package manager):
```bash
# Primary method (requires internet access to astral.sh)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Fallback method if curl fails
pip install uv

# Ensure uv is in PATH
export PATH=$HOME/.local/bin:$PATH
```

#### Python Dependencies Installation
```bash
uv sync
```
**TIMING**: Takes approximately 40 seconds. NEVER CANCEL. Set timeout to 120+ seconds.

### Running the Application

#### Option 1: Direct Python Execution (Recommended for Development)
**CRITICAL**: First run will download large models (~1.5GB each) - may take 10-30 minutes depending on internet speed.

Start embeddings server:
```bash
export PATH=$HOME/.local/bin:$PATH
uv run uvicorn embeddings-api-server:app --host 0.0.0.0 --port 8081
```

Start rerank server (in separate terminal):
```bash
export PATH=$HOME/.local/bin:$PATH
uv run uvicorn reranker-api-server:app --host 0.0.0.0 --port 8082
```

**FIRST RUN TIMING**: Model download takes 10-30 minutes per server. NEVER CANCEL. Set timeout to 2400+ seconds (40 minutes).
**SUBSEQUENT RUNS**: Start in 5-10 seconds using cached models.

#### Option 2: Docker Compose (Production)
```bash
docker compose build  # Takes 5-15 minutes. NEVER CANCEL. Set timeout to 1200+ seconds.
docker compose up -d
```

**CRITICAL REQUIREMENTS for Docker**:
- NVIDIA GPU support (optional but recommended)
- Internet access to download base images and models
- Build process includes model download, total time 15-45 minutes

## Validation

### API Testing - Text Embeddings
Test embeddings server (port 8081):
```bash
curl -v http://127.0.0.1:8081/v1/embeddings -H 'Content-Type: application/json' --data-raw '{
    "model": "cl-nagoya/ruri-large",
    "input": ["文章: テストテキストです。"]
}'
```

Expected response: JSON with `data` array containing embeddings (768-dimensional vectors).

### API Testing - Rerank
Test rerank server (port 8082):
```bash
curl -v http://127.0.0.1:8082/v1/rerank -H 'Content-Type: application/json' --data-raw '{
    "model": "cl-nagoya/ruri-reranker-large",
    "query": "質問文",
    "documents": ["文書1", "文書2", "文書3"]
}'
```

Expected response: JSON with `results` array containing ranked documents with relevance scores.

### Manual Validation Requirements
**ALWAYS** test both APIs after making changes:
1. Verify both servers start without errors
2. Test both API endpoints with sample data
3. Confirm responses match expected OpenAI-compatible format
4. Check that models load successfully (watch logs for model loading messages)

## Troubleshooting

### Common Issues
- **Model download failures**: Ensure internet connectivity to huggingface.co
- **"No NVIDIA GPU detected"**: Application works on CPU but slower performance
- **Build failures**: Verify all system dependencies installed correctly
- **Port conflicts**: Ensure ports 8081 and 8082 are available

### Environment Limitations
- **No internet access**: Application cannot download models on first run
- **No GPU**: Models run on CPU with reduced performance
- **Memory requirements**: Each model requires ~2GB RAM minimum

## Development Workflow

### Key Files and Structure
```
├── embeddings-api-server.py    # Text embeddings FastAPI server
├── reranker-api-server.py      # Rerank FastAPI server  
├── LoggerConfig.py             # Logging configuration
├── pyproject.toml              # Python dependencies (uv format)
├── compose.yaml                # Docker Compose configuration
└── Docker/                     # Dockerfiles for multi-stage builds
    ├── base-server/            # Base image with Python environment
    ├── embeddings-server/      # Embeddings-specific container
    └── reranker-server/        # Rerank-specific container
```

### Making Changes
1. **Always run validation steps** after code changes
2. **Test both servers** - changes may affect both endpoints
3. **Monitor logs** during startup for model loading progress
4. **Restart servers** after code changes (no hot reload configured)

### Dependencies Management
- Use `uv add [package]` to add new dependencies
- Run `uv sync` after dependency changes (40 seconds, set 120+ second timeout)
- Both `pyproject.toml` and `uv.lock` must be committed

## Common Tasks Reference

### Repository Root Contents
```
.git/                  # Git repository data
.github/              # GitHub configuration (this file)
.gitignore            # Git ignore rules
.python-version       # Python version specification (3.13)
Docker/               # Docker build configurations
LICENSE               # License file
LoggerConfig.py       # Logging configuration utility
README.md             # Documentation (Japanese)
compose.yaml          # Docker Compose services definition
embeddings-api-server.py  # Main embeddings server
pyproject.toml        # Python project configuration
reranker-api-server.py    # Main rerank server  
uv.lock               # Locked dependency versions
```

### Key Configuration Details
- **Python version**: 3.13 (specified in .python-version)
- **Package manager**: uv (faster than pip)
- **Web framework**: FastAPI with uvicorn
- **ML framework**: sentence-transformers
- **Models**: Japanese language models from cl-nagoya
- **API compatibility**: OpenAI embeddings and rerank API format