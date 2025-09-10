#!/bin/bash

# Enterprise Auth Template - Start with Monitoring
# This script starts the complete application stack with monitoring enabled

set -e

echo "🚀 Starting Enterprise Auth Template with Monitoring..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

print_status "Docker is running"

# Check if .env.monitoring exists
if [ ! -f ".env.monitoring" ]; then
    print_warning ".env.monitoring not found, creating from template..."
    cp .env.example .env.monitoring || {
        print_error "Failed to create .env.monitoring"
        exit 1
    }
fi

# Load environment variables
export $(grep -v '^#' .env.monitoring | xargs)
print_status "Environment variables loaded"

# Create networks if they don't exist
docker network create monitoring 2>/dev/null || true
docker network create app-network 2>/dev/null || true
print_status "Docker networks ready"

# Stop any existing containers
print_info "Stopping any existing containers..."
docker-compose -f docker-compose.dev-with-monitoring.yml down 2>/dev/null || true

# Pull latest images
print_info "Pulling latest Docker images..."
docker-compose -f docker-compose.dev-with-monitoring.yml pull

# Start the monitoring stack first
print_info "Starting monitoring infrastructure..."
docker-compose -f docker-compose.dev-with-monitoring.yml up -d prometheus grafana alertmanager node-exporter

# Wait for monitoring services to be ready
print_info "Waiting for monitoring services to start..."
sleep 10

# Start database and cache
print_info "Starting database and cache services..."
docker-compose -f docker-compose.dev-with-monitoring.yml up -d postgres redis

# Wait for database
print_info "Waiting for database to be ready..."
for i in {1..30}; do
    if docker-compose -f docker-compose.dev-with-monitoring.yml exec -T postgres pg_isready -U dev_user > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

print_status "Database is ready"

# Start exporters
print_info "Starting metric exporters..."
docker-compose -f docker-compose.dev-with-monitoring.yml up -d postgres-exporter redis-exporter

# Start application services
print_info "Starting application services..."
docker-compose -f docker-compose.dev-with-monitoring.yml up -d backend frontend

# Wait for services to be ready
print_info "Waiting for all services to be ready..."
sleep 15

# Check service health
print_info "Checking service health..."

services=("prometheus:9090" "grafana:3002" "backend:8000" "frontend:3000")
all_healthy=true

for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -sf http://localhost:$port/health > /dev/null 2>&1 || curl -sf http://localhost:$port > /dev/null 2>&1; then
        print_status "$name is healthy"
    else
        print_error "$name is not responding"
        all_healthy=false
    fi
done

# Display access information
echo ""
echo "🎯 Enterprise Auth Template is now running with monitoring!"
echo ""
echo "📱 Application Access:"
echo "   🖥️  Frontend:      http://localhost:3000"
echo "   🔗 Backend API:    http://localhost:8000"
echo "   📊 API Docs:       http://localhost:8000/docs"
echo ""
echo "📊 Monitoring Access:"
echo "   🎨 Grafana:        http://localhost:3002 (admin/admin123)"
echo "   📈 Prometheus:     http://localhost:9090"
echo "   🔔 AlertManager:   http://localhost:9093"
echo "   📊 Metrics:        http://localhost:8000/metrics"
echo ""
echo "💾 Database Access:"
echo "   🗄️  PostgreSQL:     localhost:5432 (dev_user/dev_password)"
echo "   ⚡ Redis:          localhost:6379"
echo ""

if [ "$all_healthy" = true ]; then
    print_status "All services are running successfully!"
    echo ""
    echo "🚀 Ready for development with full observability!"
    echo ""
    echo "📝 Next Steps:"
    echo "   1. Open Grafana dashboard: http://localhost:3002"
    echo "   2. Import monitoring dashboard from monitoring/grafana-dashboard.json"
    echo "   3. Start developing and watch metrics in real-time"
    echo "   4. Check Prometheus targets: http://localhost:9090/targets"
    echo ""
    echo "To stop all services: docker-compose -f docker-compose.dev-with-monitoring.yml down"
else
    print_warning "Some services may not be fully ready yet. Give them a few more minutes."
    echo "Check logs with: docker-compose -f docker-compose.dev-with-monitoring.yml logs"
fi

echo ""
echo "🔗 Useful Commands:"
echo "   📋 View logs:      docker-compose -f docker-compose.dev-with-monitoring.yml logs -f [service]"
echo "   🔄 Restart:        docker-compose -f docker-compose.dev-with-monitoring.yml restart [service]" 
echo "   🛑 Stop all:       docker-compose -f docker-compose.dev-with-monitoring.yml down"
echo "   🧹 Clean up:       docker-compose -f docker-compose.dev-with-monitoring.yml down -v"
echo ""

print_status "Setup complete! 🎉"