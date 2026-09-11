---
name: spark-bytecode-verifier
description: Fresh-verify Spark address-registry deployed bytecode with local Forge. Use when the user asks to verify Spark registry bytecode, verify source-tagged addresses, run forge verify-bytecode for a registry target, verify addresses changed in a registry PR, or verify all addresses for one chain. Runs a fresh forge verify-bytecode against the declared upstream source in a disposable checkout, classifies creation and runtime separately, and writes a sanitized Markdown report. Do NOT use for ordinary Solidity builds or unrelated contract verification.
---

# Spark bytecode verifier

Fresh, local bytecode verification of source-tagged Spark address-registry targets.

The default outcome of this skill is a **new** `forge verify-bytecode` run against the
declared upstream source. Prior GitHub reviews and source comments are context, never a
substitute for a fresh run.

## When to invoke

Activate when the user asks to:

- Verify Spark registry bytecode
- Verify source-tagged addresses
- Run `forge verify-bytecode` for a registry target
- Verify the addresses changed in a registry PR
- Verify all addresses for one chain

Do **not** activate for ordinary Solidity builds, `forge verify-contract` explorer
submissions, or verification of contracts unrelated to the Spark registry.

## Do not begin by declaring prior evidence a result

Do not open a run by searching for prior verification comments and reporting them as
verification. Prior evidence is consulted only to recover context (linked-library
addresses, build settings, constructor shapes) or to corroborate a fresh result. See
`references/forge-semantics.md` and the evidence policy below.

## Required team setup

The user must have, and nothing more:

- Claude Code
- Git
- Forge and Cast (Foundry), **pinned to stable v1.7.1, commit
  `4072e48705af9d93e3c0f6e29e93b5e9a40caed8`** (`foundryup -i 1.7.1`)
- Chain RPC URLs and explorer API keys provided either via `.claude/settings.local.json` or as
  shell exports available before Claude Code starts (one-time setup below)

**Foundry pin (hard stop).** Preflight must confirm that both `forge --version` and
`cast --version` report `Commit SHA: 4072e48705af9d93e3c0f6e29e93b5e9a40caed8`. If either
differs, stop — matching semantics are version-sensitive and this campaign is pinned to that
commit.

**Quickstart: no `.claude/settings.local.json` yet.** If that file doesn't exist when this
skill is invoked, don't explain the whole credential model — just do this, fast:

1. Create `.claude/settings.local.json` with an `env` object containing every variable name
   this run needs (empty strings), per `references/chains.md`.
2. Confirm it's gitignored (it already is in this repo).
3. Ask the user, in one short message, to paste in the RPC URLs / API keys for the chains
   they want to test — nothing more.
4. Stop and wait for them to paste values.
5. Tell the user to **restart Claude Code** (exit and relaunch) — tool shells only read
   `.claude/settings.local.json` env values at launch, so edits made mid-session are invisible
   to `forge`/`cast`/`cast chain-id` until then. Then stop and wait again; do not attempt to
   verify the variables loaded until they confirm the restart.

Never fill in a value yourself, never print one back, never proceed on empty/placeholder
strings.

**One-time credential setup (required before first use).** Choose either of these supported
sources for RPC URLs and explorer keys:

1. Create `.claude/settings.local.json` in the repo root (personal, gitignored — never commit
   it):

```json
{ "env": { "MAINNET_RPC_URL": "https://…", "ETHERSCAN_API_KEY": "…", "BASE_RPC_URL": "…" } }
```

2. Export the same variables from `~/.zshenv`, or from a personal file sourced by `~/.zshenv`,
   before launching Claude Code. Claude Code's Bash tool uses non-interactive zsh, which reads
   `~/.zshenv` but not `~/.zshrc`; exports configured only in `~/.zshrc` are not a supported
   credential source for this skill.

Include every chain you intend to verify (`references/chains.md` lists the variable names).
Restart Claude Code after creating or changing either credential source so the session and its
tool shells pick up the values.

Never source a project- or PR-controlled `.env` file **from inside a session**. The skill does
not hardcode variable names as unchangeable literals and does not implement its own
credentials-file parser; it reads whatever the environment provides, checks **presence only**,
confirms chain identity by RPC (never by variable name), and never prints a value.
`references/chains.md` lists the team's variable names. If a needed variable is absent, stop
and explain both supported setup choices above: add it to `.claude/settings.local.json`, or
export it from `~/.zshenv` (or a personal file sourced there), then restart the session. Never
suggest `~/.zshrc`, invent a value, or substitute a public/random RPC. There is no Python
dependency, and this skill adds no CI to the repository.

The skill packages three small helper scripts under `scripts/` (`run-dir.zsh`, `capture.zsh`,
`hex.zsh`) that implement the security-sensitive procedures — marked temporary workspace,
capture/sanitize/read, guarded cleanup, and validated hex/JSON extraction. They need only stock
macOS `zsh` and Perl; nothing is installed. Invoke them as documented in
`references/workflow.md` — never retype their logic inline, and never modify them during a run.

## Core principles

1. **Fresh verification first.** Compile the declared candidate and run Forge against the
   deployment. Exit status alone never means success.
2. **Fail closed.** Unknown or ambiguous output, missing source, wrong chain, missing
   libraries, replay errors, or creation mismatch before an independent runtime check are
   all non-success. See `references/troubleshooting.md`.
3. **Chain-qualified identity.** Every target is `chain ID + address + registry constant`.
   The same literal address on two chains is two separate jobs — never deduplicate by
   address.
4. **Temporary local work only.** Clone upstream into a unique OS-temp run directory, never
   into the user's existing checkouts. Remove it at the end. See
   `references/workflow.md` section "Temporary workspace".
5. **Secrets stay local.** Check only that variables are *set*; never print their values and
    never embed a resolved RPC, verifier URL, or key in a report. Every credential-using command
    must run through the packaged `scripts/capture.zsh`, which captures stdout/stderr, sanitizes
    the capture, and only then makes it readable. Never enable shell tracing. If redaction
    cannot be guaranteed, stop before writing the report.

## High-level procedure

Follow `references/workflow.md` for the full decision tree and command shapes. In outline:

1. Identify the registry ref and the requested scope (one target / one chain / changed
   targets / all source-tagged targets).
2. Read source comments on that ref and compute target totals fresh — never reuse a historical
   count from earlier reviews or reports.
3. Validate required environment variables are **present** (not their values) with the
   macOS-zsh procedure in `references/workflow.md`.
4. Create a unique temporary run directory with `scripts/run-dir.zsh create`, referenced from
    then on by its printed **absolute literal path** (shell variables do not persist between
    commands here).
5. Confirm the RPC `eth_chainId` equals the intended numeric chain ID through the common
   capture/sanitize/read procedure (`scripts/capture.zsh`).
6. Group targets by `repository + commit + build context`.
7. Validate all registry-derived values and the allowed repository owner, then clone/check out
   each source group **once** at its full resolved commit: clone **without** recursing
   submodules, detach to the exact ref, then init that ref's submodules and assert
   `git status --short` is empty before any `forge` command (`verify-bytecode` compiles the
   whole project; a contaminated checkout produces false blockers and weaker matches — see
   `references/workflow.md` §4).
8. Record exact `forge --version` / `cast --version` (commit-pinned) and resolved build
   settings (solc, optimizer, runs, EVM, via-IR, metadata mode, remappings, dependency
   commits). **Run every `forge` command from inside the checkout** (`cd` or `--root`), never
   from `spark-address-registry`.
9. Apply the required build context, EVM override, constructor args, and linked-library
   configuration for the target (see `references/special-cases.md`).
10. Verify linked libraries **before** their linked parent; configure deployed library
    addresses in the checkout, then verify the parent. Each library gets its own evidence
    subrecord.
11. For constructor-bearing targets, recover and decode the actual constructor arguments
    independently (see `references/workflow.md` section "Constructor recovery and durable
    evidence"); do not claim placeholder
    values were verified.
12. Run the authoritative fresh `forge verify-bytecode` with those recovered arguments and
    per-chain verifier flags through the same capture/sanitize/read procedure used for `cast`
    and explorer calls — **without** an explicit `--chain` for named chains (a pin bug breaks
    runtime replay; chain identity is guaranteed by the preflight `cast chain-id` check — see
    `references/workflow.md` section "Authoritative Forge run"). Label any earlier Forge run
    diagnostic only.
13. Record creation and runtime status **separately**, with per-phase "independently checked"
    flags.
14. Fail closed on unknown output or mismatch.
15. Write a sanitized Markdown report (see `references/report-template.md`); for multi-batch
    runs, also write one aggregate reconciliation report.
16. Remove the temporary source checkouts with `scripts/run-dir.zsh cleanup` (marker-guarded
    delete + existence check) and report the cleanup outcome.

## Evidence policy

Label every piece of evidence in the report, not just the target as a whole, as exactly one of:

- **Fresh run output** — produced by this run.
- **Prior/corroborating evidence** — an accessible earlier result used only to corroborate
  or recover context.
- **Documented but untested** — stated in references/plan, not exercised this run.
- **Inferred** — reasoned, not observed.

Prior evidence must match the current `chain ID + address + constant` tuple to be cited at
all.

## Result classification

Record creation and runtime as separate states, each one of:
`Full`, `Partial`, `Mismatch`, `Error`, `Skipped`, `Not independently checked`.

Then assign one final class (nine total):
`Exact build verified`, `Raw exact bytes, no bytecode hash`, `Non-CBOR bytecode verified`,
`Creation verified, runtime incomplete`, `Runtime-only verified`, `Version-offset logic
evidence`, `Mixed result`, `Candidate rejected`, `Investigation required`.

- **Raw exact bytes, no bytecode hash** — Forge reports partial, but local and on-chain raw
  creation and runtime bytes are independently byte-equal and the build used
  `bytecode_hash = "none"`. Exact bytes matched; do not downgrade to plain "non-CBOR."
- **Version-offset logic evidence** — the target matched at a *different* ref than tagged,
  plus a direct ref-to-ref equivalence proof that the non-metadata bytecode is unchanged
  across every intervening ref (see `references/special-cases.md`). Weaker than an exact
  tagged-ref match.

Never collapse an outcome to an unqualified `verified`.

## Reporting

Write the full report to `agent-notes/responses/<run-name>-response.md`. When a run is split
into batches (e.g. per chain), also write one **aggregate reconciliation report** at
`agent-notes/responses/<campaign>-summary.md` that ties per-target results back to the
registry ref and proves coverage totals. In chat return only: the report path(s), a short
summary (≤10 lines), and any blocker. Do not paste the full report into chat.

## Cleanup

Before finishing: remove the temporary run directory, confirm no source clone remains, and
confirm no secret appears in retained evidence. Preserve the report plus only explicitly named
sanitized evidence artifacts outside the run directory that the report links. If cleanup fails,
say so explicitly in the report and in chat.

## Campaign phase codes

References like "V2-2" in these docs are validation-campaign milestones, recorded so you know
what has been observed live versus what remains hypothesis: V2-1/V2-1b = skill drafting and
remediation; V2-2 = Ethereum rehearsal (done 2026-07-21); V2-3 = method rehearsals across
Ethereum/Base/World Chain (done 2026-07-21); V2-4 = remaining-chain rehearsal (pending —
notably XLayer and Robinhood); V2-5 = full registry campaign (pending). A note marked
"V2-4 rehearsal item" means: documented but not yet observed live — treat accordingly.

## References

- `references/workflow.md` — decision tree, command shapes, batching, escalation.
- `references/forge-semantics.md` — exact matching semantics and evidence ceilings.
- `references/chains.md` — per-chain env vars, verifier, capabilities (Ethereum/Base/World
  Chain observed live; other chains documented, pending V2-4).
- `references/special-cases.md` — libraries, build-context exceptions, EVM overrides, known corrections.
- `references/report-template.md` — required report fields.
- `references/troubleshooting.md` — safe actions for each failure mode.
