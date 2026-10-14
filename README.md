# TimeScroll+

**TimeScroll+ is an unofficial, modified fork of [TimeScroll](https://timescroll.muzhen.org/)**
([upstream source](https://github.com/XInTheDark/TimeScrollApp)). It is not affiliated with or
endorsed by the TimeScroll author. Like the original, it is licensed under the
[GNU GPL v3](LICENSE).

It installs as a separate app (`TimeScroll+.app`, bundle ID `com.paidem.TimeScroll`) and reuses
existing TimeScroll captures. It does not auto-update; new versions are published on this
repository's [Releases](https://github.com/paidem/TimeScrollApp/releases) page.

## Changes from upstream

Based on TimeScroll 2.0.0 (build 48). Modified by Pavel Paidem, October 2026; the full list of
changes is in the git history of the `improvements` branch.

Timeline
- Per-day mode: one day at a time, fitted to the window, with a day navigator and calendar
- Drag to scrub through snapshots; pinch to zoom
- Tick labels no longer overlap; dates shown only where the day changes
- Filters (apps, media, dates) apply to the timeline live; dates are optional

Fixes
- Quitting could hang forever, and capture could silently stop, when OCR got stuck
- A second, hidden timeline window was created (e.g. with "start minimized")
- Arrow keys did not navigate when the search field had focus
- Timeline hover preview could open over the cursor and close immediately
- Cramped "View" label in search results

## Original notes

Full source code for the TimeScroll app. The upstream repo stays in sync with app releases — it
is automatically updated whenever a new app version is published.
