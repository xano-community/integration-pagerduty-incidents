function "pagerduty_resolve_incident" {
  description = "Resolve an existing PagerDuty incident"
  input {
    text incident_id { description = "PagerDuty incident ID to resolve" }
    text from_email { description = "Email address of the PagerDuty user resolving the incident" }
  }
  stack {
    api.request {
      url = "https://api.pagerduty.com/incidents"
      method = "PUT"
      headers = ["Authorization: Token token=" ~ $env.PAGERDUTY_API_KEY, "Content-Type: application/json", "Accept: application/vnd.pagerduty+json;version=2", "From: " ~ $input.from_email]
      params = {
        incidents: [{
          id: $input.incident_id,
          type: "incident_reference",
          status: "resolved"
        }]
      }
      mock = {
        "resolves incident successfully": { response: { status: 200, result: { incidents: [{ id: "PT4KHLK", type: "incident", status: "resolved", title: "Server CPU critical" }] } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 200) {
      error_type = "standard"
      error = "PagerDuty API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "resolves incident successfully" {
    input = { incident_id: "PT4KHLK", from_email: "oncall@example.com" }
    expect.to_not_be_null ($response.incidents)
  }
}