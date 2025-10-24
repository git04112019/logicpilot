# Mock API Dockerfile for testing
FROM python:3.12-alpine3.19

RUN apk add --no-cache curl

WORKDIR /app

RUN pip install --no-cache-dir flask==3.0.0 flask-cors==4.0.0

RUN cat > app.py <<'EOF'
from flask import Flask, jsonify, request
from flask_cors import CORS
import datetime

app = Flask(__name__)
CORS(app)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.datetime.now().isoformat()})

@app.route('/api/v1/models')
def models():
    return jsonify({
        'data': [
            {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo'},
            {'id': 'gpt-4', 'name': 'GPT-4'},
            {'id': 'claude-2', 'name': 'Claude 2'}
        ]
    })

@app.route('/api/v1/chat/completions', methods=['POST'])
def chat_completions():
    data = request.json
    model = data.get('model', 'gpt-3.5-turbo')
    messages = data.get('messages', [])
    
    # Mock response
    return jsonify({
        'id': 'mock-123',
        'model': model,
        'choices': [{
            'index': 0,
            'message': {
                'role': 'assistant',
                'content': 'This is a mock response from the simulated API. Your workflow is working!'
            },
            'finish_reason': 'stop'
        }],
        'usage': {'prompt_tokens': 10, 'completion_tokens': 20, 'total_tokens': 30}
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "app.py"]
