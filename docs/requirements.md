# Kirchheim Harmonists — Requirements

Web footprint for the Kirchheim Harmonists choir. This also doubles as a hands-on
learning project for agentic development with Claude Code; where there's a tension,
prefer clarity and small, verifiable steps over cleverness.

## Goals
- A simple, fast, low-maintenance website describing the choir, with an
  upcoming-events section and a way to get in contact.
- Email forwarding for `info@kirchheim-harmonists.de` to several personal inboxes.
- All infrastructure defined in Terraform.
- Everything within Cloudflare's free tiers wherever at all possible.

## Context & constraints
- Domain: `kirchheim-harmonists.de` (bought via Namecheap; DNS already delegated to
  Cloudflare).
- Public-facing **German** website → an **Impressum** and a **Datenschutzerklärung**
  are legally required, and any personal-data handling must follow GDPR (data
  minimisation, consent). This is not legal advice; treat these as hard requirements.
- **Free-tier first.** Where a feature can't be free on Cloudflare, it is deferred
  (see Phasing).

## Architecture (target)
- **DNS:** Cloudflare (done).
- **Website:** static Astro site (Svelte available for future interactive islands) →
  Cloudflare Workers with Static Assets.
- **Email in:** Cloudflare Email Routing forwards `info@` → a small Email Worker →
  multiple verified personal inboxes.
- **Infra:** Terraform, Cloudflare provider v5, state in Cloudflare R2 (`s3` backend
  with native lockfile locking).
- No hosted mailbox, no server, and no database in Phase 1.

## Phasing

### Phase 1 (now)
- Static website: about the choir, upcoming events (git-managed), a contact section
  that displays `info@`, plus Impressum and Datenschutzerklärung.
- `info@` forwarding with fan-out to several inboxes (including the conductor).
- Full Terraform for all of the above.
- Environments: **production only**.

### Phase 2 (later — out of scope now)
- Subscribe-to-updates with GDPR **double opt-in**, plus a newsletter / announcement
  send.
- These share one dependency: sending email to **non-verified** recipients, which is
  *not* free on Cloudflare (paid Email Sending). So they need a decision on the send
  path (paid Cloudflare Email Sending vs a third-party free tier such as Resend).
- Deferred deliberately: we will not collect subscriber emails until we can complete
  double opt-in, to avoid holding unconsented data.
- Design the data schema / IaC so adding this later needs no rework — but build
  nothing for it yet.

## Sub-project A — The website

**Scope (Phase 1)**
- Sections: Home / about the choir, Upcoming events, Contact (`info@` block),
  Impressum, Datenschutzerklärung.
- Events as **typed content-collection entries in git**; no CMS or admin. Adding or
  editing an event = edit a file and redeploy.
- **Fully static output** (no SSR yet). German content; structured so English could be
  added later without committing to i18n now.
- Responsive, accessible, privacy-friendly (avoid unnecessary trackers; if analytics
  are wanted, use a privacy-friendly option and disclose it).

**Non-goals (Phase 1):** contact form, subscribe form, newsletter, any login/admin,
any server-side rendering.

**Deploy:** Cloudflare Workers with Static Assets, deployed by wrangler/CI — *not* by
Terraform.

## Sub-project B — The Terraform IaC

**Scope**
- Provider `cloudflare/cloudflare` `~> 5` (the v5 rewrite; verify resource schemas
  against live docs — most online examples are stale v4).
- **State backend:** Cloudflare R2 via the `s3` backend with `use_lockfile = true`
  (Terraform ≥ 1.10; no DynamoDB). Bootstrap bucket + token created once by hand.
- **Manages:** DNS records (incl. email-related MX/SPF); Email Routing settings, verified
  destination addresses, and the routing rule sending `info@` to the fan-out Worker; the
  state-bucket config. (The site Worker + its custom domain are owned by wrangler/CI — see
  boundary below.)
- **IaC/app boundary:** Terraform owns *infrastructure that exists*; wrangler/build
  owns *code that deploys* (the site, and the Email Worker's code). The fan-out Worker
  is a small grey area — decide at build time whether TF or wrangler owns the script,
  and record the choice in `infra/CLAUDE.md`.

**Human steps Terraform can't automate**
- The owner of each destination inbox must click Cloudflare's verification link before
  forwarding goes live (rules stay disabled until then).
- One-time API token creation and `wrangler login`.

**Secrets:** least-privilege Cloudflare API token, never committed; passed via
`TF_VAR_` env vars or a git-ignored `*.tfvars`.

## Email fan-out detail
- Email Routing maps `info@` to exactly one destination, so multi-recipient delivery
  uses a small Email Worker that calls `forward()` once per address.
- Recipients (all must be **verified** destinations): Nicolai's inbox, the conductor,
  and other organizers — final list TBD, to be provided.
- Free: forwarding and sending to verified destinations cost nothing on any plan.
- Known trade-off: a reply sent from a personal inbox shows that personal address, not
  `info@` (reply-as-`info@` is a Phase 2+ concern).

## Key decisions (with rationale)
- **Astro + Svelte islands** — best fit for a content-heavy, static site; near-zero JS;
  content collections suit git-managed events; Svelte is on hand for Phase 2
  interactivity. TypeScript throughout.
- **Deploy via Workers with Static Assets** (not Pages) — Cloudflare's recommended
  path for new projects; static-asset requests are free and unlimited; SSR can be
  added to the same Worker in Phase 2 with no platform migration; avoids the now
  feature-frozen Pages platform.
- **Events as git files, not a CMS** — simplest, free, no auth or attack surface.
- **Contact = displayed `info@`** (not a form) in Phase 1 — keeps Phase 1 free of any
  send path or server code.
- **R2 state backend with native lockfile locking** — free, keeps everything on
  Cloudflare, no lock table to manage.
- **Newsletter + subscribe deferred to Phase 2** — both need paid/3rd-party sending,
  and deferring avoids holding unconsented PII.
- **Production only** — no preview environment for now.

## Open items / to provide
- Final list of `info@` fan-out recipient addresses.
- Impressum details (responsible party for the choir / Verein) and Datenschutzerklärung
  content.
- Branding: colours, logo, tone.