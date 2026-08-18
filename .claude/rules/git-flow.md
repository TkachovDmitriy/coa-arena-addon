# Git Flow

Branching, commit, and merge-request rules for this repo. `develop` is the
integration branch and the default MR target; `main` is production. Never commit
directly to `develop` or `main`.

## Branching

- **Always branch from the latest `origin/develop`** — fetch first so you never
  start from a stale local copy:
  ```sh
  git fetch origin
  git switch -c <type>/<JIRA-KEY>-<short-desc> --no-track origin/develop
  ```
  `--no-track` avoids setting `origin/develop` as the upstream (which otherwise
  risks a bare `git push` going to `develop`).
- **Branch naming** — `<type>/<JIRA-KEY>-<short-desc>` where `<type>` is one of
  `feat`, `fix`, `chore` (also `docs`, `refactor`). The type prefix stays
  lowercase; the Jira key is **uppercase** (so it auto-links in GitLab/Jira and
  stays greppable). Use short, kebab-case descriptions, single hyphen — not a
  nested slash:
  ```
  feat/SON-123-deactivate-user-modal      ✅
  feat/SON-123/deactivate-user-modal       ❌ extra path segment; risks a Git
                                              D/F ref conflict with feat/SON-123
  feat/deactivate-user-modal               ⚠️ only when there is genuinely no ticket
  ```
- **One Jira key per branch name.** A branch name carries a single *anchor* key —
  see [Jira ticket references](#jira-ticket-references) for multi-ticket and epic
  cases.
- **One logical change per branch / MR.** Keep it focused and reviewable.
- Keep local `develop` fresh when you use it: `git switch develop && git pull --ff-only`.

## Commits

- **Bracketed type prefix + Jira key** in the subject (matches this repo's
  history): `[Feature]`, `[Fix]`, `[Docs]`, `[Chore]`, `[Refactor]`, `[Test]`,
  then the uppercase key. e.g. `[Feature] SON-123 add deactivate confirmation
  modal`. Keep it one concise line. (Note: this is the *title* convention —
  **branch** prefixes stay lowercase: `feat/*`, `fix/*`, `chore/*`.)
- **No `Co-Authored-By` trailer.**
- A longer commit body is encouraged for non-trivial work — it becomes the MR
  description automatically (see below).

## Jira ticket references

Put the **uppercase Jira key** (e.g. `SON-123`) in *both* the branch name and the
commit/MR title. Findability is the reason: the branch name only survives in
`git log` because this repo merges with merge commits (`Merge branch
'feat/SON-123-...'`); the title survives regardless of merge strategy. With the
key in both, `git log --grep="SON-123"` is reliable no matter how the MR landed,
and GitLab/Jira auto-link it. Always uppercase — Jira keys are case-sensitive and
lowercase won't auto-link.

The rule splits by *where the data fits*: a branch name can only hold one readable
key, so the full list of tickets lives in the title and MR body.

- **Single ticket (default, preferred).** One ticket → one small branch → one MR.
  - Branch: `feat/SON-123-rights-splits`
  - Title: `[Feature] SON-123 rights splits`
  - MR body: `Closes SON-123`

- **A few related tickets in one branch.** Anchor the branch and title on the
  primary key; list *every* ticket in the MR body so each is greppable and
  auto-closes:
  - Branch: `feat/SON-123-rights-splits` (primary key only)
  - Title: `[Feature] SON-123 rights splits`
  - MR body:
    ```
    Closes SON-123
    Closes SON-124
    Closes SON-125
    ```
  - ⚠️ Needing 3+ tickets in one branch usually means the MR is too big — split it
    unless the change genuinely can't be (e.g. a shared refactor across stories).

- **A whole epic.** Don't make one giant epic branch — the epic lives in Jira, and
  each child story gets its own small branch/MR that rolls up under it:
  - `feat/SON-124-add-role-picker`, `feat/SON-125-role-validation`, … merged
    independently.
  - Only use an epic-scoped integration branch (`feat/SON-100-user-management`,
    child branches targeting *it* instead of `develop`) when the epic ships as one
    atomic, flag-gated release — it reintroduces a long-lived branch, so avoid it
    by default.

## Pushing

- Push to a **same-named remote branch** and set upstream:
  ```sh
  git push -u origin HEAD
  ```
- Optionally create the MR in the same push (GitLab push options):
  ```sh
  git push -u origin HEAD \
    -o merge_request.create \
    -o merge_request.target=develop \
    -o merge_request.remove_source_branch
  ```

## Merge requests

- **Target `develop`.** Use the `.gitlab/merge_request_templates/Default.md`
  template (auto-filled in the web UI).
- **CLI-created MRs must use the same template** as the web UI. The web form
  auto-fills `Default.md`, but `git push` does **not** — so seed the description
  from the template file explicitly via push options, then fill in the sections.
  **Prefer `git` push options (not `glab`) for now:**
  ```sh
  git push -u origin HEAD \
    -o merge_request.create \
    -o merge_request.target=develop \
    -o merge_request.description="$(cat .gitlab/merge_request_templates/Default.md)"
  ```
- MR description sources (any one): the template (web UI, or seeded via the push
  option above) or the commit body (single-commit branches). Whatever you pass on
  the CLI overrides the auto-filled template — so pass the template itself.
- Title uses the bracketed type prefix **+ Jira key**, e.g.
  `[Chore] SON-123 add gitlab merge request template`. Fill the template's
  `Jira:` field, and add `Closes SON-XXX` in the body for every ticket the MR
  resolves (see [Jira ticket references](#jira-ticket-references)).
- **Delete the source branch on merge.**

## Never rewrite shared history

- **Do not `--amend`, `rebase`, or force-push a commit that is already pushed or
  merged** (especially merge commits on `develop`). Amend only local, unpushed
  commits on your own branch.
- If a change is already merged and needs a follow-up, **create a new branch +
  MR** — never edit the merged commit.
- If local history gets tangled, recover via `git reflog` and reset your branch
  back to `origin/develop`; don't push the tangle.

## Quick reference

| Goal | Command |
|---|---|
| New branch (recommended) | `git fetch && git switch -c feat/SON-123-x --no-track origin/develop` |
| Refresh local develop too | `git fetch && git switch develop && git pull --ff-only && git switch -c feat/SON-123-x` |
| Push + set upstream | `git push -u origin HEAD` |
| Push + open MR → develop | `git push -u origin HEAD -o merge_request.create -o merge_request.target=develop` |
| Same, seeding the template | add `-o merge_request.description="$(cat .gitlab/merge_request_templates/Default.md)"` |
| ❌ Avoid | branching off stale local `develop`; nested-slash branch names (`feat/SON-123/x`); lowercase Jira keys; amending/force-pushing merged commits |
