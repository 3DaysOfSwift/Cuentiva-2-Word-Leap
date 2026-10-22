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
with a 180 ms steering reaction delay. It also verifies coin contact, roughly 30
collectibles per book, no duplicate collections after retry/resize, and safe completion.
Floating-point positions use a small tolerance. Decoder tests cover the bilingual reader
and original Cuentiva cover metadata; tokenizer tests cover full-stop platforms.

These tests can also execute on macOS with the simulation, book decoder and their
dependencies in a temporary Swift package. In that context the manuscript is a test
resource (`Bundle.module`); Xcode's hosted tests use the app's manuscript (`Bundle.main`).
Such a run verifies the production simulation, not SpriteKit rendering, touch delivery,
safe-area layout, or physical-device performance. Those still need an iOS playtest.

Game Over coverage: `AdventureRunStatisticsTests` verifies unique word/platform/verb
counts, cumulative book totals and duplicate-safe coin/time reports. `ActivePlayTimeTests`
checks that waiting and death add no time and checkpoint retries/resizing preserve it.
`AdventureRunFeatureTests` checks next-level continuity versus a fresh adventure.
`LevelPlanBuilderTests` checks offline verb-form matching against the vocabulary reused
from Verbos, plus the explicit unavailable state for a missing vocabulary. This is an
estimate: homographs and verbs outside that teaching collection are not fully classified.
`ViewModelTests/GameViewModelTests.swift` covers the summary, retry and fresh-start
presentation through isolated features; it requires the hosted iOS test target.

Device checks: fall, see the friendly skeleton transition, inspect the six summary tiles,
continue from checkpoint, finish a book and choose Next level, then die again. Also test
background/foreground, rotation, Reduce Motion and large Dynamic Type. Counts cover the
current adventure (including checkpoint retries and Next level), not lifetime totals.
