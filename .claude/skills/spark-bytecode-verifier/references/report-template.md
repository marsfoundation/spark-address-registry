# Report template

Write to `agent-notes/responses/<run-name>-response.md`. One record per
`chain ID + address + constant` target. Keep complete, sanitized output — including rejected
candidate outputs. Never include secret values; show RPC, verifier, and credential-bearing URLs as
variable names or `<REDACTED_URL>`. Public source-repository and immutable evidence URLs are
required provenance and may be shown after host/owner validation.

## Report header (once per run)

```markdown
# Spark bytecode verification — <run name>

- Tool: `<full forge --version>` / `<full cast --version>`
  (both must report Commit SHA 4072e48705af9d93e3c0f6e29e93b5e9a40caed8)
- Registry ref: `<ref / commit of spark-address-registry>`
- Scope: `<one target | one chain | changed targets | all source-tagged>`
- Target count (recomputed this run): `<n>`
- Cleanup outcome: `<cleanup ok | CLEANUP FAILED — details>`
```

## Per-target record

````markdown
## <chain> <ID>: <CONSTANT>

- Chain / ID: `<chain>` / `<numeric id>`
- Address: `<checksummed address>`
- Registry constant: `<CONSTANT>`
- Source repository: `<url>`
- Source ref: `<full commit sha>` (`<tag/label>`)
- Source path / contract: `<path>:<Contract>`
- Build context repo: `<repo whose settings were used, if different from source repo>`
- Build settings: solc `<ver>`, optimizer `<on/off>`, runs `<n>`, EVM `<version>`,
  via-IR `<on/off>`, metadata mode `<mode>`, remappings/deps `<summary>`
- Linked libraries: `<none | complete name→address map; each has a subrecord below>`
- Constructor args: `<actual typed values + encoded bytes | none | recovered: …>`
- Creation-data source: `<provider/endpoint variable or trace method; sanitized-response SHA-256>`
- Deployment tx / block: `<tx hash>` / `<block>`
- Verifier: `<etherscan | blockscout | oklink | custom>`
- RPC / provider: `<class only; archive? ; credentials redacted>`

Command (sanitized — variable names / `<REDACTED_URL>`, never resolved values):

```bash
<complete forge verify-bytecode command, run from inside the checkout>
```

Output (complete, sanitized — captured to file, redacted, then quoted):

```text
<complete unabridged output; every token-bearing URL/header/error redacted>
```

- Creation state: `<Full | Partial | Mismatch | Error | Skipped | Not independently checked>`
- Creation independently checked: `<yes / no>`
- Runtime state: `<Full | Partial | Mismatch | Error | Skipped | Not independently checked>`
- Runtime independently checked: `<yes / no>`
- Raw creation hashes (when partial/replay disputed): local `<hash>`, on-chain `<hash>`
- Non-CBOR creation hashes: local `<hash/unavailable>`, on-chain `<hash/unavailable>`
- Raw runtime hashes: local instantiated `<hash/unavailable>`, deployed `<hash>`
- Non-CBOR runtime hashes: local instantiated `<hash/unavailable>`, deployed `<hash/unavailable>`
- Forge-output evidence label: `<Fresh run output | Prior/corroborating evidence | Documented but untested | Inferred>`
- Final classification: `<one of the nine classes below>`
- Limitations / blockers: `<partial metadata, replay error, version offset, build context,
  archive/trace gap, unsupported explorer, or none>`

Evidence items (one row per distinct item; repeat rows as needed):

| Item | Evidence label | Sanitized artifact/excerpt and SHA-256 | Conclusion |
|---|---|---|---|
| Forge output | `<exact label>` | `<report section/hash>` | `<phase statuses>` |
| Library verification | `<exact label>` | `<subrecord/hash>` | `<result>` |
| Constructor recovery | `<exact label>` | `<sanitized evidence/hash>` | `<decoded values>` |
| Prior context | `<exact label>` | `<immutable link/hash>` | `<context only>` |
| Raw/normalized comparison | `<exact label>` | `<lengths/hashes>` | `<equal/different/unavailable>` |
| Ref-equivalence proof | `<exact label>` | `<refs/config/artifact hashes>` | `<proved/unavailable>` |
````

### Library subrecord (one per linked library, before its parent's record)

````markdown
### <chain> <ID>: <CONSTANT> — library <LibName>

- Library: `<path>:<LibName>`
- Deployed address (configured on the parent): `<address>`
- Source ref: `<full commit sha>`

Command:

```bash
<forge verify-bytecode command for the library>
```

Output (sanitized):

```text
<complete output>
```

- Creation state / independently checked: `<state>` / `<yes/no>`
- Runtime state / independently checked: `<state>` / `<yes/no>`
- Forge-output evidence label: `<Fresh run output | Prior/corroborating evidence | Documented but untested | Inferred>`
- Final classification: `<class>`
````
The parent's record is not meaningful until every library subrecord is present and its
deployed address is configured (`special-cases.md` section "MainnetController and its eight
libraries").

## Final classification vocabulary (nine)

`Exact build verified` · `Raw exact bytes, no bytecode hash` · `Non-CBOR bytecode verified` ·
`Creation verified, runtime incomplete` · `Runtime-only verified` ·
`Version-offset logic evidence` · `Mixed result` · `Candidate rejected` ·
`Investigation required`.

## Run footer (once) / aggregate reconciliation report

For a single-batch run, include this footer. For a multi-batch campaign, also write it as the
standalone `agent-notes/responses/<campaign>-summary.md`:

```markdown
## Reconciled totals

- Targets in scope on registry ref: `<n>`
- Target records: `<n>`
- Fresh Forge runs: `<n>`; corroborated by prior evidence: `<n>`
- By final class: <counts per class>
- Cross-chain identical addresses (counted separately): `<list>`
- Targets not independently checked / dropped from batch: `<list or none>`
- Blockers requiring a human: `<list or none>`
- Coverage check: in-scope targets = target records: `<pass/fail>`
```

## Rules

- Do not summarize several commands as "all matched"; retain each complete output.
- Partial → "Non-CBOR bytecode verified" (or "Raw exact bytes, no bytecode hash" when raw bytes
  are proven equal under `bytecode_hash = "none"`); never "Exact build verified."
- Creation match + runtime replay error → "Creation verified, runtime incomplete."
- A runtime line printed after a creation mismatch → `Not independently checked`.
- Version-offset match → "Version-offset logic evidence" with the ref-to-ref equivalence proof.
- Cross-chain identical addresses get separate records.
- A blocker is an attribute of its target record, never an extra record or count.
- Every evidence item carries its own exact evidence label. This includes Forge output, each
  library run, constructor recovery, prior context, raw/normalized byte comparison, and
  ref-equivalence proof when several evidence types support one target.
- If redaction of any field cannot be guaranteed, **stop before writing the report**.
