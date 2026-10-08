# BabyShopHub Frontend Foundation

This repository contains the Flutter client for BabyShopHub. The app owns its screens, navigation, input handling, client-side validation, loading and error states, and API client behavior. Backend services are maintained separately and are not part of this repository.

## Repository ownership

- `lib/`: Flutter application and feature code
- `assets/`: App images and other bundled resources
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: Flutter platform hosts
- `test/`: Flutter tests
- `docs/design/`: UI and brand guidance

## Application modules

1. Authentication and profiles
2. Categories and products
3. Cart and checkout
4. Orders and tracking
5. Reviews and ratings
6. Support
7. Administration

Use feature branches and reviewed pull requests for changes to the app.

## Branch rules

- `main` is stable and accepts reviewed pull requests only.
- `develop` is the integration branch.
- Use `feature/<short-name>` branches.
- Keep commits focused and run tests before opening a pull request.
- Never commit credentials, JWT secrets, database passwords, or `.env` files.

## Definition of done

A task is complete when its requirements are implemented, tested, documented where needed, and reviewed in a pull request. Run Flutter analysis and relevant tests before submitting changes.
