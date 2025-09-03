#!/bin/bash

echo "Building and testing fake-openai-server unified Docker image..."

# Build the unified image
echo "🔨 Building unified Docker image..."
docker build -f Docker/unified-server/Dockerfile -t fake-openai-server/unified-server:latest . || {
    echo "❌ Failed to build Docker image"
    exit 1
}

echo "✅ Docker image built successfully"

# Test entrypoint script validation
echo "🧪 Testing entrypoint script..."
docker run --rm fake-openai-server/unified-server:latest --help || {
    echo "❌ Entrypoint script test failed"
    exit 1
}

echo "✅ Entrypoint script validation passed"

# Test with environment variables
echo "🧪 Testing SERVICE_TYPE environment variable..."
docker run --rm -e SERVICE_TYPE=invalid fake-openai-server/unified-server:latest && {
    echo "❌ Should have failed with invalid service type"
    exit 1
}

echo "✅ Environment variable validation passed"

echo ""
echo "🎉 Basic validation tests passed!"
echo "📝 Note: Full functionality tests require internet access for model downloads"
echo ""
echo "To test the services manually:"
echo "  # Start embeddings server:"
echo "  docker run -p 8081:8081 -e SERVICE_TYPE=embeddings fake-openai-server/unified-server:latest"
echo ""
echo "  # Start reranker server:"
echo "  docker run -p 8082:8082 -e SERVICE_TYPE=reranker fake-openai-server/unified-server:latest"
echo ""
echo "  # Or use docker-compose:"
echo "  docker-compose up -d"