# Custom /todo Command - Setup Guide

## ✅ Correct Implementation (Following Official Claude Code Guidelines)

This custom command has been properly implemented following the official Claude Code slash command documentation at https://docs.anthropic.com/en/docs/claude-code/slash-commands

## File Structure Created

```
~/.claude/commands/
└── todo.md                 # User-level (global) command

project/.claude/commands/
└── todo.md                 # Project-level command
```

## Command File Format

Each `todo.md` file follows the official structure:

```markdown
---
allowed-tools: TodoWrite, Read, Grep, Glob, Write
description: Create comprehensive todo lists with clean organization and documentation
argument-hint: [options] [task description or --all]
---

[Command prompt and instructions]
```

### Key Components:

1. **Frontmatter** (YAML format between `---`):
   - `allowed-tools`: Specifies which tools the command can use
   - `description`: Brief description shown in command list
   - `argument-hint`: Shows expected argument format

2. **Command Body**:
   - Contains the prompt/instructions for Claude
   - Uses `$ARGUMENTS` to capture all user arguments
   - Can use `$1`, `$2` for positional arguments

## How It Works

1. **User types**: `/todo --priority high Implement OAuth2`

2. **Claude receives**: The content of `todo.md` with `$ARGUMENTS` replaced by `--priority high Implement OAuth2`

3. **Claude executes**: The instructions in the command file, using allowed tools to create comprehensive todos

## Command Features

### Supported Options
- `--all` - Create todos for all pending tasks
- `--from-file <path>` - Read tasks from file
- `--priority <level>` - Set task priority
- `--category <type>` - Categorize tasks
- `--estimate <time>` - Add time estimates
- `--component <type>` - Organize by component
- `--feature <name>` - Associate with features
- `--test-required` - Ensure test coverage

### Task Expansion
The command automatically expands simple tasks into comprehensive workflows:

**Input**: "Implement user authentication"

**Output**:
- Planning/design phase
- Implementation phase
- Testing phase (unit, integration)
- Documentation phase
- Review/validation phase

## Usage Examples

### Basic Usage
```bash
/todo Implement password reset feature
```

### With Options
```bash
/todo --priority high --component backend Fix session timeout bug

/todo --category refactor --test-required Optimize database queries

/todo --all  # Creates todos for all tasks in conversation
```

## File Organization Maintained

The command ensures clean file organization:

```
project/
├── src/                    # Core code (modify existing)
├── tests/                  # Test files (add as needed)
├── docs/
│   └── CHANGES.md         # Document all core modifications
└── .todo/                  # Todo tracking (git-ignored)
    ├── current.json
    ├── completed.json
    └── metrics.json
```

## Documentation Generated

When modifying core files, the command creates/updates `CHANGES.md`:

```markdown
## Changes - [Date]

### Modified Files
- **[file_path]**: [what changed and why]
  - Lines: [start-end]
  - Rollback: [how to revert]

### Impact Analysis
- Features affected: [list]
- Risk level: [low/medium/high]
- Testing required: [what to test]
```

## Quality Assurance

The command enforces:
- ✅ Every task gets a todo entry
- ✅ No file system pollution
- ✅ All core changes documented
- ✅ Clean folder structure maintained
- ✅ Proper documentation created
- ✅ Changes are reversible
- ✅ Impact is analyzed
- ✅ Testing requirements identified

## Testing the Command

To test if the command is working:

1. **Check installation**:
   ```bash
   ls -la ~/.claude/commands/todo.md
   ls -la .claude/commands/todo.md
   ```

2. **Use the command**:
   ```bash
   /todo Test task creation
   ```

3. **Verify output**:
   - Check that todos are created comprehensively
   - Verify no unnecessary files are created
   - Confirm documentation is generated for changes

## Advanced Features

### Command Namespacing
You can create namespaced commands by using subdirectories:

```
.claude/commands/
├── todo.md
└── dev/
    ├── setup.md
    └── test.md
```

Usage: `/dev/setup`, `/dev/test`

### Bash Command Integration
Commands can execute bash directly with `!` prefix:
```markdown
!git status
```

### File References
Commands can reference files with `@` prefix:
```markdown
Review the code in @src/main.ts
```

## Troubleshooting

### Command Not Found
- Ensure files are in correct directories
- Check file has `.md` extension
- Verify frontmatter is valid YAML

### Command Not Working as Expected
- Check `allowed-tools` includes necessary tools
- Verify `$ARGUMENTS` is properly placed
- Review command prompt clarity

### File Pollution Issues
- Ensure command enforces `.todo/` directory usage
- Check documentation requirements are met
- Verify cleanup instructions are included

## Benefits of Proper Implementation

1. **Standardized**: Follows official Claude Code guidelines
2. **Maintainable**: Clear structure and documentation
3. **Shareable**: Can be shared across projects/teams
4. **Extensible**: Easy to add new options and features
5. **Clean**: Prevents file system pollution
6. **Traceable**: Documents all changes made

## References

- [Official Claude Code Slash Commands Documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Claude Code Documentation Map](https://docs.anthropic.com/en/docs/claude-code/claude_code_docs_map.md)

---

**Note**: The previous implementation in CLAUDE.md files has been replaced with this proper implementation following official guidelines. The command files in `.claude/commands/` directories are now the authoritative source for the `/todo` command.