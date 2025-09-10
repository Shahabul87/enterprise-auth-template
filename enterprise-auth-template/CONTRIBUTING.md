# Contributing to Enterprise Authentication Template

Thank you for your interest in contributing to the Enterprise Authentication Template! This document provides guidelines and instructions for contributing to this project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Security Considerations](#security-considerations)
- [Documentation](#documentation)
- [Community](#community)

## 🤝 Code of Conduct

This project adheres to a code of conduct that ensures a welcoming and inclusive environment for all contributors. By participating, you agree to:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Docker & Docker Compose** - For containerized development
- **Node.js 18+** - For frontend development
- **Python 3.11+** - For backend development
- **Git** - Version control

### Setting Up the Development Environment

1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/your-username/enterprise-auth-template.git
   cd enterprise-auth-template
   ```

2. **Copy Environment Configuration**
   ```bash
   cp .env.example .env.dev
   # Edit .env.dev with your configuration
   ```

3. **Start Development Services**
   ```bash
   # Start all services
   docker-compose -f docker-compose.dev.yml up -d
   
   # Verify services are running
   docker-compose ps
   ```

4. **Run Initial Setup**
   ```bash
   # Initialize database and seed data
   make db-migrate
   make db-seed
   
   # Verify setup
   make quick-test
   ```

## 🔄 Development Workflow

### Branching Strategy

We follow a **Git Flow** branching model:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Individual feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Critical production fixes

### Working on a Feature

1. **Create a Feature Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   ```bash
   # Make your changes
   # Test thoroughly
   # Commit with conventional commit messages
   ```

3. **Test Your Changes**
   ```bash
   # Run backend tests
   cd backend && pytest tests/ -v
   
   # Run frontend tests
   cd frontend && npm test
   
   # Run integration tests
   make test-integration
   ```

4. **Submit Pull Request**
   ```bash
   git push origin feature/your-feature-name
   # Create PR through GitHub interface
   ```

## 📝 Code Standards

### Python (Backend)

- **Style Guide**: Follow PEP 8
- **Formatter**: Black (line length: 88)
- **Import Sorting**: isort
- **Linting**: flake8 + mypy for type checking
- **Docstrings**: Google style

```python
def authenticate_user(username: str, password: str) -> Optional[User]:
    """
    Authenticate user with username and password.
    
    Args:
        username: User's email or username
        password: Plain text password
        
    Returns:
        User object if authentication successful, None otherwise
        
    Raises:
        AuthenticationError: If authentication fails
    """
    # Implementation here
```

### TypeScript (Frontend)

- **Style Guide**: Airbnb TypeScript style
- **Formatter**: Prettier
- **Linting**: ESLint with TypeScript rules
- **Type Safety**: Strict TypeScript configuration

```typescript
interface UserAuthProps {
  onSuccess: (user: User) => void;
  onError: (error: AuthError) => void;
}

const UserAuth: React.FC<UserAuthProps> = ({ onSuccess, onError }) => {
  // Component implementation
};
```

### Code Quality Tools

**Backend Quality Checks:**
```bash
cd backend
python -m black app/ tests/          # Format code
python -m isort app/ tests/          # Sort imports
python -m flake8 app/ tests/         # Lint code
python -m mypy app/                  # Type check
```

**Frontend Quality Checks:**
```bash
cd frontend
npm run lint                         # ESLint
npm run typecheck                    # TypeScript check
npx prettier --write .               # Format code
```

## 🧪 Testing Requirements

### Test Coverage Requirements

- **Backend**: Minimum 85% code coverage
- **Frontend**: Minimum 80% code coverage
- **Integration**: All API endpoints tested

### Backend Testing

```bash
cd backend

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=app --cov-report=term-missing

# Run specific test categories
pytest tests/unit/ -v           # Unit tests
pytest tests/integration/ -v    # Integration tests
pytest tests/security/ -v       # Security tests
```

### Frontend Testing

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

### Test Guidelines

1. **Write Tests First**: Follow TDD when possible
2. **Test Categories**:
   - Unit tests for business logic
   - Integration tests for API endpoints
   - Component tests for React components
   - E2E tests for critical user flows

3. **Test Naming**: Use descriptive test names
   ```python
   def test_user_authentication_with_valid_credentials():
       """Test that valid credentials authenticate successfully."""
   ```

## 🔄 Pull Request Process

### Before Submitting

1. **Run All Checks**
   ```bash
   # Backend checks
   make lint-backend
   make test-backend
   
   # Frontend checks
   make lint-frontend
   make test-frontend
   
   # Security checks
   make security-audit
   ```

2. **Update Documentation**
   - Update relevant documentation
   - Add/update API documentation
   - Update CHANGELOG.md

3. **Check Breaking Changes**
   - Identify any breaking changes
   - Update migration guides if needed

### PR Template

When creating a pull request, include:

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Security review completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is well-documented
- [ ] Tests added for new functionality
- [ ] All tests pass
- [ ] Documentation updated
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Code Review**: Maintainers review code and provide feedback
3. **Testing**: Additional testing by maintainers if needed
4. **Approval**: At least one maintainer approval required
5. **Merge**: Maintainers handle the merge process

## 🔒 Security Considerations

### Security Guidelines

1. **Never Commit Secrets**
   - Use environment variables
   - Review commits before pushing
   - Use `.env` files (never committed)

2. **Input Validation**
   - Validate all user inputs
   - Use Pydantic/Zod schemas
   - Sanitize data before processing

3. **Authentication & Authorization**
   - Follow OAuth 2.0 / OpenID Connect standards
   - Implement proper session management
   - Use secure token storage

4. **Database Security**
   - Use parameterized queries
   - Implement proper access controls
   - Regular security audits

### Reporting Security Issues

For security vulnerabilities, please see our [Security Policy](SECURITY.md).

## 📚 Documentation

### Documentation Standards

1. **Code Documentation**
   - Document all public APIs
   - Include examples in docstrings
   - Maintain inline comments for complex logic

2. **API Documentation**
   - Update OpenAPI/Swagger specs
   - Include request/response examples
   - Document error codes and messages

3. **User Documentation**
   - Keep README.md updated
   - Maintain setup guides
   - Update architecture documentation

### Documentation Location

- **API Docs**: Auto-generated at `/docs` endpoint
- **User Guides**: `/docs` directory
- **Code Docs**: Inline documentation
- **Architecture**: `ARCHITECTURE.md`

## 👥 Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Pull Requests**: Code contributions and reviews

### Getting Help

1. **Documentation**: Check existing documentation first
2. **Search Issues**: Look for existing solutions
3. **Create Issue**: Provide detailed information
4. **Join Discussions**: Ask questions in GitHub Discussions

### Recognition

Contributors are recognized through:
- GitHub contributor graphs
- Mention in release notes
- Attribution in documentation

## 📅 Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- Breaking changes increment MAJOR
- New features increment MINOR
- Bug fixes increment PATCH

### Release Checklist

1. Update CHANGELOG.md
2. Update version numbers
3. Run full test suite
4. Create release PR
5. Tag release after merge
6. Publish release notes

## 🙏 Thank You

Your contributions make this project better for everyone. Whether you're fixing bugs, adding features, improving documentation, or helping other users, your effort is appreciated!

---

## Quick Reference Commands

```bash
# Setup
make setup                  # Initial project setup
make dev-up                # Start development environment

# Testing  
make test                  # Run all tests
make test-backend          # Backend tests only
make test-frontend         # Frontend tests only

# Code Quality
make lint                  # Run all linters
make format               # Format all code
make security-audit       # Security checks

# Documentation
make docs                 # Generate documentation
make docs-serve          # Serve documentation locally
```

For more detailed information, see our [Development Setup Guide](docs/setup/DEVELOPMENT.md).