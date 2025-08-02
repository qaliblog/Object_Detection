#!/bin/bash

echo "=== Fixing AAPT2 Daemon Issues in Termux ==="

# Function to clean Gradle caches
clean_gradle_cache() {
    echo "Cleaning Gradle cache..."
    rm -rf ~/.gradle/caches/
    rm -rf .gradle/
    rm -rf app/build/
    echo "Gradle cache cleaned."
}

# Function to kill AAPT2 daemons
kill_aapt2_daemons() {
    echo "Killing any running AAPT2 daemons..."
    pkill -f aapt2 || true
    sleep 2
    echo "AAPT2 daemons killed."
}

# Function to set environment variables
set_environment() {
    echo "Setting environment variables..."
    export ANDROID_AAPT2_FROM_MAVEN_OVERRIDE=/data/data/com.termux/files/usr/bin/aapt2
    export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"
    echo "Environment variables set."
}

# Function to check if we're in Termux
check_termux() {
    if [[ -d "/data/data/com.termux" ]]; then
        echo "Detected Termux environment."
        
        # Check if aapt2 is available
        if [[ -f "/data/data/com.termux/files/usr/bin/aapt2" ]]; then
            echo "Termux aapt2 found at /data/data/com.termux/files/usr/bin/aapt2"
            return 0
        else
            echo "Warning: Termux aapt2 not found. Installing..."
            pkg install -y aapt2
            return 0
        fi
    else
        echo "Not in Termux environment, but applying fixes anyway."
        return 1
    fi
}

# Main execution
main() {
    check_termux
    
    echo "Applying AAPT2 fixes..."
    
    # Kill any running daemons
    kill_aapt2_daemons
    
    # Clean caches
    clean_gradle_cache
    
    # Set environment
    set_environment
    
    echo "=== AAPT2 Fixes Applied ==="
    echo "You can now try building with:"
    echo "./gradlew assembleDebug --no-daemon --no-parallel"
    echo ""
    echo "Or run this script before building:"
    echo "source ./fix_aapt2_issues.sh && ./gradlew assembleDebug"
}

# Run main function
main "$@"