.PHONY: build test run lint lint-fix

build:          ## Build the simulator
	swift build

test:           ## Run tests
	swift test

run:            ## Run the simulator
	swift run

lint:           ## Run SwiftLint
	swiftlint

lint-fix:       ## Run SwiftLint with auto-fix
	swiftlint --fix
