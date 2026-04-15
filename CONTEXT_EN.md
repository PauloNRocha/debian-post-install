# Project Context - Debian Post-Install

## Goal

Maintain a small and auditable Debian 13 post-install toolkit focused on desktop and workstation setups.

The project is no longer trying to cover every Debian release or every possible machine profile. Each module must have:

- a clear scope;
- predictable behavior;
- explicit logging;
- minimal surprise.

## Current scope

- Debian 13 only.
- `deb822` as the preferred APT layout, while still accepting classic `sources.list` on Debian 13.
- Modular scripts orchestrated by `install.sh`.
- Shared helpers in `lib/common.sh`.

## Maintenance rules

- Prefer Debian packages by default.
- Third-party repositories must be opt-in and documented.
- Do not use remote shell pipelines as the default installation path.
- Do not claim support for flows that are not tested.
- Keep README and changelog aligned with the real repository state.
