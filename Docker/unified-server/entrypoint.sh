#!/bin/bash

set -e

# Default values
SERVICE_TYPE=${SERVICE_TYPE:-reranker}
HOST=${HOST:-0.0.0.0}

# Function to start embeddings server
start_embeddings() {
    echo "Starting embeddings server on port 8081..."
    exec uv run uvicorn embeddings-api-server:app --host ${HOST} --port 8081
}

# Function to start reranker server
start_reranker() {
    echo "Starting reranker server on port 8082..."
    exec uv run uvicorn reranker-api-server:app --host ${HOST} --port 8082
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [embeddings|reranker]"
    echo "Or set SERVICE_TYPE environment variable to 'embeddings' or 'reranker'"
    echo ""
    echo "Environment variables:"
    echo "  SERVICE_TYPE: Service to start (embeddings or reranker) [default: reranker]"
    echo "  HOST: Host to bind to [default: 0.0.0.0]"
    echo ""
    echo "Examples:"
    echo "  SERVICE_TYPE=embeddings $0"
    echo "  SERVICE_TYPE=reranker $0"
    echo "  $0 embeddings"
    echo "  $0 reranker"
}

# Check if argument is provided, override environment variable
if [ $# -gt 0 ]; then
    SERVICE_TYPE=$1
fi

# Start the appropriate service
case "$SERVICE_TYPE" in
    embeddings)
        start_embeddings
        ;;
    reranker)
        start_reranker
        ;;
    *)
        echo "Error: Unknown service type '$SERVICE_TYPE'"
        echo ""
        show_usage
        exit 1
        ;;
esac