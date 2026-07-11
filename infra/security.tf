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

# --- Certificate issuance restriction (CAA) -------------------------------
# Restrict which CAs may issue certificates for this domain to the ones
# Cloudflare uses for Universal SSL (values verified against Cloudflare's
# "Certificate authorities" docs). This blocks certificate mis-issuance by any
# other CA.
#
# Safe by design: with Universal SSL on, Cloudflare automatically adds CAA
# records for any CA it still needs once a CAA record exists, so this cannot
# lock Cloudflare out of issuing/renewing — it only shuts out third-party CAs.
# `issue` covers leaf certs; `issuewild` the wildcard (*.domain) cert. CAA at
# the apex is inherited by all subdomains, so one set here covers www etc.
locals {
  caa_issuers = [
    "letsencrypt.org",                    # Let's Encrypt
    "pki.goog; cansignhttpexchanges=yes", # Google Trust Services
    "ssl.com",                            # SSL.com
    "sectigo.com",                        # Sectigo (backup certificates)
  ]

  caa_records = merge(
    { for ca in local.caa_issuers : "issue::${ca}" => { tag = "issue", value = ca } },
    { for ca in local.caa_issuers : "issuewild::${ca}" => { tag = "issuewild", value = ca } },
  )
}

resource "cloudflare_dns_record" "caa" {
  for_each = local.caa_records

  zone_id = var.zone_id
  name    = "kirchheim-harmonists.de"
  type    = "CAA"
  ttl     = 1 # automatic

  data = {
    flags = 0
    tag   = each.value.tag
    value = each.value.value
  }
}
