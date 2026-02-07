# Codex Agent Prompt Template

## Variables
- `{{EPIC}}` - Epic description
- `{{EPIC_DIR}}` - Epic directory path
- `{{PROJECT_DIR}}` - Project root directory
- `{{OUTPUT_FILE}}` - Where to save output

## Prompt

Analyze code implementation approach for: {{EPIC}}

**Project Context:**
- Project Directory: {{PROJECT_DIR}}
- Epic Directory: {{EPIC_DIR}}

**Analysis Tasks:**
1. Recommend code structure and organization
2. Define interface specifications
3. Suggest file/module layout
4. Outline testing strategy
5. Identify potential technical debt

**Output Requirements:**
Provide detailed analysis and save to: {{EPIC_DIR}}/{{OUTPUT_FILE}}

**JSON Structure:**
```json
{
  "epic": "{{EPIC}}",
  "timestamp": "current ISO-8601",
  "structure": {
    "overview": "High-level structural recommendation",
    "directories": [
      {
        "path": "suggested/path",
        "purpose": "What goes here",
        "files": ["expected files"]
      }
    ],
    "modules": [
      {
        "name": "Module name",
        "responsibility": "What it handles",
        "dependencies": ["other modules"],
        "exports": ["public interfaces"]
      }
    ]
  },
  "interfaces": [
    {
      "name": "InterfaceName",
      "type": "class|interface|function|type",
      "definition": "TypeScript/pseudo-code definition",
      "usage": "How to use"
    }
  ],
  "testing": {
    "strategy": "Overall testing approach",
    "unit_tests": ["Areas needing unit tests"],
    "integration_tests": ["Integration test scenarios"],
    "e2e_tests": ["End-to-end test cases"]
  },
  "technical_debt": [
    {
      "area": "Where debt might accumulate",
      "risk": "low|medium|high",
      "mitigation": "How to prevent/address"
    }
  ],
  "recommendations": [
    "Key recommendation 1",
    "Key recommendation 2"
  ]
}
```

Focus on maintainability, testability, and scalability.
