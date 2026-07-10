# email-router

Tiny Cloudflare Email Worker that fans `info@kirchheim-harmonists.de` out to several
verified inboxes.

## How it works
Cloudflare Email Routing invokes this Worker's `email()` handler for each message
matching the `info@` routing rule. The Worker splits the `FORWARD_TO` secret on commas
and forwards the message to each address with `message.forward()`. No `send_email`
binding is needed for forwarding to already-verified destination addresses.

## Configuring recipients
Recipient addresses are **not** in code or git (this is a public repo):

- **Production:** `wrangler secret put FORWARD_TO` (comma-separated list), from this
  directory. Each address must already be a verified destination address in Cloudflare
  Email Routing (see `infra/email.tf`).
- **Local dev:** copy `.dev.vars.example` to `.dev.vars` (git-ignored) and edit it.

## Deploy
```sh
npm install
npm run deploy   # wrangler deploy
```

**Ordering matters:** this Worker must be deployed (so a Worker with this name exists)
*before* `terraform apply` creates the email routing rule that targets it by name —
see `infra/email.tf` and `infra/CLAUDE.md`.
