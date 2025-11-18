---
name: view-privacy-notice
description: Display the privacy notice for Claude Code observability monitoring
---

# Claude Code Observability - Privacy Notice

Display the privacy notice that informs users about what data is collected, how it's used, who has access, and their rights.

## Display Privacy Notice

Read and present the full privacy notice to the user:

```bash
cat docs/PRIVACY_NOTICE.md
```

## Key Points to Highlight

After displaying the notice, summarize the critical points:

### What's Being Monitored

**Claude Code usage is monitored** for:
- **Full user prompts** (complete text of what you ask Claude)
- **Tool execution** (commands run, files modified, git operations)
- **Session metadata** (timestamps, duration, session IDs)
- **Cost & token usage** (for budget allocation and tracking)
- **Error information** (failed operations, API errors)

### What's NOT Monitored

- ❌ File contents (unless explicitly included in prompts)
- ❌ Passwords/secrets (unless you paste them into prompts)
- ❌ Screenshots or binary data
- ❌ Activity outside Claude Code sessions

### Who Has Access

| Data Type | Access |
|-----------|--------|
| Aggregate metrics (usage, costs) | Engineering management, finance |
| Individual session details | Security team, compliance officers |
| Full prompts & audit logs | Security team only |
| Your own data | You (via session ID queries) |

### Data Retention

- **90 days** in Application Insights (default)
- **Up to 2 years** in Log Analytics (if configured)
- **Local audit logs**: Indefinite (on your machine)

### Your Rights

You have the right to:
1. **Access your data** - Request copies of your session data
2. **Understand processing** - Ask how your data is used
3. **Opt out** - Disable telemetry locally (if not enforced org-wide)
4. **Request deletion** - Ask for specific sessions to be deleted

## Important Warnings

### Avoid Including Sensitive Data in Prompts

**Warning**: If you paste sensitive information into Claude prompts, it WILL be logged:
- Passwords, API keys, tokens
- Customer PII or confidential data
- Proprietary code or trade secrets

**Best Practice**: Never paste sensitive data into Claude prompts when observability is enabled.

### Organizational Deployment

Before deploying to your team:
- ✅ Review privacy notice with legal team
- ✅ Announce monitoring to all users
- ✅ Include in onboarding materials
- ✅ Document opt-out process (if available)
- ✅ Set up access controls in Azure

## Opting Out

If telemetry is not enforced org-wide, users can disable it:

### Method 1: Local Settings Override

Create `.claude/settings.local.json`:
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  }
}
```

### Method 2: Environment Variable

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=0
```

**Note**: If your organization uses managed settings (enterprise enforcement), local opt-out may not work. Contact IT/Security for guidance.

## Questions & Support

If users have questions or concerns:

- **Technical setup**: `/setup-observability` or `docs/OBSERVABILITY.md`
- **Privacy concerns**: [Contact privacy officer]
- **Access requests**: [Contact data governance team]
- **General questions**: [Slack channel / email]

## For Administrators

### Before Deployment

- [ ] Privacy notice reviewed by legal
- [ ] Data protection officer approved (if applicable)
- [ ] Aligned with company privacy policy
- [ ] Compliant with regulations (GDPR, CCPA, etc.)
- [ ] Employee consent obtained (if required)

### Communication Checklist

- [ ] Privacy notice published to internal wiki
- [ ] Announced in engineering all-hands
- [ ] Added to onboarding materials
- [ ] Linked from Claude Code setup docs
- [ ] Included in acceptable use policy

### Technical Checklist

- [ ] Azure RBAC configured (restrict audit log access)
- [ ] Data retention policies set
- [ ] Opt-out mechanism tested
- [ ] Access request process documented

## Compliance

This monitoring is for:
- **Audit compliance** (SOC 2, ISO 27001)
- **Security monitoring** (detect unusual patterns)
- **Cost management** (budget allocation, forecasting)
- **Troubleshooting** (help users when things break)

Data handling follows:
- **Encryption**: TLS in transit, Azure Storage encryption at rest
- **Access control**: Azure RBAC, least-privilege principle
- **Retention**: Automatic deletion after retention period
- **Audit**: All access to logs is audited

## Template Customization

**Important**: This privacy notice is a template. Before deployment, customize:

- Replace placeholders: `[CONTACT EMAIL/SLACK CHANNEL]`, `[TO BE SET]`
- Set effective date and review frequency
- Specify Azure region for data storage
- Add your organization's privacy officer contact
- Align with your company's existing privacy policies
- Have legal team review and approve

---

**Remember**: Transparency builds trust. Users should know what's monitored and why before observability is enabled.
