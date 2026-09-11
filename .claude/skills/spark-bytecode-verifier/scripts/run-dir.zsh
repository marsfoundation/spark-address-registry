#!/bin/zsh -f
# Marked temporary run directory: create and guarded cleanup.
#
# Usage:
#   run-dir.zsh create
#       Creates a unique mode-700 directory under ${TMPDIR:-/tmp} with the
#       ownership marker, and prints its absolute path (the only output).
#   run-dir.zsh cleanup <absolute-run-dir>
#       Deletes the directory only when every guard passes: absolute path,
#       not a symlink, basename spark-verify.*, non-symlink ownership marker.
#       Prints "cleanup ok" on success; refusal/failure goes to stderr, exit 1.

set +x

mode="$1"

case "$mode" in
  create)
    umask 077
    run_dir="$(mktemp -d "${TMPDIR:-/tmp}/spark-verify.XXXXXX")" || exit 1
    [[ "$run_dir" == /* && ! -L "$run_dir" ]] || exit 1
    : > "$run_dir/.spark-bytecode-verifier-owned" || exit 1
    print -r -- "$run_dir"
    ;;
  cleanup)
    run_dir="$2"
    marker="$run_dir/.spark-bytecode-verifier-owned"
    base="${run_dir:t}"

    if [[ -n "$run_dir" && "$run_dir" == /* && ! -L "$run_dir" && -d "$run_dir" &&
          "$base" == spark-verify.* && -f "$marker" && ! -L "$marker" ]]; then
      rm -rf "$run_dir"
      if [[ -e "$run_dir" || -L "$run_dir" ]]; then
        print -r -- "CLEANUP FAILED: verified run directory still exists: $run_dir" >&2
        exit 1
      fi
      print -r -- 'cleanup ok'
    else
      print -r -- "CLEANUP REFUSED: run-directory guard failed: $run_dir" >&2
      exit 1
    fi
    ;;
  *)
    print -r -- 'usage: run-dir.zsh create | cleanup <absolute-run-dir>' >&2
    exit 64
    ;;
esac
