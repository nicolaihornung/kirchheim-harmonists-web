# Email Routing for kirchheim-harmonists.de: fan out info@ to several verified
# inboxes via the kirchheim-harmonists-email-router Worker.
#
# Ordering matters:
#   1. The email Worker must already be deployed (wrangler, see
#      workers/email-router/) before `terraform apply` runs the rule below —
#      cloudflare_email_routing_rule targets it by name and the Worker must exist.
#   2. The destination address(es) info@ fans out to are created and verified
#      by hand in the dashboard (Email Routing → Destination addresses), NOT by
#      Terraform: the account-scoped "Email Routing Addresses" permission isn't
#      available in the current custom-token editor, and verification (clicking
#      the confirmation link) was always a human-in-the-loop step regardless.
#      The Worker learns the recipients from its FORWARD_TO secret (wrangler),
#      so Terraform doesn't need them either.

# Turns on Email Routing for the zone. `enabled` is computed by the provider —
# do not set it here.
resource "cloudflare_email_routing_settings" "this" {
  zone_id = var.zone_id
}

# Creates the MX and SPF DNS records Email Routing needs.
resource "cloudflare_email_routing_dns" "this" {
  zone_id = var.zone_id
}

# Routes info@ to the fan-out Worker, which forwards to the recipients above
# (recipients are passed to the Worker via the FORWARD_TO secret, not Terraform).
resource "cloudflare_email_routing_rule" "info_fanout" {
  zone_id = var.zone_id
  name    = "info@ fan-out"
  enabled = true

  matchers = [{
    type  = "literal"
    field = "to"
    value = "info@kirchheim-harmonists.de"
  }]

  actions = [{
    type  = "worker"
    value = [var.email_worker_name]
  }]

  depends_on = [
    cloudflare_email_routing_settings.this,
  ]
}
