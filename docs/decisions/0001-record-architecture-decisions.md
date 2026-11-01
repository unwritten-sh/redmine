# 0001. Record architecture decisions

- Status: accepted
- Date: 2026-11-01

## Context

Redmine is about twenty years old. Many choices (database support, the asset pipeline, how plugins load) are visible in the code but the reasons are only in issues on www.redmine.org. Agents and new contributors need the reasons next to the code.

## Decision

We keep one short Markdown file per decision in `docs/decisions/`, numbered `NNNN-title-in-kebab-case.md`. Each file has three sections:

- **Context**: the problem and the forces at play.
- **Decision**: what we chose, in one or two paragraphs.
- **Consequences**: what gets easier, what gets harder, what to watch.

A record that was reconstructed from the code says so in its status line: "Inferred from the code, to be confirmed by the team." A decision that changes replaces the old record with a new one; the old record gets the status "superseded by NNNN".

## Consequences

- A change that makes or reverses an architectural choice adds a record in the same change.
- Records are short. Detail stays in the code, in `docs/architecture.md` or in the linked redmine.org issue.
