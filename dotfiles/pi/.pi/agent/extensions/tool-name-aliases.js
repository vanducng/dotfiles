// Pi extension: recover from a model that calls a built-in tool by a corrupted name.
// Some proxied models sometimes emit a mangled tool name (for example `then_write` for `write`); Pi answers
// "Tool <name> not found" and the model repeats the call on its next turn. This registers each name in an explicit
// alias list as a tool that runs the real tool, and keeps those aliases out of the tool list sent to the model.
//
// Only names listed here (or in the local file below) are aliased. There is no fuzzy matching: any other unknown
// name still fails exactly as before.
//
// Local aliases: a JSON object {"<corrupted name>": "<built-in tool>"} in $PI_TOOL_ALIASES_FILE, default
// ~/.pi/agent/tool-aliases.json. Use it for names that depend on one proxy setup. Linked by `make stow-pi`; /reload to load.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

// Corrupted names seen in session logs, each with the tool its arguments match.
export const DEFAULT_ALIASES = {
  then_write: "write",
  have_write: "write",
  dignity_edit: "edit",
  ship_edit: "edit",
};
const TARGETS = new Set(["bash", "read", "write", "edit", "grep", "find", "ls"]);
const NAME = /^[A-Za-z0-9_.-]{1,128}$/;

// Merges the default list with the local file. Entries that are not a name mapped to a built-in tool are dropped
// (reported through `warn`), and an alias can never shadow a built-in tool.
export function loadAliases(file, warn = () => {}) {
  const aliases = { ...DEFAULT_ALIASES };
  let local = {};
  if (file && fs.existsSync(file)) {
    try { local = JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) { warn(`${file}: ${e.message}`); }
  }
  for (const [alias, target] of Object.entries(local && typeof local === "object" ? local : {})) {
    if (NAME.test(alias) && !TARGETS.has(alias) && TARGETS.has(target)) aliases[alias] = target;
    else warn(`ignored alias '${alias}': needs a plain name and a built-in target (${[...TARGETS].join(", ")})`);
  }
  return aliases;
}

export default function (pi) {
  const file = process.env.PI_TOOL_ALIASES_FILE || path.join(os.homedir(), ".pi", "agent", "tool-aliases.json");
  const aliases = loadAliases(file, msg => console.error(`tool-name-aliases: ${msg}`));
  // Only aliases that were actually registered are hidden; a skipped one (no target, or the name is taken) is not.
  const registered = new Set();

  // Registered once the built-in tools exist, so each alias can take its target's parameter schema.
  pi.on("session_start", () => {
    const all = pi.getAllTools();
    for (const alias of Object.keys(aliases)) {
      const target = all.find(t => t.name === aliases[alias]);
      if (!target || all.some(t => t.name === alias)) continue;
      pi.registerTool({
        name: alias,
        label: alias,
        description: `Alias of ${target.name}: runs ${target.name} with the same arguments.`,
        parameters: target.parameters,
        // Active, so a call by this name resolves; hidden, so the model is never told the name exists.
        prepareLoadout: () => ({ hiddenDeclarations: [...registered] }),
        async execute(_id, params, signal, onUpdate, ctx) {
          const out = await ctx.executeTool(target.name, params, { signal, onUpdate });
          if (!out.isError) return out.result;
          // Keep a non-object error result readable instead of spreading a string into numbered keys.
          return out.result && typeof out.result === "object"
            ? { ...out.result, isError: true }
            : { content: [{ type: "text", text: String(out.result) }], isError: true };
        },
      });
      registered.add(alias);
    }
  });
}
