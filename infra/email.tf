# Email Routing for kirchheim-harmonists.de: fan out info@ to several verified
# inboxes via the kirchheim-harmonists-email-router Worker.
#
# Ordering matters:
#   1. The email Worker must already be deployed (wrangler, see
#      workers/email-router/) before `terraform apply` runs the rule below —
#      cloudflare_email_routing_rule targets it by name and the Worker must exist.
#   2. Each address in cloudflare_email_routing_address must be verified by its
#      owner (they receive a confirmation email with a link to click). Forwarding
#      to an address silently fails until it is verified — Terraform cannot do
#      this step; it's human-in-the-loop.

# Turns on Email Routing for the zone. `enabled` is computed by the provider —
# do not set it here.
resource "cloudflare_email_routing_settings" "this" {
  zone_id = var.zone_id
}

# Creates the MX and SPF DNS records Email Routing needs.
resource "cloudflare_email_routing_dns" "this" {
  zone_id = var.zone_id
}

# One destination address per recipient. Each must be verified by its owner
# before mail actually reaches them.
resource "cloudflare_email_routing_address" "recipients" {
  for_each = toset(var.forward_recipients)

  account_id = var.account_id
  email      = each.value
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
    cloudflare_email_routing_address.recipients,
  ]
}
