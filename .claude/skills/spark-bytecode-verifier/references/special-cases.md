# Special cases

Actionable exceptions. Historical results below are **Prior/corroborating evidence** or
**Documented but untested**, never fresh results. Re-run Forge for the current target.

## MainnetController and its eight libraries

Ethereum `ALM_CONTROLLER` = `0x5c46Fc65855c0C7465a1EA85EEA0B24B601502D3`,
`sparkdotfi/spark-alm-controller`, `src/MainnetController.sol:MainnetController`,
ref `984ec546fb2c98ed729ae91d2d73e97dedbf111f` (v1.10.0), solc 0.8.25, optimizer 1 run,
Cancun EVM.

It links **eight** libraries that are not registry constants. Verify each library first, then
configure its deployed address in the checkout before verifying the controller:

```toml
libraries = [
  "./src/libraries/AaveLib.sol:AaveLib:0xbf5d85793261d3f22e83bc367dab23a322a7ee7b",
  "./src/libraries/CCTPLib.sol:CCTPLib:0x3dd96b97d1b90aca8a60ab2b333f1e61be952b9f",
  "./src/libraries/CurveLib.sol:CurveLib:0xcf78616fa86cda22ebc860e7c1c47b2a9eafce03",
  "./src/libraries/ERC4626Lib.sol:ERC4626Lib:0x6481bb265878a72603f3955f67a019b0310b8f96",
  "./src/libraries/LayerZeroLib.sol:LayerZeroLib:0xdc1f57d806a4d28ebd70652d963873fcf4a53c7e",
  "./src/libraries/PSMLib.sol:PSMLib:0x7a08eff9aa16daa6474565bbf1b606f1c70ee164",
  "./src/libraries/UniswapV4Lib.sol:UniswapV4Lib:0xfdac54ef2a98c37405f759d42dedf05bb2ea0a4a",
  "./src/libraries/WEETHLib.sol:WEETHLib:0x61222ff9d449fcda264270998e4554bd521c5c35",
]
```

Wrong library addresses are not masked (`forge-semantics.md` section "Linked libraries not
masked"). The
controller result is meaningless until all eight are linked to their deployed addresses.
Fresh-run confirmed 2026-07-20 (V2-2): all eight libraries full/full, controller creation and
runtime partial (non-CBOR) with the complete map configured.

## Receiver build-context exceptions

A receiver's source-tag repository is not always its compilation context. Build in the
**deployment** repository/ref:

- `xchain-helpers` receivers deployed with the oracle suite matched in `xchain-ssr-oracle`
  with `optimizer_runs = 100000`.
- The Base governance `OptimismReceiver` (`0xfda082e00EF89185d9DB7E5DcD8c5505070F5A3B`) matched
  in `spark-gov-relay` (v1.0.1) with `optimizer_runs = 200`, not the oracle context.

Building `xchain-helpers` standalone mismatches on compiler settings. Confirm the intended
context by the settings match, and record which repository supplied the build config.

## EVM overrides seen in the example

Apply `FOUNDRY_EVM_VERSION=<ver>` only when deployment records / explorer settings / candidate
comparison establish it. Record both the repo default and the override. Observed:

- `paris`: Base `PSM3` (fresh-run confirmed 2026-07-21; repo default `shanghai`),
  `PSMVariant1Actions`, World Chain DSR contracts (fresh-run confirmed for `DSR_AUTH_ORACLE`
  2026-07-21; repo default `shanghai`).
- `paris`: Ethereum `spark-alm-controller` v1.0.0 targets — `ALM_PROXY` and `ALM_RATE_LIMITS`
  both fresh-run confirmed 2026-07-21 (repo default resolves `shanghai` at solc 0.8.21; deployed
  code has no `PUSH0`). On a **faithful** v1.0.0 checkout both give **full** creation matches;
  an earlier "partial" result (2026-07-20) was an artifact of a contaminated checkout
  (`workflow.md` §4).
- `paris`: Ethereum `sparklend-freezer` spells (v1.1.0 `SPELL_PAUSE_ALL`/`SPELL_PAUSE_DAI`
  fresh-run confirmed 2026-07-21; repo default resolves `shanghai` at solc 0.8.20). The
  historical example ran them with no override and reported full/full — that guidance is wrong
  at this pin; Forge's own mismatch output printed `onchain=paris`.
- `paris`: Base `SPARK_RECEIVER` (`OptimismReceiver` built in the `spark-gov-relay` v1.0.1
  context — fresh-run confirmed 2026-07-21; the gov-relay repo default resolves `cancun`).
- `paris` / `shanghai`: Arbitrum `ArbitrumReceiver` (historical note; not yet fresh-confirmed).

### Determining the override

Primary method: run the target once with the repo-default EVM. On
a mismatch, pinned Forge prints the settings comparison, e.g.
`EVM version mismatch: local=shanghai, onchain=paris` — read the `onchain=` value, re-run with
that override, and record both runs. Note the `onchain=` value comes from the explorer's
recorded compiler settings for the verified contract (`forge-semantics.md` section "Mismatch
hint lines are explorer-derived"), so corroborate it with the bytecode-objective check: absence of `PUSH0` (0x5f) in
deployed code compiled with solc ≥0.8.20 indicates a pre-shanghai EVM target. Record the opcode
evidence and the byte offset where the default-build comparison diverges. Do not cycle EVM
versions until one happens to match without a justification.

## OP-stack forwarder naming

Base and Unichain are OP-stack chains, so `SSROracleForwarderOptimism` /
`DSROracleReceiverOptimism` are the intended implementation families for their forwarders and
receivers. Do not reject on the name mismatch — but still require bytecode evidence and record
the semantic explanation.

## Cross-chain reused addresses

The same literal address can hold different contracts on different chains (same deployer nonce).
Keep each `chain ID + address` separate; never dedupe. Known collisions:
`0x1601843c…`, `0x33a3aB52…`, `0xE206AEbc…`, `0x45d91340…`. Example: `0xE206AEbc…` is
three different contracts across Arbitrum, Optimism, and World Chain.

## World Chain `cd15a90` vs `cbd09d8` — resolved (tag corrected 2026-07-21)

`WorldChain.DSR_AUTH_ORACLE` (`0x779053E25267B591Dcfbb20b2397462aaaD6B776`) was originally
tagged `@cd15a90`. A fresh V2-3 run (2026-07-21, paris settings) reproduced the suspected bug:
`cd15a90` hard-mismatches deployed code; neighbor `cbd09d8` (v1.1.1-beta.1 — changed
`timestamp >= rho` to `timestamp > rho`) is an exact full/full match under identical settings.
The registry tag was corrected to `@cbd09d8` on that evidence.

This case remains the template for a suspected-wrong tag: verify the tagged ref fresh; on a
hard mismatch, test the plausible neighbor ref under otherwise identical settings; report a
source-tag correction only from your own fresh outputs (both runs preserved), never by
restating a historical note. If a fresh run ever disagrees with prior notes, the fresh run
wins → `Investigation required`.

## Replacement `USER_ACTIONS_PSM_VARIANT1`

The current `USER_ACTIONS_PSM_VARIANT1` address has **no** prior verification. It must be
fresh-verified; do not carry any earlier `PSMVariant1Actions` evidence onto it. `PSMVariant1Actions`
uses solc 0.8.25, `FOUNDRY_EVM_VERSION=paris`, two-address constructor, and is a known
runtime-replay-error target (below).

## Version-offset freezables

**Repository access (2026-07-21):** `sparkdotfi/diamond-pau` is not publicly clonable yet
(`Repository not found` on anonymous HTTPS). The owner confirms access will be enabled for all
team users. Until then, every `diamond-pau`-tagged target (all freezables, including Ethereum
`ALM_PROXY_FREEZABLE`) is **blocked — record the blocker, do not improvise a source**. Once
access exists, the standard `sparkdotfi` HTTPS policy applies (authenticated `git`/`gh` in the
launch environment is fine; the skill never handles tokens itself).

Robinhood (`0xAEa9f5dE56e6C20383a1fcC2C3629Dca0A92cE41`) and XLayer
(`0x9449ed367C60ea757544fd990B57e1C2D0Ec3A94`) `ALMProxyFreezable` are tagged `diamond-pau`
v1.12.0 but were verified against v1.14. Accept version-offset evidence only with a direct
ref-to-ref equivalence proof (source diff + build settings + artifact comparison across every
intervening ref showing non-metadata bytecode is unchanged). Record tagged ref, verified ref,
and the equivalence proof. Classify as **`Version-offset logic evidence`** — weaker than an
exact v1.12.0 match; never label it exact.

Enumerate the complete immutable release list with `git for-each-ref --sort=version:refname
--format='%(refname:short)' refs/tags` and preserve that output. For the known v1.12-to-v1.14 case,
require the ordered inclusive set `release_refs=("v1.12.0" "v1.13.0" "v1.14.0")`; if the complete
list contains another intervening release, add it or stop. Validate each ref per `workflow.md`,
resolve it with `git rev-parse --verify "${tag}^{commit}"`, require a full SHA, and prove each
adjacent commit is ordered with `git merge-base --is-ancestor "$left_sha" "$right_sha"`.

Declare every validated target/transitive-dependency path as a quoted zsh array, for example
`dependency_paths=("$source_path" "$dependency_path_1" "$dependency_path_2")`, then compare each
adjacent pair with `git diff "$left_sha" "$right_sha" -- "${dependency_paths[@]}"`. For **every**
ref in `release_refs`, detach-checkout its full SHA, update submodules, verify `HEAD`, capture
sanitized `forge config --json`, rebuild the fully linked target, and capture creation/runtime
artifacts with `workflow.md` section 8a. Record raw lengths/SHA-256 hashes and compare normalized
artifacts too. Stock macOS has no trusted Solidity-CBOR decoder; if raw artifacts differ and no
separately approved CBOR tool was preflighted, the non-metadata equivalence proof is unavailable
and the target is `Investigation required`. Label each source/config/artifact item independently.

## Known replay-error targets (creation-only in the example)

Creation matched, runtime replay errored (EIP-7623-style; runtime **incomplete**, not a match):
`EmergencySpell_SparkLend_FreezeSingleAsset`, `PSMVariant1Actions`, Ethereum `ALMProxy`,
Ethereum `RateLimits`, Base `ALMProxy`, Base `RateLimits`, `SSROracleForwarderArbitrum`.
Expect the same on a fresh run unless a version/hardfork change resolves it; handle per
`troubleshooting.md` section "Runtime replay error" and classify as `Creation verified, runtime
incomplete`.
