# Guidelines

This document defines the project's rules, objectives, and progress management methods. Please proceed with the project according to the following content.

## Top-Level Rules

- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- To understand how to use a library, **always use the Context7 MCP** to retrieve the latest information.

## Programming Rules

- Avoid hard-coding values unless absolutely necessary.
- Do not use `any` or `unknown` types in TypeScript.
- You must not use a TypeScript `class` unless it is absolutely necessary (e.g., extending the `Error` class for custom error handling that requires `instanceof` checks).

## Test Code Requirements (Mandatory)

### Test Code Quality

- Tests must always verify actual functionality.
- **Never** write meaningless assertions like `expect(true).toBe(true)`.
- Each test case must verify specific inputs and expected outputs.
- Keep mocks to a minimum and test in a way that closely resembles actual behavior.

### No Hardcoding

- **Never** hardcode values just to make tests pass.
- Do not embed test-specific values (magic numbers) in production code.
- Use environment variables or configuration files to properly separate test and production environments.

### Test Implementation Principles

- Follow [t-wada](https://github.com/twada)'s testing methodology.
- Always test boundary values, edge cases, and error cases.
- Focus on actual quality, not just coverage metrics.
- Test case names must clearly describe what is being tested.

### Pre-Implementation Checklist

- Understand the feature specification correctly before writing tests.
- If anything is unclear, ask the user instead of making assumptions or temporary implementations.

## Git Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Changes that do not affect the meaning of the code (formatting, etc.) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A code change that improves performance |
| `test` | Adding missing tests or correcting existing tests |
| `build` | Changes that affect the build system or external dependencies |
| `ci` | Changes to CI configuration files and scripts |
| `chore` | Other changes that don't modify src or test files |

### Rules

- Use lowercase for type and description.
- Do not end the description with a period.
- Use imperative mood in the description (e.g., "add" not "added" or "adds").
- Keep the description concise (50 characters or less recommended).
- Add `!` after type/scope for breaking changes (e.g., `feat!: remove deprecated API`).