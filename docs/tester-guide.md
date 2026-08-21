# How to test TD ArenaLens

Thank you for helping test TD ArenaLens. You do not need any programming
knowledge or GitHub access. You only need to install the addon, play a few
arena matches, and send the results through Discord.

This is an early test version. The addon stores its data locally in World of
Warcraft and does not send anything over the internet automatically.

## 1. Install the addon

1. Fully exit World of Warcraft.
2. Download the release ZIP from the link I send you. Download the file with a
   name such as `TDArenaLens-0.1.0-alpha.1.zip`, not a **Source code** archive.
3. Open your Conquest of Azeroth client folder, then open `Interface/AddOns`.
4. Extract the ZIP into the `AddOns` folder.
5. Confirm that the addon file is located at exactly:

   ```text
   Interface/AddOns/TDArenaLens/TDArenaLens.toc
   ```

   If you instead have a path such as
   `AddOns/TDArenaLens-0.1.0-alpha.1/TDArenaLens/`, move the inner
   `TDArenaLens` folder directly into `AddOns`.
6. Start the game. On the character-selection screen, click **AddOns** and
   make sure **TD ArenaLens** is enabled.

## 2. Prepare for the test

Log in to your character and enter these commands in the game chat, one at a
time:

```text
/console scriptErrors 1
/reload
/tdlens about
/tdlens debug on
```

The `/tdlens about` command should show the addon name and installed version.
The `/tdlens debug on` command enables detailed diagnostic logging.

## 3. Test an arena match

1. Play an arena match normally. Please test an arena skirmish, a rated arena,
   or both if they are available to you.
2. After the match ends, enter:

   ```text
   /tdlens
   ```

3. Check whether the match result and opponents were recorded. For a rated
   arena, also check the displayed rating change.
4. Do not use `/reload` or exit the game until you have copied the diagnostic
   log.

## 4. Send the result

Immediately after each arena match, enter:

```text
/tdlens arena export
/tdlens log
```

In the diagnostic log window:

1. Click **Select All**.
2. Press `Ctrl+C`.
3. Paste the copied text into a private Discord message to me.

Please include this short report with the log:

```text
Type: skirmish / rated
Result: win / loss
Was the match recorded correctly: yes / no
What was incorrect, if anything:
```

If a Lua error window appears, take a screenshot or copy its text and send
that as well.

The report may contain your character name and the names of opponents. You can
review it before sharing it. Sending it through a private Discord message is
fine.

## Important notes

- The diagnostic log is cleared by `/reload`, exiting the game, or logging in
  again. Copy it immediately after each arena match.
- Match history should remain saved after `/reload`. Once you have sent the
  log, you can run `/reload`, open `/tdlens` again, and tell me whether the
  match is still present.
- If the addon does not appear in the addon list or `/tdlens` does not work,
  send me a screenshot of your `Interface/AddOns/TDArenaLens` folder.
- You do not need to send passwords, account details, game files, or your
  entire `WTF` folder.
