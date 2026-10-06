#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Resolves xcodebuild -destination for iOS Simulator tests.
# Override with SIM_DEST, or SIM_DEVICE_NAME (e.g. "iPhone 17 Pro").
resolve_simulator_destination() {
  if [[ -n "${SIM_DEST:-}" ]]; then
    echo "$SIM_DEST"
    return 0
  fi

  if [[ -n "${SIM_DEVICE_NAME:-}" ]]; then
    echo "platform=iOS Simulator,name=${SIM_DEVICE_NAME}"
    return 0
  fi

  local line udid
  local -a preferences=(
    "iPhone 17 Pro"
    "iPhone 17"
    "iPhone 16 Pro"
    "iPhone 16"
    "iPhone 15"
    "iPhone 14"
    "iPhone SE"
  )

  for pattern in "${preferences[@]}"; do
    line="$(xcrun simctl list devices available 2>/dev/null | grep -F "${pattern} (" | head -1 || true)"
    if [[ -n "$line" ]]; then
      udid="$(echo "$line" | sed -E 's/^[[:space:]]+.*\(([A-F0-9-]{36})\).*/\1/')"
      if [[ "$udid" =~ ^[A-F0-9-]{36}$ ]]; then
        echo "platform=iOS Simulator,id=${udid}"
        return 0
      fi
    fi
  done

  # Any available iPhone
  line="$(xcrun simctl list devices available 2>/dev/null | grep -E '^[[:space:]]+iPhone ' | head -1 || true)"
  if [[ -n "$line" ]]; then
    udid="$(echo "$line" | sed -E 's/^[[:space:]]+.*\(([A-F0-9-]{36})\).*/\1/')"
    if [[ "$udid" =~ ^[A-F0-9-]{36}$ ]]; then
      echo "platform=iOS Simulator,id=${udid}"
      return 0
    fi
  fi

  echo "No available iOS Simulator found. Install one in Xcode (Settings → Platforms) or set SIM_DEST / SIM_DEVICE_NAME." >&2
  echo "Example: SIM_DEST='platform=iOS Simulator,name=iPhone 17 Pro' $0" >&2
  return 1
}

echo "== SwiftLint =="
swiftlint lint --strict

echo "== Domain tests + coverage floor =="
cd Packages/Domain
swift test --enable-code-coverage
PROFDATA="$(find .build -name '*.profdata' 2>/dev/null | head -1 || true)"
if [[ -n "$PROFDATA" ]]; then
  DOMAIN_BIN="$(find .build -path '*Domain.build*' -name 'Domain' -type f 2>/dev/null | head -1 || true)"
  if [[ -n "$DOMAIN_BIN" ]]; then
    COVERAGE="$(xcrun llvm-cov report "$DOMAIN_BIN" -instr-profile="$PROFDATA" 2>/dev/null | awk '/TOTAL/ {print $4}' | tr -d '%' || echo "0")"
    echo "Domain line coverage: ${COVERAGE}%"
    MIN_DOMAIN_COV="${MIN_DOMAIN_COV:-45}"
    awk -v c="$COVERAGE" -v m="$MIN_DOMAIN_COV" 'BEGIN { exit !(c+0 >= m+0) }' || {
      echo "Domain coverage ${COVERAGE}% is below minimum ${MIN_DOMAIN_COV}%"
      exit 1
    }
  fi
fi
cd "$ROOT"

echo "== Core tests =="
cd Packages/Core && swift test
cd "$ROOT"

SIM_DEST="$(resolve_simulator_destination)"
echo "== Using Simulator destination: ${SIM_DEST} =="

echo "== Generate Xcode project =="
xcodegen generate

echo "== iOS Simulator: Data tests =="
(cd Packages/Data && xcodebuild test \
  -scheme Data \
  -destination "$SIM_DEST" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -quiet)

echo "== iOS Simulator: Features tests =="
(cd Packages/Features && xcodebuild test \
  -scheme Features \
  -destination "$SIM_DEST" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -quiet)

RESULT_BUNDLE="$ROOT/TestResults.xcresult"
rm -rf "$RESULT_BUNDLE"

echo "== iOS Simulator: App + UI tests (with coverage) =="
xcodebuild test \
  -project StockTracker.xcodeproj \
  -scheme StockTracker \
  -destination "$SIM_DEST" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  -resultBundlePath "$RESULT_BUNDLE" \
  -quiet

echo "== App coverage summary =="
xcrun xccov view --report --only-targets "$RESULT_BUNDLE" | head -20

echo "CI test pipeline completed successfully."
