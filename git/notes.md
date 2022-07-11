# Git

**Helpful Commands**:

- `git show <commit-ID>` shows what changed
- `git diff` shows what will change
  - If `git add .` has already been run, you need `git diff --cached`
- `git restore --staged <files>` will unstage (undo `git add .`) files from ready change
- `git revert HEAD` will make a new commit that is actually just 1 previous of current
  - You can `git revert <commit ID>` to make a new commit restoring the specified location
  - Revert keeps the history, even though you technically rolled back / restored and old commit
- `git reset --hard <commit ID>` resets to the specified commit and does not keep the history