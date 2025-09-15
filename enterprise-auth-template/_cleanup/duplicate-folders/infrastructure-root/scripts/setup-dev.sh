#!/bin/bash

# Development Environment Setup Script
# This script sets up the complete development environment for testing Flutter + Backend

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required tools
check_requirements() {
    print_info "Checking requirements..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter is not installed. You won't be able to run the Flutter app."
    else
        print_info "Flutter version: $(flutter --version | head -n 1)"
    fi
    
    print_info "✅ All requirements met!"
}

# Create environment files
setup_env_files() {
    print_info "Setting up environment files..."
    
    # Backend .env
    if [ ! -f "../../backend/.env" ]; then
        cat > ../../backend/.env << EOF
# Development Environment Configuration
ENVIRONMENT=development
DEBUG=true

# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=enterprise_auth_dev
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# JWT
JWT_SECRET_KEY=dev-secret-key-$(openssl rand -hex 32)
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# Email
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=noreply@dev.local

# CORS
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://10.0.2.2:3000"]

# OAuth (Add your keys here)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
EOF
        print_info "Created backend/.env"
    else
        print_warning "backend/.env already exists, skipping..."
    fi
    
    # Flutter .env
    if [ ! -f "../../enterprise-auth-template/flutter_auth_template/.env" ]; then
        cat > ../../enterprise-auth-template/flutter_auth_template/.env << EOF
# Flutter Development Configuration
API_BASE_URL=http://localhost:8000
ENVIRONMENT=development
EOF
        print_info "Created Flutter .env"
    else
        print_warning "Flutter .env already exists, skipping..."
    fi
}

# Get machine IP for mobile testing
get_machine_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        IP=$(hostname -I | awk '{print $1}')
    else
        # Windows (Git Bash)
        IP=$(ipconfig | grep -A 4 'Wireless LAN adapter Wi-Fi' | grep 'IPv4' | awk '{print $NF}')
    fi
    
    echo $IP
}

# Start Docker services
start_docker_services() {
    print_info "Starting Docker services..."
    
    cd ../docker
    
    # Stop any existing containers
    docker-compose down 2>/dev/null || true
    
    # Start infrastructure services
    docker-compose up -d
    
    # Wait for services to be healthy
    print_info "Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    docker-compose ps
    
    # Start backend with development overrides
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d backend
    
    print_info "✅ Docker services started!"
}

# Setup Flutter dependencies
setup_flutter() {
    print_info "Setting up Flutter dependencies..."
    
    if command -v flutter &> /dev/null; then
        cd ../../enterprise-auth-template/flutter_auth_template
        flutter pub get
        print_info "✅ Flutter dependencies installed!"
    else
        print_warning "Flutter not installed, skipping Flutter setup..."
    fi
}

# Display connection information
display_info() {
    MACHINE_IP=$(get_machine_ip)
    
    echo ""
    echo "=========================================="
    echo "🚀 DEVELOPMENT ENVIRONMENT READY!"
    echo "=========================================="
    echo ""
    echo "📱 SERVICES:"
    echo "  • Backend API: http://localhost:8000"
    echo "  • API Documentation: http://localhost:8000/docs"
    echo "  • MailHog (Email): http://localhost:8025"
    echo "  • pgAdmin: http://localhost:5050"
    echo "  • Redis Commander: http://localhost:8081"
    echo "  • MinIO Console: http://localhost:9001"
    echo ""
    echo "📱 MOBILE TESTING:"
    echo "  • Machine IP: ${MACHINE_IP}"
    echo "  • Android Emulator API: http://10.0.2.2:8000"
    echo "  • Physical Device API: http://${MACHINE_IP}:8000"
    echo ""
    echo "🔐 DEFAULT CREDENTIALS:"
    echo "  • Admin: admin@example.com / Admin123!@#"
    echo "  • User: john.doe@example.com / User123!@#"
    echo "  • Manager: jane.manager@example.com / Manager123!@#"
    echo ""
    echo "📋 NEXT STEPS:"
    echo "  1. Start Flutter app:"
    echo "     cd enterprise-auth-template/flutter_auth_template"
    echo "     flutter run -d chrome  # For web"
    echo "     flutter run -d android # For Android"
    echo "     flutter run -d ios     # For iOS"
    echo ""
    echo "  2. For physical device testing:"
    echo "     • Update Flutter environment.dart with IP: ${MACHINE_IP}"
    echo "     • Ensure device is on same network"
    echo "     • For Android: adb reverse tcp:8000 tcp:8000"
    echo ""
    echo "  3. View logs:"
    echo "     docker-compose logs -f backend"
    echo ""
    echo "=========================================="
}

# Main execution
main() {
    print_info "Starting development environment setup..."
    
    check_requirements
    setup_env_files
    start_docker_services
    setup_flutter
    display_info
    
    print_info "✅ Setup complete!"
}

# Run main function
main