# notes/

Design scratchpads: one file per topic (`<topic>-ideas.md`). This is where reasoning, options that were turned down, and worked numbers live.

- Debate here, not in `SPEC.md`.
- Once something is decided, merge the decision into `SPEC.md`, add the file to SPEC's "Sources merged" line with the date, and add a ROADMAP decisions-log entry. If the decision is hard to reverse, surprising, and a real trade-off, also write an ADR in `docs/adr/` and link it from that entry. New terms go in `GLOSSARY.md`.
- Keep the file afterwards: it explains *why*. `SPEC.md` wins on conflicts.
- Claude reads a note only when a task points to it.
