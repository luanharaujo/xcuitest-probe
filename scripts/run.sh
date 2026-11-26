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
  # SIM_RUNTIME: runtime identifier to use (default: the newest plain iOS runtime).
  SIM_UDID=$(xcrun simctl list devices available -j | SIM_RUNTIME="${SIM_RUNTIME:-}" python3 -c '
import json, os, re, sys
d = json.load(sys.stdin)["devices"]
want = os.environ["SIM_RUNTIME"]
plain = [k for k in d if re.fullmatch(r".*SimRuntime\.iOS-[0-9-]+", k)]
order = sorted(plain, key=lambda k: [int(x) for x in re.findall(r"[0-9]+", k.rsplit("iOS-", 1)[1])])
for rt in ([want] if want else list(reversed(order))):
    for dev in d.get(rt, []):
        if dev["name"].startswith("iPhone"):
            print(dev["udid"]); sys.exit()
sys.exit("no iPhone simulator found")
')
fi
[ -n "$SIM_UDID" ] || exit 1
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
