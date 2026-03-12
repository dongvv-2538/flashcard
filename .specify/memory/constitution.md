<!--
## Sync Impact Report

**Version change**: (unversioned template) → 1.0.0
**Bump type**: MINOR (initial population — all sections created fresh)

### Principles

| Status   | Title                            |
|----------|----------------------------------|
| ✅ Added | I. Code Quality                  |
| ✅ Added | II. Testing Standards            |
| ✅ Added | III. User Experience Consistency |
| ✅ Added | IV. Performance Requirements     |

### Sections

- Added: Core Principles (4 principles — template 5th slot omitted per user request)
- Added: Quality Gates
- Added: Development Workflow
- Added: Governance

### Templates

| File                                   | Status                                                                |
|----------------------------------------|-----------------------------------------------------------------------|
| `.specify/templates/plan-template.md`  | ✅ No structural changes required; Constitution Check section aligns  |
| `.specify/templates/spec-template.md`  | ✅ Aligned; performance success criteria pattern already present      |
| `.specify/templates/tasks-template.md` | ✅ Updated — tests changed from OPTIONAL to REQUIRED per Principle II |
| `.github/agents/*.md`                  | ✅ No outdated CLAUDE-only or stale principle references found        |

### Deferred TODOs

None — all placeholders resolved.
-->

# Flashcard Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

All production code MUST meet the following standards before being merged:

- Code MUST pass all configured linter and formatter checks with zero errors.
- Functions and methods MUST be single-purpose; cyclomatic complexity MUST NOT exceed 10.
- Dead code, unused variables, and unused imports MUST NOT be committed.
- All pull requests MUST receive at least one peer review and approval before merge.
- Self-documenting naming MUST be used; inline comments are reserved for non-obvious logic only.

**Rationale**: Consistent code quality prevents technical debt accumulation and reduces
cognitive overhead for reviewers and future contributors.

### II. Testing Standards (NON-NEGOTIABLE)

All new code MUST be accompanied by appropriate tests:

- Unit tests MUST be written before or alongside implementation (TDD cycle: Red → Green → Refactor).
- Test coverage for new code MUST NOT fall below 80%.
- All public-facing APIs and user-visible flows MUST have integration tests.
- Tests MUST be deterministic; any flaky test MUST be fixed or deleted immediately — no skipping.
- Acceptance tests derived from user story acceptance scenarios MUST pass before a story is closed.

**Rationale**: Robust test coverage is the primary safety net against regressions and is
required to maintain velocity as the codebase grows.

### III. User Experience Consistency (NON-NEGOTIABLE)

All user-facing changes MUST adhere to the following:

- UI components MUST use the project's design system; one-off styles MUST be reviewed and approved.
- Terminology, layout patterns, and interaction feedback MUST be consistent across all screens and flows.
- Error messages MUST be human-readable, specific, and actionable — no raw error codes exposed to users.
- Accessibility MUST meet WCAG 2.1 Level AA as a minimum; keyboard navigation MUST be tested.
- Any change to a shared interaction pattern MUST be documented and communicated to the team.

**Rationale**: Inconsistent UX erodes user trust and increases support burden. A unified
experience is a product quality metric, not a stylistic preference.

### IV. Performance Requirements (NON-NEGOTIABLE)

All features MUST satisfy the following performance thresholds:

- Page or screen initial load MUST complete within 2 seconds on median hardware and standard broadband.
- API read endpoints MUST respond within 200ms at the 95th percentile (p95) under nominal load.
- Memory usage MUST NOT grow unboundedly; any feature processing large datasets MUST include
  profiling evidence before merge.
- Performance regressions introduced by a pull request MUST be accompanied by a trade-off analysis
  justifying the regression.
- Bundle size increases >10KB (gzipped) MUST be explicitly approved by a team lead.

**Rationale**: Flashcard is a study tool used in time-constrained study sessions. Sluggish
performance directly undermines the core user value proposition.

## Quality Gates

All pull requests MUST pass the following gates before merge. A failing gate blocks merge unless
an explicit exemption is documented in the PR and linked to a Complexity Tracking entry in the
feature plan.

- **Gate 1 — Lint & Format**: Zero linter errors; formatter applied (CI enforced).
- **Gate 2 — Test Coverage**: Coverage report shows ≥80% on changed/new lines.
- **Gate 3 — Integration Tests**: All integration and acceptance tests pass on CI.
- **Gate 4 — Performance Baseline**: No unexplained p95 latency regression >10% vs. main branch.
- **Gate 5 — UX Review**: Any UI change has been reviewed against the design system checklist.
- **Gate 6 — Peer Review**: At least one approved review from a team member other than the author.

## Development Workflow

The following workflow MUST be followed for all feature work:

1. **Spec first**: A feature specification MUST exist and be approved before implementation begins.
2. **Plan before code**: An implementation plan with Constitution Check MUST be completed and gated.
3. **TDD cycle**: Write failing tests → get approval → implement → refactor.
4. **Incremental delivery**: Each user story MUST be independently deliverable and testable.
5. **PR discipline**: PRs MUST be focused (single user story or task group); large PRs MUST be split.
6. **Constitution Check on PRs**: Every PR description MUST include a brief Constitution Check
   confirming compliance with all four principles (Code Quality, Testing Standards, UX Consistency,
   Performance Requirements).

## Governance

This Constitution supersedes all other documented practices when conflicts arise.

**Amendment procedure**:

1. Propose the amendment in writing with rationale and impact analysis.
2. Run the `speckit.constitution` agent to assess sync impact across templates and artifacts.
3. Obtain team approval (majority sign-off for MINOR/PATCH; unanimous for MAJOR).
4. Update all dependent artifacts identified in the Sync Impact Report.
5. Commit with message format: `docs: amend constitution to vX.Y.Z (<description>)`.

**Versioning policy** (semantic):

- MAJOR: Removal or backward-incompatible redefinition of a principle.
- MINOR: New principle or section added, or materially expanded guidance.
- PATCH: Wording clarification, typo fix, or non-semantic refinement.

**Compliance review**: Principles MUST be verified at each PR review. A quarterly compliance
review MUST assess whether principles remain appropriate and whether Quality Gates are enforced
consistently.

**Version**: 1.0.0 | **Ratified**: 2026-03-12 | **Last Amended**: 2026-03-12
