# Chains

**Live status (updated 2026-07-21):** Ethereum (1), Base (8453), and World Chain (480) are
**observed working end to end** in the V2-2/V2-3 rehearsals — chain-id confirmation, Etherscan
V2 creation/source lookup on the single `ETHERSCAN_API_KEY`, full creation comparison, and
runtime replay (replay completed on Base and World Chain; Ethereum replay works but old
transactions can hit the EIP-7623 gas-floor artifact). All **other** rows remain documented or
inferred hypotheses pending V2-4 — do not cite them as fresh results.

The variable names below are the team's actual `.env` names (owner-confirmed 2026-07-20) — they
are still **not hardcoded** into the skill. Read whatever environment the supported credential
setup in `SKILL.md` provides, check presence only, never print values, and confirm chain identity
by RPC (`cast chain-id`), not by the variable name. Never source a project- or PR-controlled
`.env`. Credentials may come from `.claude/settings.local.json` or shell exports in `~/.zshenv`
(or a personal file sourced there) before Claude Code starts; `~/.zshrc` alone is not supported
because tool shells are non-interactive. If a name is absent, explain both setup choices and ask
the user to restart Claude Code after adding it.

## Explorer keys

| Key variable | Explorer | Covers |
|---|---|---|
| `ETHERSCAN_API_KEY` | Etherscan V2 (single key) | Ethereum 1, Base 8453, Arbitrum 42161, Optimism 10, Unichain 130, Avalanche 43114 (paid tier), World Chain 480, Gnosis 100 |
| `XLAYER_API_KEY` | OKLink | XLayer 196 — **not yet in the team `.env`**; required before XLayer targets can run |
| none required | Blockscout (API keys are optional) | Robinhood 4663 |

The single Etherscan V2 key is **confirmed by observation** (V2-2/V2-3) for chains 1, 8453,
and 480 — one `ETHERSCAN_API_KEY` served creation/source lookups on all three. Coverage of the
remaining Etherscan-family chains is documentation-based pending V2-4.

## Per-chain matrix (status per row)

| Chain | ID | RPC var | Explorer | Forge verifier | Key var | Creation lookup | Max support (hypothesis) |
|---|---:|---|---|---|---|---|---|
| Ethereum | 1 | `MAINNET_RPC_URL` | Etherscan | `etherscan` | `ETHERSCAN_API_KEY` | yes (`getcontractcreation`) | full — **observed** (V2-2/V2-3; old txs can hit EIP-7623 replay artifact) |
| Base | 8453 | `BASE_RPC_URL` | Basescan | `etherscan` | same key | yes | full — **observed** (V2-3 incl. runtime replay) |
| Arbitrum One | 42161 | `ARBITRUM_ONE_RPC_URL` | Arbiscan | `etherscan` | same key | yes | full (factory targets need a trace-capable RPC) |
| Optimism | 10 | `OPTIMISM_RPC_URL` | OP Etherscan | `etherscan` | same key | yes | full |
| Unichain | 130 | `UNICHAIN_RPC_URL` | Uniscan | `etherscan` | same key | yes | full |
| Avalanche | 43114 | `AVAX_RPC_URL` | Snowscan/Snowtrace | `etherscan` (or custom→Routescan) | same key (paid tier) | yes | full (key tier is the risk) |
| World Chain | 480 | `WORLD_CHAIN_RPC_URL` | Worldscan (Etherscan-family); Blockscout alt | `etherscan` (or `blockscout`) | same key | yes — **observed** (chainid=480 on the single key) | full — **observed** (V2-3 incl. runtime replay) |
| XLayer | 196 | `XLAYER_RPC_URL` | OKLink (`https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER`) | `oklink` | `XLAYER_API_KEY` (**not yet in the team `.env`**) | **blocked offline:** plugin support for `getsourcecode` and `getcontractcreation` is undocumented | unknown pending V2-4 action probes; re-genesis at block 42,810,021 may also limit historical replay |
| Robinhood | 4663 | `RH_RPC_URL` | Blockscout (`https://robinhoodchain.blockscout.com/api`) | `blockscout` | none required | generic Blockscout API documents `getcontractcreation`; Robinhood instance is untested | full is **Documented but untested** / **Inferred** pending V2-4 instance and Forge rehearsal |
| Gnosis | 100 | `GNOSIS_CHAIN_RPC_URL` | Gnosisscan; Blockscout | `etherscan` (or `blockscout`) | same key | yes | **currently untagged / future scope** — no source tags in initial 119; watch `evm_version` (own hardfork) |

## Notes

- **Archive/trace:** local runtime replay may need an archive-capable RPC and, for factory
  deployments, `trace_transaction`. Prefer archive endpoints; a public rate-limited RPC may be
  insufficient (`troubleshooting.md` section "Archive / trace unavailable").
- **Pinned endpoint resolution:** Foundry commit
  `4072e48705af9d93e3c0f6e29e93b5e9a40caed8` (stable v1.7.1) pins `alloy-chains 0.2.34`.
  `verify-bytecode`'s API URL comes from `--verifier-url` first and then from chain
  configuration. `alloy-chains 0.2.34` contains **neither Robinhood mainnet 4663 nor XLayer
  196** (only `RobinhoodTestnet` 46630), so both chains require an explicit `--verifier-url`.
- **XLayer:** chain 196 is absent from pinned `alloy-chains`, so the exact official OKLink plugin
  URL must be supplied. Official OKLink documentation and the immutable OKX plugin source
  establish this verification-submission base and direct users to obtain an API key. They do not
  establish that the adapter accepts the Etherscan-compatible `getsourcecode` and
  `getcontractcreation` reads that pinned `verify-bytecode` invokes. This is a V2-4 blocker; do
  not claim either that creation lookup works or that it is unsupported before the probes in
  `workflow.md` section 7b are observed. OKLink documents source retrieval at the separate
  `/api/v5/explorer/contract/verify-contract-info` endpoint, but pinned Forge does not call that
  endpoint, and the docs do not identify an equivalent creation-transaction lookup.
- **Robinhood:** chain 4663 is **absent** from pinned `alloy-chains 0.2.34` (only
  `RobinhoodTestnet` 46630 exists there), so the endpoint cannot be inherited: the campaign
  command must pass an explicit
  `--verifier-url "https://robinhoodchain.blockscout.com/api"` (provided by
  `RH_VERIFIER_URL`, including for redaction, per `workflow.md`).
  Blockscout documents both required read actions and optional API keys, but Robinhood's live
  instance has not been observed. Label support **Documented but untested** or **Inferred** until
  V2-4 supplies fresh evidence.
- **Verifier flags (per family; see `workflow.md` section "Common capture, sanitize, then read
  procedure"):**
  - Etherscan-family (Ethereum, Base, Arbitrum, Optimism, Unichain, Avalanche, World Chain,
    Gnosis): `--verifier etherscan --etherscan-api-key "$ETHERSCAN_API_KEY"`. Do **not** pass
    `--chain` (a pin bug breaks runtime replay for named chains — `workflow.md` section
    "Authoritative Forge run"): Foundry infers the chain from the RPC and resolves the
    Etherscan-V2 endpoint from it. Do not pass an empty or custom `--verifier-url` either.
  - XLayer: export the official URL as `SPARK_VERIFIER_URL_XLAYER`, then use `--verifier oklink
    --verifier-url "$SPARK_VERIFIER_URL_XLAYER" --verifier-api-key "$XLAYER_API_KEY"`. The exact
    official URL is in the matrix above. Whether an explicit `--chain 196` is needed for this
    unnamed chain is a V2-4 rehearsal item (`workflow.md` section "7c. Authoritative Forge run").
  - Robinhood: use `RH_VERIFIER_URL="https://robinhoodchain.blockscout.com/api"`, then use
    `--verifier blockscout --verifier-url "$RH_VERIFIER_URL"`
    (required — chain 4663 is absent from pinned `alloy-chains 0.2.34`). No API key is required
    by documented Blockscout behavior. The live instance, and whether an explicit `--chain 4663`
    is needed, remain V2-4 rehearsal items.

## Offline source basis

- Pinned Foundry `verify-bytecode` client path:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/verify/src/bytecode.rs>
- Pinned Etherscan-compatible URL resolution:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/verify/src/etherscan/mod.rs>
- Generic provider validation, relevant to `verify-contract` but bypassed by
  `verify-bytecode`'s client path:
  <https://github.com/foundry-rs/foundry/blob/4072e48705af9d93e3c0f6e29e93b5e9a40caed8/crates/verify/src/provider.rs>
- Pinned `alloy-chains 0.2.34` registry (only `RobinhoodTestnet` 46630 — no Robinhood mainnet
  4663, no XLayer 196), from the published crate source `alloy-chains-0.2.34/src/named.rs`:
  <https://docs.rs/crate/alloy-chains/0.2.34/source/src/named.rs>
- Immutable official OKX XLayer plugin configuration:
  <https://github.com/okx/hardhat-explorer-verify/blob/0f2914a0c77ef38ee913813607371caaa55b1a68/src/config/ChainConfig.ts>
- Official OKLink Foundry documentation:
  <https://www.oklink.com/docs/en/#developer-tools-contract-verification-plugin-contract-verification-using-foundry>
- Official Blockscout Foundry documentation:
  <https://docs.blockscout.com/devs/verification/foundry-verification>
- Official Blockscout read-action documentation:
  <https://docs.blockscout.com/api-reference/contract/get-contract-source-code-for-verified-contract>
  and
  <https://docs.blockscout.com/api-reference/contract/get-contract-creator-and-creation-transaction-hash>
- Official Robinhood chain and verifier configuration:
  <https://docs.robinhood.com/chain/connecting> and
  <https://docs.robinhood.com/chain/deploy-smart-contracts>.
