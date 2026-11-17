// The Pi footer's model label: <provider>/<id prefix>/<short model>, built from the id, never the display name.
// Usage: node pi-model-label.check.mjs <model-label.js>
import path from "node:path";
import { pathToFileURL } from "node:url";

const file = process.argv[2];
if (!file) { console.error("usage: pi-model-label.check.mjs <model-label.js>"); process.exit(2); }
const { modelLabel } = await import(pathToFileURL(path.resolve(file)).href);

let fail = 0;
const is = (provider, id, want) => {
	const got = modelLabel(provider, id);
	const ok = got === want;
	if (!ok) fail++;
	console.log(`  ${ok ? "✓" : "✗"} ${provider} + ${id} -> ${want}${ok ? "" : `  (got ${got})`}`);
};
is("cpa", "claude-opus-5-5", "cpa/opus-5.5");
is("cpa", "acme/claude-opus-5-5", "cpa/acme/opus-5.5");
is("cpa", "acme/gpt-6.1-sol", "cpa/acme/sol-6.1");
is("openai-codex", "gpt-6.1-sol", "openai-codex/sol-6.1");
is("cpa", "claude-sonnet-5-5", "cpa/sonnet-5.5");
is("cpa", "claude-haiku-4-5-20251001", "cpa/haiku-4.5"); // a date suffix is not part of the version
is("cpa", "claude-3-7-sonnet-20250219", "cpa/sonnet-3.7"); // version first in the id, family first in the label
is("cpa", "gpt-6-luna", "cpa/luna-6");
is("cpa", "gpt-6.1-terra", "cpa/terra-6.1");
// Not parsed: shown as is.
is("cpa", "gpt-5.4", "cpa/gpt-5.4"); // no family word
is("cpa", "claude", "cpa/claude"); // no version
is("cpa", "glm-5.1", "cpa/glm-5.1"); // a vendor the rule does not know
is("cpa", "acme/widget-9", "cpa/acme/widget-9"); // a prefix, and a family the rule does not know
is("", "claude-opus-5-5", "opus-5.5"); // no provider
console.log(fail ? `pi model label: ${fail} failed` : "pi model label: ok");
process.exit(fail ? 1 : 0);
