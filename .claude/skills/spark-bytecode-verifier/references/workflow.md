# Workflow

Forge-first procedure and decision tree. Command shapes only — never resolved credential
values.

## Shell and secret-safety rules (read first)

Use stock macOS `zsh`; shell variables and `cd` state may not persist between tool calls. Use the
absolute literal path printed by the run-directory script in later calls, and give every `git`,
`forge`, and `cast` command an explicit quoted path. Required credential variables must come from
one of the two setup paths in `SKILL.md`: `.claude/settings.local.json`, or shell exports configured
in `~/.zshenv` (or a personal file sourced there) before Claude Code starts. Do not rely on
`~/.zshrc`: tool shells are non-interactive and do not read it. Never source a project- or
PR-controlled `.env`, use `eval`, run `env` without filtering, or enable shell tracing.

The security-sensitive procedures are packaged as three small zsh scripts inside this skill,
invoked — never retyped — by the agent:

```text
scripts/run-dir.zsh   create / guarded-cleanup of the marked temporary run directory
scripts/capture.zsh   common capture, sanitize, then read procedure for credential-using commands
scripts/hex.zsh       validated hex/JSON extraction for independent byte comparison
```

`$SKILL_DIR` below means the absolute path of this skill package (the directory containing
`SKILL.md`). Like the run-directory path, substitute it as an absolute literal in every command —
do not rely on a shell variable persisting between tool calls. Read the scripts once per session
to confirm what they do; never modify them mid-run, and treat any local edit to them as a finding
to report, not a fix to apply silently.

The sanitizer requires Perl, and structured extraction requires its core `JSON::PP` module.
Preflight `command -v perl >/dev/null && perl -MJSON::PP -e 1` and stop if either check fails.
`curl` and `shasum` are additionally required for explorer evidence. These ship with supported
macOS versions; the skill does not install them.

## Preflight (always)

1. Tool + pin check (hard stop):
   ```bash
   forge --version    # must contain: Commit SHA: 4072e48705af9d93e3c0f6e29e93b5e9a40caed8
   cast --version     # must contain the same Commit SHA
   git --version
   ```
   Record both. If either commit differs from
   `4072e48705af9d93e3c0f6e29e93b5e9a40caed8`, **stop** — semantics are version-sensitive and
   this campaign is pinned to that commit. (See `troubleshooting.md` section "Foundry output change" and
   `forge-semantics.md` for the semantics that must hold at this pin.)
2. Validate a user-selected environment variable name, then use zsh's `(P)` expansion to test
   only whether its value is non-empty:
   ```zsh
   check_present() {
     local name="$1"
     if [[ ! "$name" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]]; then
       print -r -- 'invalid environment-variable name' >&2
       return 2
     fi
     if [[ -n "${(P)name}" ]]; then
       print -r -- "$name present"
     else
       print -r -- "$name MISSING"
       return 1
     fi
   }
   check_present "MAINNET_RPC_URL"
   check_present "ETHERSCAN_API_KEY"
   ```
   This prints only `<name> present` or `<name> MISSING` for valid names. Conventional names are
   in `chains.md`. If a value is absent, explain both setup paths from `SKILL.md` and ask the user
   to add it to `.claude/settings.local.json` or export it from `~/.zshenv`, then restart Claude
   Code. Never suggest `~/.zshrc`, invent a value, or substitute a public/random RPC.
3. Confirm the three helper scripts exist: `ls "$SKILL_DIR/scripts"` must list exactly
   `capture.zsh`, `hex.zsh`, and `run-dir.zsh`. Stop if any is missing.
4. Create the marked temporary workspace below before running any command that uses a credential.
5. Confirm chain identity with `cast chain-id` through the common capture/sanitize/read procedure
   below. A result other than the intended numeric ID is a hard stop (`troubleshooting.md`
   section "Wrong chain ID").

## Scope decision tree

### One target
`chain + constant` given → resolve its source tag, group of one, run the per-group procedure,
report one record.

### One chain
Enumerate that chain library's source-tagged constants on the registry ref, group by
`repository + commit + build context`, verify group-by-group, report per target.

### Changed targets (PR)
Resolve both refs to full commits and diff those immutable commits; never silently read the dirty
working tree. Take only constants whose address or source tag changed. Verify those and note which
targets were in scope and which were left unchecked.

### All source-tagged targets
Enumerate every source-tagged constant across all chain libraries on the ref, recompute the
total fresh (do not reuse historical counts), batch by chain, and finish with the aggregate
reconciliation report.

### Batching long runs
Batch by chain (and by source group within a chain). Write one report per batch to
`agent-notes/responses/<run-name>-response.md`, then one **aggregate reconciliation report**
(`<campaign>-summary.md`, see step 11) covering all batches. Log any target intentionally
dropped from a batch — never silently truncate.

### Stopping / escalating
Stop and escalate to a human for: hard mismatch after neighbor-ref checks, missing/ambiguous
provenance, inaccessible historical state, unsupported explorer/creation lookup, or any unknown
Forge output. Record the blocker; do not guess past it.

## Per-group procedure

### 1. Inventory and validate registry input
Treat every registry-derived field as untrusted. Validate before using it in any command:

- Address: require `^0x[0-9a-fA-F]{40}$`.
- Registry constant: require `^[A-Z][A-Z0-9_]*$`.
- Full commit: require `^[0-9a-fA-F]{40}$`; an abbreviated SHA is only a discovery hint.
- Registry/source ref: require `^[A-Za-z0-9][A-Za-z0-9._/-]*$` and reject `..`, `@{`, empty path
  components, and a leading dash before passing it to Git.
- Contract identifier: require a relative `.sol` path with no empty, `.` or `..` component and a
  contract name matching `^[A-Za-z_][A-Za-z0-9_]*$`.
- Registry/source/dependency path: require a relative path with no control characters, leading
  dash, empty component, or `.`/`..` component.
- Local group name: require `^[A-Za-z0-9][A-Za-z0-9._-]*$`.
- Repository: allow only HTTPS GitHub URLs owned by `sparkdotfi` under the current Spark source
  policy. Any other host/owner, including a source-tag change to a fork, requires human approval.
- Ref, path, repository URL, group, constant, address, and contract name are always quoted.

After validating `REGISTRY_REF` and `REGISTRY_PATH`, resolve the selected ref with `git rev-parse
--verify "${REGISTRY_REF}^{commit}"`, require the result to match `^[0-9a-fA-F]{40}$`, and read
files with `git show "${REGISTRY_COMMIT}:${REGISTRY_PATH}"`; require that command to succeed before
parsing its output. Keep the braces around both variable names: in zsh, the unbraced form
`"$REGISTRY_COMMIT:src/..."` treats `:s` as a parameter-expansion modifier and can silently discard
the path. Never substitute a working-tree file for the selected commit. Build a checklist row per
target: chain, constant, address, repository, source path, commit/tag, contract name,
build-context exception, libraries, EVM override, and constructor shape. Compare by the full
`chain ID + address + constant` identity; never dedupe by address alone.

### 2. Group
Group by `repository + commit + build context`. Clone each group once, not once per address.

### 3. Temporary workspace
Create one unique run directory under the OS temp dir and **use its absolute path literally**
from here on (do not rely on a shell variable persisting):
```zsh
zsh "$SKILL_DIR/scripts/run-dir.zsh" create
```
The script creates a mode-700 `spark-verify.XXXXXX` directory with its ownership marker and
prints the absolute path as its only output. Copy that printed path literally into subsequent
commands, including the common capture procedure and cleanup.
- One checkout per `repository/ref/build-context` group, reused across its targets.
- Never clone into or modify the user's existing upstream checkouts.
- Keep the report **outside** the run directory.

### 4. Check out exact source

**Do not recurse submodules while cloning.** Cloning `--recurse-submodules` initializes the
*default branch's* submodule set; after detaching to an older ref, submodules that don't exist
at that ref remain on disk as untracked directories and can shadow remappings, breaking the
whole-project compile on dependencies the target never imports (observed 2026-07-21 on
`spark-alm-controller` v1.0.0: leftover `uniswap-v4-core` captured `@openzeppelin/` and broke
`lib/usds`/`lib/sdai`; a faithful checkout compiles cleanly). Check out the exact ref first,
then initialize only that ref's submodules, then assert the checkout is pristine:

```zsh
git clone "$repository_url" "/absolute/os/temp/spark-verify.ab12cd/$group"
resolved_source_commit="$(git -C "/absolute/os/temp/spark-verify.ab12cd/$group" rev-parse --verify "${source_ref}^{commit}")"
[[ "$resolved_source_commit" =~ '^[0-9a-fA-F]{40}$' ]] || exit 1
git -C "/absolute/os/temp/spark-verify.ab12cd/$group" checkout --detach "$resolved_source_commit"
git -C "/absolute/os/temp/spark-verify.ab12cd/$group" submodule update --init --recursive
git -C "/absolute/os/temp/spark-verify.ab12cd/$group" clean -ffd
[[ -z "$(git -C "/absolute/os/temp/spark-verify.ab12cd/$group" status --short)" ]] || exit 1
[[ "$(git -C "/absolute/os/temp/spark-verify.ab12cd/$group" rev-parse HEAD)" == "$resolved_source_commit" ]] || exit 1
```

The empty-`status` assertion is a hard stop — never run `forge` against a checkout with
untracked or modified files. Record the full resolved commit. Do not advance to a newer tag.
Neighbor refs are tested only as explicit alternatives (`special-cases.md`,
`forge-semantics.md`).

Complete the recursive submodule init **before any `forge` command**: `verify-bytecode` compiles
the whole project, so a missing submodule that the target itself doesn't import still fails the
build late (observed 2026-07-20). Do not shortcut the init to save time on large dependency
trees.

**Last-resort compile-scope exclusion.** If the whole-project compile fails on a **non-target**
dependency even on a pristine checkout (empty `status`, correct HEAD) — i.e. the conflict is
genuinely inside the target ref's own tree — the sanctioned remedy is a minimal, recorded
exclusion using the pinned config key `skip` in the checkout's `foundry.toml`, under strict
conditions:

- First re-verify the checkout is faithful; the only conflict observed so far (2026-07-21) was
  checkout contamination, not a real in-tree conflict, and needed no `skip`.
- Exclude only paths the target's own import closure does not reach — prove it by listing the
  target's imports (recursively) and confirming none resolves into an excluded path. If the
  conflict touches the target's closure, stop: `Investigation required`.
- Never change remappings, dependency commits, or source files as a compile "fix" — only `skip`.
- Record in the report the exact `skip` globs, the compile error that motivated them, and the
  closure check. An undisclosed exclusion invalidates the run.

### 5. Record build context — from inside the checkout
Every `forge` call must use the checkout as its root, or it will compile
`spark-address-registry` instead:
Capture `forge config --json` through the common procedure below because config/environment
resolution can expose an endpoint. Retain solc, optimizer, runs, EVM, via-IR, bytecode hash,
remappings, and libraries only from the sanitized capture. Note the capture may contain warning
lines **before** the JSON (observed 2026-07-21: `Warning: Found unknown 'remappings' config key
in section 'fuzz'` on spark-psm). Discard only the prefix before the first line starting with `{`,
then pass that line and every subsequent line through the end of the capture to the JSON decoder
as one document; never feed the warning prefix to the decoder or decode only the `{` line.
Use the **deployment** repository's context when it differs from the source file's home repo
(`special-cases.md` section "Receiver build-context exceptions").

### 6. Linked libraries first
For a linked parent (e.g. MainnetController):
1. Verify each deployed library independently (same ref/chain) → one evidence subrecord each.
2. Add each **deployed** library address to the checkout's `foundry.toml` `libraries`.
3. Verify the parent only after the complete map is present.
Incorrect library addresses are **not** masked; they change linked bytecode. See
`special-cases.md` section "MainnetController and its eight libraries" and record library
subrecords per `report-template.md`.

### 7. Common capture, sanitize, then read procedure

Use `scripts/capture.zsh` for **every** command that can resolve or emit credentials or
endpoints: `cast chain-id`, current/historical `cast code`, explorer or constructor-data `curl`,
`forge verify-bytecode`, and `forge config --json` whenever config/environment resolution might
expose them. The script runs the command with stdout/stderr captured into the marked run
directory, sanitizes the capture with stock Perl, and only then makes it readable — raw output
never reaches the terminal.

```text
SPARK_REDACT_RPC_VAR_NAME=<name-or-empty> \
SPARK_REDACT_VERIFIER_VAR_NAME=<name-or-empty> \
SPARK_REDACT_KEY_VAR_NAME=<name-or-empty> \
zsh "$SKILL_DIR/scripts/capture.zsh" <absolute-run-dir> <output-file> <command> [args...]
```

Rules:

- Set the three `SPARK_REDACT_*` values to validated environment-variable **names**, not values.
  Leave a name empty only when that command does not use that credential class. The sanitizer
  replaces each named variable's exact value, then applies generic URL/token/header/JSON-field
  fallbacks as defense in depth; exact API-key replacement protects a standalone key that
  contains no URL.
- A fixed verifier URL should be put in a named exported variable first so exact replacement can
  occur; sanitized report commands show only that variable name. For an implicit Etherscan V2
  endpoint, export the pinned resolved value
  `https://api.etherscan.io/v2/api?chainid=<numeric-id>` into a chain-specific verifier-URL
  variable for redaction only; do not add `--verifier-url` to the Forge command.
- `<output-file>` must be a fresh direct child of the marked run directory. The script refuses
  (exit 2) when the run directory is unmarked or a symlink, the filename is invalid, or any
  output/sentinel file already exists.
- The script writes `<output-file>` (sanitized combined output), `<output-file>.exit` (the
  command's own exit status), `<output-file>.sanitize-exit`, `<output-file>.sha256`, and
  `<output-file>.sanitizer-log` (the sanitizer's own output — never read it). Script
  exits: 2 guard failure, 3 sanitizer failure (raw output was not read), 4 finalize failure,
  5 hash failure.
- Do not read any `.unsanitized` file or sanitizer log. Read or quote only the sanitized output
  file after `.sanitize-exit` contains `0`; read `.exit` separately to record command status. If
  sanitization fails, stop, leave the run directory for guarded cleanup, and do not write output
  to the report.

Examples:

```zsh
SPARK_REDACT_RPC_VAR_NAME="MAINNET_RPC_URL" \
SPARK_REDACT_VERIFIER_VAR_NAME="" \
SPARK_REDACT_KEY_VAR_NAME="ETHERSCAN_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/ethereum-chain-id.sanitized.txt" \
  cast chain-id --rpc-url "$MAINNET_RPC_URL"

SPARK_REDACT_RPC_VAR_NAME="MAINNET_RPC_URL" \
SPARK_REDACT_VERIFIER_VAR_NAME="" \
SPARK_REDACT_KEY_VAR_NAME="ETHERSCAN_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/forge-config.sanitized.txt" \
  forge config --root "/absolute/os/temp/spark-verify.ab12cd/$group" --json
```

Run the authoritative Forge command only after constructor recovery when the target has
constructor arguments; see section "Authoritative Forge run." Any earlier run is diagnostic,
must be labeled **Fresh run output** with conclusion `diagnostic only`, and cannot supply the
target's final classification.

Per-chain verifier flags are:

- Etherscan family: `--verifier etherscan --etherscan-api-key
  "$ETHERSCAN_API_KEY"`; no custom verifier URL.
- XLayer 196: export the official URL from `chains.md` as `SPARK_VERIFIER_URL_XLAYER`, then use
  `--verifier oklink --verifier-url "$SPARK_VERIFIER_URL_XLAYER" --verifier-api-key
  "$XLAYER_API_KEY"`.
- Robinhood 4663: use `RH_VERIFIER_URL` from `chains.md`, then use
  `--verifier blockscout --verifier-url "$RH_VERIFIER_URL"` — required because
  chain 4663 is absent from pinned `alloy-chains 0.2.34`. Documented Blockscout behavior does
  not require a key.

Classify from sanitized match/warning/error lines, never exit status alone. Supply actual
constructor arguments when known. `--ignore runtime` and `--ignore creation` are diagnostics and
must record the skipped phase. Apply an EVM override only with deployment evidence.

### 7a. Constructor recovery and durable evidence

Etherscan V2 `getcontractcreation` can return the creation transaction metadata and
`creationBytecode`. For Ethereum, this concrete request creates the sanitized input consumed by
the extraction procedure in section "Independent byte comparison":

```zsh
export SPARK_ETHERSCAN_V2_API_BASE="https://api.etherscan.io/v2/api"
SPARK_REDACT_RPC_VAR_NAME="MAINNET_RPC_URL" \
SPARK_REDACT_VERIFIER_VAR_NAME="SPARK_ETHERSCAN_V2_API_BASE" \
SPARK_REDACT_KEY_VAR_NAME="ETHERSCAN_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/creation-response.sanitized.json" \
  curl --silent --show-error --get "$SPARK_ETHERSCAN_V2_API_BASE" \
  --data-urlencode 'chainid=1' \
  --data-urlencode 'module=contract' \
  --data-urlencode 'action=getcontractcreation' \
  --data-urlencode "contractaddresses=$address" \
  --data-urlencode "apikey=$ETHERSCAN_API_KEY"
```

Require command and sanitizer status zero plus a parseable Etherscan V2 response for the exact
validated address. If `creationBytecode` or required input is absent, fetch the transaction input
separately through the RPC; for a custom factory, use a trace-capable RPC and extract the target
`CREATE` action's init bytes. Then:

1. Determine direct `CREATE`, default CREATE2 deployer (remove its 32-byte salt), or custom factory.
2. Compile fully linked local initcode at the pinned ref and settings.
3. Extract the encoded constructor arguments as the on-chain initcode's **tail beyond the local
   initcode's length** (`hex.zsh ctor-tail`). This mirrors pinned Forge's own recovery
   (`creation_code[local_len..]`). It requires the on-chain initcode to be at least as long as
   the local initcode; a shorter on-chain initcode blocks the target.
4. ABI-decode the tail against the pinned artifact ABI and compare values with deployment
   records. The decode must consume the tail exactly; unresolved decoding blocks the
   constructor-bearing target.
5. The recovery is confirmed only by the authoritative Forge run reporting a creation match
   (full or partial) with these exact `--encoded-constructor-args`. Note the tail is *derived
   from* the on-chain bytes, so "the tail matches" is circular — the load-bearing evidence is
   the length arithmetic, the clean exact-length ABI decode, and Forge's creation match.
   When the local initcode is additionally an **exact prefix** of the on-chain initcode
   (`hex.zsh ctor-suffix` succeeds — only possible when the metadata trailer also matches),
   record that stronger fact; a `ctor-suffix` refusal on a metadata-differing build is expected,
   not a failure.
6. Hash the **sanitized** response with SHA-256 (`shasum -a 256`). Put a sanitized excerpt and
   hash in the Markdown report, or copy an explicitly named
   `<run-name>-<target>-constructor-evidence.sanitized.json` outside the run directory and link it.

Never preserve a raw response containing a key or token-bearing URL. Record the evidence item's
label separately. Do not claim evidence that cleanup will delete.

### 7b. V2-4 explorer compatibility probes (not yet run)

XLayer's official OKLink submission base is
`https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER`, but official
documentation does not establish that it accepts the Etherscan-compatible `getsourcecode` and
`getcontractcreation` reads used by pinned Forge. During V2-4, run these exact requests through
`scripts/capture.zsh` (do not run them in V2-1b):

```zsh
export SPARK_VERIFIER_URL_XLAYER="https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER"
SPARK_REDACT_RPC_VAR_NAME="" \
SPARK_REDACT_VERIFIER_VAR_NAME="SPARK_VERIFIER_URL_XLAYER" \
SPARK_REDACT_KEY_VAR_NAME="XLAYER_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/xlayer-source.sanitized.txt" \
  curl --silent --show-error --get "$SPARK_VERIFIER_URL_XLAYER" \
  --data-urlencode 'module=contract' \
  --data-urlencode 'action=getsourcecode' \
  --data-urlencode 'address=0xdCe929A335C75a1676EF5957A4D7a3b928C48820' \
  --data-urlencode "apikey=$XLAYER_API_KEY"
SPARK_REDACT_RPC_VAR_NAME="" \
SPARK_REDACT_VERIFIER_VAR_NAME="SPARK_VERIFIER_URL_XLAYER" \
SPARK_REDACT_KEY_VAR_NAME="XLAYER_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/xlayer-creation.sanitized.txt" \
  curl --silent --show-error --get "$SPARK_VERIFIER_URL_XLAYER" \
  --data-urlencode 'module=contract' \
  --data-urlencode 'action=getcontractcreation' \
  --data-urlencode 'contractaddresses=0xdCe929A335C75a1676EF5957A4D7a3b928C48820' \
  --data-urlencode "apikey=$XLAYER_API_KEY"
```

Robinhood's public endpoint and Blockscout actions are documented, but the instance is untested,
and chain 4663 is absent from pinned `alloy-chains 0.2.34`, so the campaign command must pass
`--verifier-url` explicitly. During V2-4, export that public endpoint as
`RH_VERIFIER_URL` (used both for `--verifier-url` and capture redaction) and run
these exact keyless probes:

```zsh
export RH_VERIFIER_URL="https://robinhoodchain.blockscout.com/api"
SPARK_REDACT_RPC_VAR_NAME="" \
SPARK_REDACT_VERIFIER_VAR_NAME="RH_VERIFIER_URL" \
SPARK_REDACT_KEY_VAR_NAME="" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/robinhood-source.sanitized.txt" \
  curl --silent --show-error --get "$RH_VERIFIER_URL" \
  --data-urlencode 'module=contract' --data-urlencode 'action=getsourcecode' \
  --data-urlencode 'address=0x797c58C9779D46a437D8f57908D6d56371A55F02'
SPARK_REDACT_RPC_VAR_NAME="" \
SPARK_REDACT_VERIFIER_VAR_NAME="RH_VERIFIER_URL" \
SPARK_REDACT_KEY_VAR_NAME="" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/robinhood-creation.sanitized.txt" \
  curl --silent --show-error --get "$RH_VERIFIER_URL" \
  --data-urlencode 'module=contract' --data-urlencode 'action=getcontractcreation' \
  --data-urlencode 'contractaddresses=0x797c58C9779D46a437D8f57908D6d56371A55F02'
```

Require parseable Etherscan-shaped results, a
contract name for `getsourcecode`, and a target address plus 32-byte transaction hash for
`getcontractcreation`. Unsupported, auth, malformed, HTML, or empty responses remain blockers.
Passing probes still do not prove chain support until a fresh Forge rehearsal succeeds.

### 7c. Authoritative Forge run

For a constructor-bearing target, complete section "Constructor recovery and durable evidence"
and the extraction/ABI decode in section "Independent byte comparison" first.

**Contract identifier**: pass the bare contract **name** (e.g. `RateLimits`), not
`path:Contract` — at this pin the `path:Contract` form fails artifact resolution
(`Contract artifact not found locally`; observed 2026-07-20). Because name-only resolution
scans the whole compiled project, first require the name to be unique in the checkout:

```zsh
grep -rlE "^(abstract )?contract RateLimits\b" \
  "/absolute/os/temp/spark-verify.ab12cd/$group" --include='*.sol'
```

Exactly one file may match (the tagged source path). Zero matches is a hard stop. Multiple
matches require closure analysis before proceeding (observed 2026-07-21: vendored duplicates —
the same OZ contract in `lib/openzeppelin-contracts/` and nested inside another lib — grep as
two files while Forge's compilation closure contains only the remapped copy):

- If exactly one match is the file the checkout's remappings actually resolve for the target's
  import (and `forge inspect <Name> bytecode` resolves cleanly to a single artifact), proceed,
  recording which file was chosen and why the others are outside the closure.
- If more than one match is genuinely inside the compilation closure, hard stop — never let a
  real name collision verify the wrong artifact.

**No `--chain` flag**: at this pin, passing an explicit `--chain` for a named chain (e.g. `1` →
`mainnet`) breaks the runtime-replay path after the creation comparison with
`foundry config error: invalid type: found string "mainnet", expected u64` (observed
2026-07-20). Omit `--chain` and let Forge infer the chain from the RPC — chain identity is
already independently guaranteed by the preflight `cast chain-id` check against the same RPC
variable. (Robinhood 4663 and XLayer 196 are unnamed chains with explicit `--verifier-url`;
whether they need `--chain <id>` is a V2-4 rehearsal item.)

The authoritative Ethereum run passes the recovered constructor bytes explicitly:

```zsh
constructor_flags=()
[[ "$constructor_bearing" == "yes" || "$constructor_bearing" == "no" ]] || exit 1
if [[ "$constructor_bearing" == "yes" ]]; then
  constructor_args_file="/absolute/os/temp/spark-verify.ab12cd/constructor-args.hex"
  [[ -f "$constructor_args_file" && ! -L "$constructor_args_file" ]] || exit 1
  constructor_args="$(<"$constructor_args_file")"
  [[ "$constructor_args" =~ '^0x([0-9A-Fa-f]{2})*$' ]] || exit 1
  constructor_flags=(--encoded-constructor-args "$constructor_args")
fi

export SPARK_FORGE_VERIFIER_URL_ETHEREUM="https://api.etherscan.io/v2/api?chainid=1"
SPARK_REDACT_RPC_VAR_NAME="MAINNET_RPC_URL" \
SPARK_REDACT_VERIFIER_VAR_NAME="SPARK_FORGE_VERIFIER_URL_ETHEREUM" \
SPARK_REDACT_KEY_VAR_NAME="ETHERSCAN_API_KEY" \
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/authoritative-forge.sanitized.txt" \
  forge verify-bytecode --root "/absolute/os/temp/spark-verify.ab12cd/$group" \
  "$address" "$contract_name" "${constructor_flags[@]}" \
  --rpc-url "$MAINNET_RPC_URL" \
  --verifier etherscan --etherscan-api-key "$ETHERSCAN_API_KEY"
```

Set `constructor_bearing` only to validated `yes` or `no`. For no-argument targets the array is
empty and no constructor flag is passed. Set `$contract_name` to the validated, uniqueness-checked
contract name. An EVM override established per `special-cases.md` is passed as an environment
variable on the same command (e.g. `FOUNDRY_EVM_VERSION=paris`) and recorded in evidence. Adapt
only the verifier flags for non-Ethereum chains. This captured run, not a preliminary run used
during recovery, supplies authoritative Forge statuses.

**Budget real time.** First compiles of large dependency trees and historical runtime replay
routinely exceed a 2-minute foreground tool budget (observed 2026-07-21: a replay-bearing
authoritative run hit a 120 s timeout and succeeded unchanged when re-run in the background).
Run authoritative commands with a long timeout or as background jobs; a timeout is an
environment artifact, and re-running the identical command is acceptable — the run is
deterministic and the capture guards refuse stale output files.

### 8. Classify
Record creation and runtime **separately**, each `Full | Partial | Mismatch | Error | Skipped |
Not independently checked`, with a per-phase "independently checked: yes/no" flag. Then assign
one of the nine final classes (`SKILL.md` section "Result classification"). If creation mismatched and
Forge stopped before an independent runtime comparison, mark runtime `Not independently
checked`, not `Mismatch`.

At the pin (Foundry stable v1.7.1, `4072e48…`), the **only** missing-status-line exception is:

- The predeploy warning `Attempting to verify predeployed contract at <address>. Ignoring
  creation code verification.` permits creation `Skipped`, independently checked `no`; record
  runtime only from its actual match/error line. This fires only when the explorer's
  creation-data response has one of the two recognized predeploy shapes.

There is **no** explorer-optional fallback at this pin: the explorer `getcontractcreation` and
`getsourcecode` calls are mandatory, and any explorer failure other than the recognized
predeploy shapes is fatal (`Error fetching creation data from verifier-url: ...`). A run can
never silently downgrade to runtime-only. Custom-factory deployments have no skip warning
either — Forge extracts the initcode from `trace_transaction` (fatal when no matching `CREATE`
trace is found) and proceeds to full creation and runtime verification, so factories require a
trace-capable RPC. Any other missing/unknown status shape is `Investigation required`. These
branches are source-confirmed at the pinned commit; their provider-specific text and target
behavior remain to be observed in live rehearsal.

### 8a. Independent byte comparison

Use this when Forge reports partial, `bytecode_hash = "none"`, a replay dispute, or a version
offset. The extraction and validation steps use `scripts/hex.zsh`, which validates every input
and fails rather than guessing; its hex output goes to stdout for redirection into the run
directory. Extract fully linked local creation/runtime hex with quoted identifiers (exports apply
per shell block — re-export in each tool call):

```zsh
export SPARK_REDACT_RPC_VAR_NAME="MAINNET_RPC_URL"   # the target chain's RPC variable
export SPARK_REDACT_VERIFIER_VAR_NAME=""
export SPARK_REDACT_KEY_VAR_NAME=""
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/local-creation.sanitized.txt" \
  forge inspect --root "/absolute/os/temp/spark-verify.ab12cd/$group" "$contract_name" bytecode
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/local-runtime.sanitized.txt" \
  forge inspect --root "/absolute/os/temp/spark-verify.ab12cd/$group" "$contract_name" deployedBytecode
```

The sanitized `forge inspect` captures combine stdout and stderr, so on checkouts with compiler
warnings they mix diagnostic lines into the bytecode. Before using them as hex inputs, extract
the single bare hex line with `hex.zsh extract-hex` (hard failure on zero or multiple hex
lines):

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" extract-hex \
  "/absolute/os/temp/spark-verify.ab12cd/local-creation.sanitized.txt" \
  > "/absolute/os/temp/spark-verify.ab12cd/local-creation.hex"
zsh "$SKILL_DIR/scripts/hex.zsh" extract-hex \
  "/absolute/os/temp/spark-verify.ab12cd/local-runtime.sanitized.txt" \
  > "/absolute/os/temp/spark-verify.ab12cd/local-runtime.hex"
```

Use the extracted `local-creation.hex` / `local-runtime.hex` files in every step below.

Acquire on-chain runtime bytes with an explicit current or historical `cast code` command, and
direct/default-CREATE2 transaction input or custom-factory traces, through the same capture
script (same three exports as above):

```zsh
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/onchain-runtime.sanitized.txt" \
  cast code "$address" --rpc-url "$MAINNET_RPC_URL"
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/onchain-runtime-at-block.sanitized.txt" \
  cast code "$address" --block "$deployment_block" --rpc-url "$MAINNET_RPC_URL"
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-input.sanitized.txt" \
  cast tx "$deployment_tx" input --rpc-url "$MAINNET_RPC_URL"
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-to.sanitized.txt" \
  cast tx "$deployment_tx" to --rpc-url "$MAINNET_RPC_URL"
zsh "$SKILL_DIR/scripts/capture.zsh" "/absolute/os/temp/spark-verify.ab12cd" \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-trace.sanitized.json" \
  cast rpc --rpc-url "$MAINNET_RPC_URL" trace_transaction "$deployment_tx"
```

The sanitized `cast tx ... input` capture is the direct/default-CREATE2 hex file after validating
it against `^0x(?:[0-9A-Fa-f]{2})*$`. For a custom factory, extract the init bytes of the single
`CREATE` trace whose result address exactly equals the validated target — `hex.zsh trace-init`
stops on zero or multiple matches and accepts exactly the two documented `cast rpc` output shapes
(direct result or JSON-RPC wrapper):

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" trace-init \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-trace.sanitized.json" "$address" \
  > "/absolute/os/temp/spark-verify.ab12cd/onchain-creation.hex"
```

For Etherscan V2 evidence, extract `result[0].creationBytecode` with the same JSON validation; if
absent, use the transaction/trace path above:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" creation-bytecode \
  "/absolute/os/temp/spark-verify.ab12cd/creation-response.sanitized.json" \
  > "/absolute/os/temp/spark-verify.ab12cd/onchain-creation.hex"
```

When using transaction input (not explorer `creationBytecode` or a trace `init`), the pinned
default CREATE2 deployer is `0x4e59b44847b379578588920ca78fbf26c0b4956c`. `hex.zsh
strip-create2-salt` removes the first 32 bytes only after verifying the sanitized `deployment-to`
value case-insensitively equals that address; otherwise it refuses and you must use the complete
direct transaction input or target trace `init`:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" strip-create2-salt \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-to.sanitized.txt" \
  "/absolute/os/temp/spark-verify.ab12cd/deployment-input.sanitized.txt" \
  > "/absolute/os/temp/spark-verify.ab12cd/onchain-creation.hex"
```

For a direct `CREATE`, after hex validation run `cp
"/absolute/os/temp/spark-verify.ab12cd/deployment-input.sanitized.txt"
"/absolute/os/temp/spark-verify.ab12cd/onchain-creation.hex"`. Explorer `creationBytecode` and a
matched factory trace `init` are already initcode and must not have a salt removed.

Produce `constructor-args.hex` as the post-salt on-chain initcode's tail beyond the fully
linked local creation bytecode's length (`hex.zsh ctor-tail`; both inputs are validated hex, and
a shorter on-chain initcode is a hard failure). This mirrors pinned Forge's own argument
recovery; per section 7a, the recovery stands only with a clean exact-length ABI decode plus the
authoritative Forge creation match:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" ctor-tail \
  "/absolute/os/temp/spark-verify.ab12cd/local-creation.hex" \
  "/absolute/os/temp/spark-verify.ab12cd/onchain-creation.hex" \
  > "/absolute/os/temp/spark-verify.ab12cd/constructor-args.hex"
constructor_signature="constructorArgs(address,uint256)()" # dummy name + empty returns; only the input types matter to `cast decode-abi --input` — replace the types from the pinned ABI
cast decode-abi --input "$constructor_signature" \
  "$(<"/absolute/os/temp/spark-verify.ab12cd/constructor-args.hex")"
```

Replace the example canonical types from the pinned artifact ABI, quote the complete signature,
and record decoded values. If the ABI decode fails or does not consume the tail exactly, do not
guess; the constructor evidence remains unresolved. Optionally also run `hex.zsh ctor-suffix`
(exact-prefix form) — when it succeeds, record the stronger exact-prefix fact; when the build is
a metadata-differing partial match its refusal is expected. Append the independently recovered ABI-encoded suffix to
local creation bytecode before comparing it with that on-chain initcode — `hex.zsh join`
validates and concatenates the hex files without guessing a boundary:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" join \
  "/absolute/os/temp/spark-verify.ab12cd/local-creation.hex" \
  "/absolute/os/temp/spark-verify.ab12cd/constructor-args.hex" \
  > "/absolute/os/temp/spark-verify.ab12cd/local-creation-with-args.hex"
```

For a no-argument constructor, use a validated empty `0x` argument file. Never compare an
unlinked artifact. Convert each validated hex-only file to binary with `hex.zsh to-bin`, which
also rejects malformed or odd-length hex, then record lengths, hashes, and byte equality:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" to-bin "$hex_file" > "$binary_file"
wc -c "$binary_file"
shasum -a 256 "$binary_file"
cmp -s "$local_binary" "$onchain_binary"
print -r -- "cmp_exit=$?"
```

Record lengths, SHA-256 hashes, and `cmp` status for creation and runtime independently. Artifact
`deployedBytecode` is **not** instantiated runtime when immutables or library self-address guards
exist. Raw artifact/runtime comparison is allowed only when the artifact's runtime has no
immutable references — `hex.zsh assert-no-immutables` enforces exactly this condition (Foundry
omits `deployedBytecode.immutableReferences` when it is empty, so the script accepts an absent
key on a shape-anchored artifact) — **and** the target is not a deployed library or another
self-address-dependent case, which the script cannot see and the agent must check separately.
Otherwise this stock-macOS workflow cannot produce instantiated local runtime bytes: record the
independent runtime comparison as unavailable and use `Investigation required` for any class
that depends on it. Do not label artifact bytes as "local replay."

Run it on the compiled artifact inside the checkout — `out/<SourceFile>.sol/<Name>.json`. (At
this pin `forge inspect <Name> artifact --json` does not exist — `artifact` is not an accepted
field — so the build product is the only source.) It is a local build product with no
credentials, so it may be read without the capture procedure:

```zsh
zsh "$SKILL_DIR/scripts/hex.zsh" assert-no-immutables \
  "/absolute/os/temp/spark-verify.ab12cd/$group/out/RateLimits.sol/RateLimits.json"
```

Assign `Raw exact bytes, no bytecode hash` only when local creation plus recovered arguments equals
on-chain initcode, the permitted local-runtime comparison equals on-chain runtime, and sanitized
`forge config --json` proves `bytecode_hash = "none"`.

For a non-CBOR comparison, remove a trailer only after decoding the last two bytes as a big-endian
length and proving the entire indicated terminal region is valid CBOR; remove the CBOR bytes and
the two-byte length suffix, nothing else. Stock macOS provides no CBOR validator. Therefore this
skill cannot produce an independent normalized hash with stock tools alone. Unless a separately
approved CBOR decoder is preflighted and its version/command recorded, do not strip by length
heuristic and classify a target that depends on this independent proof as `Investigation
required`. Forge's own `Partial` status remains fresh Forge evidence of its pinned matcher, not an
independent normalization proof.

### 9. Report
One record per target using `report-template.md`, with library subrecords for linked parents.
Keep complete sanitized output, including rejected candidate outputs.

### 10. Cleanup — guarded, with verification
Use the absolute literal printed by `run-dir.zsh create`:
```zsh
zsh "$SKILL_DIR/scripts/run-dir.zsh" cleanup "/absolute/os/temp/spark-verify.ab12cd"
```
The script deletes only when every guard passes — absolute non-symlink directory, basename
`spark-verify.*`, non-symlink ownership marker — then verifies the directory no longer exists.
It prints `cleanup ok` on success; refusal or failure exits 1 with an explicit message. The
basename glob is accepted under any absolute macOS temp parent, including `/var/folders/.../T/`.
Confirm no clone remains and no secret appears in the report. Report refusal/failure explicitly
in the report and chat. The report and any named sanitized evidence artifact must already be
outside this directory.

### 11. Aggregate reconciliation report (multi-batch runs)
After all batches, write `agent-notes/responses/<campaign>-summary.md`:
- One row per `chain ID + address + constant` with its final class and links to its independently
  labeled evidence items; do not invent one aggregate label for mixed evidence.
- Totals reconciled against the registry ref (`in-scope targets = target records`; a blocker is
  an attribute of its target record, not an additional count).
- List of blockers requiring a human and any target dropped from a batch.
This is the artifact that proves complete coverage for the full-registry campaign (V2-5).
