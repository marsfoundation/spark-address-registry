# Troubleshooting

Deterministic, fail-closed responses. When in doubt, stop and record a blocker — never report
success from an ambiguous state.

## Missing RPC / explorer key

Expected variable unset → **stop** for that chain/target. The names in `chains.md` are the
team's convention, not hardcoded — ask the user which variable holds that chain's RPC/key (or
to set it). Never invent a value, never substitute a public/random RPC, never build a
credentials-file parser, and never source a project- or PR-controlled `.env` from inside the
session. Use the validated macOS-zsh `check_present` procedure in `workflow.md`; it prints only
`<name> present` or `<name> MISSING`. Point the user at the one-time credential setup in
`SKILL.md` ("Required team setup"): add the variable to `.claude/settings.local.json`, or export
it from `~/.zshenv` (or a personal file sourced there), then restart Claude Code. Do not suggest
`~/.zshrc`; the Bash tool's non-interactive zsh does not read it.

## Wrong chain ID

Sanitized `cast chain-id` output differs from the intended numeric ID → **hard stop**. The RPC
points at the wrong network; do not verify. Fix the variable or the intended chain, re-confirm,
then proceed. Run `cast chain-id` only through `workflow.md` section 7.

## No code at target

Sanitized `cast code` output is `0x` → wrong address, wrong chain,
or not yet deployed at the queried block. Stop; re-check the target tuple. Do not proceed to
Forge. Current and historical `cast code` calls use `workflow.md` section 7; never read raw output.

## Explorer auth / creation-lookup failure

The explorer is mandatory at the pinned commit: any failure of the key, `getsourcecode`, or
`getcontractcreation` is fatal for that target — the only exception is the two recognized
predeploy response shapes (`forge-semantics.md` section "Explorer is mandatory at the pin — no runtime-only fallback").
XLayer's OKLink read-action compatibility and Robinhood's deployed Blockscout instance remain
documented but untested; use `workflow.md` section 7b during V2-4. Never silently downgrade to
runtime-only or claim creation was checked.

## Archive / trace unavailable

Runtime replay needs historical state / `trace_transaction` the provider does not serve →
runtime is **incomplete**, not mismatch. Try another archive provider to distinguish a
provider limit from local replay behavior. Fallback input is historical `cast code`, captured and
sanitized with `workflow.md` section 7, but raw
`cast code` vs artifact `deployedBytecode` is not automatically sufficient (self-address guards,
immutables). Classify `Creation verified, runtime incomplete` or runtime `Not independently
checked`.

## Project compile fails on a non-target dependency

`verify-bytecode` compiles the whole project, so an import failure in a lib the target never
touches blocks verification. **Check checkout contamination first** — the only observed case
(2026-07-21) was leftover default-branch submodules shadowing a remapping after detaching to an
older ref; `git clean -ffd` + the §4 empty-`status` assertion fixed it with no other change.
Only if the checkout is pristine and the conflict is genuinely inside the target ref's own
tree: add minimal `skip` globs to the checkout's `foundry.toml` covering only the failing
**non-target** paths, prove the target's import closure doesn't reach them, and record the
globs + compile error + closure check in the report. Never fix it by changing remappings,
dependency commits, or sources. If the conflict touches the target's own closure →
`Investigation required`.

## `Error: Contract name mismatch`

The candidate contract name differs from the name the explorer recorded for the verified
contract; Forge bails **before any bytecode comparison** (`forge-semantics.md` section
"Contract-name pre-check: `Error: Contract name mismatch`"). For a deliberately wrong candidate
this is `Candidate rejected`, with the name pre-check noted in its limitations (no bytes were
compared). For the registry's tagged contract it means registry and explorer disagree —
`Investigation required`; do not switch the contract name to make the run pass.

## Unlinked bytecode

Forge errors that libraries are unlinked → you have not configured all deployed library
addresses. Verify each library first, add every address to `foundry.toml`, then retry the
parent (`special-cases.md` section "MainnetController and its eight libraries"). Do not guess a library address; wrong addresses
are not masked.

## Build mismatch (hard)

`did not match` / `Mismatch` → do **not** stop at a vague mismatch. Recheck: exact ref, solc,
optimizer/runs, EVM version, metadata mode, source paths, and the **deployment** build context.
Then test plausible neighbor refs under identical settings (`special-cases.md` section "World
Chain `cd15a90` vs `cbd09d8` — resolved (tag corrected 2026-07-21)"). Persistent mismatch →
`Candidate rejected`; retain the full rejected output;
escalate if provenance is expected to match.

## Partial match

Partial = non-CBOR bytes equal under the pinned Forge matcher (`forge-semantics.md`). Record
local/deployed byte lengths and check build settings. Independent trailer validation/comparison
requires a separately approved CBOR decoder; stock macOS cannot safely provide it. Without one,
record the independent normalized proof as unavailable rather than stripping by length. Classify
`Non-CBOR bytecode verified` from fresh pinned Forge output (or use the raw-exact
`bytecode_hash = "none"` case only after raw equality proof). Never promote it to `Exact build
verified`.

## Runtime replay error

`gas floor (...) exceeds the gas limit (...)` or similar → local replay artifact, runtime
**incomplete** (`forge-semantics.md` section "EIP-7623-style replay errors are runtime-incomplete"). Preserve the full sanitized error, tx hash, block, Forge
version, provider. Optionally retry with the historically appropriate hardfork behavior or
another archive provider. Classify `Creation verified, runtime incomplete` — never a runtime
match.

## Custom factory

At the campaign pin there is **no** factory runtime-skip warning: Forge extracts the target's
initcode from `trace_transaction` and then runs both creation comparison and runtime replay. A
factory target therefore requires a trace-capable RPC; when no matching `CREATE` trace is found,
Forge fails with `Could not extract the creation code` — treat that as an RPC/provider
capability blocker (try an archive/trace provider), not a mismatch. Record the factory path in
evidence. Any missing-runtime output shape is `Investigation required`.

## Foundry output change

Output lacks an expected status line without the pinned predeploy warning documented in
`forge-semantics.md`, or a new/unrecognized shape appears → **unknown output, fail closed**.
Do not classify from exit status. Record only the sanitized output verbatim and escalate. Also
re-confirm the Foundry pin: both `forge --version` and
`cast --version` must report commit `4072e48705af9d93e3c0f6e29e93b5e9a40caed8`; a different
commit is itself a stop condition, since matching semantics are version-sensitive.

## Cleanup failure

The guarded delete (`workflow.md` section 10) refuses/fails, or the post-delete existence check still finds
the directory → **report explicitly** in the report and in chat; do not mark the run clean.
Delete only a non-symlink absolute literal path whose basename matches `spark-verify.*` and which
contains the verifier-owned marker. This supports the real macOS `/var/folders/.../T/` parent.
Also re-scan the report for any secret before finishing; if a secret may have leaked, stop and
flag it (rotate, not just delete).
