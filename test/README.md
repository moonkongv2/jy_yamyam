# Test organization

- Place tests in a file named for the production subject or user flow they cover.
- Keep helpers local to the consuming test file by default. Move a helper to
  `test/helpers/` only when multiple test files share the same setup or fixture.
- Prefer focused test files of about 1,000 lines or fewer. Split larger files by
  responsibility or user flow before they become catch-all suites.
- Keep app startup smoke coverage in `app_bootstrap_test.dart`.
