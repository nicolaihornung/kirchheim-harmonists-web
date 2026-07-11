// Decode obfuscated <Email /> spans into real mailto: links on load.
// Kept as an external file (not an inline <script>) so the site's Content-
// Security-Policy can use a strict script-src 'self' with no 'unsafe-inline'.
for (const el of document.querySelectorAll('.js-email')) {
	const enc = el.getAttribute('data-e');
	if (!enc) continue;
	const address = atob(enc);
	const a = document.createElement('a');
	a.href = 'mailto:' + address;
	a.textContent = el.getAttribute('data-label') || address;
	const rest = el.className.replace('js-email', '').trim();
	if (rest) a.className = rest;
	el.replaceWith(a);
}
