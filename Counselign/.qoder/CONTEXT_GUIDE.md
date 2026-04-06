# Qoder Context Guide

This guide helps you quickly provide the right context to Qoder for maximum effectiveness.

## Quick Reference

### Always Include in Context
When starting a conversation or task, attach these files/folders:

1. **Memory Bank** (most important):
   - `memory-bank/activeContext.md`
   - `memory-bank/progress.md`
   - `memory-bank/systemPatterns.md`
   - Or just attach entire `memory-bank/` folder

2. **Qoder Rules**:
   - `.qoder/` folder (contains all rules)

### For Feature Development
Attach:
- Memory Bank folder
- `.qoder/` folder
- Relevant feature directory from `lib/`
- Related API config if needed

### For Bug Fixes
Attach:
- Memory Bank folder
- `.qoder/` folder
- File(s) with the bug
- Related test files if applicable

### For Architecture Questions
Attach:
- Memory Bank folder (especially systemPatterns.md)
- `.qoder/rules/` folder
- Relevant directories for context

### For New Features
Attach:
- Memory Bank folder
- `.qoder/` folder
- Similar existing feature code (as reference)
- Target location for new code

## How Qoder Uses Context

### Memory Bank Files
**Qoder reads these to understand:**
- Current project state
- What you're working on
- Recent changes
- Known issues
- Next steps
- Architecture patterns
- Tech stack

### Qoder Rules
**Qoder reads these to know:**
- Project coding standards
- Security requirements
- Testing expectations
- Documentation workflow
- Architecture guidelines
- Language-specific rules

### Code Files
**Qoder reads these to:**
- Understand implementation
- Identify patterns
- Find similar code
- Locate dependencies
- Check consistency

## Optimization Tips

### Minimal Context for Simple Tasks
For quick questions or simple changes:
```
- activeContext.md
- The specific file to change
```

### Standard Context for Most Tasks
For regular development work:
```
- memory-bank/ folder
- .qoder/ folder
- Relevant feature folder
```

### Full Context for Complex Tasks
For major features or refactoring:
```
- memory-bank/ folder
- .qoder/ folder
- All related feature folders
- API configuration
- Related tests
```

## Context Commands

### Update Memory Bank
**When to use:**
- After completing significant work
- When switching focus areas
- Weekly/daily to keep current
- Before sharing with team

**What to attach:**
- All memory-bank files
- Recent changed files

**Say:**
"Update memory bank" or "update the memory bank"

### Create Feature Plan
**When to use:**
- Starting new feature
- Complex changes needed
- Architecture decisions required

**What to attach:**
- memory-bank folder
- .qoder folder
- Similar feature reference

**Say:**
"Plan: [feature description]" or "Enter planner mode for [feature]"

## File Attachment Best Practices

### Use Folder Attachments
✅ **Good:** Attach `memory-bank/` folder
❌ **Avoid:** Selecting each .md file individually

✅ **Good:** Attach `lib/studentscreen/` folder
❌ **Avoid:** Selecting each .dart file individually

### Select Relevant Code
✅ **Good:** Highlight specific function/class with issue
✅ **Good:** Show example of desired pattern
❌ **Avoid:** Selecting entire large files when only part is relevant

### Progressive Context
Start with less context, add more if needed:
1. First: Memory Bank + specific file
2. If needed: Add related files
3. If still needed: Add feature folder
4. Last resort: Add multiple folders

## Common Scenarios

### "Fix this bug"
**Attach:**
1. `memory-bank/activeContext.md`
2. File with bug (with selection highlighting bug)
3. Test file if exists

### "Add this feature"
**Attach:**
1. `memory-bank/` folder
2. `.qoder/` folder
3. Similar existing feature folder
4. Target location for new feature

### "How does X work?"
**Attach:**
1. `memory-bank/systemPatterns.md`
2. Relevant feature folder
3. Related API files

### "Review my code"
**Attach:**
1. `.qoder/rules/` folder
2. Changed files
3. Related tests

### "Setup new screen"
**Attach:**
1. `memory-bank/` folder
2. `.qoder/` folder
3. Similar screen as example
4. `lib/routes.dart`

## Memory Bank Maintenance

### Daily Updates
After significant work, say:
"Update memory bank"

Then attach:
- All memory-bank files
- Recently changed files

### Weekly Reviews
Review and update:
- progress.md (completed work)
- activeContext.md (current focus)
- Known issues

### After Major Changes
Update:
- systemPatterns.md (new patterns)
- techContext.md (dependencies)
- progress.md (status)

## Getting Best Results

### Be Specific
❌ "Fix the appointment screen"
✅ "Fix the date picker in appointment cancellation dialog that shows wrong month"

### Provide Context
❌ "Add validation"
✅ "Add email validation to the student profile form, similar to the existing login form validation"

### Reference Examples
❌ "Create a new screen"
✅ "Create a counselor appointments screen similar to student appointments screen"

### Show Desired Behavior
✅ Highlight good code: "Do it like this"
✅ Highlight bad code: "Fix this pattern"
✅ Provide examples: "Like X but for Y"

## Qoder's Workflow

When you provide context, Qoder:

1. **Reads Memory Bank** - Understands current state
2. **Reads Rules** - Knows standards to follow
3. **Analyzes Code** - Studies provided files
4. **Plans Approach** - Determines best solution
5. **Implements** - Makes changes
6. **Updates Docs** - Updates Memory Bank
7. **Verifies** - Checks consistency

## Context Checklist

Before starting a task, verify:
- [ ] Memory Bank attached (at minimum activeContext.md)
- [ ] Qoder rules attached (.qoder/ folder)
- [ ] Relevant code files attached
- [ ] Task clearly described
- [ ] Examples provided if applicable
- [ ] Expected outcome explained

## Remember

**More context = Better results**
But also: **Relevant context > More context**

Focus on quality of context, not just quantity. Attach the Memory Bank and Qoder rules, then add specific code relevant to your task.
