# Gemini Agent Prompt Template

## Variables
- `{{EPIC}}` - Epic description
- `{{EPIC_DIR}}` - Epic directory path
- `{{OUTPUT_FILE}}` - Where to save output

## Prompt

Research implementation patterns and best practices for: {{EPIC}}

**Focus Areas:**
1. Industry best practices and design patterns
2. Library and framework recommendations
3. Security considerations and compliance
4. Performance optimization strategies
5. Real-world case studies

**Output Requirements:**
Provide output as JSON and save to: {{EPIC_DIR}}/{{OUTPUT_FILE}}

**JSON Structure:**
```json
{
  "epic": "{{EPIC}}",
  "timestamp": "current ISO-8601",
  "patterns": [
    {
      "name": "Pattern name",
      "description": "How to apply",
      "pros": ["advantages"],
      "cons": ["disadvantages"],
      "example": "Code or implementation example"
    }
  ],
  "libraries": [
    {
      "name": "Library",
      "purpose": "What it solves",
      "url": "Documentation URL",
      "recommendation": "Strongly recommended | Recommended | Consider"
    }
  ],
  "security": [
    {
      "concern": "Security topic",
      "recommendation": "How to address"
    }
  ],
  "performance": [
    {
      "area": "Performance area",
      "optimization": "Recommended approach"
    }
  ],
  "sources": ["URL references"]
}
```

Be thorough and cite authoritative sources. Focus on practical, actionable advice.
