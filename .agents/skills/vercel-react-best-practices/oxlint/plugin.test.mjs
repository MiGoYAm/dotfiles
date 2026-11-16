import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

import { lint } from "./test-utils.mjs";

const pluginPath = fileURLToPath(new URL("./plugin.mjs", import.meta.url));

test("functional updates follow React bindings and respect scope", (t) => {
  const directory = mkdtempSync(join(tmpdir(), "vrbp-lint-"));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  const config = join(directory, "config.json");
  writeFileSync(config, JSON.stringify({
    plugins: [],
    categories: { correctness: "off" },
    jsPlugins: [{ name: "vrbp", specifier: pluginPath }],
    rules: { "vrbp/prefer-functional-state-update": "error" },
  }));

  const cases = [
    ["arithmetic", "setCount(count + 1)", 1],
    ["spread", "setCount([...count, next])", 1],
    ["object-spread", "setCount({ ...count, name: next })", 1],
    ["filter", "setCount(count.filter(item => item.id !== id))", 1],
    ["nested-callback", "setTimeout(() => setCount(count + 1), 100)", 1],
    ["logical", "setCount(!count)", 1],
    ["type-assertion", "setCount((count as number) + 1)", 1],
    ["updater", "setCount(previous => previous + 1)", 0],
    ["function-updater", "setCount(function(previous) { return previous + 1 })", 0],
    ["literal", "setCount(0)", 0],
    ["argument", "setCount(next)", 0],
    ["other-state", "const [other] = useState(0); setCount(other + 1)", 0],
    ["no-op", "setCount(count)", 0],
    ["shadowed-state", "[1].forEach(count => setCount(count + 1))", 0],
    ["shadowed-setter", "function run(setCount) { setCount(count + 1) }", 0],
    ["property-name", "setCount(object.count)", 0],
    ["literal-key", "setCount({ count: next })", 0],
    ["computed-key", "setCount({ [count]: next })", 1],
    ["reassigned-setter", "setCount = replacement; setCount(count + 1)", 0],
    ["reassigned-state", "count = next; setCount(count + 1)", 0],
  ].map(([name, body, expected]) => [name,
    `import { useState } from "react"; function Component(next) { let [count, setCount] = useState(0); ${body}; return null; }`, expected]);

  cases.push(
    ["import-alias", 'import {useState as state} from "react"; function C(){const [n, put]=state(0);put(n+1)}', 1],
    ["namespace", 'import * as R from "react"; function C(){const [n, put]=R.useState(0);put(n+1)}', 1],
    ["default-import", 'import R from "react"; function C(){const [n, put]=R.useState(0);put(n+1)}', 1],
    ["computed-hook", 'import R from "react"; function C(){const [n, put]=R["useState"](0);put(n+1)}', 1],
    ["custom-hook", 'import {useState} from "other"; function C(){const [n, put]=useState(0);put(n+1)}', 0],
    ["local-hook", 'function useState(){return [0,console.log]}; function C(){const [n, put]=useState();put(n+1)}', 0],
    ["shadowed-hook", 'import {useState} from "react"; function C(useState){const [n, put]=useState(0);put(n+1)}', 0],
    ["shadowed-namespace", 'import R from "react"; function C(R){const [n, put]=R.useState(0);put(n+1)}', 0],
    ["two-states", 'import {useState} from "react"; function C(){const [a,sa]=useState(0);const [b,sb]=useState(0);sa(a+1);sb(b+1)}', 2],
  );

  const files = cases.map(([name, code]) => {
    const path = join(directory, `${name}.tsx`);
    writeFileSync(path, code);
    return path;
  });
  const diagnostics = lint(config, files);
  for (const [name, , expected] of cases) {
    const actual = diagnostics.filter((item) => item.filename.endsWith(`/${name}.tsx`));
    assert.equal(actual.length, expected, `${name}: ${JSON.stringify(actual)}`);
    assert.ok(actual.every((item) => item.code === "vrbp(prefer-functional-state-update)"));
    assert.ok(actual.every((item) => !item.fix), "Moving work into an updater must not be an automatic fix");
  }
});

function checkLocalRule(t, rule, cases) {
  const directory = mkdtempSync(join(tmpdir(), "vrbp-local-"));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  const config = join(directory, "config.json");
  writeFileSync(config, JSON.stringify({
    plugins: [], categories: { correctness: "off" },
    jsPlugins: [{ name: "vrbp", specifier: pluginPath }],
    rules: { [`vrbp/${rule}`]: "error" },
  }));
  const files = cases.map(([name, code]) => {
    const path = join(directory, `${name}.tsx`);
    writeFileSync(path, code);
    return path;
  });
  const diagnostics = lint(config, files);
  for (const [name, , expected] of cases) {
    const actual = diagnostics.filter((item) => item.filename.endsWith(`/${name}.tsx`));
    assert.equal(actual.length, expected, `${rule}/${name}: ${JSON.stringify(actual)}`);
    assert.ok(actual.every((item) => item.code === `vrbp(${rule})` && !item.fix));
  }
}

test("render RegExp checks preserve memo, event, utility and shadowing boundaries", (t) => {
  checkLocalRule(t, "no-render-regexp", [
    ["render", 'function Highlighter({text,query}){const re=new RegExp(query,"i");return <p>{text.split(re)}</p>}', 1],
    ["arrow", 'const Highlighter=({text,query})=>{const re=new RegExp(query,"i");return <p>{text.split(re)}</p>}', 1],
    ["stateful", 'function Highlighter({text,query}){const re=new RegExp(query,"gi");return <p>{text.split(re)}</p>}', 1],
    ["module", 'const re=new RegExp("foo","i");function Highlighter({text}){return <p>{text.split(re)}</p>}', 0],
    ["memo", 'import {useMemo} from "react";function Highlighter({text,query}){const re=useMemo(()=>new RegExp(query,"i"),[query]);return <p>{text.split(re)}</p>}', 0],
    ["event", 'function Highlighter({query}){const onClick=()=>new RegExp(query,"i").test(input);return <button onClick={onClick}/>}', 0],
    ["effect", 'import {useEffect} from "react";function Highlighter({query}){useEffect(()=>{test(new RegExp(query,"i"))},[query]);return <p/>}', 0],
    ["utility", 'function parse(query){return new RegExp(query,"i")}', 0],
    ["non-jsx", 'function Parser(query){return new RegExp(query,"i")}', 0],
    ["shadowed", 'function Highlighter({RegExp}){const re=new RegExp(query);return <p>{re}</p>}', 0],
  ]);
});

test("storage warnings distinguish areas, scopes and invalidation barriers", (t) => {
  checkLocalRule(t, "no-repeated-storage-read", [
    ["repeated", 'function read(){const a=localStorage.getItem("theme");const b=localStorage.getItem("theme");return [a,b]}', 1],
    ["third", 'function read(){const a=localStorage.getItem("theme");const b=localStorage.getItem("theme");const c=localStorage.getItem("theme");return [a,b,c]}', 2],
    ["areas", 'function read(){const a=localStorage.getItem("theme");const b=sessionStorage.getItem("theme");return [a,b]}', 0],
    ["keys", 'function read(){const a=localStorage.getItem("theme");const b=localStorage.getItem("locale");return [a,b]}', 0],
    ["write", 'function read(){const a=localStorage.getItem("theme");localStorage.setItem("theme","dark");const b=localStorage.getItem("theme");return [a,b]}', 0],
    ["clear", 'function read(){const a=localStorage.getItem("theme");localStorage.clear();const b=localStorage.getItem("theme");return [a,b]}', 0],
    ["unknown-call", 'function read(){const a=localStorage.getItem("theme");updatePreferences();const b=localStorage.getItem("theme");return [a,b]}', 0],
    ["unknown-initializer", 'function read(){const a=localStorage.getItem("theme");const result=updatePreferences();const b=localStorage.getItem("theme");return [a,result,b]}', 0],
    ["branch", 'function read(){const a=localStorage.getItem("theme");if(update)updatePreferences();const b=localStorage.getItem("theme");return [a,b]}', 0],
    ["shadowed", 'function read(localStorage){const a=localStorage.getItem("theme");const b=localStorage.getItem("theme");return [a,b]}', 0],
    ["window", 'function read(){const a=window.localStorage.getItem("theme");const b=localStorage.getItem("theme");return [a,b]}', 1],
    ["computed", 'function read(){const a=localStorage["getItem"]("theme");const b=localStorage.getItem("theme");return [a,b]}', 1],
    ["await", 'async function read(){const a=localStorage.getItem("theme");const b=await load();const c=localStorage.getItem("theme");return [a,b,c]}', 0],
    ["dynamic-key", 'function read(key){const a=localStorage.getItem(key);const b=localStorage.getItem(key);return [a,b]}', 0],
    ["functions", 'function readA(){const a=localStorage.getItem("theme");return a}function readB(){const b=localStorage.getItem("theme");return b}', 0],
  ]);
});
