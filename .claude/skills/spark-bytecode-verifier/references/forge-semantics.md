# Forge verify-bytecode semantics and evidence ceilings

`forge verify-bytecode` matching is **version-sensitive**. This campaign uses only Foundry
stable v1.7.1, commit `4072e48705af9d93e3c0f6e29e93b5e9a40caed8`. The historical review example
(kept as local context in the registry maintainers' `agent-notes/verification-example.md`; not
part of this skill and not required) contains explanations that do not match this
implementation; the pinned model is here.

## Foundry version caveat

- Preflight hard-stops unless both `forge --version` and `cast --version` report the exact pin.
- Semantics below are source-confirmed at that commit. Provider-specific messages, output ordering,
  and target results remain **Documented but untested** until a live rehearsal; source review is
  not fresh chain support evidence.

## Partial comparison and terminal CBOR metadata

`partial` means bytes are equal **after removing each side's complete valid terminal Solidity
CBOR metadata trailer** (not merely the IPFS hash field). For creation code, the
constructor-argument tail is also excluded from the partial comparison. Exact bytes compiled
with `bytecode_hash = "none"` are also reported as `partial`.

Report a partial as "non-CBOR bytecode matched," not "only the metadata hash differed." A
partial is positive evidence of non-CBOR byte equality; it does **not** establish exact
metadata/build provenance.

## Full creation vs partial creation

Full creation comparison includes constructor arguments and the full metadata trailer.
Partial creation comparison strips the CBOR trailer and the constructor-args tail. Do not
promote a partial creation match to an exact-build claim.

## No immutable masking

`forge verify-bytecode` does **not** use artifact `immutableReferences` to mask runtime
bytes. Immutable values are produced by constructor replay and compared normally. Different
immutable values outside metadata cause a mismatch. (The example's "immutables masked" claim
is wrong.)

## Constructor arguments and silent explorer suffix recovery

Constructor arguments matter for full creation comparison and for runtime replay. Placeholder
args worked in some example runs only because Foundry fetched the on-chain creation input and
**silently replaced** a mismatched supplied suffix with the actual suffix, using a
length-based recovery heuristic that depends on explorer creation data. Normal output does not
show the recovered arguments.

Therefore: supply real ABI-shaped constructor args when known; recover and decode the actual
suffix independently before classifying a constructor-bearing deployment; and never claim the
displayed placeholder values were verified.

## Linked libraries not masked

External libraries must all be linked before verification, and incorrect library addresses are
**not** masked — a wrong address changes linked bytecode and should cause mismatch. Verify each
library and configure its deployed address before verifying the parent.

## Local historical runtime replay

Runtime verification reconstructs the deployment environment and **locally** replays earlier
transactions from the deployment block before the deployment transaction, then executes local
initcode and compares the produced runtime with deployed runtime. This uses Foundry's EVM
executor, not the RPC node's execution. Archive/trace access may be required (historical state
at deployment block − 1, historical code/nonce, full blocks, tx/receipt, `trace_transaction`
for factories).

## EIP-7623-style replay errors are runtime-incomplete

Messages like `gas floor (NNNNN) exceeds the gas limit (NNNNN)` are emitted by Foundry's
**local** replay applying current gas-floor rules to a historical tx — not proof an RPC node
rejected anything. A creation match plus a runtime replay error is:
```
creation verified; runtime verification incomplete
```
Strong evidence, but not a runtime match. Do not call it runtime-verified.

## Contract-name pre-check: `Error: Contract name mismatch`

Before any bytecode comparison, pinned Forge compares the candidate contract name against the
name the **explorer** recorded for the verified contract, and bails with exactly
`Error: Contract name mismatch` when they differ. This is a legitimate rejection — classify
`Candidate rejected`, noting the name pre-check in the record's limitations — but it is an
explorer-metadata check, not a bytecode result: no bytes were compared. If the registry tag and the explorer disagree about what lives
at the address, that discrepancy itself is `Investigation required`, not a silent acceptance of
either name.

## Mismatch hint lines are explorer-derived

On a mismatch, pinned Forge prints a settings comparison against the explorer's recorded
compiler configuration, e.g. `EVM version mismatch: local=shanghai, onchain=paris` (also
optimizer/runs differences). These lines are the fastest way to identify a wrong build setting
(see `special-cases.md` "Determining the override"), but the `onchain=` side is the explorer's
claim about the verified source, not something derived from the deployed bytes — corroborate
with bytecode-objective evidence before adopting an override.

## A match does not uniquely attribute a ref

A full or partial match proves the deployed bytecode equals the output of *that source
compilation closure and settings* — not that the tagged ref is the only ref producing it. When a
contract's closure is byte-identical across several tags (observed for `sparklend-freezer`
spells: every tag matches), a match at the tagged ref and a match at a neighbor ref carry the
same information. Consequently a "wrong neighboring ref" negative control is vacuous for
closure-invariant contracts — a meaningful negative control must change the contract's own
closure or build settings (wrong contract, wrong EVM, wrong optimizer where it matters).

## Mismatch may return process exit zero

Foundry can print bytecode-mismatch messages while returning a successful process exit code.
Classify only from the explicit `matched with status ...` lines / structured output, never
from exit status alone.

## Runtime not independently checked after creation short-circuit

At the pin, a creation mismatch stops before independent runtime replay but prints/serializes a
runtime mismatch result. Mark runtime `Not independently checked`, not `Mismatch`, unless a
separate runtime comparison actually ran.

## Explorer is mandatory at the pin — no runtime-only fallback

At this pin the explorer is **required**: `verify-bytecode` fetches `getcontractcreation` and
`getsourcecode` before any comparison, and any explorer failure is fatal
(`Error fetching creation data from verifier-url: ...`) — except the two recognized
**predeploy** response shapes, which set predeploy mode. In predeploy mode Forge warns
`Attempting to verify predeployed contract at <address>. Ignoring creation code verification.`,
deploys the candidate at genesis, and reports only a runtime comparison. Record creation
`Skipped`, independently checked `no`; this is runtime-only evidence and never
constructor/creation evidence.

There is no other path that warns and continues without the explorer. A missing or failing
explorer can never be silently downgraded to runtime-only; preserve the sanitized error and
fail closed. (`Runtime-only verified` is therefore reachable at this pin only for predeploys or
via an explicit `--ignore creation` diagnostic, which still requires working explorer lookups.)

For a non-default custom factory, pinned Forge extracts the target's initcode from
`trace_transaction` — fatal when no matching `CREATE` trace is found — and then proceeds to
**both** creation comparison and runtime replay. There is no factory runtime-skip warning at
this pin; factories simply require a trace-capable RPC. Direct `CREATE` and Foundry's default
CREATE2 deployer are handled from transaction input (the 32-byte salt is removed for the
default CREATE2 deployer before analyzing initcode).

Missing creation/runtime status lines are accepted only alongside the exact predeploy warning
above. Any other absent or unknown shape is `Investigation required`.

## Source references

Immutable pinned references:

- Matching / partial comparison (`match_bytecodes`, raw-equal + `bytecode_hash = none` →
  `Partial`):
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/verify/src/utils.rs>
- Predeploy detection (`maybe_predeploy_contract` — any other explorer error is fatal): same
  `utils.rs` file.
- CBOR metadata detection/removal:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/common/src/utils.rs>
- Creation data, factory trace extraction & runtime replay:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/verify/src/bytecode.rs>
- CLI behavior tests:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/forge/tests/cli/verify_bytecode.rs>
