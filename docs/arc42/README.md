# HealthKitReporter — Architecture Documentation (arc42)

This set describes the architecture of HealthKitReporter following the [arc42](https://arc42.org) template.
It is derived from the code in `Sources/`, `Tests/`, `Example/` and `.github/workflows/`; where the code and
these pages disagree, the code wins and the page is a bug.

| # | Chapter | Content |
| :--- | :--- | :--- |
| 1 | [Introduction and Goals](01-introduction-and-goals.md) | Purpose, quality goals, stakeholders |
| 2 | [Architecture Constraints](02-architecture-constraints.md) | Platform, distribution, contract and conventions |
| 3 | [Context and Scope](03-context-and-scope.md) | Business and technical context |
| 4 | [Solution Strategy](04-solution-strategy.md) | The few decisions that shape everything else |
| 5 | [Building Block View](05-building-block-view.md) | Facade, services, types, payloads, decorators |
| 6 | [Runtime View](06-runtime-view.md) | Read, write, observe and multi-step retrieval |
| 7 | [Deployment View](07-deployment-view.md) | SwiftPM distribution, CI and release |
| 8 | [Crosscutting Concepts](08-crosscutting-concepts.md) | Harmonization, units, errors, availability, concurrency |
| 9 | [Architecture Decisions](09-architecture-decisions.md) | Index of the ADRs in `docs/adr/` |
| 10 | [Quality Requirements](10-quality-requirements.md) | Quality tree and scenarios |
| 11 | [Risks and Technical Debt](11-risks-and-technical-debt.md) | Known risks and debt |
| 12 | [Glossary](12-glossary.md) | Ubiquitous language |

Diagrams are Mermaid (C4-style flowcharts and sequence diagrams) and render inline on GitHub.
