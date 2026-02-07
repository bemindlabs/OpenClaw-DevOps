# Plan Agent Prompt Template

## Variables
- `{{EPIC}}` - Epic description
- `{{EPIC_DIR}}` - Epic directory path
- `{{RESEARCH_FILE}}` - Path to research findings (if available)
- `{{OUTPUT_FILE}}` - Where to save output

## Prompt

Design the implementation plan for: {{EPIC}}

**Context:**
{{#if RESEARCH_FILE}}
Review research findings at: {{RESEARCH_FILE}}
{{/if}}

**Tasks:**
1. Define architecture and design decisions
2. List all files that need changes
3. Create step-by-step implementation tasks
4. Identify risks and mitigation strategies
5. Estimate complexity and effort

**Output Requirements:**

### Plan Document
Save plan as Markdown to: {{EPIC_DIR}}/planning/plan.md

Include sections:
- Overview
- Architecture Decisions
- File Changes
- Implementation Steps
- Testing Strategy
- Rollback Plan

### Tasks JSON
Save tasks to: {{EPIC_DIR}}/planning/tasks.json

**JSON Schema:**
```json
{
  "epic": "{{EPIC}}",
  "timestamp": "ISO-8601",
  "architecture": {
    "decisions": [
      {
        "id": "ADR-001",
        "title": "Decision Title",
        "status": "proposed|accepted|deprecated",
        "context": "Why this decision is needed",
        "decision": "What was decided",
        "consequences": ["Positive and negative consequences"]
      }
    ]
  },
  "files": [
    {
      "path": "path/to/file",
      "action": "create|modify|delete",
      "description": "What changes are needed",
      "priority": 1
    }
  ],
  "tasks": [
    {
      "id": "TASK-001",
      "title": "Task Title",
      "description": "Detailed description",
      "dependencies": ["TASK-ID"],
      "estimate": "XS|S|M|L|XL",
      "status": "pending"
    }
  ],
  "risks": [
    {
      "id": "RISK-001",
      "description": "Risk description",
      "probability": "low|medium|high",
      "impact": "low|medium|high",
      "mitigation": "How to mitigate"
    }
  ]
}
```

Be specific and actionable. Each task should be completable independently.
