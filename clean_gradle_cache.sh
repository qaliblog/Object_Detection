#!/bin/bash

echo "=== Cleaning Gradle Cache to Fix Corruption Issues ==="

# Function to clean Gradle caches
clean_gradle_cache() {
    echo "Cleaning Gradle cache..."
    
    # Stop Gradle daemon
    echo "Stopping Gradle daemon..."
    ./gradlew --stop
    
    # Clean project build
    echo "Cleaning project build..."
    ./gradlew clean
    
    # Remove Gradle cache directories
    echo "Removing Gradle cache directories..."
    rm -rf ~/.gradle/caches/
    rm -rf ~/.gradle/daemon/
    rm -rf ~/.gradle/wrapper/dists/
    rm -rf .gradle/
    rm -rf app/build/
    rm -rf build/
    
    echo "Gradle cache cleaned successfully."
}

# Function to verify cleanup
verify_cleanup() {
    echo "Verifying cleanup..."
    if [[ ! -d "~/.gradle/caches" ]] && [[ ! -d ".gradle" ]] && [[ ! -d "app/build" ]]; then
        echo "✅ Cache cleanup verified successfully."
    else
        echo "⚠️  Some cache directories may still exist."
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "=== Next Steps ==="
    echo "1. Try building again:"
    echo "   ./gradlew assembleDebug --no-daemon --no-parallel"
    echo ""
    echo "2. If you're in Termux, also run:"
    echo "   ./fix_aapt2_issues.sh"
    echo ""
    echo "3. If issues persist, try:"
    echo "   ./gradlew assembleDebug --refresh-dependencies"
}

# Main execution
main() {
    echo "Starting Gradle cache cleanup..."
    
    # Clean cache
    clean_gradle_cache
    
    # Verify cleanup
    verify_cleanup
    
    # Show next steps
    show_next_steps
    
    echo "=== Gradle Cache Cleanup Complete ==="
}

# Run main function
main "$@"