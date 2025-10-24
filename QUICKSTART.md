# LogicPilot - Quick Start Guide

## 🚀 1-Minute Setup

### Prerequisites
```bash
# Check you have Docker installed
docker --version  # Should be 20.10+
docker-compose --version  # Should be 2.0+
```

### Option A: Simple Test Run (No Setup Needed)

```bash
# Clone the repo
git clone https://github.com/git04112019/logicpilot.git
cd logicpilot

# Build and run in one command
./build-production.sh

# Or manually:
docker build -t logicpilot:production-v2.0 -f Dockerfile.logicpilot.production .
docker run --rm logicpilot:production-v2.0 /app/workflows/demo.yaml
```

You should see:
```
INFO:LogicPilot.core:Running workflow: Production Demo
🚀 LogicPilot Production v2.0
✅ System operational
INFO:LogicPilot.core:Workflow completed successfully
```

### Option B: Full Stack with Mock API (Recommended)

```bash
# Clone the repo
git clone https://github.com/git04112019/logicpilot.git
cd logicpilot

# Initial setup
make setup

# Build and start everything
make deploy

# This will:
# 1. Build the Docker images
# 2. Start LogicPilot + Mock API
# 3. Run health checks
```

### Option C: Using Makefile (Best Experience)

```bash
# See all available commands
make help

# Quick deployment
make deploy

# Run a specific workflow
make run-workflow WORKFLOW=/app/workflows/demo.yaml

# View logs
make logs

# Check health
make health

# Stop everything
make stop

# Clean up
make clean
```

## 📝 Common Commands

```bash
# Build images
make build

# Start services
make run

# View logs in real-time
make logs

# Run workflow with Docker Compose
docker-compose -f docker-compose.production.yml run --rm logicpilot /app/workflows/demo.yaml

# Run workflow standalone
docker run --rm logicpilot:production-v2.0 /app/workflows/demo.yaml

# Get shell access
make shell

# Check system info
make info
```

## 🎯 Create Your First Workflow

1. Create `workflows/hello.yaml`:

```yaml
metadata:
  title: "Hello LogicPilot"
  version: "1.0.0"

tasks:
  - action: print_message
    message: "👋 Hello from LogicPilot!"
    style: success
  
  - action: print_message
    message: "System time: {{ env.HOSTNAME | default('localhost') }}"
    style: info
```

2. Run it:

```bash
# Using make
make run-workflow WORKFLOW=/app/workflows/hello.yaml

# Using docker-compose
docker-compose -f docker-compose.production.yml run --rm \
  -v $(pwd)/workflows:/app/workflows:ro \
  logicpilot /app/workflows/hello.yaml

# Using docker directly
docker run --rm \
  -v $(pwd)/workflows:/app/workflows:ro \
  logicpilot:production-v2.0 /app/workflows/hello.yaml
```

## 🔧 Troubleshooting

### Error: "service depends on undefined service"

**Solution**: Make sure you pulled the latest code. Run:
```bash
git pull origin main
make clean
make deploy
```

### Error: "Cannot connect to Docker daemon"

**Solution**: Start Docker service:
```bash
sudo systemctl start docker
# or on macOS: open Docker Desktop
```

### Error: "Port already in use"

**Solution**: Stop conflicting services or change ports in `docker-compose.production.yml`:
```yaml
ports:
  - "8001:8000"  # Change 8000 to 8001
```

### Build fails with "no space left"

**Solution**: Clean Docker:
```bash
docker system prune -a
```

## 🌐 Using with Real APIs

To use real OpenAI/OpenRouter APIs:

```bash
# Set environment variables
export OPENROUTER_API_KEY="your-actual-api-key"
export OPENROUTER_API_URL="https://openrouter.ai/api/v1"

# Run workflow
docker run --rm \
  -e OPENROUTER_API_KEY \
  -e OPENROUTER_API_URL \
  -v $(pwd)/workflows:/app/workflows:ro \
  logicpilot:production-v2.0 /app/workflows/advanced.yaml
```

Or edit `.env` file:
```bash
cp .env.example .env
# Edit .env with your API keys
nano .env
```

Then use docker-compose which will load .env automatically:
```bash
docker-compose -f docker-compose.production.yml up -d
```

## 📊 Monitoring (Optional)

Start with Prometheus & Grafana:

```bash
make run-with-monitoring

# Access:
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

## 📚 Next Steps

1. **Read Full Docs**: Check `README.md` and `README.production.md`
2. **Explore Examples**: Look at `workflows/demo.yaml` and `workflows/advanced.yaml`
3. **Create Workflows**: Start building your own automation
4. **Join Community**: Star ⭐ the repo and contribute!

## 🆘 Get Help

- Check logs: `make logs`
- View status: `make health`
- System info: `make info`
- Full docs: `README.production.md`

## ✅ Verification

Run the verification script:
```bash
./verify-build.sh
```

Expected output:
```
✅ Image found: logicpilot:production-v2.0 (173MB)
✅ Demo workflow executed successfully
✅ Found 5 actions registered
✅ Health check passed
```

---

**🎉 You're ready to go! Happy automating with LogicPilot! 🚀**
