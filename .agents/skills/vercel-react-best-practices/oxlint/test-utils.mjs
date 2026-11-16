import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const binary = fileURLToPath(new URL("./node_modules/oxlint/bin/oxlint", import.meta.url));

export function lint(config, files) {
  const result = spawnSync(process.execPath, [binary, "--config", config,
    "--disable-nested-config", "--format", "json", ...files], { encoding: "utf8" });
  assert.ok([0, 1].includes(result.status), result.stderr || result.stdout);
  const output = JSON.parse(result.stdout);
  assert.ok(output.diagnostics.every((item) => item.code), result.stdout);
  return output.diagnostics;
}
