#!/usr/bin/env bash
# Test watch mode for PercyBrain
# Automatically runs tests when files change

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
WATCH_INTERVAL=${WATCH_INTERVAL:-2}  # Seconds between checks
TEST_COMMAND=${TEST_COMMAND:-"./tests/run-all-unit-tests.sh"}
WATCH_DIRS=${WATCH_DIRS:-"lua tests"}

# Track test state
LAST_HASH=""
LAST_STATUS=0
RUN_COUNT=0

# Function to get hash of all watched files
get_file_hash() {
    find $WATCH_DIRS -name "*.lua" -type f -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d' ' -f1
}

# Function to get changed files
get_changed_files() {
    local current_files=$(find $WATCH_DIRS -name "*.lua" -type f -exec md5sum {} \; 2>/dev/null | sort)
    if [ -n "$LAST_FILES" ]; then
        diff <(echo "$LAST_FILES") <(echo "$current_files") | grep ">" | cut -d' ' -f3
    fi
    LAST_FILES="$current_files"
}

# Function to run tests
run_tests() {
    RUN_COUNT=$((RUN_COUNT + 1))

    clear
    echo -e "${BOLD}${BLUE}🧪 Test Run #${RUN_COUNT}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⏱️  $(date '+%H:%M:%S') - Running tests...${NC}\n"

    # Run tests and capture both output and exit code
    local start_time=$(date +%s)
    if $TEST_COMMAND; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${GREEN}✅ All tests passing!${NC} (${duration}s)"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${RED}❌ Tests failed!${NC} (${duration}s)"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 1
    fi
}

# Function to show status line
show_status() {
    local status_icon="🟢"
    local status_text="${GREEN}passing${NC}"

    if [ $LAST_STATUS -ne 0 ]; then
        status_icon="🔴"
        status_text="${RED}failing${NC}"
    fi

    echo -e "\n${BOLD}${BLUE}👁️  Watching for changes...${NC} (Ctrl+C to stop)"
    echo -e "Status: $status_icon Tests are $status_text | Interval: ${WATCH_INTERVAL}s | Watching: ${WATCH_DIRS}"
}

# Trap Ctrl+C to exit cleanly
trap 'echo -e "\n${YELLOW}Stopped watching.${NC}"; exit 0' INT

# Print header
clear
echo -e "${BOLD}${BLUE}🔬 PercyBrain Test Watcher${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "Watching: ${BOLD}$WATCH_DIRS${NC}"
echo -e "Command: ${BOLD}$TEST_COMMAND${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Initial run
echo -e "${YELLOW}🚀 Starting initial test run...${NC}\n"
run_tests
LAST_STATUS=$?
LAST_HASH=$(get_file_hash)
LAST_FILES=$(find $WATCH_DIRS -name "*.lua" -type f -exec md5sum {} \; 2>/dev/null | sort)

show_status

# Watch loop
while true; do
    sleep $WATCH_INTERVAL

    CURRENT_HASH=$(get_file_hash)

    if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        # Get list of changed files
        CHANGED_FILES=$(get_changed_files)

        echo -e "\n${YELLOW}📝 Changes detected in:${NC}"
        echo "$CHANGED_FILES" | while read -r file; do
            if [ -n "$file" ]; then
                echo -e "  ${BLUE}→${NC} $(basename $file)"
            fi
        done
        echo ""

        if run_tests; then
            if [ $LAST_STATUS -ne 0 ]; then
                echo -e "${BOLD}${GREEN}🎉 Tests fixed!${NC}"
                # Optional: Desktop notification
                which notify-send >/dev/null 2>&1 && notify-send -u normal "✅ Tests Fixed" "All PercyBrain tests are now passing!"
            fi
            LAST_STATUS=0
        else
            if [ $LAST_STATUS -eq 0 ]; then
                echo -e "${BOLD}${RED}💔 Tests broken!${NC}"
                # Optional: Desktop notification
                which notify-send >/dev/null 2>&1 && notify-send -u critical "❌ Tests Broken" "Some PercyBrain tests are failing!"
            fi
            LAST_STATUS=1
        fi

        LAST_HASH=$CURRENT_HASH
        show_status
    fi
done
