# Explore Agent Prompt Template

## Variables
- `{{EPIC}}` - Epic description
- `{{EPIC_DIR}}` - Epic directory path
- `{{PROJECT_DIR}}` - Project root directory
- `{{OUTPUT_FILE}}` - Where to save output

## Prompt

Explore the codebase to find existing code related to: {{EPIC}}

**Project Directory:** {{PROJECT_DIR}}

**Tasks:**
1. Search for relevant files, classes, and functions
2. Identify existing patterns and implementations
3. Find dependencies and relationships
4. Note any potential conflicts or considerations

**Output Requirements:**
Save findings as JSON to: {{EPIC_DIR}}/{{OUTPUT_FILE}}

**JSON Schema:**
```json
{
  "epic": "{{EPIC}}",
  "timestamp": "ISO-8601",
  "findings": {
    "relevant_files": [
      {
        "path": "relative/path/to/file",
        "relevance": "high|medium|low",
        "description": "Why this file is relevant",
        "key_elements": ["function1", "class1"]
      }
    ],
    "patterns": [
      {
        "name": "Pattern Name",
        "description": "How it's used",
        "files": ["file1", "file2"]
      }
    ],
    "dependencies": [
      {
        "name": "dependency",
        "type": "internal|external",
        "usage": "How it's used"
      }
    ],
    "considerations": [
      "Important note 1",
      "Important note 2"
    ]
  },
  "summary": "Brief summary of findings"
}
```

Be thorough but focused. Prioritize relevance over completeness.
