// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  build: {
    // Emit all CSS as external files (never inline a <style> block). Astro
    // inlines small stylesheets by default, which would force the CSP to allow
    // style-src 'unsafe-inline'. Externalising every stylesheet lets style-src
    // stay 'self' only — a strictly tighter policy. See site/public/_headers.
    inlineStylesheets: 'never',
  },
});
