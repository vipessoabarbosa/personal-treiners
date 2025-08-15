#!/bin/bash

# ==============================================
# FITCOACH PRO - DEPLOYMENT SCRIPT
# ==============================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="staging"
COMPONENT="all"
SKIP_TESTS=false
SKIP_BUILD=false
FORCE_DEPLOY=false
VERBOSE=false

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
FitCoach Pro Deployment Script

Usage: $0 [OPTIONS]

Options:
    -e, --environment ENV    Target environment (development|staging|production) [default: staging]
    -c, --component COMP     Component to deploy (backend|frontend|mobile|all) [default: all]
    -s, --skip-tests         Skip running tests before deployment
    -b, --skip-build         Skip build process
    -f, --force              Force deployment even if checks fail
    -v, --verbose            Enable verbose output
    -h, --help               Show this help message

Examples:
    $0 -e staging -c backend
    $0 -e production -c all --skip-tests
    $0 -e development -c frontend -v

Environments:
    development    Local development environment
    staging        Staging environment (Railway + Vercel)
    production     Production environment (Railway + Vercel + App Stores)

Components:
    backend        Node.js API server
    frontend       React web application
    mobile         React Native mobile app
    all            Deploy all components

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -c|--component)
            COMPONENT="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -b|--skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -f|--force)
            FORCE_DEPLOY=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
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

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_info "Valid environments: development, staging, production"
    exit 1
fi

# Validate component
if [[ ! "$COMPONENT" =~ ^(backend|frontend|mobile|all)$ ]]; then
    print_error "Invalid component: $COMPONENT"
    print_info "Valid components: backend, frontend, mobile, all"
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "package.json" ]] && [[ ! -f "docker-compose.yml" ]]; then
    print_error "This script must be run from the project root directory"
    exit 1
fi

# Load environment variables
if [[ -f "environments/${ENVIRONMENT}.env" ]]; then
    print_info "Loading environment variables for $ENVIRONMENT"
    set -a  # automatically export all variables
    source "environments/${ENVIRONMENT}.env"
    set +a
else
    print_warning "Environment file not found: environments/${ENVIRONMENT}.env"
fi

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check required tools
    local required_tools=("node" "npm" "git" "docker")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "Required tool not found: $tool"
            exit 1
        fi
    done
    
    # Check Node.js version
    local node_version=$(node --version | cut -d'v' -f2)
    local required_version="18.0.0"
    
    if ! node -e "process.exit(process.version.slice(1).localeCompare('$required_version', undefined, {numeric: true}) >= 0 ? 0 : 1)"; then
        print_error "Node.js version $required_version or higher is required (current: v$node_version)"
        exit 1
    fi
    
    # Check if git working directory is clean (for production)
    if [[ "$ENVIRONMENT" == "production" ]] && [[ "$FORCE_DEPLOY" == false ]]; then
        if [[ -n $(git status --porcelain) ]]; then
            print_error "Git working directory is not clean. Commit or stash changes before production deployment."
            print_info "Use --force to override this check."
            exit 1
        fi
    fi
    
    print_success "Prerequisites check passed"
}

# Function to run tests
run_tests() {
    if [[ "$SKIP_TESTS" == true ]]; then
        print_warning "Skipping tests (--skip-tests flag used)"
        return 0
    fi
    
    print_info "Running tests..."
    
    case $COMPONENT in
        "backend"|"all")
            if [[ -d "backend" ]]; then
                print_info "Running backend tests..."
                cd backend
                npm test
                cd ..
            fi
            ;;
    esac
    
    case $COMPONENT in
        "frontend"|"all")
            if [[ -d "frontend" ]]; then
                print_info "Running frontend tests..."
                cd frontend
                npm test -- --watchAll=false
                cd ..
            fi
            ;;
    esac
    
    case $COMPONENT in
        "mobile"|"all")
            if [[ -d "mobile" ]]; then
                print_info "Running mobile tests..."
                cd mobile
                npm test
                cd ..
            fi
            ;;
    esac
    
    print_success "All tests passed"
}

# Function to build components
build_components() {
    if [[ "$SKIP_BUILD" == true ]]; then
        print_warning "Skipping build (--skip-build flag used)"
        return 0
    fi
    
    print_info "Building components..."
    
    case $COMPONENT in
        "backend"|"all")
            if [[ -d "backend" ]]; then
                print_info "Building backend..."
                cd backend
                npm run build
                cd ..
            fi
            ;;
    esac
    
    case $COMPONENT in
        "frontend"|"all")
            if [[ -d "frontend" ]]; then
                print_info "Building frontend..."
                cd frontend
                npm run build
                cd ..
            fi
            ;;
    esac
    
    case $COMPONENT in
        "mobile"|"all")
            if [[ -d "mobile" ]]; then
                print_info "Building mobile..."
                cd mobile
                if [[ "$ENVIRONMENT" == "production" ]]; then
                    npx expo build:ios --release-channel production
                    npx expo build:android --release-channel production
                else
                    npx expo publish --release-channel "$ENVIRONMENT"
                fi
                cd ..
            fi
            ;;
    esac
    
    print_success "Build completed"
}

# Function to deploy to development
deploy_development() {
    print_info "Deploying to development environment..."
    
    # Start local development environment
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "backend" ]]; then
        print_info "Starting development backend..."
        docker-compose up -d postgres redis
        sleep 5
        
        cd backend
        npm run dev &
        BACKEND_PID=$!
        cd ..
    fi
    
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "frontend" ]]; then
        print_info "Starting development frontend..."
        cd frontend
        npm run dev &
        FRONTEND_PID=$!
        cd ..
    fi
    
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "mobile" ]]; then
        print_info "Starting development mobile..."
        cd mobile
        npx expo start &
        MOBILE_PID=$!
        cd ..
    fi
    
    print_success "Development environment started"
    print_info "Backend: http://localhost:3001"
    print_info "Frontend: http://localhost:5173"
    print_info "Mobile: Check Expo CLI output for QR code"
    
    # Wait for user input to stop
    read -p "Press Enter to stop development servers..."
    
    # Kill background processes
    [[ -n "$BACKEND_PID" ]] && kill $BACKEND_PID 2>/dev/null || true
    [[ -n "$FRONTEND_PID" ]] && kill $FRONTEND_PID 2>/dev/null || true
    [[ -n "$MOBILE_PID" ]] && kill $MOBILE_PID 2>/dev/null || true
    
    docker-compose down
}

# Function to deploy to staging
deploy_staging() {
    print_info "Deploying to staging environment..."
    
    # Deploy backend to Railway
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "backend" ]]; then
        print_info "Deploying backend to Railway (staging)..."
        # This would typically trigger the GitHub Actions workflow
        git push origin develop
    fi
    
    # Deploy frontend to Vercel
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "frontend" ]]; then
        print_info "Deploying frontend to Vercel (staging)..."
        cd frontend
        npx vercel --prod --token="$VERCEL_TOKEN" || true
        cd ..
    fi
    
    # Deploy mobile to Expo
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "mobile" ]]; then
        print_info "Publishing mobile to Expo (staging)..."
        cd mobile
        npx expo publish --release-channel staging
        cd ..
    fi
    
    print_success "Staging deployment completed"
    print_info "Frontend: https://fitcoach-staging.vercel.app"
    print_info "Backend: https://fitcoach-api-staging.railway.app"
    print_info "Mobile: Check Expo dashboard for staging release"
}

# Function to deploy to production
deploy_production() {
    print_info "Deploying to production environment..."
    
    # Additional safety checks for production
    if [[ "$FORCE_DEPLOY" == false ]]; then
        print_warning "You are about to deploy to PRODUCTION!"
        read -p "Are you sure you want to continue? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            print_info "Production deployment cancelled"
            exit 0
        fi
    fi
    
    # Deploy backend to Railway
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "backend" ]]; then
        print_info "Deploying backend to Railway (production)..."
        git push origin main
    fi
    
    # Deploy frontend to Vercel
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "frontend" ]]; then
        print_info "Deploying frontend to Vercel (production)..."
        cd frontend
        npx vercel --prod --token="$VERCEL_TOKEN"
        cd ..
    fi
    
    # Deploy mobile to stores
    if [[ "$COMPONENT" == "all" ]] || [[ "$COMPONENT" == "mobile" ]]; then
        print_info "Deploying mobile to app stores (production)..."
        cd mobile
        npx expo publish --release-channel production
        
        # Build for app stores
        print_info "Building for app stores..."
        npx eas build --platform all --profile production
        
        # Submit to stores (requires manual approval)
        print_warning "App store submission requires manual approval"
        print_info "Run 'npx eas submit --platform all' when ready to submit"
        cd ..
    fi
    
    print_success "Production deployment completed"
    print_info "Frontend: https://dashboard.fitcoach.pro"
    print_info "Backend: https://api.fitcoach.pro"
    print_info "Mobile: Check app stores for review status"
}

# Function to run health checks
run_health_checks() {
    print_info "Running health checks..."
    
    case $ENVIRONMENT in
        "staging")
            # Check staging endpoints
            if curl -f "https://fitcoach-api-staging.railway.app/health" > /dev/null 2>&1; then
                print_success "Backend health check passed"
            else
                print_error "Backend health check failed"
                return 1
            fi
            
            if curl -f "https://fitcoach-staging.vercel.app" > /dev/null 2>&1; then
                print_success "Frontend health check passed"
            else
                print_error "Frontend health check failed"
                return 1
            fi
            ;;
        "production")
            # Check production endpoints
            if curl -f "https://api.fitcoach.pro/health" > /dev/null 2>&1; then
                print_success "Backend health check passed"
            else
                print_error "Backend health check failed"
                return 1
            fi
            
            if curl -f "https://dashboard.fitcoach.pro" > /dev/null 2>&1; then
                print_success "Frontend health check passed"
            else
                print_error "Frontend health check failed"
                return 1
            fi
            ;;
    esac
    
    print_success "All health checks passed"
}

# Main deployment function
main() {
    print_info "Starting FitCoach Pro deployment"
    print_info "Environment: $ENVIRONMENT"
    print_info "Component: $COMPONENT"
    print_info "Skip Tests: $SKIP_TESTS"
    print_info "Skip Build: $SKIP_BUILD"
    print_info "Force Deploy: $FORCE_DEPLOY"
    echo
    
    # Run deployment steps
    check_prerequisites
    run_tests
    build_components
    
    # Deploy based on environment
    case $ENVIRONMENT in
        "development")
            deploy_development
            ;;
        "staging")
            deploy_staging
            sleep 30  # Wait for deployment
            run_health_checks
            ;;
        "production")
            deploy_production
            sleep 60  # Wait for deployment
            run_health_checks
            ;;
    esac
    
    print_success "Deployment completed successfully!"
}

# Run main function
main "$@"