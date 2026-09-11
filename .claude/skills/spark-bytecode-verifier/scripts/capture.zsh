#!/bin/zsh -f
# Common capture, sanitize, then read procedure.
#
# Runs a command with stdout/stderr captured into the marked run directory,
# sanitizes the capture with stock Perl, and only then makes it readable.
# Raw output never reaches the terminal.
#
# Usage:
#   SPARK_REDACT_RPC_VAR_NAME=<env-var-name-or-empty> \
#   SPARK_REDACT_VERIFIER_VAR_NAME=<env-var-name-or-empty> \
#   SPARK_REDACT_KEY_VAR_NAME=<env-var-name-or-empty> \
#   capture.zsh <absolute-run-dir> <output-file> <command> [args...]
#
# The three SPARK_REDACT_* values are validated environment-variable NAMES,
# never values. Leave one empty only when the command does not use that
# credential class.
#
# Files written next to <output-file> (which must be a direct child of the
# run directory):
#   <output-file>                sanitized combined stdout/stderr (read this)
#   <output-file>.exit           the command's own exit status
#   <output-file>.sanitize-exit  sanitizer status; read output only when 0
#   <output-file>.sha256         SHA-256 of the sanitized file
#   <output-file>.sanitizer-log  sanitizer's own stdout/stderr — never read it
#
# Script exit status: 0 success; 2 guard failure; 3 sanitizer failure
# (raw output was not read); 4 finalize failure; 5 hash failure.
# The command's own status is only in <output-file>.exit, never this script's.

set +x

expected_run_dir="$1"
output_file="$2"
shift 2

raw_file="${output_file}.unsanitized"
sanitizer_log="${output_file}.sanitizer-log"

[[ "$expected_run_dir" == /* &&
   -d "$expected_run_dir" && ! -L "$expected_run_dir" &&
   -f "$expected_run_dir/.spark-bytecode-verifier-owned" &&
   ! -L "$expected_run_dir/.spark-bytecode-verifier-owned" &&
   "${output_file:h}" == "$expected_run_dir" &&
   "${output_file:t}" =~ '^[A-Za-z0-9][A-Za-z0-9._-]*$' &&
   ! -e "$output_file" && ! -L "$output_file" &&
   ! -e "$raw_file" && ! -L "$raw_file" &&
   ! -e "$sanitizer_log" && ! -L "$sanitizer_log" &&
   ! -e "${output_file}.exit" && ! -L "${output_file}.exit" &&
   ! -e "${output_file}.sanitize-exit" && ! -L "${output_file}.sanitize-exit" &&
   ! -e "${output_file}.sha256" && ! -L "${output_file}.sha256" ]] || exit 2

"$@" >"$raw_file" 2>&1
command_status=$?
print -r -- "$command_status" >"${output_file}.exit" || exit 2

perl -0pi -e '
  BEGIN {
    @pairs = ();
    for $spec (["SPARK_REDACT_RPC_VAR_NAME", "<REDACTED_RPC_URL>"],
               ["SPARK_REDACT_VERIFIER_VAR_NAME", "<REDACTED_VERIFIER_URL>"],
               ["SPARK_REDACT_KEY_VAR_NAME", "<REDACTED_API_KEY>"]) {
      $name = $ENV{$spec->[0]} // "";
      die "invalid redaction variable name" if length($name) && $name !~ /^[A-Za-z_][A-Za-z0-9_]*$/;
      $value = length($name) ? ($ENV{$name} // "") : "";
      push @pairs, [$value, $spec->[1]] if length($value);
    }
  }
  for $pair (@pairs) {
    ($value, $marker) = @$pair;
    s/\Q$value\E/$marker/g;
  }
  s{([?&](?:api[_-]?key|apikey|token|access[_-]?token|key)=)[^&\s"<>]+}{$1<REDACTED_TOKEN>}gi;
  s{((?:authorization|x-api-key|ok-access-key)\s*[:=]\s*)(?:bearer\s+)?\S+}{$1<REDACTED_TOKEN>}gi;
  s{("[^"]*(?:api[_-]?key|apikey|token|secret|password|rpc[_-]?url|key|url)[^"]*"\s*:\s*")[^"]*(")}{$1<REDACTED_TOKEN>$2}gi;
  s{((?:api[_-]?key|apikey|token|secret|password|rpc[_-]?url|key)\s*=\s*")[^"]*(")}{$1<REDACTED_TOKEN>$2}gi;
  s{https?://[^\s"<>]+}{<REDACTED_URL>}g;
' "$raw_file" >"$sanitizer_log" 2>&1
sanitizer_status=$?

if (( sanitizer_status != 0 )); then
  print -r -- "$sanitizer_status" >"${output_file}.sanitize-exit" || exit 3
  print -r -- 'SANITIZATION FAILED; raw output was not read' >&2
  exit 3
fi

mv "$raw_file" "$output_file" || exit 4
print -r -- '0' >"${output_file}.sanitize-exit" || exit 4
shasum -a 256 "$output_file" >"${output_file}.sha256" || exit 5
