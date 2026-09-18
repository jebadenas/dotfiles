---
name: ticket-workflow
description: Investigate a Jira ticket and create lightweight local investigation documentation with an approach plan, including automatic attachment/image sync and analysis. Use when the user says "pick up", "investigate", "start work on", "plan work for", or asks to review ticket screenshots/images/attachments (e.g. "pick up GTAX-336", "investigate FU-738", "check attachments on FBT-392").
metadata:
  author: Jos Badenas
  version: "1.3"
---

# Ticket Workflow

Structured investigation and planning workflow for Jira tickets. Automates Steps 1–2 (READ + PLAN) of the 8-step engineering workflow.

## When to Use

- User says "pick up [TICKET]", "investigate [TICKET]", "start work on [TICKET]", or "plan work for [TICKET]"
- User asks to review screenshots/images/files attached to a Jira ticket
- User wants to kick off work on a Jira ticket with proper investigation and documentation

## Configuration

- **Atlassian Cloud ID:** `eroad.atlassian.net`
- **Local ticket docs root:** `~/.pi/agent/tickets/<TICKET-KEY>/`
- **Attachment sync script:** `~/.pi/agent/skills/ticket-workflow/sync-jira-attachments.sh`
- **Auth setup script:** `~/.pi/agent/skills/ticket-workflow/setup-jira-auth.sh`
- **Jira auth env vars for attachment sync:** `JIRA_EMAIL` and `JIRA_API_TOKEN`
- **Optional auth file for auto-load:** `~/.config/copilot/jira.env` (or `JIRA_AUTH_FILE`)

## Workflow

### Phase 1: READ (Investigate)

Execute these steps automatically:

1. **Sync Jira attachments to local disk first**
   - If Jira auth is not configured yet, run `~/.pi/agent/skills/ticket-workflow/setup-jira-auth.sh` once.
   - Run `~/.pi/agent/skills/ticket-workflow/sync-jira-attachments.sh <TICKET-KEY>`
   - Save artifacts under the session ticket folder for direct agent access
   - Include a generated attachment index in the same folder
   - If attachments exist, treat image/screenshot analysis as part of the default investigation (no extra user prompt required)

2. **Fetch the Jira ticket** using `getJiraIssue` with the ticket key
   - Read the full description, acceptance criteria, and all comments
   - Read and reference attachment metadata/index from the local synced files
   - Identify: assignee, reporter, status, priority, parent epic, linked issues

3. **Map dependencies**
   - Check parent epic for sibling tickets (use JQL: `parent = {epicKey}`)
   - Check linked/blocked issues
   - Summarise: what must be done before this ticket? What depends on this ticket?

4. **Search Confluence** for related documentation
   - Use `search` with the ticket key and key terms from the summary
   - Read the top 3–5 relevant pages
   - Note: API specs, architecture docs, decision records, runbooks

5. **Search GitHub** for related code
   - Use `search_code` with key terms (function names, service names, error messages)
   - Use `search_pull_requests` for recent related PRs
   - Identify which repos are involved and what code paths matter

6. **Summarise findings** to the user:
   - What the ticket is asking for (in plain English)
   - What you found in Confluence/GitHub
   - What was found in attachments (especially images/screenshots)
   - Key dependencies and blockers
   - Open questions that need answers

### Phase 2: PLAN (Local Documentation & Approach)

After presenting the summary, ask the user if they want to proceed to planning. Then:

1. **Create local investigation docs** in the session ticket folder
   - Path: `~/.pi/agent/tickets/<TICKET-KEY>/`
   - Primary file: `INVESTIGATION.md`
   - **Reuse first** — if the file exists, update it rather than duplicating content.

2. **INVESTIGATION.md structure:**

   ```
   ## Overview
   Ticket link, status, customer/context, problem statement

   ## Approach Plan
   Table with: Phase | Action | Owner | Status
   Include Definition of Done

   ## Key Findings
   What was discovered during investigation (architecture, code paths, related docs)

   ## [Domain-specific sections as needed]
   e.g. Required Fields, Validation Rules, Integration Paths — whatever is relevant

   ## Activity Log
   Date | Action | Notes — timestamped record of work done

   ## References
   Links to: Jira ticket, Confluence docs, GitHub repos, PRs
   ```

3. **Draft the approach plan** with:
   - Numbered phases with clear actions
   - Owner for each phase
   - Status indicators (🟡 Waiting, ⬜ Blocked, ✅ Done)
   - Explicit blockers called out
   - Definition of Done

### Phase 3: HANDOFF (Guide Next Steps)

After updating local docs, **stop and ask the user** what they want to do next:

- Move to Step 3 (BRANCH) — suggest branch name following convention
- Contact someone about a blocker — draft a Jira comment with @mention for the user to post
- Switch to a different ticket
- Continue investigating

**Do NOT automatically:**
- Create git branches
- Open pull requests
- Post Jira comments on behalf of the user
- Transition ticket status
- Make code changes

These require explicit user confirmation.

## Principles

- **Prefer local docs** — use local ticket documentation by default instead of Confluence pages
- **Search before creating** — always check if a local investigation file exists before making a new one
- **Summarise before acting** — present findings to the user before creating docs
- **Ask before writing** — confirm with the user before posting comments or making changes
- **Draft-only Jira comments** — suggest the comment text and let the user post it
- **Link everything** — every investigation file links back to the Jira ticket and relevant repos/docs
- **Name owners** — every action item in the plan has an explicit owner
- **Quantify when possible** — error counts, field counts, timeline dates
