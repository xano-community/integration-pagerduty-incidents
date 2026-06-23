# PagerDuty Integration for Xano

Create and resolve incidents in PagerDuty from your Xano backend. Automate incident management by triggering alerts from application errors and resolving them programmatically when issues are fixed.

## Functions

| Function | Description |
| --- | --- |
| `pagerduty_create_incident` | Creates a new incident in PagerDuty to trigger alerting. |
| `pagerduty_resolve_incident` | Resolves an existing incident in PagerDuty. |

## Install

### Option A — Ask Claude Code

With the [Xano MCP](https://github.com/xano-labs/mcp-server) enabled in Claude Code, paste this into Claude:

> Install the integration at https://github.com/xano-community/integration-pagerduty-incidents into my Xano workspace.

Claude will clone the repo and push the functions to your workspace.

### Option B — Use the Xano CLI

1. Install and authenticate the [Xano CLI](https://docs.xano.com/cli):
   ```sh
   npm install -g @xano/cli
   xano auth
   ```

2. Clone and push this integration:
   ```sh
   git clone https://github.com/xano-community/integration-pagerduty-incidents.git
   cd integration-pagerduty-incidents
   xano workspace push . -w <your-workspace-id>
   ```

   Replace `<your-workspace-id>` with the ID from `xano workspace list`.

## Configure Credentials

1. Log in to your PagerDuty account at https://app.pagerduty.com.
2. Navigate to Integrations > Developer Tools > API Access Keys.
3. Click Create New API Key, provide a description, and copy the generated key.
4. In Xano, set the environment variable PAGERDUTY_API_KEY to your API key.

Environment variables used by this integration:

- `PAGERDUTY_API_KEY`

See `.env.example` for a template.

## Usage

Call any function from another function, task, or API endpoint using `function.run`:

```xs
function.run "pagerduty_create_incident" {
  input = {
    title: "Server CPU critical",
    service_id: "<your-pagerduty-service-id>",
    from_email: "<valid-pagerduty-user-email>"
  }
} as $result
```

## Function Reference

### `pagerduty_create_incident`

Opens a new incident on a specified PagerDuty service with a title, urgency level, and optional body details. This triggers the service's escalation policy and notifies on-call responders. Use this to automatically escalate critical application errors, failed jobs, or threshold breaches detected in your Xano workflows.

**Required inputs:**
- `title` — incident title/description
- `service_id` — PagerDuty service ID to create the incident on
- `from_email` — email address of a valid PagerDuty user in your account (required by the PagerDuty REST API v2 `From:` header)

**Optional inputs:**
- `urgency` — `"high"` (default) or `"low"`
- `incident_key` — deduplication key to prevent duplicate incidents
- `body` — detailed incident description

### `pagerduty_resolve_incident`

Transitions an open incident to the resolved state by its incident ID. This stops further escalation notifications and marks the issue as handled. Ideal for closing the loop on automated alerting — resolve incidents automatically when your application confirms the underlying issue has been corrected.

**Required inputs:**
- `incident_id` — PagerDuty incident ID to resolve
- `from_email` — email address of a valid PagerDuty user in your account (required by the PagerDuty REST API v2 `From:` header)

## License

MIT — see [LICENSE](./LICENSE).
