# Custom /todo Command Documentation

## Overview
The `/todo` command is a custom slash command properly implemented following Claude Code's official slash command guidelines. It creates comprehensive todo lists while maintaining clean code organization and proper documentation.

## Implementation Details
The command is implemented as Markdown files in two locations:
- **User-level (Global)**: `~/.claude/commands/todo.md`
- **Project-level**: `.claude/commands/todo.md`

## Core Principles
1. **Comprehensiveness**: Never skip any task, no matter how small
2. **Clean Organization**: Maintain clean folder structure without pollution
3. **Documentation**: Always document changes to core files
4. **Traceability**: Track all modifications with rollback plans

## Command Syntax

### Basic Usage
```bash
/todo [options] [task description]
```

### User-Level Options (Available Globally)
- `--all` - Create todos for all pending tasks in conversation
- `--from-file <path>` - Create todos from tasks listed in a file
- `--priority <level>` - Set priority (high/medium/low) for tasks
- `--category <name>` - Categorize tasks (feature/bug/refactor/docs/test)
- `--estimate <time>` - Add time estimates to tasks

### Project-Level Options (Enterprise Auth Template)
- `--component <type>` - Specify component (backend/frontend/flutter/infra)
- `--feature <name>` - Associate with feature (auth/rbac/audit/session)
- `--sprint <id>` - Assign to sprint/milestone
- `--assignee <name>` - Assign to team member
- `--test-required` - Mark as requiring test coverage

## Examples

### Example 1: Simple Task List
```bash
/todo "Implement user authentication"
```
Creates:
- Implement user authentication

### Example 2: Comprehensive Feature Implementation
```bash
/todo --component all --feature auth --priority high --test-required "Implement OAuth2 with Google"
```
Creates:
- Backend: API endpoint implementation
- Backend: Service layer logic
- Backend: Database model updates
- Frontend: Form component
- Frontend: API client integration
- Flutter: Screen implementation
- Tests: Unit tests
- Tests: Integration tests
- Documentation: API docs update

### Example 3: Refactoring with Documentation
```bash
/todo --category refactor --priority medium "Refactor user service for better performance"
```
Creates:
- Analyze current user service performance
- Identify bottlenecks
- Refactor database queries
- Optimize caching strategy
- Update service tests
- Document changes in CHANGES.md
- Performance benchmarking

### Example 4: Bug Fix Workflow
```bash
/todo --category bug --priority high --component backend "Fix session timeout issue"
```
Creates:
- Reproduce session timeout issue
- Debug session management code
- Implement fix in session service
- Add unit tests for edge cases
- Test fix in development environment
- Document fix in CHANGES.md
- Create regression test

## File Organization

### Clean Structure Maintained
```
project/
├── src/                 # Core code (modify existing)
├── tests/               # Test files (add as needed)
├── docs/
│   └── CHANGES.md      # Document all modifications
└── .todo/
    ├── current.json    # Active todos (git-ignored)
    ├── completed.json  # Archived todos
    └── metrics.json    # Task metrics

```

### CHANGES.md Template
```markdown
## Core File Modifications - 2025-01-13

### Modified Files
1. **backend/app/services/auth_service.py**
   - Lines: 45-89
   - Reason: Added OAuth2 Google authentication support
   - Changes: Implemented Google OAuth flow with JWT generation
   - Rollback: git revert [commit-hash]

### Impact Analysis
- Affected features: User authentication, session management
- Risk level: Medium
- Testing required: OAuth flow, token generation, session creation
```

## Best Practices

### DO's ✅
- Create todos for ALL tasks mentioned
- Document every core file change
- Maintain clean folder structure
- Include testing tasks
- Add documentation tasks
- Specify clear success criteria
- Include rollback plans

### DON'Ts ❌
- Skip "obvious" tasks
- Create unnecessary files
- Pollute the file system
- Modify without documentation
- Ignore dependencies
- Make irreversible changes
- Skip testing requirements

## Integration with Development Workflow

### 1. Planning Phase
```bash
# Create comprehensive task list from requirements
/todo --from-file requirements.txt --category feature
```

### 2. Implementation Phase
```bash
# Track implementation progress
/todo --component backend --sprint current "Implement new feature"
```

### 3. Testing Phase
```bash
# Create test todos
/todo --category test --test-required "Test all authentication flows"
```

### 4. Documentation Phase
```bash
# Document all changes
/todo --category docs "Update API documentation and changelog"
```

## Automated Triggers

The `/todo` command can be automatically triggered by:
1. **PR Creation**: Creates review todos
2. **Test Failure**: Creates fix todos
3. **Security Issues**: Creates security todos
4. **Performance Regression**: Creates optimization todos
5. **Dependency Updates**: Creates update todos

## Command Implementation Details

### Task Processing Flow
```typescript
interface TodoProcessing {
  // 1. Parse user input
  parseInput(input: string): Task[];

  // 2. Apply options
  applyOptions(tasks: Task[], options: Options): Task[];

  // 3. Generate comprehensive list
  expandTasks(tasks: Task[]): DetailedTask[];

  // 4. Organize by component
  organizeTasks(tasks: DetailedTask[]): OrganizedTasks;

  // 5. Create documentation
  documentChanges(tasks: OrganizedTasks): Documentation;

  // 6. Output todos
  outputTodos(tasks: OrganizedTasks): void;
}
```

### Quality Assurance Checklist
- [ ] All tasks from input are captured
- [ ] No unnecessary files created
- [ ] Core changes documented
- [ ] Clean structure maintained
- [ ] Documentation generated
- [ ] Changes are reversible
- [ ] Impact analyzed
- [ ] Testing requirements identified

## Troubleshooting

### Issue: Tasks Being Skipped
**Solution**: Use `--all` flag to ensure comprehensive coverage

### Issue: File System Pollution
**Solution**: Review `.todo/` directory and clean up temporary files

### Issue: Missing Documentation
**Solution**: Check `docs/CHANGES.md` for all core modifications

### Issue: Complex Task Breakdown
**Solution**: Use `--component all` to get full task breakdown

## Version History

- **v1.1.0** (2025-01-13): Added project-specific options for Enterprise Auth Template
- **v1.0.0** (2025-01-13): Initial implementation with base options

## Support

For issues or enhancements to the `/todo` command:
1. Check CLAUDE.md files for latest updates
2. Review this documentation
3. Report issues in project repository

---

**Remember**: The `/todo` command enforces comprehensive task tracking while maintaining clean code organization. Never skip tasks, always document changes, and keep the file system clean.