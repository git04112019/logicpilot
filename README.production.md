# LLMs OS Production - Quick Start Guide

## 🚀 Production-Ready LLMs OS with LogicPilot Integration

This is a production-grade Docker build combining **LogicPilot** Alpine-based architecture with the powerful **LLMs OS** workflow automation system from https://github.com/test01082023/llms-os.

## ✨ Features

- **Ultra-Light**: Alpine Linux base (~150MB total image size)
- **Production-Ready**: Multi-stage builds, non-root user, health checks
- **Workflow Automation**: YAML-based workflow definitions
- **AI Integration**: Built-in OpenAI/Anthropic API support with mock API for testing
- **Monitoring Ready**: Prometheus & Grafana integration
- **Security Hardened**: Non-root execution, minimal attack surface
- **Fast Build**: Optimized layer caching

## 📦 What's Included

### Built-in Actions
- `print_message` - Formatted console output with colors
- `chat_completion` - LLM API calls (OpenRouter compatible)
- `http_request` - HTTP client for API calls
- `file_read` / `file_write` - File operations

### Components
- **LLMs OS Engine**: Core workflow execution engine
- **Mock API**: Flask-based OpenRouter API simulator
- **Monitoring**: Optional Prometheus + Grafana stack
- **CLI**: Command-line interface for workflow execution

## 🚀 Quick Start

### Option 1: Simple Build & Run

```bash
# Make build script executable
chmod +x build-production.sh

# Build the image
./build-production.sh

# Run demo workflow
docker run --rm llms-os:production-v2.0 /app/workflows/demo.yaml
```

### Option 2: Full Stack with Docker Compose

```bash
# Setup directories
make setup

# Build and start all services
make deploy

# Or manually:
docker-compose -f docker-compose.production.yml up -d

# Check health
make health

# View logs
make logs
```

### Option 3: With Monitoring

```bash
# Start with Prometheus & Grafana
make run-with-monitoring

# Access dashboards:
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

## 📝 Running Workflows

### Run Demo Workflow

```bash
# Using make
make run-workflow WORKFLOW=/app/workflows/demo.yaml

# Using docker-compose
docker-compose -f docker-compose.production.yml run --rm llms-os /app/workflows/demo.yaml

# Direct docker run
docker run --rm llms-os:production-v2.0 /app/workflows/demo.yaml
```

### Create Custom Workflow

Create `workflows/my-workflow.yaml`:

```yaml
metadata:
  title: "My Custom Workflow"
  version: "1.0.0"

tasks:
  - action: print_message
    message: "🎉 Starting my workflow"
    style: success
  
  - action: http_request
    url: "https://api.github.com/users/octocat"
    method: GET
    save_as: github_user
  
  - action: print_message
    message: "User: {{ github_user.json.name }}"
    style: info
  
  - action: chat_completion
    model: "gpt-3.5-turbo"
    messages:
      - role: user
        content: "Summarize in one sentence: AI workflows"
    save_as: summary
  
  - action: print_message
    message: "{{ summary.content }}"
    style: success
```

Run it:
```bash
docker-compose -f docker-compose.production.yml run --rm \
  -v $(pwd)/workflows:/app/workflows:ro \
  llms-os /app/workflows/my-workflow.yaml
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│  Dockerfile.llms-os.alpine (150MB)          │
│  ┌───────────────────────────────────────┐  │
│  │ Stage 1: Base (Alpine 3.19 + Python) │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │ Stage 2: Builder                      │  │
│  │  - Install dependencies               │  │
│  │  - Create LLMs_OS package             │  │
│  │  - Build actions & workflows          │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │ Stage 3: Final (Non-root, Minimal)   │  │
│  │  - Copy only runtime files            │  │
│  │  - Health checks enabled              │  │
│  │  - Volumes for data persistence       │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## 🔧 Development

### Get Shell Access

```bash
# Using make
make shell

# Using docker
docker run --rm -it llms-os:production-v2.0 /bin/sh
```

### View Logs

```bash
# All services
make logs

# Just LLMs OS
make logs-llms

# Just Mock API
make logs-api
```

### Rebuild

```bash
# With cache
make build

# Without cache
make build-no-cache
```

## 🔐 Security Features

- ✅ Multi-stage build (minimal final image)
- ✅ Non-root user (appuser:1000)
- ✅ No package cache in final image
- ✅ Read-only root filesystem compatible
- ✅ Health checks enabled
- ✅ Minimal attack surface (Alpine base)
- ✅ No unnecessary build tools in production

## 📊 Monitoring

### Enable Monitoring Stack

```bash
docker-compose -f docker-compose.production.yml --profile monitoring up -d
```

Access:
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

### Available Metrics

- Workflow execution time
- Action success/failure rates
- API call latency
- System resource usage

## 🧪 Testing

### Run Tests

```bash
make test
```

### Manual Testing

```bash
# Test help command
docker run --rm llms-os:production-v2.0 --help

# Test health check
docker run --rm llms-os:production-v2.0 python -c "import LLMs_OS; print('OK')"

# Test demo workflow
docker run --rm llms-os:production-v2.0 /app/workflows/demo.yaml
```

## 🚀 Production Deployment

### Docker Swarm

```bash
docker stack deploy -c docker-compose.production.yml llms-os
```

### Kubernetes

```bash
# Build and push image
docker tag llms-os:production-v2.0 your-registry/llms-os:v2.0
docker push your-registry/llms-os:v2.0

# Deploy (create your k8s manifests)
kubectl apply -f k8s/deployment.yaml
```

### Environment Variables

```bash
# Required
OPENROUTER_API_URL=https://openrouter.ai/api/v1
OPENROUTER_API_KEY=your-actual-api-key

# Optional
LOG_LEVEL=INFO
ENVIRONMENT=production
```

## 📦 Image Details

**Final Image Size**: ~150MB

**Layers**:
- Base: python:3.12-alpine3.19 (~50MB)
- Dependencies: ~70MB
- Application: ~30MB

**Volumes**:
- `/app/workflows` - Workflow definitions
- `/app/programs` - LogicMap programs
- `/app/logs` - Application logs
- `/app/data` - Persistent data

**Ports**:
- `8080` - Application API (if enabled)
- `9090` - Prometheus metrics (if enabled)

## 🛠️ Makefile Commands

```bash
make help              # Show all commands
make setup             # Initial setup
make build             # Build images
make run               # Start services
make stop              # Stop services
make logs              # View logs
make health            # Check health
make clean             # Clean up
make deploy            # Build and deploy
make info              # System information
```

## 🐛 Troubleshooting

### Build fails

```bash
# Clean and rebuild
make clean-all
make build-no-cache
```

### Container won't start

```bash
# Check logs
docker logs llms-os-production

# Check health
docker inspect llms-os-production | grep Health
```

### Workflow fails

```bash
# Run with verbose logging
docker run --rm -e LOG_LEVEL=DEBUG llms-os:production-v2.0 /app/workflows/demo.yaml
```

## 📚 Additional Resources

- **Original LLMs OS**: https://github.com/test01082023/llms-os
- **OpenRouter API**: https://openrouter.ai/docs
- **Alpine Linux**: https://alpinelinux.org/

## 🎯 Use Cases

- **CI/CD Automation**: Integrate AI into deployment pipelines
- **Data Processing**: Automated ETL with AI enhancement
- **Content Generation**: Bulk content creation workflows
- **API Testing**: Automated API testing with LLM validation
- **DevOps**: Infrastructure automation with AI insights

## 📄 License

MIT License - See LICENSE file

## 🤝 Contributing

Contributions welcome! Please open an issue or PR.

---

**Built with ❤️ combining LogicPilot + LLMs OS**

**Production-ready and optimized for scale! 🚀**
