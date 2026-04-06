---
trigger: always_on
alwaysApply: true
---
# Flutter Frontend Architecture

## Project Structure

**Entry Point:**
- `lib/main.dart` - App bootstrap, providers, theme
- `lib/routes.dart` - Route table and navigation

**Feature Modules:**
- `lib/landingscreen/` - Landing flow, dialogs, state
- `lib/studentscreen/` - Student features and UI
- `lib/counselorscreen/` - Counselor features and UI
- `lib/adminscreen/` - Admin features and UI

**Feature Organization (per module):**
```
feature_screen/
├── models/          # Data models
├── state/           # State management
├── widgets/         # Feature-specific widgets
└── *_screen.dart    # Screen entry points
```

**Shared Layers:**
- `lib/api/` - API clients, config, interceptors
- `lib/utils/` - Helpers, formatters, constants
- `lib/widgets/` - Reusable shared widgets

## Architecture Principles

### Clean Architecture
**Layer Separation:**
- Presentation (Widgets/Screens)
- State Management (Providers/Controllers)
- Domain (Models/Entities)
- Data (API/Repositories)

**Dependencies Flow:**
- Outer layers depend on inner layers
- Inner layers independent of outer
- Use abstractions at boundaries

### State Management
**Preferred Approach:**
- Use Riverpod for state management
- Use freezed for immutable state
- Controller pattern for business logic
- Keep state close to where it's used

**State Organization:**
- Controllers in `state/` directories
- Controllers update UI state
- Methods as inputs, state as output
- Use `keepAlive` when state should persist

**Avoid:**
- Global mutable state
- setState in large widgets
- Business logic in widgets
- Shared state without clear ownership

### Widget Architecture

**Keep Screens Lean:**
- Move logic to state/services
- Extract complex widgets
- Use composition over nesting
- Const constructors where possible

**Avoid Deep Nesting:**
- Break down into smaller widgets
- Extract reusable components
- Flatten widget trees
- Improves readability and performance

**Widget Guidelines:**
- Single responsibility per widget
- Less than 300 lines per file
- Extract private widgets to separate files if >50 lines
- Use const constructors for static widgets

### Data Layer

**Models:**
- Keep models immutable
- Implement `fromJson`/`toJson`
- Use proper typing
- Avoid logic in models

**API Integration:**
- Centralize in `lib/api/`
- Use interceptors for auth
- Handle errors gracefully
- Timeout configurations in config

**Repository Pattern:**
- Abstract data sources
- Cache when appropriate
- Handle offline scenarios
- Return domain models

## Code Quality Standards

### Naming Conventions
- **Files/Directories:** `snake_case`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Constants:** `UPPERCASE` (environment vars)
- **Private members:** `_leadingUnderscore`

### Function Standards
- Start with verbs
- Single purpose, <20 instructions
- Use descriptive names
- Boolean functions: `isX`, `hasX`, `canX`

### Type Safety
- Always declare types
- Avoid `dynamic` when possible
- Create necessary types
- Use generics appropriately

## Testing Strategy

### Unit Tests
- Test each public function
- Test models and utilities
- Test state/controller logic
- Use mocks for dependencies

### Widget Tests
- Test widget rendering
- Test user interactions
- Test state changes
- Verify UI behavior

### Integration Tests
- Test complete user flows
- Test API integration
- Test navigation
- Test error scenarios

**Testing Commands:**
```bash
flutter test                    # Unit and widget tests
flutter test integration_test   # Integration tests
flutter analyze                 # Static analysis
```

## Quality Gates

**Before Commits:**
- Run `flutter analyze` - zero warnings
- Run tests - all passing
- Check formatting - `flutter format .`
- Verify no debug code

**Performance:**
- Use const constructors
- Minimize rebuilds
- Profile complex screens
- Optimize list rendering

## Route Management

**Centralized Routing:**
- All routes in `lib/routes.dart`
- Use named routes
- Type-safe navigation
- Use AutoRoute if available

**Navigation Patterns:**
- Push for forward navigation
- Pop for backward navigation
- Replace for auth flows
- Guards for protected routes

## Dependency Management

**Using GetIt:**
- Singleton for services/repositories
- Factory for use cases
- Lazy singleton for controllers
- Register at app startup

**Composer (for backend):**
- Managed via `Counselign/composer.json`
- Run in backend directory only

**Flutter Dependencies:**
- Managed via `pubspec.yaml`
- Pin major versions
- Document why packages are used
- Regular security updates
