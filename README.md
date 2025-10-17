# About this project

this is where i save and share all my claude subagents, configs, tips, tricks,
lies, half-truths, hopes, prayers, and encantations when using claude code.

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

## Hooks

Automated workflows triggered by events:

**Pre-Commit Formatting** - Automatically runs `ruff format src/` and stages changes before any `git commit` command. Ensures code is always formatted before it hits the repo.

**Configuration:** `.claude/settings.json`


