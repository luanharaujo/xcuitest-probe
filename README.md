# xcuitest-probe

The smallest SwiftUI app with one XCUITest: launch the app, tap a button, check that a label changes.

I use it to tell a broken host apart from a broken Xcode or simulator runtime. If this passes on a clean GitHub macOS runner and fails on my machine, the machine is the problem.

## Run

```
brew install xcodegen
./scripts/run.sh                 # picks the newest iPhone simulator
SIM_UDID=<udid> ./scripts/run.sh # or a specific one
```

The script prints the macOS, Xcode and iOS runtime versions, runs the test once and reports the exit code and duration. CI runs the same script on `macos-latest` (default and newest Xcode) and on the `xcode-27` image.
