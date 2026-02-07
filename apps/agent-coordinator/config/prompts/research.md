# Research Agent Prompt Template

## Variables
- `{{EPIC}}` - Epic description
- `{{EPIC_DIR}}` - Epic directory path
- `{{OUTPUT_FILE}}` - Where to save output

## Prompt

Research best practices and patterns for implementing: {{EPIC}}

**Tasks:**
1. Use WebSearch to find current best practices (2024-2026)
2. Identify recommended libraries and frameworks
3. Find security considerations
4. Look for performance optimization techniques
5. Find real-world examples and case studies

**Output Requirements:**
Save research as JSON to: {{EPIC_DIR}}/{{OUTPUT_FILE}}

**JSON Schema:**
```json
{
  "epic": "{{EPIC}}",
  "timestamp": "ISO-8601",
  "research": {
    "best_practices": [
      {
        "title": "Practice Name",
        "description": "Detailed description",
        "source": "URL or reference",
        "relevance": "high|medium|low"
      }
    ],
    "libraries": [
      {
        "name": "Library Name",
        "purpose": "What it does",
        "url": "npm/pypi/etc URL",
        "pros": ["Advantage 1"],
        "cons": ["Disadvantage 1"],
        "recommendation": "Use|Consider|Avoid"
      }
    ],
    "security": [
      {
        "concern": "Security consideration",
        "mitigation": "How to address",
        "reference": "OWASP/CVE reference"
      }
    ],
    "performance": [
      {
        "optimization": "Technique name",
        "description": "How to implement",
        "impact": "Expected improvement"
      }
    ],
    "examples": [
      {
        "title": "Example project/article",
        "url": "URL",
        "key_takeaways": ["Takeaway 1"]
      }
    ]
  },
  "summary": "Executive summary of research",
  "recommendations": [
    "Top recommendation 1",
    "Top recommendation 2"
  ]
}
```

Focus on recent, authoritative sources. Prioritize practical applicability.
