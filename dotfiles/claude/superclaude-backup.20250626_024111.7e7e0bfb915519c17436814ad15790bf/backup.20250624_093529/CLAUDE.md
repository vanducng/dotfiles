# Duc's Data Kitchen 🍳

## Environment Setup
- **Python Management**: mise + uv for Python version and dependency management
- **Package Management**: Use `uv` for fast, reliable dependency resolution
- **Environment Activation**: `mise use python@3.11` (or latest stable version)

## Code Style & Standards

### Python
- **Formatter**: ruff (default settings with modifications below)
- **Line Length**: 120 characters
- **Quotes**: Double quotes by default
- **Spacing**: No extra spaces around operators/brackets
- **Type Hints**: Use modern type hints (Python 3.10+ style)
  - Use `dict` instead of `Dict`, `list` instead of `List`
  - Use `Optional[T]` or `T | None` for nullable types
  - Type hint all function parameters and return values where practical

### Documentation
- **Comments**: Avoid obvious comments; focus on "why" not "what"
- **Docstrings**: Required for:
  - Complex methods with business logic
  - Core functions used across multiple modules
  - Public API functions
  - Data transformation functions

### SQL
- **Style**: Use uppercase for SQL keywords, lowercase for table/column names
- **Indentation**: 2 spaces for nested queries
- **Line Breaks**: Break long queries into readable chunks

## Technology Stack

### Core Tools
- **Orchestration**: Apache Airflow
- **Data Transformation**: dbt (data build tool)
- **Database**: Snowflake
- **Containerization**: Docker
- **Web Framework**: Django (for web projects)

### Development Workflow
- **Linting**: `ruff check .` (run before commits)
- **Formatting**: `ruff format .` (run before commits)
- **Type Checking**: `mypy .` (if configured in project)
- **Testing**: `pytest` (run relevant tests, not entire suite unless specified)

## Git Workflow

### Commit Convention
Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
- `feat:` new features
- `fix:` bug fixes
- `docs:` documentation changes
- `style:` formatting, missing semicolons, etc.
- `refactor:` code restructuring without functional changes
- `test:` adding or updating tests
- `chore:` maintenance tasks

### Git Best Practices
- **Staging**: Always stage specific files individually - never use `git add .` or `git add -A`
- **Review Changes**: Use `git diff` before committing
- **Atomic Commits**: One logical change per commit
- **Descriptive Messages**: Clear, concise commit messages explaining the "why"

## Project-Specific Commands

### Python/Django Projects
- `uv run manage.py runserver` - Start Django development server
- `uv run manage.py migrate` - Apply database migrations
- `uv run manage.py test` - Run Django tests
- `uv run python -m pytest` - Run pytest tests

### dbt Projects
- `dbt run` - Execute models
- `dbt test` - Run data tests
- `dbt docs generate && dbt docs serve` - Generate and serve documentation
- `dbt run --select model_name+` - Run specific model and downstream dependencies

### Database Access (via Makefile)
- `make melody-dbshell` - Open PostgreSQL shell for direct database queries
- `make psql` - Alternative PostgreSQL connection
- `make melody-shell` - Django shell with database access via ORM

### Docker
- `docker-compose up -d` - Start services in background
- `docker-compose logs -f service_name` - Follow logs for specific service
- `docker-compose exec service_name bash` - Execute bash in running container

### Airflow
- `airflow dags test dag_id execution_date` - Test DAG
- `airflow tasks test dag_id task_id execution_date` - Test specific task
- `airflow db upgrade` - Upgrade Airflow database

## Code Patterns

### Error Handling
- Use specific exception types
- Log errors with context information
- Fail fast for configuration errors
- Graceful degradation for external service failures

### Data Processing
- Validate data early in pipelines
- Use batch processing for large datasets
- Implement proper logging for data quality issues
- Document data lineage and transformations

### Configuration
- Use environment variables for configuration
- Separate config by environment (dev/staging/prod)
- Never commit secrets or credentials
- Use connection pooling for database connections

## Testing Guidelines
- **Unit Tests**: Test individual functions/methods
- **Integration Tests**: Test data pipelines end-to-end
- **Data Tests**: Validate data quality and business rules
- **Mock External Services**: Use mocks for APIs, databases in unit tests

## Security Considerations
- Never log sensitive data (PII, credentials, API keys)
- Use parameterized queries to prevent SQL injection
- Implement proper authentication/authorization
- Regularly update dependencies for security patches

## Performance Guidelines
- Profile code before optimizing
- Use connection pooling for database operations
- Implement proper indexing strategies
- Monitor query performance in Snowflake
- Use efficient data structures and algorithms