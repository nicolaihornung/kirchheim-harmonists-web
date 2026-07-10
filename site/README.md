# Kirchheim Harmonists — Website

Static Astro site for the choir, deployed to **Cloudflare Workers (Static Assets)**.
Phase 1: fully static (no SSR, no adapter).

## Commands

Run all commands from the `site/` directory.

| Command                        | Action                                          |
| :----------------------------- | :---------------------------------------------- |
| `npm install`                  | Installs dependencies                           |
| `npm run dev`                  | Starts local dev server at `localhost:4321`     |
| `npm run build`                | Builds the production site to `dist/`           |
| `npx astro check`              | Type & content-collection checks                |
| `npx wrangler deploy --dry-run`| Validates the deploy config without deploying   |

## Deployment (CI/CD)

Pushing to `main` (any change under `site/**`) triggers
[`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml): it builds the site and
runs `wrangler deploy`, publishing to Cloudflare Workers. The first deploy also provisions
the custom domains declared in `wrangler.jsonc` (`kirchheim-harmonists.de` + `www`).

Terraform/infra is **not** run by CI — see `../infra/README.md`.

### Required GitHub Actions secrets
Set these under **repo → Settings → Secrets and variables → Actions**:

- `CLOUDFLARE_API_TOKEN` — a scoped API token (see below)
- `CLOUDFLARE_ACCOUNT_ID` — your Cloudflare account ID

### Least-privilege token scopes (for `CLOUDFLARE_API_TOKEN`)
- **Account · Workers Scripts: Edit** — deploy the Worker + upload static assets
- **Zone (`kirchheim-harmonists.de`) · Workers Routes: Edit** — attach the custom domains
- **Zone · DNS: Edit** — a Custom Domain creates/points a DNS record
- (optional) **Account · Account Settings: Read** — account resolution

This is a *separate* token from the one Terraform uses (that one only needs DNS + Email
Routing edit). Keep them distinct so each is least-privilege.
