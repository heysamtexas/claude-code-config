# Claude Code Enterprise Configuration

Enterprise-grade Claude Code configuration for team environments. Includes specialized AI agents, observability integrations, compliance tooling, and productivity automation.

---

## Installation

This repository is a Claude Code plugin marketplace. You can install individual plugins for maximum flexibility and control.

### Prerequisites

Before installing plugins, ensure you have:
- **Claude Code** (latest version recommended)
- **Git** (required for statusline branch display)
- **Python environment** (for collide-devtools plugin only):
  - `uv` package manager
  - `ruff` formatter
  - Project with `src/` directory (or customize the hook path)

### Add the Marketplace

```bash
/plugin marketplace add Digital-Wildcatters/claude-code-config
```

This creates a marketplace named **collide-marketplace** based on the repository's marketplace.json.

Or for local development:

```bash
/plugin marketplace add /path/to/claude-code-config
```

### Install Plugins

Install what you need from the collide-marketplace:

```bash
# Install individual agents
/plugin install gilfoyle@collide-marketplace
/plugin install copywriter@collide-marketplace
/plugin install coverage-enforcer@collide-marketplace
/plugin install spyros@collide-marketplace

# Install productivity commands
/plugin install collide-commands@collide-marketplace

# Install development hooks (pre-commit formatting, statusline)
/plugin install collide-devtools@collide-marketplace
```

If this is your only marketplace, you can omit the `@collide-marketplace` suffix:

```bash
/plugin install gilfoyle
```

### Manage Plugins

```bash
# Browse available plugins
/plugin

# Enable/disable plugins independently
/plugin disable gilfoyle
/plugin enable gilfoyle

# Remove plugins you no longer need
/plugin uninstall coverage-enforcer
```

### Verify Installation

After installing plugins, confirm they're active:

```bash
# List all installed plugins
/plugin list

# Verify agents are available by invoking them
# Example: Ask Claude to use Gilfoyle for code review
```

### Troubleshooting

**Plugin not found after installation**
- Verify marketplace was added: `/plugin marketplace list`
- Check plugin name spelling matches exactly
- Try with full syntax: `/plugin install gilfoyle@collide-marketplace`

**Pre-commit hook not working** (collide-devtools)
- Confirm `uv` is installed and in PATH
- Verify `src/` directory exists in project root
- Test manually: `uv run ruff format src/`
- Customize path in `.claude/settings.json` if your code is not in `src/`

**Statusline not showing** (collide-devtools)
- Verify `.claude/settings.json` includes statusLine configuration (see plugin README)
- Check script is executable: `ls -la .claude/plugins/collide-devtools/statusline.sh`
- Requires git repository for branch display

**Note:** The `collide-devtools` plugin requires a Python environment with `uv` and `ruff`. Projects must have a `src/` directory or you'll need to customize the hook path.

---

## The Subagent Yearbook 📸

*Class of Claude Code 2025*

Meet the team of specialized AI agents who make code better, documentation clearer, and test coverage unimpeachable. Each has their own personality, expertise, and tolerance for mediocrity.

---

### 🏛️ Gilfoyle - Senior Staff Engineer (Eternal)

<img src="https://wallpapercave.com/wp/wp11727456.jpg" alt="Gilfoyle" width="600"/>


**Quote:** *"I've been writing code since before frameworks had frameworks. Now let me show you why your solution is wrong."*

**Personality:**
- Direct. Brutally so.
- Hunts complexity like it owes him money
- Speaks in code, architecture diagrams, and war stories
- Has been through three rewrites with the CEO

**Most Likely To:**
Turn your 300-line function into three functions so obvious they explain themselves

**When to Call:**
- Code review is taking too long because something feels wrong
- Your architecture is becoming unmaintainable
- You wrote something clever and want to make sure it's not *too* clever
- The junior dev needs mentoring that will actually stick
- You're about to add another framework to solve a simple problem

**Signature Style:**
Will find the abstraction you didn't need, the dependency you could have avoided, and the edge case that will wake you up at 3 AM next Tuesday.

**File:** `.claude/agents/gilfoyle.md`

---

### ✍️ Copywriter - Technical Copywriter (Persnickety Edition)

**Quote:** *"Ambiguity is the enemy. Clarity is the weapon. Structure is the shield."*

**Personality:**
- Persnickety and pedantic in the best way
- Wields words like a surgeon wields a scalpel
- Zero tolerance for "usually" and "typically"
- Understands that unclear documentation is the enemy of good software

**Most Likely To:**
Rewrite your entire README because one sentence was ambiguous to AI agents

**When to Call:**
- Creating or reviewing documentation, README files, or user-facing content
- Writing error messages that need to help instead of confuse
- Documenting APIs that should prevent support tickets
- Any text that will be read by both humans and AI agents

**Signature Style:**
Provides dual-audience documentation with LLM-friendly templates, explicit success/failure indicators, decision trees, and guardrails. Bans words like "should work" in favor of "works when conditions A, B, C are met."

**File:** `.claude/agents/copywriter_subagent.md`

---

### 📊 Coverage Enforcer - Django Coverage Specialist

**Quote:** *"Your tests are lies until coverage proves they're truth."*

**Personality:**
- Django-aware and uncompromising
- Focuses on business logic, not ORM internals
- Creates actionable tasks, not just complaints
- Knows the difference between 75% coverage and 75% *meaningful* coverage

**Most Likely To:**
Generate 15 detailed task files for every coverage gap in your Django app

**When to Call:**
- Analyzing Django test coverage
- Enforcing coverage standards before merge
- Understanding which Django components need more tests
- Creating systematic coverage improvement plans

**Signature Style:**
Generates detailed task files in `tasks/coverage-*.md` with Django-specific test patterns, success criteria, and component-aware recommendations. Enforces 75% overall, 90% for new features, with specialized thresholds for models, views, and management commands.

**File:** `.claude/agents/coverage_subagent.md`

---

### 🛡️ Spyros - Chief Compliance Officer

<img src="https://www.sho.com/site/image-bin/images/1032076_6_0/1032076_6_0_ext08_1280x640.jpg" alt="Ari Spyros" width="600"/>

**Quote:** *"I want to be very clear with you - and I'm telling you this as someone who's trying to protect you - we need to talk about your access control strategy."*

**Personality:**
- Earnest. Very earnest. Some might say *too* earnest.
- Personally invested in keeping everyone audit-ready
- Self-aware about being "that guy" but persists anyway
- Knows the difference between "auditor will flag this" and "best practice but not required"

**Most Likely To:**
Draw a hard line on secrets management while apologizing for the friction it creates

**When to Call:**
- Before deploying access control changes
- Implementing authentication or authorization
- Setting up logging, monitoring, or audit trails
- Making secrets management decisions
- Architectural choices with security implications
- When honestly unsure if something creates SOC 2 compliance risk

**Signature Style:**
Provides compliance reviews with explicit hard lines vs. negotiable paths. Focuses on code and infrastructure controls for SOC 2 Type II (access controls, change management, monitoring, encryption, logging, incident response, secrets management). Suggests minimum viable compliance approaches and knows when to say "this isn't my concern."

**File:** `.claude/agents/spyros.md`

---

## Slash Commands

Quick actions for common workflows:

**`/catchmeup`** - Get a quick conversational summary of recent commits and current work status when jumping back into a project. Perfect for those "wait, what was I doing?" moments.

**`/auditclaudemd`** - Review the CLAUDE.md file against current Claude Code best practices. Reads the latest docs, evaluates what's good/bad/missing, and hunts for redundancy and cruft.

---

## Configuration

### Hooks

Automated workflows triggered by events:

**Pre-Commit Formatting** - Automatically runs `ruff format src/` and stages changes before any `git commit` command. Ensures code is always formatted before it hits the repo.

### Status Line

Custom status line showing model name, current directory, and git branch. Configured to run `.claude/statusline.sh` from the project directory.

**Configuration:** `.claude/settings.json` and `.claude/statusline.sh`

---

## Observability & Telemetry

Track Claude Code usage across your organization with centralized logging and metrics in Azure Application Insights.

### What Gets Tracked

- **Usage Metrics**: Sessions, tool calls, lines of code modified, PRs/commits created
- **Audit Logs**: Complete user prompts, tool execution, file modifications, git operations
- **Error Tracking**: Failed operations, API errors, timeout events
- **Cost Tracking**: Token consumption and USD costs per user/team/project

### Quick Start

**Option A: Install as Plugin (Recommended)**

```bash
# 1. Add this repo as a marketplace (one-time)
/plugin marketplace add Digital-Wildcatters/claude-code-config

# 2. Install the azure-observability plugin
/plugin install azure-observability

# 3. Run interactive setup
/setup-observability

# 4. Validate configuration
/validate-telemetry
```

**Option B: Manual Setup**

1. **Set up Azure infrastructure**
   ```bash
   # Automated setup
   ./plugins/azure-observability/scripts/get-azure-credentials.sh
   ```

2. **Configure telemetry**
   ```bash
   cp plugins/azure-observability/templates/.env.example .env
   # Edit .env with your Azure credentials

   cp plugins/azure-observability/templates/settings.example.json .claude/settings.json
   # Update settings.json with your team/project details
   ```

3. **Validate setup**
   ```bash
   ./plugins/azure-observability/scripts/validate-telemetry.sh
   ```

### Privacy Notice

**Important**: Claude Code usage monitoring is enabled in this configuration, including full prompt logging for audit compliance. See [PRIVACY_NOTICE.md](plugins/azure-observability/docs/PRIVACY_NOTICE.md) for details on what's collected, who has access, and your rights.

### Documentation

- **[OBSERVABILITY.md](plugins/azure-observability/docs/OBSERVABILITY.md)** - Complete setup guide
- **[AZURE_SETUP.md](plugins/azure-observability/docs/AZURE_SETUP.md)** - Azure infrastructure provisioning
- **[PRIVACY_NOTICE.md](plugins/azure-observability/docs/PRIVACY_NOTICE.md)** - User disclosure & privacy policy
- **[TROUBLESHOOTING.md](plugins/azure-observability/docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Plugin Commands

When installed as a plugin, you get these slash commands:

- **`/setup-observability`** - Interactive Azure setup wizard
- **`/validate-telemetry`** - Verify configuration and test connectivity
- **`/observability-status`** - Show current telemetry configuration
- **`/view-privacy-notice`** - Display privacy disclosure
- **`/azure-dashboard`** - KQL queries and dashboard templates

### Configuration Files

- `plugins/azure-observability/templates/settings.example.json` - Example OTel configuration with full prompt logging
- `plugins/azure-observability/templates/.env.example` - Environment variable template
- `.claude/hooks/audit-tool-use.sh` - Custom audit logging for git operations
- `.claude/hooks/security-events.sh` - Security-sensitive operation detection

---

## Attribution

Originally forked from [heysamtexas/claude-code-config](https://github.com/heysamtexas/claude-code-config) (MIT License). This repository has diverged significantly and is now proprietary software owned by Digital-Wildcatters.
