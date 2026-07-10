# infra/ — Terraform (Cloudflare)

Manages all Cloudflare infrastructure for `kirchheim-harmonists.de`.

## Provider & docs — verify BEFORE writing resources
- Provider: `cloudflare/cloudflare`, pinned `~> 5`. **v5 is a ground-up,
  auto-generated rewrite**; resource names and schemas differ from v4, and the large
  majority of blog examples online are v4 and therefore WRONG.
- Before adding or editing ANY resource or data source, look up its current schema:
  - Registry: <https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs>
  - Cloudflare docs are agent-friendly: append `index.md` to a page URL, or use a
    product `llms.txt` index — e.g. `email-routing/`, `workers/`, `pages/`, `r2/` under
    <https://developers.cloudflare.com/>.
- Terraform CLI **≥ 1.10** (required for `use_lockfile`).

## State backend — R2 (free)
- Use the `s3` backend pointed at R2 with native lockfile locking
  (`use_lockfile = true`; no DynamoDB). R2's recurring free tier easily covers this.
- The `s3` backend needs several AWS-isms disabled to talk to R2 (custom endpoint,
  region placeholder, and skip-flags for credential/region validation and checksums).
  **Verify the exact current flag set against the Terraform s3-backend docs and
  Cloudflare's R2+Terraform guidance before trusting any snippet, including from
  memory.**
- The bootstrap R2 bucket + API token are created by hand once (document in the repo
  README), since the backend can't store its own configuration.

## Resources in scope, Phase 1 — names to VERIFY, not assume
- DNS records for the site and email routing.
- Email Routing: settings, destination addresses, and the rule pointing `info@` at the
  fan-out Worker (the `cloudflare_email_routing_*` family — verify exact names/args).
- (The site Worker, its custom domain, and static assets are deployed by wrangler/CI —
  **not** Terraform. See the boundary note below.)
- Optionally the Email Worker script itself — but see the boundary note below.

## IaC/app boundary
- **Terraform owns:** DNS (incl. email-related records), Email Routing settings/addresses/
  rules, R2 state-bucket config, API-token-scoped configuration.
- **wrangler/build owns:** the site Worker — its script, static assets, **and its custom
  domain** (declared in `wrangler.jsonc`, deployed via GitHub Actions) — plus the Email
  Worker *code*.
- **Decision (site domain): Option A.** The site's custom domain is deploy-coupled, so
  wrangler owns it; Cloudflare then auto-manages the apex DNS record for that domain.
  Terraform therefore does *not* manage the site route.
- **Grey area — decided (I3):** the fan-out Worker's *code* is deployed via
  `wrangler`/CI (`.github/workflows/deploy-email-worker.yml`, mirroring the site
  deploy workflow), **not** a `cloudflare_workers_script` resource. Terraform only
  wires the `cloudflare_email_routing_rule` to it **by name**
  (`var.email_worker_name`, see `infra/email.tf`). This keeps the same boundary as the
  site Worker and means the Worker must be deployed once (so a Worker with that name
  exists) *before* the Terraform rule is applied — see `workers/email-router/README.md`.

## Human-in-the-loop (Terraform CANNOT do these)
- Each email destination address must be verified by its owner clicking a link; rules
  stay disabled until then.
- Initial Cloudflare API token creation and `wrangler login`.

## Secrets
- Least-privilege Cloudflare API token, scoped to this zone/account and the specific
  products in use. Never commit it. Pass via `TF_VAR_` env vars or a git-ignored
  `*.tfvars`.

## Commands — run before declaring done
- `terraform fmt -recursive`
- `terraform validate`
- `terraform plan` — always read the plan; never `apply` without reviewing it.
