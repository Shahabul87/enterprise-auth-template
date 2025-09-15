---
allowed-tools: TodoWrite, Read, Grep, Glob, Write
description: Create comprehensive todo lists with clean organization and documentation
argument-hint: [options] [task description or --all]
---

Create a comprehensive todo list for the following: $ARGUMENTS

CRITICAL REQUIREMENTS:
1. NEVER skip any task, no matter how small or obvious
2. NEVER create unnecessary files that pollute the system
3. ALWAYS update core files when needed but document ALL changes - NEVER create files with "_enhanced", "_updated", "_new" suffixes unless explicitly requested
4. ALWAYS follow clean folder structure and organization
5. ALWAYS create proper documentation for modifications
6. ALWAYS follow Clean Architecture principles by Robert C. Martin - business logic MUST be independent of frameworks

Parse the arguments to determine:
- If "--all" is specified: Create todos for ALL pending tasks in the current conversation
- If "--from-file <path>" is specified: Read the file and create todos from its contents
- If "--priority <level>" is specified: Set priority (high/medium/low) for all tasks
- If "--category <type>" is specified: Categorize as feature/bug/refactor/docs/test
- If "--estimate <time>" is specified: Add time estimates to tasks
- If "--component <type>" is specified: Organize by backend/frontend/flutter/infra
- If "--feature <name>" is specified: Associate with auth/rbac/audit/session features
- If "--test-required" is specified: Ensure test coverage tasks are included

Task Expansion Rules:
1. For any implementation task, automatically include:
   - Clean Architecture layer design (Domain/Application/Infrastructure/Presentation)
   - Design/planning subtask (following SOLID principles)
   - Implementation subtask (respecting dependency rules)
   - Testing subtask (unit/integration/e2e)
   - Documentation subtask
   - Review/validation subtask

2. For backend tasks, include:
   - API endpoint implementation
   - Service layer logic
   - Database model updates
   - Migration scripts if needed
   - Unit and integration tests
   - API documentation updates

3. For frontend tasks, include:
   - Component implementation
   - State management setup
   - API client integration
   - UI/UX implementation
   - Accessibility checks
   - Component tests

4. For Flutter tasks, include:
   - Screen implementation
   - Provider/state setup
   - Service integration
   - Platform-specific code
   - Widget tests
   - Integration tests

5. For infrastructure tasks, include:
   - Configuration updates
   - Environment setup
   - CI/CD pipeline updates
   - Deployment scripts
   - Monitoring setup
   - Security configuration

6. Apply 20 Senior Engineering Principles:
   - Design for change (auth methods will evolve)
   - Dependency inversion (auth logic independent of frameworks)
   - Test pyramid (many unit tests, few E2E)
   - Observability built-in (auth metrics, session tracking)
   - Simplicity over cleverness (debuggable by juniors)
   - Continuous refactoring (small increments)
   - Error handling as design (auth failures, rate limits)
   - Engineer for 3AM debugging

7. For Clean Architecture compliance in this project:
   Backend (FastAPI):
   - Domain: Models without framework dependencies
   - Application: Services with business logic
   - Infrastructure: Database, external APIs
   - Presentation: FastAPI routes/controllers

   Frontend (Next.js):
   - Domain: Business entities and rules
   - Application: Use cases and state management
   - Infrastructure: API clients, storage
   - Presentation: React components

   Flutter:
   - Domain: Core business models
   - Application: Providers and services
   - Infrastructure: API integration, local storage
   - Presentation: Screens and widgets

Documentation Requirements:
- If modifying core files, create or update docs/CHANGES.md with:
  - File path and lines modified
  - Reason for change
  - What was changed
  - How to rollback if needed
  - Impact analysis
  - Testing requirements

File Organization:
- Keep all temporary todo tracking in .todo/ directory (git-ignored)
- Document core changes in docs/CHANGES.md
- Never create scattered temporary files
- Maintain clean project structure

Quality Assurance:
- Every task must have clear success criteria
- Include validation/verification steps
- Add rollback plans for risky changes
- Ensure all changes are reversible
- Include performance considerations
- Add security review tasks where applicable

Output the todos using the TodoWrite tool with proper status tracking:
- New tasks start as "pending"
- Currently working task as "in_progress"
- Completed tasks as "completed"

Remember: The goal is COMPREHENSIVE task tracking while maintaining a CLEAN codebase with PROPER documentation.