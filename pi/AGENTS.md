# Global Agent Instructions

<!-- rtk-instructions v2 -->
## RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

### Rule

Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

### Meta commands (use directly)

```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```
<!-- /rtk-instructions -->

## Repository organization (EROAD work only)

These rules apply **only to EROAD-related repositories and work**. Non-EROAD
personal projects are not governed by this section.

- Clone all repositories under `/Users/josuebadenas/local-development`; never clone or move work repositories directly under `/Users/josuebadenas` or `/Users/josuebadenas/local/git`.
- Put EROAD repositories in the local EROAD monorepo area: `/Users/josuebadenas/local-development/eroad/repos`.
- Put all non-EROAD repositories in `/Users/josuebadenas/local-development/personal`.
- Before cloning, check whether the destination repo already exists in the correct area and reuse it instead of creating duplicates.
