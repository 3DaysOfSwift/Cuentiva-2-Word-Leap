# Adventure startup and the bundled library

Adventure keeps one WorldBackdrop in place while preparing its first presentation.
There is no launch spinner, separate loading screen, empty castle map or visible
zero-balance placeholder. LibraryFeature concurrently reads the local catalogue,
completed-castle IDs and doubloon balance. It publishes those values together on
the main actor before setting isReady. LibraryViewModel exposes that readiness;
LibraryView reveals the menu and noninteractive balance with a short opacity
transition. Reduce Motion disables that transition. The hidden balance reserves
the same space so content preparation does not change the backdrop's geometry.

The existing static launch storyboard and Adventure use the same village artwork,
aspect-fill treatment and uniform shadow colour at 32% opacity. Adventure omits
the other screens' additional vignette to avoid a brightness change. iOS owns
that launch surface; exact launch-to-SwiftUI rendering still needs a device check.
No timed splash screen or minimum waiting duration is added. Revisiting Adventure
keeps its populated menu visible. A missing/corrupt library shows a retry message
over the same backdrop instead of silently presenting an empty map.

## Bundled data

The shipped asset is `CuentivaWordLeap/3 - App Resources/Editorial/Library.dat`:
52 books, 157,725 bytes (about 154 KiB). This is the library resource size, not
the installed app size. The synchronized Xcode app group includes the resource.

It uses the **same CUENLIB version-two binary format as Cuentiva**: a 16-byte
header, 152-byte book records, 32-byte sentence records, little-endian offsets
and interned UTF-8 strings. This is not JSON with a renamed extension. For the
same normalized book records, output was checked byte-for-byte against
Cuentiva's original compiler.

Word Leap reads its required fields: stable IDs, catalogue order, storyteller,
Spanish/English titles and passages, and cover level/symbol/palette. Unused
learning fields are absent or empty; this is not a copy of Cuentiva's entire
reader database. Existing manuscript and metadata remain the editable source.
All 52 decoded StoryBooks equal the original source, including punctuation,
translations and cover metadata. Existing progress keys and book IDs are unchanged.

The repository reads this bundled binary on its actor and caches the resulting
books. Startup does not parse the manuscript/metadata JSON or contact GitHub.
Level geometry is still built when a book is played; the separate verb vocabulary
is unchanged. Manual pull-to-refresh still retrieves the editorial manuscript
and updates the in-memory catalogue; this change does not add downloaded-file
persistence or background catalogue updates.

## Regeneration and validation

From the project folder, after editing the manuscript or cover metadata:

```sh
python3 scripts/build_library_dat.py
python3 scripts/build_library_dat.py --check
```

Commit Library.dat alongside its source changes. The check command fails if the
binary is stale. The hosted parity test also detects content differences; there
is no Python dependency during app launch and no automatic build-time compiler.

The isolated three-book test fixture has its own compiled resource:

```sh
python3 scripts/build_library_dat.py \
  --stories CuentivaWordLeapTests/Fixtures/AdventureLibrary.txt \
  --output CuentivaWordLeapTests/Fixtures/AdventureLibrary.dat
```

The binary reader rejects unknown versions, truncated/out-of-bounds tables,
invalid UTF-8, duplicate book IDs and missing required story content. Input size,
book count and passage count are bounded before allocation/materialization.

## Verification — 23 October 2026

- 65 core tests in 18 suites pass in the temporary macOS harness, including all
  52 books' content parity and existing gameplay simulations.
- Production Swift module emission and hosted-test iOS typechecking pass.
- Full Xcode build remains blocked here by Interface Builder reporting
  `iOS 26.2 Platform Not Installed`, alongside CoreSimulator service errors.
- This does not establish visual launch continuity or measured launch performance.
  On device, cold-launch offline with saved coins and a completed castle: the first
  visible map must show the correct balance, completed castle and next unlock.
  Repeat with a fresh install, Reduce Motion, and returning from Settings/gameplay.
