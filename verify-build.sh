#!/bin/bash
# Quick verification script

echo "🔍 LLMs OS Production - Verification Test"
echo "=========================================="
echo

# Check if image exists
if docker images llms-os:production-v2.0 | grep -q llms-os; then
    echo "✅ Image found: llms-os:production-v2.0"
    docker images llms-os:production-v2.0 --format "   Size: {{.Size}}"
else
    echo "❌ Image not found"
    exit 1
fi

echo

# Test 1: Basic workflow
echo "Test 1: Running demo workflow..."
if docker run --rm llms-os:production-v2.0 /app/workflows/demo.yaml 2>&1 | grep -q "System operational"; then
    echo "✅ Demo workflow executed successfully"
else
    echo "❌ Demo workflow failed"
    exit 1
fi

echo

# Test 2: List available actions
echo "Test 2: Checking available actions..."
docker run --rm --entrypoint /bin/sh llms-os:production-v2.0 -c "python3 -c \"from LLMs_OS.registry import list_actions; actions = list_actions(); print(f'✅ Found {len(actions)} actions: {actions}')\""

echo

# Test 3: Health check
echo "Test 3: Health check..."
if docker run --rm --entrypoint /bin/sh llms-os:production-v2.0 -c "python3 -c 'import LLMs_OS; print(\"✅ Package imports successfully\")'"; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
    exit 1
fi

echo
echo "=========================================="
echo "✅ All verification tests passed!"
echo "=========================================="
echo
echo "Ready to use! Try these commands:"
echo "  docker run --rm llms-os:production-v2.0 /app/workflows/demo.yaml"
echo "  make deploy (if using Makefile)"
echo "  docker-compose -f docker-compose.production.yml up -d"
