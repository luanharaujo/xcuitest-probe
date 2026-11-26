#!/bin/bash
# Build and run the UI test once on an iOS simulator, then print the versions.
# SIM_UDID: use this simulator instead of picking one.
set -uo pipefail
cd "$(dirname "$0")/.."
OUT="${OUT_DIR:-build}"
mkdir -p "$OUT"

echo "== versions"
sw_vers
xcodebuild -version
xcrun simctl list runtimes | grep -i ios

if [ -z "${SIM_UDID:-}" ]; then
  SIM_UDID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
d = json.load(sys.stdin)["devices"]
ios = sorted((k for k in d if "iOS" in k), key=lambda k: [int(x) for x in k.rsplit("iOS-", 1)[1].split("-")])
for rt in reversed(ios):
    for dev in d[rt]:
        if dev["name"].startswith("iPhone"):
            print(dev["udid"]); sys.exit()
')
fi
echo "== simulator"
xcrun simctl list devices | grep "$SIM_UDID"

xcodegen generate --quiet
start=$(date +%s)
xcodebuild test \
  -project Probe.xcodeproj -scheme Probe \
  -destination "id=$SIM_UDID" \
  -derivedDataPath "$OUT/dd" \
  -resultBundlePath "$OUT/result-$(date +%H%M%S).xcresult" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$OUT/test.log" | grep -E "Test Case|error|Error Domain|TEST (SUCCEEDED|FAILED)|\*\* "
rc=${PIPESTATUS[0]}
echo "== result rc=$rc seconds=$(( $(date +%s) - start ))"
exit "$rc"
