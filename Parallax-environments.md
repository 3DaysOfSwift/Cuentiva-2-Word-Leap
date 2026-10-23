# Book environment packs

All 52 books use layered backgrounds, revealed gradually through the adventure.
Assignments are fixed to stable book IDs, not play counts or completion counts.
A retry, replay, title edit or catalogue reorder keeps the same environment.
Unknown future book IDs use Sky Falls until deliberately assigned.

## Progressive reveal

| First appearance | Environment | Debut book |
| --- | --- | --- |
| Books 1–10 | Sky Falls | El viaje de Pipa |
| 11 | Coast | La lluvia sobre el escenario |
| 16 | Roots | La silla de la ventana |
| 21 | Railway | Una luz para dos |
| 26 | Puddle | El reloj del invernadero |
| 31 | Observatory | El brindis del farero |
| 36 | Harbour | La etiqueta escondida |
| 41 | Theatre | La escalera de niebla |
| 46 | Orchard | El último ensayo |
| 51 | Storm | El farol de la playa |
| 52 | Letters — finale | La toalla y el billete |

Between debuts, previously introduced packs rotate in a fixed order without
consecutive repeats. Books 11–15 alternate Coast/Sky Falls; books 16–20 use
Roots/Sky Falls/Coast/Roots/Sky Falls. Later groups draw from the growing pool.
Each new pack gets its debut before joining the rotation.

Castle access now follows the same adventure order: Castle 1 is open, and each
later castle requires its predecessor's completion. Already-completed castles
remain replayable, including legacy out-of-order completions. Scenery assignments
remain fixed; unlocks use existing saved completion IDs without a migration.

## Try the environments

Rebuild in Xcode and play book 1 to see Sky Falls. Completing books 1–10 opens
book 11's Coast environment; completing through book 15 opens Roots at book 16.
Other debut books are listed above. Climb several platforms:
landmarks should move slowly behind the faster foreground, while the distant
backdrop stays fixed. These are camera-driven effects, not tilt controls.

## Composition and behaviour

Each new setting has a clean portrait backdrop, a transparent landmark and a
transparent foreground cluster. Artwork is reconstructed from the original
paintings, not pixel-perfect extraction. Landmarks move at 16% of camera climb;
foreground clusters move at 38%. Setting-appropriate stars, fireflies, pollen or
mist provide a quieter additional layer. The central gameplay area stays clear.

Sky Falls retains its existing sky, distant islands, waterfall islands and
cloud banks, with respective scenery speeds of 14%, 34% and 52%.
Waterfalls move with their islands; flowing-water animation is not implemented.

All scenery is decorative, has no physics bodies, and stays behind platforms.
Nodes recycle after leaving the viewport, with at most 69 nodes per pack and no
per-frame creation. Reduce Motion disables parallax and particle twinkling.
Active play time drives twinkling, so background time is not counted.

## CFA ownership

`GameView → GameViewModel → AppModel.wordLeapFeature` remains unchanged.
Book loading stays with `AppModel.libraryFeature → CuentivaBookRepository`.

- `StoryBook.environment` reads the shared assignment policy.
- `BookEnvironment` owns stable book-ID assignments, pack names and backdrops.
- `ParallaxSceneryRecipe` declares artwork, depth, density and particles.
- `ParallaxBackgroundNode` renders SpriteKit scenery.
- `ParallaxLayout` calculates camera-relative recycling geometry.
- `WordLeapScene` passes camera altitude and active play time to the renderer.

Physics, spawn safety, platform reachability, rewards, book ordering and saves
are unchanged. No new manager, persistence format, task or screen was added.

## Artwork, provenance and size

The ten new packs add 30 assets: ten JPEG backdrops and twenty genuinely
transparent PNG clusters in `CuentivaWordLeap/Assets.xcassets`.
Cutouts are capped at 1,024 pixels on their longest edge. Backdrops retain their
generated portrait dimensions and use JPEG quality 85.

`Book-parallax-artwork.json` records exact prompts, references, generated source
paths, processing and final destinations for all ten packs. `Parallax-artwork.json`
records the earlier Sky Falls pack. Both used the built-in image-generation tool.

The ten original flat paintings are preserved under
`Artwork/OriginalBackgrounds`, outside the app bundle, for future art direction.
`Book-background-artwork.json` records their updated reference paths.

- New pack source images: **26,639,392 bytes (26.64 MB)**.
- Original flat images moved out of the bundle: **5,953,460 bytes (5.95 MB)**.
- Net source-image increase for replacing those originals: **20,685,932 bytes
  (20.69 MB)**.
- Existing Sky Falls source images: **4,648,879 bytes (4.65 MB)**, unchanged.

These are source-image sizes, not compiled app or App Store download sizes.
A current compiled size is unavailable because asset compilation is blocked.

## Progressive assignment verification — 23 October 2026

- Six focused background tests passed, covering all 52 assignments, reveal
  boundaries, no consecutive repeats after book 10, replay stability and unknown IDs.
- The broader macOS model/simulation suite passed **40 tests in 11 suites**,
  including every book's reachability at 30/60/120 fps across five viewports.
- All production Swift sources type-checked against the iOS SDK.
- The Release build failed at launch-screen compilation with
  `iOS 26.2 Platform Not Installed` and CoreSimulator connection errors.
  No installed-app playtest or hosted iOS test run was completed.
- Logs: `/private/tmp/word-leap-progression-{tests,typecheck,build}.log`.

## Earlier artwork verification — 23 October 2026

- **37 tests in 11 suites passed** in a temporary macOS package using production
  model, simulation, recipe and layout files. This includes all 52 books across
  five viewport sizes at 30/60/120 fps, plus pack geometry and recycling checks.
- All production Swift sources type-checked with Swift 6 against the iOS 26.2
  SDK targeting iOS 18. Test-enabled module emission also succeeded.
- All hosted iOS test sources type-checked, including texture-alpha and
  SpriteKit-node tests. Those hosted tests have not executed here.
- All twenty new source PNGs were decoded and checked for transparent and
  near-opaque pixels. Individual artwork was visually inspected; one clipped
  forest foreground was regenerated before installation.
- A full Release build was attempted but failed in asset compilation because
  CoreSimulatorService was inaccessible and actool reported no available
  simulator runtimes. This is not a successful build or install.
- Matthew Thomas tested and approved the earlier Sky Falls prototype. The ten
  new packs have not yet received an interactive iPhone playtest.

Current validation logs are `/private/tmp/word-leap-all-packs-*.log`.

Before release, run all ten new settings plus Sky Falls from Xcode. Check several
scenery wraps, retry after falling, rotation, background/resume and Reduce Motion.
Inspect visual overlaps and profile frame rate and texture memory on an iPhone.
