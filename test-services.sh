#!/bin/bash

set -e

echo "Testing fake-openai-server unified image..."

# Test embeddings server
echo "Testing embeddings server (port 8081)..."
curl -f -v http://127.0.0.1:8081/v1/embeddings \
    -H 'Content-Type: application/json' \
    --data-raw '{
        "model": "cl-nagoya/ruri-large",
        "input": ["文章: テストテキストです。"]
    }' || {
    echo "❌ Embeddings server test failed"
    exit 1
}

echo "✅ Embeddings server test passed"
echo ""

# Test reranker server
echo "Testing reranker server (port 8082)..."
curl -f -v http://127.0.0.1:8082/v1/rerank \
    -H 'Content-Type: application/json' \
    --data-raw '{
        "model": "cl-nagoya/ruri-v3-reranker-310m",
        "query": "質問文",
        "documents": ["文書1", "文書2", "文書3"]
    }' || {
    echo "❌ Reranker server test failed"
    exit 1
}

echo "✅ Reranker server test passed"
echo ""
echo "🎉 All tests passed! Both services are working correctly."