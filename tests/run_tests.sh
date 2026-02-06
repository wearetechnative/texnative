#!/usr/bin/env bash
# Test runner script for texnative Lua unit tests
# Usage: ./run_tests.sh [options]
#
# Options:
#   --verbose    Show detailed test output
#   --coverage   Enable coverage reporting (if luacov installed)
#   -h, --help   Show this help message

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default options
VERBOSE=""
COVERAGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --coverage)
            COVERAGE="--coverage"
            shift
            ;;
        -h|--help)
            head -12 "$0" | tail -10
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

cd "$PROJECT_ROOT"

echo "Running texnative unit tests..."
echo "================================"

# Try running with nix-shell if busted is not directly available
if command -v busted &> /dev/null; then
    busted tests/unit/ $VERBOSE $COVERAGE
else
    # Use nix-shell to get busted
    nix-shell -p luaPackages.busted --run "busted tests/unit/ $VERBOSE $COVERAGE"
fi

echo ""
echo "================================"
echo "All tests completed successfully!"
