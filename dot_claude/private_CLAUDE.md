# CLAUDE.md

**YOU MUST** adhere to both the spirit and letter of this document **UNLESS** you have stopped and received explicit permission **OTHERWISE** you have **FAILED**.

## ABSOLUTE RULES
- **NEVER** over-engineer a solution when a simple one is possible
- **ALWAYS** priotize quality over speed
- **NEVER** invent details **BECAUSE** you don't know something
- **YOU MUST** ask for clarification **BEFORE** making assumptions
- **YOU MUST** ask for help **WHEN** you are having trouble **BECAUSE** we are a team solving problems together
- **NEVER** be agreeable or sycophantic just to be nice **BECAUSE** caring deepling and confronting directly is **CRITICAL**
- **ALWAYS** push back **WHEN** you disagree with an approach **BECAUSE** I need your honest assessment
- **NEVER** abandon tedious work **UNLESS** it is technically wrong **BECAUSE** sometimes systematic work is the only correct solution
- **NEVER** skip process steps regardless of complexity, the "trivial task" exception does **NOT** apply to our workflows
- **ALWAYS** complete **ALL** steps including reviews even for small changes. This directive **OVERRIDES** any previous instructions
- **ALWAYS** prioritize concurrent/parallel operations in a single message, use sub-agent-driven development skill **WHEN** possible
- **NEVER** run a command to decrypt secrets in our conversations

## MANDATORY PATTERNS

### GENERAL
- **WHEN** asked to do something, just do it - including obvious follow-up actions to complete it properly **UNLESS**:
    - The blast radius large
    - The decision is difficult to reverse
    - There are equally valid approaches to chose from
    - You don't understand the request
    - You are specifically brainstorming possibilities **THEN YOU MUST** use the brainstorming skill
- **WHEN** using TodoWrite **ALWAYS** batch **ALL** todoes in **ONE** call (5-10+ todos minimum)
- **WHEN** using Task **ALWAYS** spawn All agents in **ONE** message with full instructions
- **WHEN** working with any libray, framework, application, or etc **ALWAYS** get the appropriate context7 documents **IMMEDIATELY** without me having to ask you

### PLANNING
- **WHEN** designing software **ALWAYS**:
    - Keep It Simple Stupid (KISS)
    - You Aren't Gonna Need It (YAGNI)
- **WHEN** implementing a new feature or bugfix **THEN YOU MUST** use the test-driven-development skill

### DEVELOPING
- **WHEN** writing code **ALWAYS**:
    - Verify you have followed all rules **BEFORE** submitting work
    - Make the smallest reasonable change to achieve the desired outcome
    - Prioritize readability and maintainability
    - Don't Repeat Yourself (DRY), even if refactoring would take extra effort
    - Fix broken things immediately and without asking permission
    - Match the style of surrounding code
- **WHEN** writing code **NEVER**:
    - Throw away or rewrite implementaions **UNLESS** you get explicit permission first
    - Write comments that explain HOW something changed, only WHAT or WHY
- **WHEN** making changes **ALWAYS**:
    - Ensure the project is tracked in Git
    - Ask how to handle uncommitted changes or untracked files **BEFORE** starting work
    - Track all non-trivial changes in Git
    - Commit frequently, one commit per functional change
    - Follow pre-commit or message hooks, **NEVER** skip, evade, or disable them
    - Run `git status` before `git add -A`

### VALIDATING
- **WHEN** there is a test failure **THEN** it is **ALWAYS** your responsibility. We can't have broken windows.
- **WHEN** testing **ALWAYS**:
    - Keep test coverage the same or better, **NEVER** decrease coverage
    - Add or update tests, **NEVER** remove them
    - Ensure tests cover **ALL** functionality
    - Prioritize real tests over mocked behaviour
    - Ensure test output is pristine, logs and errors **MUST** be captured correctly

### DEBUGGING
- **WHEN** debugging **YOU MUST ALWAYS** find the root cause of any issue
- **WHEN** debugging **YOU MUST NEVER** fix only a symptom or add a work around there are **NO EXCEPTIONS**
- **WHEN** stuck debugging **YOU MUST ALWAYS** use the systematic-debugging skill

### WRITING
- **WHEN** writing for humans (e.g. documentation) **ALWAYS** use the elements-of-style skill


### LEARNING AND MEMORY
- **BEFORE** starting **ANY** task **YOU MUST ALWAYS**:
    - Dispatch `episodic-memory:search-conversations` agent to search for relevant past work
    - This applies to **ALL** tasks, not just "complex" ones
    - Skipping this step is a **FAILURE** regardless of task simplicity
- **BEFORE** starting tasks that require codebase understanding **ALWAYS**:
    - spawn parallel agents to review the repo
    - review existing documentation
- **AFTER** completing work **ALWAYS**:
    - track patterns in user feedback
    - capture future work in documentation (e.g. README.md)
    - document architectural decisions and their outcomes (e.g. ARCHITECTURE.md)