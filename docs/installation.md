# Installing the TD ArenaLens test release

This is an early test release for Conquest of Azeroth. It stores data only in
World of Warcraft's local `SavedVariables` and does not send anything over the
internet. Backing up your `WTF` folder before testing is recommended.

## Install

1. Fully exit World of Warcraft.
2. Open the TD ArenaLens release page on GitHub and download
   `TDArenaLens-<version>.zip` from the **Assets** section. Do not download the
   automatically generated "Source code" archives.
3. Open the CoA client folder, then open `Interface/AddOns` inside it.
4. Extract the downloaded ZIP directly into `AddOns`.
5. Confirm that the manifest is located at
   `Interface/AddOns/TDArenaLens/TDArenaLens.toc`.
6. Start the game. On the character-selection screen, click **AddOns** and make
   sure **TD ArenaLens** is enabled.

There must not be an extra directory level such as
`AddOns/TDArenaLens-0.1.0-alpha.1/TDArenaLens/`. The directory containing
`TDArenaLens.toc` must be named exactly `TDArenaLens`.

## Verify the installation

Run these commands in the in-game chat:

```text
/tdlens about
/tdlens debug
```

The first command should display the addon name, author, and installed version.
The second should display the current capture state. Open match history with
`/tdlens` or a left-click on the minimap button. Open the diagnostic window
with `/tdlens log` or a right-click on the minimap button.

Enable Lua error reporting while testing:

```text
/console scriptErrors 1
/reload
```

Play an arena skirmish or rated arena, open `/tdlens`, and check the result,
opponents, and rating change. Run `/reload` afterward and confirm that the match
remains in history. If an error occurs or the recorded data is incorrect, copy
the text from `/tdlens log`. Review it before posting publicly because it may
contain your character name and opponent names.

## Update

1. Fully exit the game.
2. Optionally back up the `WTF` folder.
3. Replace the old `Interface/AddOns/TDArenaLens` directory with the
   `TDArenaLens` directory from the new release ZIP.
4. Start the game and verify the new version with `/tdlens about`.

Do not remove `WTF` if you want to keep match history. Replacing the addon files
does not remove its `SavedVariables`.

## Uninstall

Fully exit the game and remove `Interface/AddOns/TDArenaLens`. To remove the
saved data as well, find the `TDArenaLens.lua` files under
`WTF/Account/.../SavedVariables` and delete them only after making any backup
you want to keep.
