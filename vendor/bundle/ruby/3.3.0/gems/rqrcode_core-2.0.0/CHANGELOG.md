# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2025-04-24

- Various README updates
- Fix for issue #43
- Fix for issue #42
- Drop Ruby < 3 to keep up with dependency updates
- Add option to use ENV `RQRCODE_CORE_ARCH_BITS` to override the bits value (32 or 64) used during the encoding process.
  This has been shown to greatly reduce the memory usage but I can't prove it doesn't break anything for all people.
  Use at your own risk.
- Fixed the 'Do Your Own Rendering' example code to reflect the current interface.

## [1.2.0] - 2021-08-26

- Added Multi Mode Support which allows for multi-segment encoding. Thanks to [@ssayer](https://github.com/ssayer)

## [1.1.0] - 2021-07-01

- Add a basic benchmark file
- Add standardRB badge
- Add `.freeze` on `CONST` lookup objects
- Remove unused `@mode` instance variable
- A batch of small refactors and optimizations

## [1.0.0] - 2021-04-23

### Changed

- README updated
- Small documentation clarification [@smnscp](https://github.com/smnscp).
- Rakefile cleaned up. You can now just run `rake` which will run specs and fix linting using `standardrb`

### Breaking Changes

- Very niche but a breaking change never the less. The `to_s` method _no longer_ accepts the `:true` and `:false` arguments, but prefers `:dark` and `:light`.

## [0.2.0] - 2020-12-26

### Changed

- fix `required_ruby_version` for Ruby 3 support

[unreleased]: https://github.com/whomwah/rqrcode_core/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/whomwah/rqrcode_core/compare/v1.2.0...2.0.0
[1.2.0]: https://github.com/whomwah/rqrcode_core/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/whomwah/rqrcode_core/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/whomwah/rqrcode_core/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/whomwah/rqrcode_core/compare/v0.1.2...v0.2.0
