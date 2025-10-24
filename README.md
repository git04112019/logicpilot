# LogicPilot Production - AI Workflow Automation

🚀 **Production-ready workflow automation system powered by AI**

Alpine-based Docker container combining LogicPilot architecture with LLMs OS workflow automation capabilities.

## ✨ Features

- **Ultra-Light**: Alpine Linux base (~173MB total)
- **Production-Ready**: Multi-stage builds, non-root user, health checks
- **AI Integration**: OpenAI/Anthropic API support with mock API
- **Workflow Automation**: YAML-based workflow definitions
- **5 Built-in Actions**: print_message, chat_completion, http_request, file_read, file_write
- **Security Hardened**: Non-root execution, minimal packages
- **Monitoring Ready**: Prometheus & Grafana integration

## 🚀 Quick Start

### Option 1: Simple Build & Run

```bash
# Build the image
docker build -t logicpilot:production-v2.0 -f Dockerfile.logicpilot.production .

# Run demo workflow
docker run --rm logicpilot:production-v2.0 /app/workflows/demo.yaml
```

### Option 2: Using Build Script

```bash
# Make executable and run
chmod +x build-production.sh
./build-production.sh
```

### Option 3: Full Stack with Docker Compose

```bash
# Start all services (app + mock API)
docker-compose -f docker-compose.production.yml up -d

# Check status
docker-compose -f docker-compose.production.yml ps

# Run workflow
docker-compose -f docker-compose.production.yml run --rm logicpilot /app/workflows/demo.yaml

# Stop services
docker-compose -f docker-compose.production.yml down
```

### Option 4: Using Makefile (Easiest!)

```bash
# See all commands
make help

# Initial setup
make setup

# Build and deploy
make deploy

# Run workflow
make run-workflow WORKFLOW=/app/workflows/demo.yaml

# View logs
make logs

# Check health
make health

# Clean up
make clean
```

## 📝 Create Custom Workflow

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
  logicpilot /app/workflows/my-workflow.yaml
```

## 🎯 Available Actions

| Action | Description | Example |
|--------|-------------|---------|
| `print_message` | Display formatted messages | `message: "Hello!" style: success` |
| `chat_completion` | Call LLM API (OpenRouter/OpenAI) | `model: "gpt-3.5-turbo"` |
| `http_request` | Make HTTP requests | `url: "..." method: GET` |
| `file_read` | Read file content | `path: "data.txt"` |
| `file_write` | Write to files | `path: "output.txt"` |

## 📁 Project Structure

```
logicpilot/
├── Dockerfile.logicpilot.production    ⭐ Main production build
├── Dockerfile.logicpilot.alpine.v1     (Original LogicPilot)
├── docker-compose.production.yml       ⭐ Full stack orchestration
├── Makefile                            ⭐ 20+ automation commands
├── build-production.sh                 Build script
├── verify-build.sh                     Testing script
├── requirements.txt                    Python dependencies
├── .env.example                        Environment template
├── README.md                           This file
├── README.production.md                Detailed documentation
├── BUILD_COMPLETE.md                   Build summary
└── mock-api/
    └── Dockerfile                      Mock API for testing
```

## 🔧 Requirements

- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum
- 5GB disk space

## 📦 Docker Image

**Name**: `logicpilot:production-v2.0`  
**Size**: 173MB  
**Base**: Python 3.12 Alpine 3.19  
**Architecture**: Multi-stage build

## 🧪 Testing

```bash
# Run verification tests
chmod +x verify-build.sh
./verify-build.sh
```

Expected output:
```
✅ Image found: logicpilot:production-v2.0 (173MB)
✅ Demo workflow executed successfully
✅ Found 5 actions registered
✅ Health check passed
```

## 🌐 Production Deployment

### Environment Variables

```bash
# Required for real API usage
OPENROUTER_API_URL=https://openrouter.ai/api/v1
OPENROUTER_API_KEY=your-actual-api-key

# Optional
LOG_LEVEL=INFO
ENVIRONMENT=production
```

### Docker Run

```bash
docker run -d \
  --name logicpilot-prod \
  -e OPENROUTER_API_KEY=your-key \
  -v $(pwd)/workflows:/app/workflows:ro \
  -v $(pwd)/logs:/app/logs \
  logicpilot:production-v2.0 /app/workflows/your-workflow.yaml
```

### Docker Compose

```bash
docker-compose -f docker-compose.production.yml up -d
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logicpilot
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: logicpilot
        image: logicpilot:production-v2.0
        env:
        - name: OPENROUTER_API_KEY
          valueFrom:
            secretKeyRef:
              name: logicpilot-secrets
              key: api-key
```

## 📊 Monitoring (Optional)

Start with Prometheus & Grafana:

```bash
docker-compose -f docker-compose.production.yml --profile monitoring up -d
```

Access:
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

## 🔐 Security Features

- ✅ Non-root user (appuser:1000)
- ✅ Minimal Alpine base
- ✅ No build tools in final image
- ✅ Health checks enabled
- ✅ Read-only filesystem compatible
- ✅ Environment-based secrets

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
make shell             # Get shell access
make info              # System information
```

## 📚 Documentation

- **Full Guide**: `README.production.md` - Complete documentation
- **Build Summary**: `BUILD_COMPLETE.md` - Detailed build info
- **Original Project**: Based on https://github.com/test01082023/llms-os

## 🎯 Use Cases

- **CI/CD Automation** - Integrate AI into pipelines
- **Data Processing** - ETL with AI enhancement
- **Content Generation** - Bulk content automation
- **API Testing** - Automated testing with LLM validation
- **DevOps Tasks** - Infrastructure automation
- **Workflow Orchestration** - Complex multi-step processes

## 🐛 Troubleshooting

### Build fails
```bash
make clean-all
make build-no-cache
```

### Container won't start
```bash
docker logs logicpilot-production
```

### Workflow fails
```bash
docker run --rm -e LOG_LEVEL=DEBUG logicpilot:production-v2.0 /app/workflows/demo.yaml
```

## 📄 License

MIT License

## 🤝 Contributing

Contributions welcome! Please open an issue or PR.

## 🙏 Credits

- **Based on**: https://github.com/test01082023/llms-os
- **LogicPilot**: Alpine-based architecture
- **Python**: FastAPI ecosystem
- **Alpine Linux**: Minimal base

---

**Built with ❤️ - Production-ready and optimized for scale! 🚀**

**Star ⭐ this repo if you find it useful!**
