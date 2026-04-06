---
trigger: always_on
alwaysApply: true
---
# Documentation & Workflow Standards

## Memory Bank Maintenance

### Update Triggers
**Always update Memory Bank after:**
- Implementing new features
- Fixing significant bugs
- Changing architecture
- Discovering new patterns
- User requests "update memory bank"

### File-Specific Guidelines

#### activeContext.md
**Update when:**
- Starting new work
- Completing tasks
- Changing focus
- Discovering issues

**Contains:**
- Current focus area
- Recent changes log
- Next planned steps
- Active decisions
- Blockers or considerations

#### systemPatterns.md
**Update when:**
- Adding routes
- Creating new patterns
- Changing navigation
- Adding feature modules
- Modifying architecture

**Contains:**
- Navigation structure
- Route definitions
- Feature module organization
- State management patterns
- Component relationships

#### techContext.md
**Update when:**
- Adding dependencies
- Changing configuration
- Database schema changes
- Environment updates
- Build tool modifications

**Contains:**
- Tech stack details
- Dependencies list
- Configuration files
- Database schema
- Build/deployment setup

#### progress.md
**Update when:**
- Completing features
- Identifying issues
- Changing status
- Starting new work
- Resolving blockers

**Contains:**
- Completed features
- In-progress work
- Planned features
- Known issues
- Testing status

#### productContext.md
**Update when:**
- Requirements change
- Adding major features
- Pivoting direction
- User feedback incorporated

**Contains:**
- Product vision
- User problems solved
- Core functionality
- User experience goals
- Success metrics

#### projectbrief.md
**Update rarely, only when:**
- Core scope changes
- Project goals shift
- Major pivots
- Stakeholder changes

**Contains:**
- Project foundation
- Core requirements
- Business goals
- Constraints
- Success criteria

## Commit Workflow

### Commit Style
**Format:**
```
<type>: <concise description>

<detailed explanation if needed>
<affected Memory Bank files>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructuring
- `docs:` Documentation only
- `test:` Test additions/changes
- `chore:` Maintenance tasks

**Examples:**
```
feat: Add appointment cancellation for students

Implemented cancellation dialog, API integration, and state management.
Updated: activeContext.md, systemPatterns.md, progress.md
```

### Commit Size
**Guidelines:**
- Small, incremental changes
- One logical change per commit
- Complete, working state
- Testable independently

**Avoid:**
- Mixing multiple features
- Incomplete implementations
- Breaking changes without migration
- Uncommitted experimental code

## Testing Workflow

### Before Committing
**Required Checks:**
```bash
# Flutter Analysis
flutter analyze

# Unit Tests
flutter test

# Widget Tests (if applicable)
flutter test test/widgets

# Integration Tests (if applicable)
flutter test integration_test

# Format Check
flutter format . --set-exit-if-changed
```

### Test Coverage Goals
- **Unit Tests:** All business logic
- **Widget Tests:** Complex UI components
- **Integration Tests:** Critical user flows
- **E2E Tests:** Key features end-to-end

### Test Maintenance
**When to Update Tests:**
- Changing tested code
- Fixing bugs (add regression tests)
- Refactoring (verify tests still valid)
- Adding features (add new tests)

## Code Review Standards

### Self-Review Checklist
**Before Requesting Review:**
- [ ] Code follows project patterns
- [ ] Memory Bank updated
- [ ] Tests added/updated
- [ ] No debug code
- [ ] Comments for complex logic
- [ ] Follows naming conventions
- [ ] Error handling implemented
- [ ] Security considerations addressed

### Review Focus Areas
**Prioritize:**
- Security vulnerabilities
- Logic correctness
- Performance concerns
- Maintainability
- Test coverage
- Documentation accuracy

## Development Workflow

### Feature Development
1. **Plan:**
   - Read relevant Memory Bank files
   - Understand requirements
   - Design approach
   - Identify affected components

2. **Implement:**
   - Small, incremental commits
   - Test as you go
   - Update docs inline
   - Handle errors

3. **Verify:**
   - Run tests
   - Manual testing
   - Check analyzer
   - Review changes

4. **Document:**
   - Update Memory Bank
   - Add code comments
   - Update inline docs
   - Reference in commits

### Bug Fix Workflow
1. **Reproduce:**
   - Create failing test
   - Document steps
   - Identify root cause

2. **Fix:**
   - Minimal change
   - Verify test passes
   - Check for regressions

3. **Document:**
   - Update known issues
   - Add regression test
   - Note in activeContext.md

## Build & Deployment

### Pre-Release Checklist
**Flutter:**
- [ ] All tests passing
- [ ] No analyzer warnings
- [ ] Performance profiled
- [ ] Release build tested
- [ ] Assets optimized
- [ ] Version bumped

**Backend:**
- [ ] Database migrations tested
- [ ] Environment configs verified
- [ ] Dependencies updated
- [ ] Security audit passed
- [ ] Logs configured
- [ ] Backups scheduled

### Platform-Specific

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Desktop:**
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

## Documentation Philosophy

### What NOT to Create
**Avoid proactively creating:**
- README files (unless explicitly requested)
- API documentation files (use inline docs)
- Test documentation (comments in tests)
- Status reports (use Memory Bank)
- Architecture diagrams as separate files

### What to Maintain
**Always keep updated:**
- Memory Bank files
- Inline code comments
- API doc comments
- Test descriptions
- Configuration files

### Documentation Location
**Inline Documentation:**
- Complex algorithms → code comments
- API contracts → doc comments
- Widget usage → doc comments
- Test purposes → test descriptions

**Memory Bank:**
- System architecture
- Feature status
- Current work
- Technical decisions
- Known issues

## Continuous Improvement

### Pattern Recognition
**When discovering patterns:**
1. Validate pattern is consistent
2. Document in appropriate rule file
3. Apply to future work
4. Refactor old code if valuable

### Learning from Issues
**When bugs occur:**
1. Add to known issues
2. Create regression test
3. Document root cause
4. Update rules if needed
5. Check for similar issues

### Refactoring Guidelines
**When to refactor:**
- Three strikes rule (third duplication)
- Before adding related features
- When tests are green
- During feature work, not separately

**Refactoring limits:**
- Keep scope small
- One pattern at a time
- Maintain test coverage
- No behavior changes
