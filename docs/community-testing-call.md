# Help test TD ArenaLens on Conquest of Azeroth

## What is TD ArenaLens?

TD ArenaLens is a free, lightweight addon for Conquest of Azeroth that records
your arena matches and lets you review them in game.

The goal is to give arena players a useful personal match history: who they
fought, whether they won or lost, how their rating changed, and eventually
more detailed information such as opponent builds, gear, and important
cooldowns.

I am making it because this information is difficult to review after a match
on CoA. The first version is focused on reliable data collection. Once that
works well for real players, I can build a better match-history interface and
decide which advanced features are genuinely useful to the community.

## What can the test version do?

- Detect and record arena matches.
- Save wins, losses, opponents, scoreboard information, and rated-team rating
  changes when the server provides them.
- Show your ten most recent matches in game.
- Keep match history separately for each character.
- Provide a diagnostic window whose text can be copied when reporting a
  problem.
- Open the match history and diagnostics from a draggable minimap button.

All data stays inside your local WoW `SavedVariables`. The addon does not send
anything over the internet and has no account, login, tracking, or automatic
upload. You choose whether to share a diagnostic report with me.

## Why do I need testers?

CoA uses a customized WoW 3.3.5 client and server. Automated tests pass, and
the main capture pipeline has been tested successfully in battlegrounds, but
real arenas may expose different event timing or API behaviour.

I especially need players who can test:

- at least one arena skirmish;
- at least one rated arena;
- whether wins, losses, opponents, and rating changes are recorded correctly;
- whether the saved match is still present after `/reload`;
- whether any Lua error appears during or after the match.

Testing one or two matches is already useful. You do not need to be a highly
rated player or understand Lua.

## What should testers expect?

This is an early pre-release, not a finished addon. The interface is currently
simple, some opponent information may be unavailable, and a match may be
marked incomplete if CoA does not expose its final scoreboard in the expected
order. Gear and talent inspection and enemy cooldown indicators are planned,
but are not part of this test version yet.

Before testing, it is sensible to back up your `WTF` folder or the addon's
SavedVariables. The addon only writes its own saved data, but backups are good
practice when testing any pre-release addon.

## How to help

1. Install the `TDArenaLens` folder in `Interface/AddOns/` and fully restart
   the game.
2. Enable Lua errors with `/console scriptErrors 1`.
3. Play a skirmish or rated arena normally.
4. Open recent matches with `/tdlens`.
5. Open the copyable diagnostic window with `/tdlens log`.
6. Send me what worked, what was recorded incorrectly, any Lua error, and the
   copied diagnostic text. Please also mention whether the match was a
   skirmish or rated arena.

Diagnostic and arena-export text can contain your character name and opponent
names. Review it before posting it publicly.

## Interested?

If a local, in-game arena match history sounds useful and you are comfortable
trying an early version, I would appreciate your help. Your test results will
determine whether the capture system is reliable enough for a public release
and which features should be built next.

