# Claude Code Usage Monitoring - Privacy Notice

**Effective Date**: [TO BE SET]
**Last Updated**: [TO BE SET]

## Purpose

This notice informs you that Claude Code usage within our organization is monitored for **audit compliance**, **security**, and **cost management** purposes.

## What We Monitor

When you use Claude Code, the following data is collected and stored in our Azure Application Insights infrastructure:

### 1. User Prompts (Full Text)

- **What**: Complete text of every prompt you submit to Claude
- **Why**: Audit trail, compliance, understanding usage patterns
- **Example**: "Help me refactor the authentication module"

### 2. Tool Usage & Commands

- **What**: Tools Claude executes (file edits, bash commands, git operations)
- **Why**: Security monitoring, audit compliance
- **Example**: File paths modified, git commits, bash commands run

### 3. Session Metadata

- **What**: Session IDs, timestamps, duration, your user account ID
- **Why**: Usage analytics, cost allocation
- **Example**: Session started at 2025-01-15 10:30 AM, lasted 45 minutes

### 4. Git Operations

- **What**: Commits, pushes, pull requests created via Claude
- **Why**: Audit trail of code changes
- **Example**: Committed 15 files to feature branch

### 5. Cost & Token Usage

- **What**: Tokens consumed (input/output/cache), USD costs
- **Why**: Budget tracking, chargeback allocation
- **Example**: Session cost: $0.45, 10,000 tokens

### 6. Error Information

- **What**: Failed operations, error messages, API failures
- **Why**: Troubleshooting, reliability monitoring
- **Example**: "Tool execution timeout after 30 seconds"

## What We DO NOT Monitor

The following data is **NOT** collected:

- ❌ File contents (unless you explicitly include them in prompts)
- ❌ Passwords, API keys, or secrets (unless you include them in prompts)
- ❌ Screenshots or binary data
- ❌ Your browsing history or activity outside Claude Code
- ❌ Keyboard input outside Claude Code sessions

**⚠️ Important**: If you paste sensitive information (passwords, API keys, personal data) into Claude prompts, that information **will be logged**. Please avoid including sensitive data in your prompts.

## How We Use This Data

Collected data is used for:

1. **Audit & Compliance**: Security reviews, compliance audits (e.g., SOC 2)
2. **Cost Management**: Team/project cost allocation, budget forecasting
3. **Security Monitoring**: Detecting unusual or risky operations
4. **Troubleshooting**: Helping you when Claude Code isn't working
5. **Analytics**: Understanding adoption, usage patterns, productivity metrics

## Who Has Access

Access to Claude Code telemetry data is restricted:

| Data Type | Who Can Access |
|-----------|---------------|
| Aggregate metrics (usage, costs) | Engineering management, finance teams |
| Individual session details | Security team, compliance officers |
| Full prompt text & audit logs | Security team only (for investigations) |
| Your own session data | You (via session ID queries) |

Access is controlled via Azure Role-Based Access Control (RBAC).

## Data Retention

| Data Type | Retention Period |
|-----------|-----------------|
| Metrics & aggregates | 90 days in Application Insights |
| Detailed logs | 90 days (default), up to 2 years in Log Analytics |
| Local audit logs | Indefinite (stored on your machine) |

After the retention period, data is automatically deleted from Azure.

## Data Storage & Security

- **Where**: Azure Application Insights (Microsoft-managed infrastructure)
- **Region**: [TO BE SPECIFIED - e.g., East US, West Europe]
- **Encryption**: Data encrypted in transit (TLS) and at rest (Azure Storage encryption)
- **Compliance**: Azure is SOC 2, ISO 27001, GDPR compliant

## Your Rights

You have the right to:

1. **Access your data**: Request a copy of your Claude Code session data
2. **Understand processing**: Ask how your data is being used
3. **Opt out**: Disable telemetry locally (see below)
4. **Data deletion**: Request deletion of specific session data (subject to retention policies)

To exercise these rights, contact: [CONTACT EMAIL/SLACK CHANNEL]

## Opting Out

Telemetry can be disabled locally (if not enforced organization-wide):

### Method 1: Local Settings Override

Create `.claude/settings.local.json` in your project:

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

**Note**: If your organization uses managed settings (enterprise-wide enforcement), local opt-out may not be possible. Contact IT/Security for guidance.

## Third-Party Data Sharing

Claude Code telemetry data is **NOT** shared with:

- ❌ Anthropic (Claude's creator) - Only standard API usage is tracked by Anthropic
- ❌ Third-party vendors
- ❌ External partners or customers

Data stays within our organization's Azure infrastructure.

## Changes to This Notice

We may update this notice as our monitoring practices evolve. Changes will be communicated via:

- Engineering all-hands meetings
- Internal wiki announcements
- Email notifications

Continued use of Claude Code after changes constitutes acceptance.

## Questions & Concerns

If you have questions about this monitoring:

- **Technical setup**: See [OBSERVABILITY.md](./OBSERVABILITY.md)
- **Privacy concerns**: Contact [PRIVACY OFFICER EMAIL]
- **Access requests**: Contact [DATA GOVERNANCE EMAIL]
- **General questions**: [SLACK CHANNEL / EMAIL]

## Acknowledgment

By using Claude Code within our organization, you acknowledge that:

1. You have read and understand this privacy notice
2. You are aware your usage is monitored
3. You will not include sensitive data (passwords, secrets) in prompts
4. You understand the data retention and access policies

---

**Document Owner**: [TEAM/DEPARTMENT]
**Review Frequency**: Annually
**Next Review**: [DATE]

---

## For Administrators

### Legal Review

Before deploying this monitoring:

- [ ] Privacy notice reviewed by legal team
- [ ] Approved by data protection officer (if applicable)
- [ ] Aligned with company privacy policy
- [ ] Compliant with applicable regulations (GDPR, CCPA, etc.)
- [ ] Employee consent obtained (if required)

### Communication Checklist

- [ ] Privacy notice published to internal wiki
- [ ] Announced in engineering all-hands
- [ ] Added to onboarding materials
- [ ] Linked from Claude Code setup documentation
- [ ] Included in acceptable use policy

### Technical Implementation

- [ ] Azure RBAC configured (restrict audit log access)
- [ ] Data retention policies set in Azure
- [ ] Opt-out mechanism tested
- [ ] Access request process documented
