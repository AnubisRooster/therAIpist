# GitNexus local hooks

Activates a background knowledge-graph refresh on every `git commit` and
`git pull`/`merge`.

One-time activation per clone:

```sh
git config core.hooksPath githooks
```

Requires the GitNexus CLI (`npm install -g gitnexus`). If the CLI is absent the
hooks silently no-op, so cloning on a machine without GitNexus never breaks.
Re-index runs are logged to `.gitnexus/hook.log`.
