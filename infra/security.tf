# Security hardening (applies at launch, alongside the rest of the infra).

# --- Email anti-spoofing --------------------------------------------------
# The domain forwards (receives) mail but does not *send* as itself, so a DMARC
# reject policy tells receivers to drop anything spoofing @kirchheim-harmonists.de.
# SPF is managed by cloudflare_email_routing_dns (see email.tf) — do not add a
# second SPF record here. Revisit alignment (SPF/DKIM) if we ever send mail as
# this domain (e.g. a Phase 2 newsletter).
resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1; p=reject; adkim=s; aspf=s"
  ttl     = 1 # automatic
}

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
