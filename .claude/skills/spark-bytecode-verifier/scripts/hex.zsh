#!/bin/zsh -f
# Validated hex/JSON evidence helpers for independent byte comparison.
# Stock Perl with core JSON::PP only. Every subcommand validates its input and
# dies rather than guessing; hex output goes to stdout for the caller to
# redirect into the run directory.
#
# Usage:
#   hex.zsh trace-init <sanitized-trace.json> <target-address>
#       Print the init bytes of the single CREATE trace whose result address
#       equals the target. Zero or multiple matches is a hard failure.
#   hex.zsh creation-bytecode <sanitized-creation-response.json>
#       Print result[0].creationBytecode from an Etherscan V2 response.
#   hex.zsh strip-create2-salt <sanitized-deployment-to-file> <sanitized-deployment-input-file>
#       Verify the transaction's `to` equals the pinned default CREATE2
#       deployer, then print the input with its 32-byte salt removed.
#   hex.zsh ctor-tail <local-creation-hex-file> <onchain-creation-hex-file>
#       Print the on-chain initcode's tail beyond the local initcode's length
#       (pinned Forge's own constructor-args recovery). Requires the on-chain
#       initcode to be at least as long as the local initcode. The result is
#       evidence only together with a clean ABI decode and a Forge creation
#       match — see workflow.md section 7a.
#   hex.zsh ctor-suffix <local-creation-hex-file> <onchain-creation-hex-file>
#       Stronger form: require the local initcode to be an exact prefix of the
#       on-chain initcode (only possible when the metadata trailer matches)
#       and print the constructor-argument suffix.
#   hex.zsh join <hex-file> [<hex-file>...]
#       Validate and concatenate hex files, printing 0x<joined>.
#   hex.zsh extract-hex <sanitized-capture-file>
#       Print the single line of the capture that is a bare even-length hex
#       string (^0x(?:[0-9A-Fa-f]{2})*$). Use on sanitized `forge inspect` captures, which mix
#       compiler warnings/diagnostics into the combined stdout+stderr capture.
#       Zero or multiple hex lines is a hard failure.
#   hex.zsh to-bin <hex-file>
#       Print the binary decoding of a validated hex file to stdout
#       (redirect to the target binary file). Rejects odd-length hex.
#   hex.zsh assert-no-immutables <artifact.json>
#       Require the artifact's runtime to have no immutable references.
#       Foundry emits deployedBytecode.immutableReferences only when it is
#       non-empty, so an absent key on a well-formed artifact means "no
#       immutables"; the artifact shape is anchored by requiring
#       deployedBytecode.object to be hex. Proves only the immutables
#       condition — the caller still owns the not-a-deployed-library /
#       self-address checks (workflow.md section 8a).

set +x

# Pinned default CREATE2 deployer (see references/forge-semantics.md).
readonly SPARK_DEFAULT_CREATE2_DEPLOYER="0x4e59b44847b379578588920ca78fbf26c0b4956c"

op="$1"
shift

case "$op" in
  trace-init)
    SPARK_TARGET_ADDRESS="$2" perl -MJSON::PP -0777 -ne '
      $j = decode_json($_); $target = lc($ENV{SPARK_TARGET_ADDRESS} // "");
      $traces = ref($j) eq "ARRAY" ? $j : $j->{result};
      die "invalid trace response\n" unless ref($traces) eq "ARRAY";
      @matches = grep {
        lc(($_->{result}{address} // "")) eq $target &&
        (($_->{action}{init} // "") =~ /^0x(?:[0-9A-Fa-f]{2})*$/)
      } @$traces;
      die "expected exactly one target CREATE trace\n" unless @matches == 1;
      print $matches[0]{action}{init}, "\n";
    ' "$1"
    ;;
  creation-bytecode)
    perl -MJSON::PP -0777 -ne '
      $j = decode_json($_); $input = $j->{result}[0]{creationBytecode} // die "missing creationBytecode\n";
      die "invalid creationBytecode\n" unless $input =~ /^0x(?:[0-9A-Fa-f]{2})*$/;
      print "$input\n";
    ' "$1"
    ;;
  strip-create2-salt)
    deployment_to="$(<"$1")"
    if [[ "${deployment_to:l}" != "$SPARK_DEFAULT_CREATE2_DEPLOYER" ]]; then
      print -r -- 'strip-create2-salt refused: transaction `to` is not the pinned default CREATE2 deployer' >&2
      exit 1
    fi
    perl -0777 -ne '
      s/\s+//g; die "invalid CREATE2 input\n" unless /^0x(?:[0-9A-Fa-f]{2}){32,}$/;
      print "0x", substr($_, 66), "\n";
    ' "$2"
    ;;
  ctor-tail)
    perl -e '
      sub read_hex {
        my ($file) = @_; open my $fh, "<", $file or die "open failed\n";
        local $/; my $hex = <$fh>; $hex =~ s/\s+//g; $hex =~ s/^0x//;
        die "invalid hex\n" unless $hex =~ /\A(?:[0-9A-Fa-f]{2})*\z/; return lc($hex);
      }
      $local = read_hex($ARGV[0]); $chain = read_hex($ARGV[1]);
      die "on-chain initcode shorter than local initcode\n" if length($chain) < length($local);
      print "0x", substr($chain, length($local)), "\n";
    ' "$1" "$2"
    ;;
  ctor-suffix)
    perl -e '
      sub read_hex {
        my ($file) = @_; open my $fh, "<", $file or die "open failed\n";
        local $/; my $hex = <$fh>; $hex =~ s/\s+//g; $hex =~ s/^0x//;
        die "invalid hex\n" unless $hex =~ /\A(?:[0-9A-Fa-f]{2})*\z/; return lc($hex);
      }
      $local = read_hex($ARGV[0]); $chain = read_hex($ARGV[1]);
      die "local initcode is not an exact prefix\n" unless index($chain, $local) == 0;
      print "0x", substr($chain, length($local)), "\n";
    ' "$1" "$2"
    ;;
  join)
    perl -e '
      for $file (@ARGV) {
        open $fh, "<", $file or die "open failed\n"; local $/; $hex = <$fh>;
        $hex =~ s/\s+//g; $hex =~ s/^0x//;
        die "invalid hex\n" unless $hex =~ /\A(?:[0-9A-Fa-f]{2})*\z/;
        $joined .= $hex;
      }
      print "0x$joined\n";
    ' "$@"
    ;;
  extract-hex)
    perl -ne '
      chomp; next unless /^0x(?:[0-9A-Fa-f]{2})*$/;
      push @hex, $_;
      END {
        die "no bare hex line found\n" unless @hex;
        die "multiple bare hex lines found\n" if @hex > 1;
        print "$hex[0]\n";
      }
    ' "$1"
    ;;
  to-bin)
    perl -0777 -ne '
      s/\s+//g; s/^0x//;
      die "invalid hex\n" unless /\A(?:[0-9A-Fa-f]{2})*\z/;
      print pack("H*", $_);
    ' "$1"
    ;;
  assert-no-immutables)
    perl -MJSON::PP -0777 -ne '
      $j = decode_json($_); $d = $j->{deployedBytecode};
      die "missing deployedBytecode object\n" unless ref($d) eq "HASH";
      $obj = $d->{object};
      die "deployedBytecode.object missing or not hex\n"
        unless defined($obj) && !ref($obj) && $obj =~ /^0x(?:[0-9A-Fa-f]{2})*$/;
      $refs = $d->{immutableReferences};
      if (!defined($refs)) { print "no immutables (immutableReferences absent)\n"; }
      elsif (ref($refs) eq "HASH") {
        die "runtime has immutable references\n" if keys %$refs;
        print "no immutables (immutableReferences empty)\n";
      }
      else { die "invalid immutableReferences\n"; }
    ' "$1"
    ;;
  *)
    print -r -- 'usage: hex.zsh trace-init|creation-bytecode|strip-create2-salt|ctor-tail|ctor-suffix|extract-hex|join|to-bin|assert-no-immutables ...' >&2
    exit 64
    ;;
esac
