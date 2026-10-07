// Single source of truth for the palette.
//
// This file used to declare a second, conflicting `AppColors` class
// (`pink` was `0xFFF5A6AE` here vs `0xFFFF6D93` in `lib/core/app_colors.dart`).
// Two same-named classes with different values is a runtime ambiguity, so this
// now re-exports the canonical definition instead of redeclaring it.
//
// The `show` clause keeps the public surface identical to the old class, so
// every existing `import '.../core/theme/app_colors.dart'` still compiles.
export '../app_colors.dart' show AppColors;
