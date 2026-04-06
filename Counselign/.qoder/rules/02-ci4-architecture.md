---
trigger: always_on
alwaysApply: true
---
# CodeIgniter 4 Backend Architecture

## Project Structure

**Entry Point:**
- `Counselign/public/index.php` - Application bootstrap

**Core Directories:**
- `Counselign/app/Config/` - Configuration files
- `Counselign/app/Controllers/` - Request handlers
- `Counselign/app/Models/` - Database layer
- `Counselign/app/Views/` - Response templates
- `Counselign/app/Services/` - Business logic
- `Counselign/app/Libraries/` - Reusable components
- `Counselign/app/Helpers/` - Utility functions

**Routing:**
- `Counselign/app/Config/Routes.php` - Route definitions

## Architecture Guidelines

### Controllers (Thin Layer)
**Responsibilities:**
- Orchestrate requests
- Delegate to models/services
- Return views or JSON responses
- Handle HTTP concerns only

**Avoid:**
- Business logic in controllers
- Direct database queries
- Complex computations
- Data transformations

### Models (Data Layer)
**Responsibilities:**
- All database access
- Data validation
- Query building
- Entity management

**Rules:**
- Use CI4's Query Builder
- Avoid raw SQL when possible
- Implement validation rules
- Return domain entities

### Services (Business Logic)
**Responsibilities:**
- Complex business operations
- Multi-model coordination
- External API integration
- Transaction management

**Patterns:**
- Single Responsibility Principle
- Dependency injection
- Return value objects
- Handle exceptions gracefully

### Views (Presentation)
**Responsibilities:**
- Render HTML
- Display data only
- Client-side interactions

**Avoid:**
- Database queries
- Business logic
- Direct model access
- Sensitive data exposure

## Security Standards

**Input Validation:**
- Use CI4 Validation library
- Validate all user inputs
- Sanitize before processing
- Use form validation rules

**Filters & Middleware:**
- CSRF protection enabled
- Authentication filters
- Authorization checks
- Rate limiting where needed

**Error Handling:**
- Use CI4 Logger for server errors
- Never expose stack traces to users
- Use session flash for user feedback
- Log security-relevant events

**Database Security:**
- Use parameterized queries
- Enable query logging in development
- Implement soft deletes where appropriate
- Use database transactions for data integrity

## Documentation Requirements

**When Adding/Modifying Endpoints:**
- Document in `memory-bank/systemPatterns.md`
- Update `memory-bank/activeContext.md`
- Add route comments
- Document request/response formats

**Database Changes:**
- Update `memory-bank/techContext.md`
- Create migration files
- Document schema changes
- Update SQL patches if needed

## Backend Reference Only

**Important:**
- Backend (`Counselign/`) is reference-only
- Do not modify unless explicitly requested
- Focus changes on Flutter frontend
- Log client-side changes in Memory Bank
