The second public test release of TD ArenaLens for Conquest of Azeroth.

Changes in this release:

- persistent debug mode and a copyable diagnostic log for live arena testing;
- an Inspect probe available through `/tdlens inspect`;
- support for Ascension's `INSPECT_TALENT_READY` event;
- diagnostic capture of inspected equipment and average item level;
- capture of scoreboard specialization, PvP rating, rating change, pre-match
  MMR, and MMR change when the server provides them;
- the new scoreboard fields are included in copyable arena and battleground
  test exports.

This remains a pre-release intended for testing. Inspect is subject to the
server's range, combat, and arena restrictions, so scoreboard data remains the
more reliable source after a match.

Download `TDArenaLens-0.1.0-alpha.2.zip` from **Assets**, extract it into
`Interface/AddOns`, and fully restart the game. The resulting path must be
`Interface/AddOns/TDArenaLens/TDArenaLens.toc`.

Read the full
[installation and test guide](https://github.com/TkachovDmitriy/coa-arena-addon/blob/v0.1.0-alpha.2/docs/installation.md).

Review diagnostic text before posting it publicly because it may contain your
character name, opponent names, equipment, rating, and MMR information.
