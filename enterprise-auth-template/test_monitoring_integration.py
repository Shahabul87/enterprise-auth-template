#!/usr/bin/env python3
"""
Test script to demonstrate the monitoring integration working.
This will run a simple FastAPI server with monitoring enabled.
"""

import asyncio
import time
import threading
from fastapi import FastAPI, Response
from fastapi.responses import PlainTextResponse
import uvicorn
import requests
import logging

# For this demo, let's simulate the monitoring components
try:
    from prometheus_client import Counter, Histogram, generate_latest
    PROMETHEUS_AVAILABLE = True
except ImportError:
    print("⚠️  prometheus_client not available, using mock implementation")
    PROMETHEUS_AVAILABLE = False

# Mock implementations if prometheus_client is not available
if not PROMETHEUS_AVAILABLE:
    class MockCounter:
        def __init__(self, *args, **kwargs):
            self.value = 0
        def inc(self):
            self.value += 1
        def labels(self, **kwargs):
            return self
    
    class MockHistogram:
        def __init__(self, *args, **kwargs):
            self.values = []
        def observe(self, value):
            self.values.append(value)
        def labels(self, **kwargs):
            return self
    
    def generate_latest():
        return """# Mock Prometheus metrics
http_requests_total 42
http_request_duration_seconds_sum 1.23
# Add more metrics here
"""

    Counter = MockCounter
    Histogram = MockHistogram

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# Create FastAPI app
app = FastAPI(
    title="Enterprise Auth Template - Monitoring Test",
    description="Test server to demonstrate monitoring integration",
    version="1.0.0"
)

@app.middleware("http")
async def monitoring_middleware(request, call_next):
    """Simple monitoring middleware"""
    start_time = time.time()
    method = request.method
    path = request.url.path
    
    try:
        response = await call_next(request)
        duration = time.time() - start_time
        status_code = str(response.status_code)
        
        # Record metrics
        REQUEST_COUNT.labels(
            method=method,
            endpoint=path,
            status_code=status_code
        ).inc()
        
        REQUEST_DURATION.labels(
            method=method,
            endpoint=path
        ).observe(duration)
        
        # Log the request
        logger.info(
            f"{method} {path} - {status_code} - {duration:.3f}s",
            extra={
                "method": method,
                "endpoint": path,
                "status_code": status_code,
                "duration": f"{duration:.3f}s"
            }
        )
        
        return response
    except Exception as e:
        duration = time.time() - start_time
        logger.error(f"Request failed: {method} {path} - {str(e)} - {duration:.3f}s")
        raise

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Enterprise Auth Template - Monitoring Test Server",
        "status": "running",
        "monitoring": {
            "prometheus_metrics": "/metrics",
            "grafana_dashboard": "http://localhost:3002",
            "prometheus_ui": "http://localhost:9090"
        }
    }

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "service": "enterprise-auth-monitoring-test"
    }

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return PlainTextResponse(
        content=generate_latest(),
        media_type="text/plain; charset=utf-8"
    )

@app.get("/test-auth")
async def test_auth():
    """Simulate authentication endpoint"""
    import random
    
    # Simulate some processing time
    await asyncio.sleep(random.uniform(0.1, 0.5))
    
    # Simulate success/failure
    success = random.choice([True, True, True, False])  # 75% success rate
    
    if success:
        return {"status": "success", "user_id": "12345", "token": "mock_jwt_token"}
    else:
        return Response(
            content='{"error": "Authentication failed"}',
            status_code=401,
            media_type="application/json"
        )

@app.get("/test-slow")
async def test_slow():
    """Simulate slow endpoint for monitoring"""
    await asyncio.sleep(2.0)  # Intentionally slow
    return {"message": "This was a slow request", "duration": "2 seconds"}

@app.post("/test-error")
async def test_error():
    """Simulate error for monitoring"""
    raise Exception("Intentional error for testing monitoring")

def generate_test_traffic():
    """Generate some test traffic to the API"""
    base_url = "http://localhost:8001"
    
    endpoints = [
        "/",
        "/health", 
        "/test-auth",
        "/test-slow",  # This will trigger slow request alerts
    ]
    
    for i in range(20):
        try:
            endpoint = endpoints[i % len(endpoints)]
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            print(f"✅ {endpoint} -> {response.status_code}")
        except Exception as e:
            print(f"❌ {endpoint} -> Error: {e}")
        
        time.sleep(1)  # Wait 1 second between requests

def run_server():
    """Run the FastAPI server"""
    print("🚀 Starting monitoring test server...")
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8001,  # Use port 8001 to avoid conflicts
        log_level="info",
        access_log=True
    )

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "traffic":
        print("🔄 Generating test traffic...")
        generate_test_traffic()
    else:
        print("""
🎯 Enterprise Auth Template - Monitoring Integration Test

This script demonstrates:
✅ FastAPI server with monitoring middleware
✅ Prometheus metrics collection (/metrics)
✅ Structured logging with context
✅ Health check endpoint
✅ Simulated authentication and error endpoints

🚀 Starting Options:
   python test_monitoring_integration.py        # Start server
   python test_monitoring_integration.py traffic # Generate test traffic

📊 Monitoring Access:
   🎨 Grafana:     http://localhost:3002 (admin/admin)
   📈 Prometheus:  http://localhost:9090
   🔍 Jaeger:      http://localhost:16686
   🔔 AlertManager: http://localhost:9093
   📊 Metrics:     http://localhost:8001/metrics

💡 After starting the server, run with 'traffic' argument in another terminal
   to generate test data for the monitoring dashboard.
        """)
        run_server()