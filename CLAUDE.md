# Kirchheim Harmonists — Web Footprint

Monorepo for the choir's website and its Cloudflare infrastructure. This is also a
learning project for agentic development, so favour clarity and small, reviewable
steps over cleverness, and teach as you go (see "How I want to work" below).

## Layout
- `docs/requirements.md` — source of truth for scope & decisions. **Read it before
  planning any work.**
- `site/` — Astro + Svelte content site → Cloudflare Pages. See `site/CLAUDE.md`.
- `infra/` — Terraform (Cloudflare provider v5) → all infrastructure. See
  `infra/CLAUDE.md`.
- `workers/email-router/` — tiny Email Worker that fans `info@` out to several inboxes
  (added when we build email routing).

## Ground rules
1. **Plan before editing.** For any non-trivial change, produce a short written plan
   and wait for approval before writing code.
2. **Verify against live docs; don't trust memory.** Cloudflare's products and the
   Terraform provider move fast, and much material online is stale (v5 differs a lot
   from v4). Before using a resource, binding, or CLI flag, confirm it against current
   docs (links are in the sub-project `CLAUDE.md` files). If you can't verify
   something, **say so and pick a guaranteed path — don't guess silently.**
3. **Respect the IaC/app boundary** (see `infra/CLAUDE.md`): Terraform owns
   *infrastructure that exists*; wrangler/build tooling owns *code that deploys*.
4. **Check real success conditions before declaring done.** Not "it should work" — run
   the build/checks, confirm routes render, confirm no scope creep and no stray
   dependencies. Verify; don't assert.
5. **Commit at each green increment** with a clear message. Those commits are our
   checkpoints — the safe points we can always reset to.
6. **Free-tier first.** Everything in Phase 1 must sit inside Cloudflare's free tiers.
   Flag anything that wouldn't.

## How I want to work (mentoring)
This is a project for learning agentic development, so alongside doing the work, help
me get better at directing an agent:
- Explain the **reasoning** behind your plans, not just the steps.
- Flag when a decision is **architecturally consequential vs. trivial**, so I learn to
  tell them apart.
- Surface your **assumptions** and anything you couldn't verify.
- Explain notable choices of **tools, models, and workflow**.
- Name the **agentic principle** you're demonstrating when it's useful — but weave it
  in, keep it concise, and never at the expense of doing the work.
- If I'm about to do something that will **bite me later**, tell me plainly.

## Scope
- **Phase 1 (current):** static site (about + events), `info@` forwarding with fan-out,
  legal pages, full Terraform. Production only.
- **Phase 2 (later):** subscribe + newsletter (needs a paid or third-party send path).
  Don't build these yet — just don't paint us into a corner.

## Constraints
- Public German website → **Impressum + Datenschutzerklärung are mandatory.**
- Domain `kirchheim-harmonists.com`; DNS already on Cloudflare.