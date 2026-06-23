function "pagerduty_create_incident" {
  description = "Create a new incident in PagerDuty to trigger alerting"
  input {
    text title { description = "Incident title/description" }
    text service_id { description = "PagerDuty service ID to create the incident on" }
    text from_email { description = "Email address of the PagerDuty user creating the incident" }
    text urgency?="high" { description = "Incident urgency: high or low" }
    text incident_key? { description = "Deduplication key to prevent duplicate incidents" }
    text body? { description = "Detailed incident body/description" }
  }
  stack {
    var $incident {
      value = {
        type: "incident",
        title: $input.title,
        service: {
          id: $input.service_id,
          type: "service_reference"
        },
        urgency: $input.urgency
      }
    }
    var.update $incident { value = $incident|set_ifnotempty:"incident_key":$input.incident_key }

    conditional {
      if ($input.body != null) {
        var.update $incident {
          value = $incident|set:"body":{
            type: "incident_body",
            details: $input.body
          }
        }
      }
    }

    api.request {
      url = "https://api.pagerduty.com/incidents"
      method = "POST"
      headers = ["Authorization: Token token=" ~ $env.PAGERDUTY_API_KEY, "Content-Type: application/json", "Accept: application/vnd.pagerduty+json;version=2", "From: " ~ $input.from_email]
      params = { incident: $incident }
      mock = {
        "creates incident successfully": { response: { status: 201, result: { incident: { id: "PT4KHLK", type: "incident", title: "Server CPU critical", status: "triggered", urgency: "high", service: { id: "PIJ90N7", summary: "Production" } } } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "PagerDuty API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates incident successfully" {
    input = { title: "Server CPU critical", service_id: "PIJ90N7", from_email: "oncall@example.com" }
    expect.to_not_be_null ($response.incident.id)
    expect.to_equal ($response.incident.status) { value = "triggered" }
  }
}