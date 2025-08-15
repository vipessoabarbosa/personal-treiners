#!/bin/bash

# ==============================================
# FITCOACH PRO - SETUP SCRIPT
# ==============================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
FitCoach Pro Setup Script

Usage: $0 [OPTIONS]

Options:
    --full              Full setup (all components)
    --backend-only      Setup backend only
    --frontend-only     Setup frontend only
    --mobile-only       Setup mobile only
    --docker-only       Setup Docker environment only
    --skip-install      Skip npm install steps
    --skip-docker       Skip Docker setup
    --help              Show this help message

This script will:
    1. Check system requirements
    2. Install dependencies
    3. Setup environment files
    4. Initialize databases
    5. Start development environment

EOF
}

# Default options
SETUP_BACKEND=true
SETUP_FRONTEND=true
SETUP_MOBILE=true
SETUP_DOCKER=true
SKIP_INSTALL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)
            SETUP_BACKEND=true
            SETUP_FRONTEND=false
            SETUP_MOBILE=false
            shift
            ;;
        --frontend-only)
            SETUP_BACKEND=false
            SETUP_FRONTEND=true
            SETUP_MOBILE=false
            shift
            ;;
        --mobile-only)
            SETUP_BACKEND=false
            SETUP_FRONTEND=false
            SETUP_MOBILE=true
            shift
            ;;
        --docker-only)
            SETUP_BACKEND=false
            SETUP_FRONTEND=false
            SETUP_MOBILE=false
            SETUP_DOCKER=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --skip-docker)
            SETUP_DOCKER=false
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to check system requirements
check_system_requirements() {
    print_info "Checking system requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org"
        exit 1
    fi
    
    local node_version=$(node --version | cut -d'v' -f2)
    if ! node -e "process.exit(process.version.slice(1).localeCompare('18.0.0', undefined, {numeric: true}) >= 0 ? 0 : 1)"; then
        print_error "Node.js version 18.0.0 or higher is required (current: v$node_version)"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git"
        exit 1
    fi
    
    # Check Docker (optional)
    if [[ "$SETUP_DOCKER" == true ]]; then
        if ! command -v docker &> /dev/null; then
            print_warning "Docker is not installed. Docker setup will be skipped."
            print_info "Install Docker from https://docker.com to use containerized development"
            SETUP_DOCKER=false
        fi
        
        if ! command -v docker-compose &> /dev/null; then
            print_warning "Docker Compose is not installed. Docker setup will be skipped."
            SETUP_DOCKER=false
        fi
    fi
    
    print_success "System requirements check passed"
}

# Function to setup environment files
setup_environment_files() {
    print_info "Setting up environment files..."
    
    # Copy .env.example to .env if it doesn't exist
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            print_success "Created .env file from .env.example"
            print_warning "Please update .env file with your actual configuration values"
        else
            print_warning ".env.example not found. You'll need to create .env manually"
        fi
    else
        print_info ".env file already exists"
    fi
    
    # Setup component-specific environment files
    local components=("backend" "frontend" "mobile")
    
    for component in "${components[@]}"; do
        if [[ -d "$component" ]]; then
            local env_file="$component/.env"
            local env_example="$component/.env.example"
            
            if [[ ! -f "$env_file" ]] && [[ -f "$env_example" ]]; then
                cp "$env_example" "$env_file"
                print_success "Created $env_file from $env_example"
            fi
        fi
    done
}

# Function to install dependencies
install_dependencies() {
    if [[ "$SKIP_INSTALL" == true ]]; then
        print_warning "Skipping dependency installation (--skip-install flag used)"
        return 0
    fi
    
    print_info "Installing dependencies..."
    
    # Install shared dependencies first
    if [[ -d "shared" ]]; then
        print_info "Installing shared dependencies..."
        cd shared
        npm install
        npm run build 2>/dev/null || true
        cd ..
    fi
    
    # Install backend dependencies
    if [[ "$SETUP_BACKEND" == true ]] && [[ -d "backend" ]]; then
        print_info "Installing backend dependencies..."
        cd backend
        npm install
        cd ..
    fi
    
    # Install frontend dependencies
    if [[ "$SETUP_FRONTEND" == true ]] && [[ -d "frontend" ]]; then
        print_info "Installing frontend dependencies..."
        cd frontend
        npm install
        cd ..
    fi
    
    # Install mobile dependencies
    if [[ "$SETUP_MOBILE" == true ]] && [[ -d "mobile" ]]; then
        print_info "Installing mobile dependencies..."
        cd mobile
        npm install
        
        # Install Expo CLI if not present
        if ! command -v expo &> /dev/null; then
            print_info "Installing Expo CLI..."
            npm install -g @expo/cli
        fi
        
        cd ..
    fi
    
    # Install test dependencies
    if [[ -d "tests" ]]; then
        print_info "Installing test dependencies..."
        cd tests
        npm install 2>/dev/null || true
        cd ..
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to setup Docker environment
setup_docker() {
    if [[ "$SETUP_DOCKER" == false ]]; then
        return 0
    fi
    
    print_info "Setting up Docker environment..."
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker and try again."
        return 1
    fi
    
    # Build and start services
    print_info "Building Docker images..."
    docker-compose build --no-cache
    
    print_info "Starting Docker services..."
    docker-compose up -d postgres redis
    
    # Wait for services to be ready
    print_info "Waiting for services to be ready..."
    sleep 10
    
    # Check if services are healthy
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; then
            print_success "PostgreSQL is ready"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            print_error "PostgreSQL failed to start after $max_attempts attempts"
            return 1
        fi
        
        print_info "Waiting for PostgreSQL... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    # Reset attempt counter for Redis
    attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose exec -T redis redis-cli ping &> /dev/null; then
            print_success "Redis is ready"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            print_error "Redis failed to start after $max_attempts attempts"
            return 1
        fi
        
        print_info "Waiting for Redis... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    print_success "Docker environment setup completed"
}

# Function to initialize database
init_database() {
    if [[ "$SETUP_BACKEND" == false ]]; then
        return 0
    fi
    
    print_info "Initializing database..."
    
    if [[ -d "backend" ]]; then
        cd backend
        
        # Run database migrations
        if [[ -f "package.json" ]] && npm run --silent 2>/dev/null | grep -q "migrate"; then
            print_info "Running database migrations..."
            npm run migrate 2>/dev/null || {
                print_warning "Migration script not found or failed. You may need to run migrations manually."
            }
        fi
        
        # Run database seeds
        if [[ -f "package.json" ]] && npm run --silent 2>/dev/null | grep -q "seed"; then
            print_info "Running database seeds..."
            npm run seed 2>/dev/null || {
                print_warning "Seed script not found or failed. You may need to run seeds manually."
            }
        fi
        
        cd ..
    fi
    
    print_success "Database initialization completed"
}

# Function to run initial tests
run_initial_tests() {
    print_info "Running initial tests to verify setup..."
    
    local test_passed=true
    
    # Test backend
    if [[ "$SETUP_BACKEND" == true ]] && [[ -d "backend" ]]; then
        print_info "Testing backend setup..."
        cd backend
        if npm test -- --passWithNoTests &> /dev/null; then
            print_success "Backend tests passed"
        else
            print_warning "Backend tests failed or not configured"
            test_passed=false
        fi
        cd ..
    fi
    
    # Test frontend
    if [[ "$SETUP_FRONTEND" == true ]] && [[ -d "frontend" ]]; then
        print_info "Testing frontend setup..."
        cd frontend
        if npm test -- --watchAll=false --passWithNoTests &> /dev/null; then
            print_success "Frontend tests passed"
        else
            print_warning "Frontend tests failed or not configured"
            test_passed=false
        fi
        cd ..
    fi
    
    # Test mobile
    if [[ "$SETUP_MOBILE" == true ]] && [[ -d "mobile" ]]; then
        print_info "Testing mobile setup..."
        cd mobile
        if npm test -- --passWithNoTests &> /dev/null; then
            print_success "Mobile tests passed"
        else
            print_warning "Mobile tests failed or not configured"
            test_passed=false
        fi
        cd ..
    fi
    
    if [[ "$test_passed" == true ]]; then
        print_success "All initial tests passed"
    else
        print_warning "Some tests failed. This is normal for initial setup."
    fi
}

# Function to show next steps
show_next_steps() {
    print_success "Setup completed successfully!"
    echo
    print_info "Next steps:"
    echo
    
    if [[ "$SETUP_BACKEND" == true ]]; then
        echo "  Backend:"
        echo "    cd backend && npm run dev"
        echo "    API will be available at: http://localhost:3001"
        echo
    fi
    
    if [[ "$SETUP_FRONTEND" == true ]]; then
        echo "  Frontend:"
        echo "    cd frontend && npm run dev"
        echo "    Web app will be available at: http://localhost:5173"
        echo
    fi
    
    if [[ "$SETUP_MOBILE" == true ]]; then
        echo "  Mobile:"
        echo "    cd mobile && npx expo start"
        echo "    Scan QR code with Expo Go app"
        echo
    fi
    
    if [[ "$SETUP_DOCKER" == true ]]; then
        echo "  Docker Services:"
        echo "    PostgreSQL: localhost:5432"
        echo "    Redis: localhost:6379"
        echo "    Adminer: http://localhost:8080"
        echo "    MailHog: http://localhost:8025"
        echo
    fi
    
    echo "  Useful commands:"
    echo "    ./scripts/deploy.sh -e development    # Start development environment"
    echo "    docker-compose logs -f               # View Docker logs"
    echo "    docker-compose down                  # Stop Docker services"
    echo
    
    print_warning "Don't forget to:"
    echo "  1. Update .env files with your actual configuration"
    echo "  2. Configure external services (database, email, etc.)"
    echo "  3. Review the documentation in docs/ folder"
    echo
}

# Main setup function
main() {
    echo "==========================================="
    echo "       FitCoach Pro Setup Script"
    echo "==========================================="
    echo
    
    print_info "Starting setup process..."
    print_info "Backend: $SETUP_BACKEND"
    print_info "Frontend: $SETUP_FRONTEND"
    print_info "Mobile: $SETUP_MOBILE"
    print_info "Docker: $SETUP_DOCKER"
    echo
    
    # Run setup steps
    check_system_requirements
    setup_environment_files
    install_dependencies
    setup_docker
    init_database
    run_initial_tests
    show_next_steps
    
    print_success "FitCoach Pro setup completed!"
}

# Run main function
main "$@"