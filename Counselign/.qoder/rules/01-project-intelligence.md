---
trigger: always_on
alwaysApply: true
---
# Project Intelligence & Memory Bank Authority

## Memory Bank is Primary Source of Truth

**ALWAYS read Memory Bank files at task start:**
- `memory-bank/projectbrief.md` - Project foundation and scope
- `memory-bank/productContext.md` - Product vision and user goals
- `memory-bank/activeContext.md` - Current work and recent changes
- `memory-bank/systemPatterns.md` - Architecture and design patterns
- `memory-bank/techContext.md` - Tech stack and configuration
- `memory-bank/progress.md` - Status and known issues

## After Meaningful Changes

**Update relevant Memory Bank files:**
- `activeContext.md`: Current focus, recent changes, next steps
- `systemPatterns.md`: New/changed endpoints, navigation, patterns
- `techContext.md`: Tech/config/schema changes
- `progress.md`: Status updates, completed work, known issues

## Code Quality Standards

**Naming Conventions:**
- Prefer clear, verbose naming over cryptic abbreviations
- Use complete words with correct spelling
- Exceptions: standard abbreviations (API, URL, ID, etc.)

**Change Management:**
- Keep edits small and incremental
- Write clear, descriptive commit messages
- One logical change per commit
- Test before committing

## Tool Usage

**Search and Navigation:**
- Use `search_codebase` for semantic understanding
- Use `search_symbol` for class/method lookups
- Use `grep_code` for pattern matching
- Read files completely when context is needed

**Parallel Operations:**
- Execute independent operations simultaneously
- Read multiple files in parallel
- Search different patterns concurrently
- NEVER parallelize file edits or terminal commands

## Documentation Philosophy

**Do NOT create:**
- Markdown documentation files unless explicitly requested
- README files proactively
- Status reports or progress docs (use Memory Bank instead)
- Test documentation (keep in code comments)

**DO create:**
- Memory Bank updates after changes
- Inline code comments for complex logic
- Type definitions and interfaces
- Unit tests alongside features
