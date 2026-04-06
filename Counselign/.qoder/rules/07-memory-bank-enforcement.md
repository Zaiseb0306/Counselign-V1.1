---
trigger: always_on
alwaysApply: true
---
# Memory Bank Enforcement & Workflow

## Critical Rules - Always Apply

### Before Starting Any Task
**MUST read these Memory Bank files:**
1. `memory-bank/projectbrief.md` - Foundation and scope
2. `memory-bank/productContext.md` - Product vision
3. `memory-bank/activeContext.md` - Current state
4. `memory-bank/systemPatterns.md` - Architecture
5. `memory-bank/techContext.md` - Tech stack
6. `memory-bank/progress.md` - Status

**Why:**
- Context resets between sessions
- Memory Bank is sole source of truth
- Ensures consistency with project
- Prevents rework and conflicts

### After Making Changes
**MUST update relevant files:**
- `activeContext.md` - Document what changed, why, and next steps
- `systemPatterns.md` - If architecture/routes affected
- `techContext.md` - If dependencies/config changed
- `progress.md` - Update completion status

**Update Format:**
```markdown
## Current Chat Fix Log
### [Date/Time] - Feature/Fix Name
- Changed: specific changes made
- Reason: why change was needed
- Impact: what this affects
- Next: what should happen next
```

## Priority Hierarchy

### 1. Memory Bank Rules (Highest Priority)
- Overrides all other guidance
- Represents established patterns
- Captures project-specific decisions
- Contains user preferences

### 2. Qoder Rules (Second Priority)
- General best practices
- Language/framework standards
- Security guidelines
- Testing standards

### 3. General Knowledge (Lowest Priority)
- Only when not contradicted above
- Standard practices
- Common patterns

## Change Documentation

### What to Document
**Always Document:**
- New features added
- Bugs fixed
- Architecture changes
- Configuration updates
- Dependency changes
- API modifications
- State management changes
- Navigation changes

**Don't Document:**
- Trivial formatting changes
- Comment updates only
- Temporary debugging code
- Experimental code (before commit)

### Where to Document

#### activeContext.md
**Use for:**
- Current work in progress
- Recent changes (last 5-10)
- Next immediate steps
- Active blockers
- Current decisions being made

**Example:**
```markdown
## Current Focus
Working on appointment cancellation feature for students.

## Recent Changes
- Added CancelAppointmentDialog widget
- Implemented cancellation API call
- Updated appointment state management
- Added error handling for cancellation

## Next Steps
- Add cancellation confirmation
- Update appointment list UI
- Add unit tests
- Update progress.md
```

#### systemPatterns.md
**Use for:**
- Route additions/changes
- New feature modules
- Architecture decisions
- State patterns
- Navigation flows
- Component relationships

**Example:**
```markdown
## Navigation Routes
- /student/appointments/cancel - Cancellation flow
  - Shows cancellation dialog
  - Confirms with user
  - Calls API
  - Refreshes list
```

#### progress.md
**Use for:**
- Completed features
- Known issues
- Planned work
- Testing status
- Deployment readiness

**Example:**
```markdown
## Completed
- ✅ Appointment cancellation
  - Student can cancel appointments
  - Confirmation dialog
  - API integration
  - Error handling
  - Tests: pending

## Known Issues
- None for cancellation feature
```

## Backend Reference Policy

### Backend is Reference Only
**Rules:**
- `Counselign/` directory is reference implementation
- Do NOT modify backend unless explicitly requested
- Focus changes on Flutter frontend (`lib/`)
- Backend changes require explicit user approval

### When Referencing Backend
**Use backend code to:**
- Understand API contracts
- Check request/response formats
- Verify endpoint availability
- Understand data models
- Check validation rules

**Document in Memory Bank:**
- Endpoints used by frontend
- Request/response structures
- Authentication requirements
- Error response formats

## Consistency Guidelines

### Code Style Consistency
**Ensure:**
- Matches existing code style in file
- Follows project conventions
- Uses established patterns
- Maintains naming conventions

### Pattern Consistency
**Ensure:**
- State management follows project pattern
- API calls use established client
- Navigation uses defined routes
- Error handling uses standard approach
- Validation uses common validators

### Documentation Consistency
**Ensure:**
- Memory Bank entries use consistent format
- Commit messages follow style guide
- Code comments match project style
- Test descriptions are clear

## Verification Checklist

### Before Declaring Complete
**Verify:**
- [ ] All Memory Bank files read
- [ ] Relevant files updated
- [ ] Changes documented in activeContext.md
- [ ] Progress.md reflects current status
- [ ] No contradictions with existing patterns
- [ ] Code follows project conventions
- [ ] Tests added/updated if needed
- [ ] No debug/temporary code remains

### Quality Checks
**Verify:**
- [ ] Code compiles without errors
- [ ] No analyzer warnings
- [ ] Tests pass (if applicable)
- [ ] Follows security guidelines
- [ ] Error handling implemented
- [ ] No sensitive data exposed

## User Request Handling

### "Update Memory Bank" Command
**When user says "update memory bank":**
1. Read ALL Memory Bank files (required)
2. Review current state thoroughly
3. Update relevant files:
   - activeContext.md (always check)
   - systemPatterns.md (if architecture changed)
   - techContext.md (if tech/config changed)
   - progress.md (always check)
4. Document what was updated and why
5. Confirm completion with summary

### Explicit Backend Changes
**Only modify backend when:**
- User explicitly requests it
- Backend modification is clearly specified
- You have confirmed understanding
- You have documented the change plan

**After backend changes:**
- Update techContext.md
- Document endpoints in systemPatterns.md
- Note in activeContext.md
- Update progress.md

## Memory Bank File Relationships

### Dependency Flow
```
projectbrief.md (rarely changes)
    ↓
    ├─→ productContext.md (occasional updates)
    ├─→ systemPatterns.md (frequent updates)
    └─→ techContext.md (periodic updates)
            ↓
        activeContext.md (very frequent updates)
            ↓
        progress.md (very frequent updates)
```

### Update Frequency
- **projectbrief.md**: Rare (major pivots only)
- **productContext.md**: Occasional (requirement changes)
- **systemPatterns.md**: Frequent (new features/patterns)
- **techContext.md**: Periodic (dependencies/config)
- **activeContext.md**: Very frequent (daily work)
- **progress.md**: Very frequent (task completion)

## Integration with Qoder Rules

### Rule Priority
1. Check Memory Bank first
2. Apply specific Qoder rules (security, architecture, etc.)
3. Use Dart/Flutter standards
4. Apply general best practices

### When Rules Conflict
**Resolution order:**
1. Explicit user instruction (highest)
2. Memory Bank documented pattern
3. Project-specific rule (.qoder/rules)
4. Language/framework standard
5. General best practice (lowest)

### Learning and Adaptation
**When discovering new patterns:**
1. Validate pattern is intentional
2. Document in appropriate rule file
3. Add to Memory Bank if project-specific
4. Apply consistently going forward

**When finding inconsistencies:**
1. Ask user for clarification
2. Document decision in Memory Bank
3. Update rules if needed
4. Refactor if requested
