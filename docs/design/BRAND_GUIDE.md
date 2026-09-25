# BabyShopHub Brand Guide

This is the provisional brand identity for the semester project. It gives the team a consistent starting point while the UI/UX designer prepares a final logo and visual system.

## Brand name

**BabyShopHub**

Use this spelling consistently in the app, documentation, screenshots, and presentation. Do not use `Baby Shop Hub`, `BabyshopHub`, or `Baby ShopHub` in user-facing text.

## Brand meaning

BabyShopHub is a friendly, dependable shopping hub for parents and caregivers. The visual identity should feel caring, calm, clear, and trustworthy rather than childish or overly decorative.

## Provisional logo mark

The current Flutter splash uses the scalable Material `child_care` icon inside a white circle. This is a temporary logo mark, not a final trademark logo. It is useful for development because it stays sharp on every screen size and requires no image download.

Final logo requirements:

- A simple baby-care symbol that remains recognizable at small sizes.
- A horizontal wordmark reading `BabyShopHub`.
- A square app-icon version for Android and iOS.
- Light-background and dark-background versions.
- SVG source plus PNG exports at 192 px, 512 px, and 1024 px.
- Transparent background around the mark.

## Colors

| Token | Hex | Use |
| --- | --- | --- |
| Brand pink | `#E86A92` | Splash background and primary brand accent |
| Logo white | `#FFFFFF` | Logo surface and text on the splash |
| Ink | `#26232A` | Primary text on light screens |
| Soft surface | `#FFF7F9` | Light pink-tinted surfaces |
| Success green | `#2E8B68` | Success states only |
| Error red | `#B3261E` | Error states only |

Do not add gradients to the splash screen. Keep its background a single solid `#E86A92`.

## Splash content

The splash should contain only:

- Centered logo mark.
- `BabyShopHub` brand name below the mark.
- Optional small `From BabyShopHub` line only if the team later chooses to show parent-company branding.

Do not add taglines, descriptions, buttons, links, menus, or product content to the splash screen.

## Splash behavior

- Show for approximately 0.9 to 1.2 seconds while no launch work is running.
- If real startup work later takes more than 2 seconds, add a subtle progress indicator.
- Keep the logo inside a square area sized from the shortest screen dimension.
- Do not stretch the logo or use a fixed full-screen image.
- Transition automatically to the first real screen.

## Asset handoff for the UI/UX designer

Create the final assets in `assets/brand/` and document them in this file. The Flutter developer should then register the assets in `pubspec.yaml` and replace the temporary Material icon after the team approves the final design.

## Ownership

- UI/UX Designer: final logo, typography, visual rules, and exports.
- Project/System Lead: approve the final brand decision and keep it consistent across documentation and presentation.
- Flutter Developer: integrate approved assets and preserve responsive splash behavior.
