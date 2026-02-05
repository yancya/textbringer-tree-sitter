# CI Parser Setup Instructions

## Problem

Tests skip when tree-sitter parsers are not installed, leading to false-green builds in CI.

## Solution

Add a step to download parsers before running tests in your CI workflow.

## Required Changes to `.github/workflows/ci.yml`

Add the following step **before** the "Run tests" step:

```yaml
- name: Setup parsers for tests
  run: bundle exec rake parsers:download
```

### Complete Example

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: ['3.3', '3.4', '4.0']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby ${{ matrix.ruby-version }}
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
          bundler-cache: true

      - name: Setup parsers for tests
        run: bundle exec rake parsers:download

      - name: Run tests
        run: bundle exec rake test
```

## Available Rake Tasks

- `rake parsers:download` - Download prebuilt parsers (fastest, recommended for CI)
- `rake parsers:build` - Build parsers from source (requires compiler)
- `rake parsers:setup` - Download if possible, fall back to build

## Parsers Required for Tests

- `ruby` - For Ruby syntax highlighting tests
- `hcl` - For HCL/Terraform tests
- `markdown` - For Markdown integration tests

## Manual Setup (Development)

To run tests locally with parsers:

```bash
bundle exec rake parsers:download
bundle exec rake test
```

Or build from source:

```bash
./scripts/build_parsers.sh
bundle exec rake test
```

## Troubleshooting

If parser download fails in CI:
1. Check network connectivity to GitHub
2. Verify the Faveod/tree-sitter-parsers release version in `scripts/download_parsers.sh`
3. Fall back to building from source: `bundle exec rake parsers:build`

## References

- Issue: #20
- Parser source: https://github.com/Faveod/tree-sitter-parsers
