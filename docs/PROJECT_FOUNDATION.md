# BabyShopHub Project Foundation

This document defines the handoff from the Project/System Lead to the feature teams. It does not implement product features.

## Repository ownership

- `lib/`, `android/`, `ios/`, `web/`: Flutter team
- `backend/`: Backend Lead
- `database/`: Database/System Analyst
- `docs/design/`: UI/UX Designer
- `docs/testing/`: QA/Documentation Lead
- `docs/api/`: Backend and Project Lead together
- `docs/requirements/` and `docs/diagrams/`: System Lead and Database Analyst

## System boundary

```text
Flutter mobile app -> Spring Boot REST API -> MySQL
                         |
                         +-> Spring Security/JWT
```

Flutter owns presentation, navigation, form validation, loading states, and API client behavior. Spring Boot owns authentication, authorization, validation, business rules, and REST responses. MySQL owns persistent data and relational constraints.

## Initial modules

1. Authentication and users
2. Categories and products
3. Cart and checkout
4. Orders and tracking
5. Reviews and ratings
6. Support
7. Administration

Feature teams should implement modules on feature branches and merge through pull requests into `develop`.

## First handoff contracts

Backend should expose a health endpoint and document the first product read endpoint. Database should provide the initial ERD, schema, and seed data. Flutter should establish folders, navigation, theme, and screen placeholders without assuming final API details. QA should create the test-plan template and issue format.

Suggested first API contract:

- `GET /api/health` -> `{ "status": "UP" }`
- `GET /api/products` -> paginated product summaries
- `GET /api/products/{id}` -> one product detail

The exact response fields must be agreed in `docs/api/` before Flutter integration.

## Branch rules

- `main` is stable and accepts reviewed pull requests only.
- `develop` is the integration branch.
- Use `feature/<short-name>` branches.
- Keep commits focused and run tests before opening a pull request.
- Never commit credentials, JWT secrets, database passwords, or `.env` files.

## Definition of done

A task is complete when its requirements are implemented, tested, documented where needed, reviewed in a pull request, merged into `develop`, and accepted by the Project/System Lead.

## Foundation exit criteria

- Every team member can clone the repository and identify their owned directory.
- `develop` exists and is the integration target.
- Backend, database, API, design, and testing handoff documents exist.
- Flutter analyzer and the starter test pass.
- Initial architecture and API decisions are documented before feature integration.
