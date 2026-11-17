// The footer's model label, built from the provider and the model id, never the display name:
// <provider>/<id prefix, if any>/<family>-<version>, for example cpa/opus-5.5 or openai-codex/sol-6.1.
// The vendor word goes, the version takes dots, and the family comes first. An id the rule can't parse shows as is.
// Grok ids have no family word, so they keep the vendor word: grok-4.7, grok-4.7-build-fast.
// This folder has no index file, so Pi does not load it as an extension.
const VENDORS = new Set(["claude", "gpt"]);

export function shortModel(name) {
	const [vendor, ...rest] = name.split("-");
	if (!VENDORS.has(vendor)) return name; // grok, glm and any other vendor the rule does not know
	const parts = rest.filter((p) => !/^\d{8}$/.test(p)); // a release date is not part of the version
	const version = parts.filter((p) => /^\d+(\.\d+)?$/.test(p));
	const family = parts.filter((p) => !version.includes(p));
	return version.length && family.length ? `${family.join("-")}-${version.join(".")}` : name;
}

export function modelLabel(provider, id) {
	const segments = id.split("/");
	const name = segments.pop();
	return [provider, ...segments, shortModel(name)].filter(Boolean).join("/");
}
