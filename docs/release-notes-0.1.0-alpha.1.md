The first public test release of TD ArenaLens for Conquest of Azeroth.

Included in this release:

- capture of completed arena matches, results, opponents, and scoreboard data;
- rated-team rating changes when the server provides them;
- separate match history for each character;
- the ten most recent matches available through `/tdlens`;
- a copyable diagnostic window available through `/tdlens log`;
- a draggable minimap button.

This is a pre-release intended for testing in real skirmish and rated arenas.
The main capture pipeline has been validated in battleground test mode, but the
custom CoA server's arena events still need community validation. Gear and
talent inspection and cooldown indicators are not included in this version.

Download `TDArenaLens-0.1.0-alpha.1.zip` from **Assets**, extract it into
`Interface/AddOns`, and fully restart the game. The resulting path must be
`Interface/AddOns/TDArenaLens/TDArenaLens.toc`.

Read the full
[installation and test guide](https://github.com/TkachovDmitriy/coa-arena-addon/blob/v0.1.0-alpha.1/docs/installation.md).

Review diagnostic text before posting it publicly because it may contain your
character name and opponent names.
