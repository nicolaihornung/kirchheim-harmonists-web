# site/ — Astro + Svelte content site

Static-first site for the choir, deployed to Cloudflare Workers (static assets).
TypeScript throughout.

## Stack
- **Astro** (Vite-based). Scaffold with the official tooling — don't hand-write
  boilerplate that a generator produces correctly and currently.
- **Svelte** only for interactive islands. **Phase 1 has no interactive forms**
  (contact is a plain `info@` block), so Phase 1 likely ships **zero islands** — that's
  expected. Svelte comes in with the Phase 2 subscribe form.
- Phase 1 output is **fully static** (no SSR, no adapter needed). Add
  `@astrojs/cloudflare` + SSR only in Phase 2, when a server endpoint first appears.

## Content
- Events live as **typed content-collection entries** (markdown/data files in git).
  Editing an event = edit a file + redeploy. No CMS, no admin auth.
- Content is in German. Structure things so English could be added later, but don't
  build i18n now.

## Pages (Phase 1)
Home / about the choir · Upcoming events · Contact (display
`info@kirchheim-harmonists.de`) · Impressum · Datenschutzerklärung.

## Non-negotiables
- Impressum + Datenschutzerklärung present and linked in the footer.
- Responsive, accessible, and privacy-friendly (no unnecessary third-party scripts or
  trackers).

## Commands — run before declaring done
- `npm run dev` — local dev server
- `npm run build` — production build
- `npx astro check` — type & diagnostics check
