# Agent Coordinator

A configurable multi-agent task management system for coordinating AI coding agents.

## Features

- **Configurable Agents**: YAML-based configuration for internal and external agents
- **Tmux Integration**: Manage multiple external CLI agents in tmux windows
- **Epic Management**: Organized directory structure for each epic/task
- **Prompt Templates**: Customizable prompt templates for each agent type
- **Session Tracking**: Track all agent sessions and their status
- **Workflow Phases**: Define multi-phase workflows with dependencies

## Quick Start

### 1. Start an Epic

```bash
# Using the script directly
./bin/agent-coordinator.sh run "Implement user authentication"

# Or add to PATH
export PATH="$PATH:/Users/lps/server/apps/agent-coordinator/bin"
agent-coordinator.sh run "Implement user authentication"
```

### 2. Check Status

```bash
agent-coordinator.sh status
```

### 3. Attach to Session

```bash
agent-coordinator.sh attach
```

### 4. Complete Epic

```bash
agent-coordinator.sh complete
```

## Directory Structure

```
apps/agent-coordinator/
├── bin/
│   └── agent-coordinator.sh      # Main executable
├── config/
│   ├── agents.yaml               # Agent configuration
│   └── prompts/                  # Prompt templates
│       ├── explore.md
│       ├── plan.md
│       ├── research.md
│       ├── gemini.md
│       └── codex.md
├── lib/                          # Library functions (future)
├── templates/                    # Additional templates
└── README.md
```

## Configuration

### agents.yaml

Main configuration file defining:

- **Project settings**: Base directories, file locations
- **Internal agents**: Task-tool based agents (explore, plan, research, etc.)
- **External agents**: CLI-based agents (gemini, codex, claude, etc.)
- **Epic structure**: Directory layout for each epic
- **Tmux settings**: Session and window configuration
- **Workflows**: Multi-phase workflow definitions

### Prompt Templates

Each agent type has a prompt template in `config/prompts/`:

- Templates use `{{VARIABLE}}` syntax for substitution
- Variables include: `{{EPIC}}`, `{{EPIC_DIR}}`, `{{PROJECT_DIR}}`, `{{OUTPUT_FILE}}`
- Templates define expected output format (usually JSON)

### Adding Custom Agents

1. Add agent to `agents.yaml`:

```yaml
agents:
  external:
    my_agent:
      cli: "my-cli-command"
      description: "What this agent does"
      output_dir: "agents/my_agent"
      output_file: "output.json"
      prompt_template: "my_agent.md"
      enabled: true
      timeout: 300
```

2. Create prompt template `config/prompts/my_agent.md`

3. Update `create_tmux_session()` and `spawn_external_agents()` in script

## Epic Directory Structure

Each epic creates a structured directory:

```
~/Solutions/.epics/2026-02-07-implement-user-auth/
├── research/               # Codebase analysis, best practices
├── planning/               # Architecture, tasks
│   ├── plan.md
│   └── tasks.json
├── implementation/         # Code changes, patches
├── review/                 # QA reports, verification
│   └── agent-summary.md
├── docs/                   # Generated documentation
├── logs/                   # Execution logs
├── agents/                 # External agent workspaces
│   ├── gemini/
│   │   ├── output.log
│   │   └── research.json
│   ├── codex/
│   │   ├── output.log
│   │   └── analysis.json
│   └── claude/
│       └── output.log
└── README.md               # Epic overview
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CONFIG_FILE` | Path to agents.yaml | `./config/agents.yaml` |
| `SOLUTIONS_DIR` | Solutions base directory | `$HOME/Solutions` |
| `EPICS_DIR` | Epics directory | `$HOME/Solutions/.epics` |
| `SESSIONS_FILE` | Session tracking file | `$HOME/.claude/agent-sessions.json` |

## Commands

| Command | Description |
|---------|-------------|
| `run <epic>` | Start new epic with multi-agent coordination |
| `status` | Check status of running agents |
| `complete` | Complete epic and generate summary |
| `attach` | Attach to tmux session |
| `stop` | Stop all running sessions |
| `help` | Show help |

## Integration with Claude Code

### Spawning Internal Agents

After running `agent-coordinator.sh run`, spawn internal agents in Claude:

```
Task(
  subagent_type: "Explore",
  description: "Explore codebase for [epic]",
  prompt: "...",
  run_in_background: true
)
```

### Collecting Results

Use `TaskOutput` to collect internal agent results, then consolidate with external agent outputs in the epic directory.

## Tmux Navigation

- `Ctrl+b 0` - Coordinator window
- `Ctrl+b 1` - Gemini window
- `Ctrl+b 2` - Codex window
- `Ctrl+b 3` - Claude window
- `Ctrl+b d` - Detach
- `Ctrl+b [` - Scroll mode

## Session Tracking

Sessions are tracked in `~/.claude/agent-sessions.json`:

```json
{
  "sessions": [
    {
      "id": "epic-implement-auth-1707284400",
      "type": "coding",
      "epic": "Implement user authentication",
      "epic_dir": "/Users/lps/Solutions/.epics/2026-02-07-implement-auth",
      "status": "running",
      "created": "2026-02-07T07:40:00Z",
      "agents": {
        "internal": [],
        "external": ["gemini", "codex", "claude"]
      },
      "tmux_session": "epic-implement-auth-1707284400"
    }
  ]
}
```

## Extending the System

### Custom Workflows

Define custom workflows in `agents.yaml`:

```yaml
workflows:
  security_review:
    name: "Security Review"
    phases:
      - name: scan
        agents:
          internal: [explore]
          external: [security_scanner]
        parallel: true

      - name: review
        agents:
          internal: [review]
          external: []
        depends_on: [scan]
```

### Custom Output Formats

Modify prompt templates to produce different output formats (JSON, YAML, Markdown).

### Plugin System (Future)

The `lib/` directory is reserved for a future plugin system.

## Troubleshooting

### Tmux Session Not Found

```bash
# List all sessions
tmux list-sessions

# Kill stuck sessions
agent-coordinator.sh stop
```

### Agent CLI Not Found

Install the required CLI tools:
- gemini: `npm install -g @google/generative-ai-cli`
- codex: OpenAI Codex CLI
- claude: Anthropic Claude CLI

### Permission Issues

```bash
chmod +x bin/agent-coordinator.sh
```

---

*Part of OpenClaw DevOps*
