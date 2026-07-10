# infra/ — Terraform for Cloudflare

Manages the Cloudflare infrastructure for `kirchheim-harmonists.de` that *exists*
(DNS, Email Routing). The **site deploy** (the Worker + its custom domain + static
assets) is owned by wrangler/CI, **not** Terraform — see `CLAUDE.md` for the boundary.

State is stored in **Cloudflare R2** via the S3-compatible backend, with native
lockfile locking (`use_lockfile`, Terraform ≥ 1.10 — no DynamoDB).

## Prerequisites
- Terraform **≥ 1.10**.
- A Cloudflare account with the `kirchheim-harmonists.de` zone (DNS already on Cloudflare).

## One-time bootstrap (done by hand — Terraform can't create its own backend)

1. **Enable R2** in the Cloudflare dashboard (R2 → *Enable*). Note: Cloudflare may ask
   for billing details even though our usage stays within the free tier.
2. **Create a private R2 bucket** for state, e.g. `kirchheim-harmonists-tfstate`.
3. **Create an R2 API token** (R2 → *Manage API Tokens* → *Create*, object read & write
   scoped to the state bucket). This yields:
   - an **Access Key ID** and **Secret Access Key** (S3 credentials), and
   - your account's S3 endpoint: `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`.
4. **Create a Cloudflare API token** for the provider (My Profile → API Tokens). The
   exact least-privilege scopes are finalised when we add resources (I3: `DNS:Edit` +
   `Email Routing:Edit` for this zone). For I1, any token that can read the account/zone
   is enough to `validate`/`plan`.
5. **Configure local secrets & backend config** (never commit these):
   ```sh
   cp backend.hcl.example backend.hcl        # then edit bucket/key/endpoint
   export AWS_ACCESS_KEY_ID=<R2 access key id>
   export AWS_SECRET_ACCESS_KEY=<R2 secret access key>
   export CLOUDFLARE_API_TOKEN=<cloudflare api token>
   ```

## Initialise & use
```sh
terraform init -backend-config=backend.hcl   # connects to R2, sets up state
terraform validate
terraform plan                               # always read the plan before applying
terraform apply                              # only after reviewing the plan
```

## Conventions
- **Secrets never get committed.** `backend.hcl`, `*.tfvars`, and tokens are git-ignored;
  credentials come from env vars.
- **`.terraform.lock.hcl` IS committed** (pins provider versions/hashes).
- **Terraform is run manually**, with the plan reviewed — it is *not* auto-applied from
  CI. Only the site deploy is automated (GitHub Actions → wrangler).
- Before adding/editing any resource, verify its **v5** schema against the registry
  (v5 names differ from v4 — see `CLAUDE.md`).

## Commands — run before declaring done
- `terraform fmt -recursive`
- `terraform validate`
- `terraform plan` — read it; never `apply` without reviewing.
