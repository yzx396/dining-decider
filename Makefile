# Dining Decider - Development Commands
# Usage: make <target>

.PHONY: test test-unit test-fast test-coverage build clean help

# Default simulator - uses iPhone 17 Pro (iOS 26.1+)
DESTINATION := platform=iOS Simulator,name=iPhone 17 Pro

# Default target
help:
	@echo "Available commands:"
	@echo "  make test          - Run all tests with code coverage"
	@echo "  make test-unit     - Run unit tests only (no UI tests)"
	@echo "  make test-fast     - Run unit tests without coverage (fastest)"
	@echo "  make test-coverage - Run tests and show coverage report"
	@echo "  make build         - Build the app for debug"
	@echo "  make build-release - Build the app for release"
	@echo "  make clean         - Clean build artifacts"

# Run all tests with coverage
test:
	xcodebuild test \
		-scheme DiningDecider \
		-destination '$(DESTINATION)' \
		-enableCodeCoverage YES \
		-parallel-testing-enabled YES \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty --color || true

# Run unit tests only (skip UI tests)
test-unit:
	xcodebuild test \
		-scheme DiningDecider \
		-destination '$(DESTINATION)' \
		-only-testing:DiningDeciderTests \
		-parallel-testing-enabled YES \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty --color || true

# Fast test run without coverage (for development)
test-fast:
	xcodebuild test \
		-scheme DiningDecider \
		-destination '$(DESTINATION)' \
		-only-testing:DiningDeciderTests \
		-parallel-testing-enabled YES \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | grep -E '(Test case|passed|failed|error:)' || true

# Run tests with coverage report
test-coverage:
	@echo "Running tests with coverage report..."
	xcodebuild test \
		-scheme DiningDecider \
		-destination '$(DESTINATION)' \
		-enableCodeCoverage YES \
		-resultBundlePath /tmp/TestResults.xcresult \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty --color || true
	@echo "\n=== Code Coverage Report ==="
	@xcrun xccov view --report /tmp/TestResults.xcresult 2>/dev/null | head -30 || echo "Coverage report generation failed"

# Build for debug
build:
	xcodebuild build \
		-scheme DiningDecider \
		-destination '$(DESTINATION)' \
		-configuration Debug \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty --color

# Build for release
build-release:
	xcodebuild build \
		-scheme DiningDecider \
		-destination 'generic/platform=iOS' \
		-configuration Release \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty --color

# Clean build artifacts
clean:
	xcodebuild clean -scheme DiningDecider
	rm -rf ~/Library/Developer/Xcode/DerivedData/DiningDecider-*
	rm -rf /tmp/TestResults.xcresult
	@echo "Build artifacts cleaned"
