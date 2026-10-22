# Tests

Run Command-U with the **Cuentiva Word Leap** scheme in Xcode, or:

```sh
xcodebuild -project 'Cuentiva Word Leap.xcodeproj' -scheme 'Cuentiva Word Leap' \
  -destination 'platform=iOS Simulator,name=iPhone Air' test
```

The synchronized test group includes Swift sources automatically. No UI test target is required.

`FeatureTests/WordLeap/WordLeapSimulationTests.swift` exercises the same simulation used
by `WordLeapScene`: supported spawn, inclusive top-edge landing, checkpoints/resizing,
and completing every bundled book across five viewport sizes at 30, 60 and 120 fps,
with a 180 ms steering reaction delay. Floating-point positions use a small tolerance.

These tests can also execute on macOS with the simulation, book decoder and their
dependencies in a temporary Swift package. In that context the manuscript is a test
resource (`Bundle.module`); Xcode's hosted tests use the app's manuscript (`Bundle.main`).
Such a run verifies the production simulation, not SpriteKit rendering, touch delivery,
safe-area layout, or physical-device performance. Those still need an iOS playtest.
