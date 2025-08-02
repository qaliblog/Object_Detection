#!/bin/bash

echo "=== Fixing SQLite Native Library Issue in Termux ==="

# Check if we're running in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo "This script is designed for Termux environment."
    echo "If you're not using Termux, the issue might be different."
fi

# Function to install required packages
install_required_packages() {
    echo "Installing required packages..."
    
    # Update package list
    pkg update -y
    
    # Install SQLite and related packages
    pkg install -y sqlite
    
    # Install additional libraries that might be needed
    pkg install -y libsqlite
    
    echo "Packages installed successfully."
}

# Function to set up environment variables
setup_environment() {
    echo "Setting up environment variables..."
    
    # Add Termux lib directory to library path
    export LD_LIBRARY_PATH="/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH"
    export JAVA_LIBRARY_PATH="/data/data/com.termux/files/usr/lib"
    
    # Create a symlink if needed
    if [ ! -f "/data/data/com.termux/files/usr/lib/libsqlite3.so" ]; then
        echo "Creating SQLite library symlink..."
        ln -sf /data/data/com.termux/files/usr/lib/libsqlite3.so.0 /data/data/com.termux/files/usr/lib/libsqlite3.so
    fi
    
    echo "Environment variables set."
}

# Function to clean and rebuild
clean_and_rebuild() {
    echo "Cleaning previous build artifacts..."
    
    # Clean Gradle cache
    ./gradlew clean
    
    # Remove problematic cache directories
    rm -rf .gradle/caches/
    rm -rf build/
    rm -rf app/build/
    
    echo "Clean completed. Attempting rebuild..."
    
    # Try building with specific JVM options
    export GRADLE_OPTS="-Djava.library.path=/data/data/com.termux/files/usr/lib -Dorg.sqlite.lib.path=/data/data/com.termux/files/usr/lib"
    
    # Build with reduced parallelism to avoid conflicts
    ./gradlew assembleDebug --no-daemon --parallel=false --max-workers=1
}

# Function to try alternative approaches
try_alternative_approaches() {
    echo "Trying alternative approaches..."
    
    # Approach 1: Disable kapt for problematic dependencies
    echo "Approach 1: Building without kapt..."
    ./gradlew assembleDebug --no-daemon -PdisableKapt=true
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful without kapt!"
        return 0
    fi
    
    # Approach 2: Use specific JVM options
    echo "Approach 2: Using specific JVM options..."
    export JAVA_OPTS="-Djava.library.path=/data/data/com.termux/files/usr/lib -Dorg.sqlite.lib.path=/data/data/com.termux/files/usr/lib -Djava.security.egd=file:/dev/./urandom"
    ./gradlew assembleDebug --no-daemon --stacktrace
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful with JVM options!"
        return 0
    fi
    
    # Approach 3: Try with different Gradle settings
    echo "Approach 3: Using minimal Gradle settings..."
    export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.configureondemand=false"
    ./gradlew assembleDebug --no-daemon --stacktrace
    
    return $?
}

# Main execution
echo "Starting SQLite fix process..."

# Install required packages
install_required_packages

# Setup environment
setup_environment

# Try the main build approach
echo "Attempting main build approach..."
if clean_and_rebuild; then
    echo "✅ Build successful!"
    echo "Your APK should be available at: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ Main build approach failed. Trying alternatives..."
    
    if try_alternative_approaches; then
        echo "✅ Build successful with alternative approach!"
        echo "Your APK should be available at: app/build/outputs/apk/debug/app-debug.apk"
    else
        echo "❌ All build approaches failed."
        echo ""
        echo "Troubleshooting steps:"
        echo "1. Make sure you have the latest version of Termux"
        echo "2. Try updating all packages: pkg update && pkg upgrade"
        echo "3. Check if SQLite is properly installed: sqlite3 --version"
        echo "4. Verify library path: ls -la /data/data/com.termux/files/usr/lib/libsqlite*"
        echo "5. Try building with: ./gradlew assembleDebug --stacktrace --info"
        echo ""
        echo "If the issue persists, you might need to:"
        echo "- Use a different SQLite implementation"
        echo "- Disable Room database temporarily"
        echo "- Use a different build environment"
    fi
fi