# Security hardening (applies at launch, alongside the rest of the infra).

# --- Email anti-spoofing --------------------------------------------------
# DMARC is NOT managed here. Cloudflare's "DMARC Management" feature already
# publishes the `_dmarc` record (p=reject) AND processes aggregate reports
# (rua=mailto:dmarc-reports@kirchheim-harmonists.de) in the dashboard. A DMARC
# record managed here too would be a *second* _dmarc record, and per RFC 7489
# §6.6.3 multiple DMARC records make receivers ignore DMARC entirely — so we
# deliberately let Cloudflare own it and do not add one. Revisit alignment
# (SPF/DKIM) if we ever send mail as this domain (e.g. a Phase 2 newsletter).
# SPF is managed by cloudflare_email_routing_dns (see email.tf).

# --- HTTPS / TLS hardening (zone-wide) ------------------------------------
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = var.zone_id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "min_tls_version" {
  zone_id    = var.zone_id
  setting_id = "min_tls_version"
  value      = "1.2"
}
