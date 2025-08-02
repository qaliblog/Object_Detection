#!/bin/bash

echo "Fixing SQLite native library issue for Termux environment..."

# Function to check if we're in Termux
check_termux() {
    if [ -d "/data/data/com.termux" ]; then
        echo "Detected Termux environment"
        return 0
    else
        echo "Not in Termux environment"
        return 1
    fi
}

# Function to set up environment variables for SQLite
setup_sqlite_env() {
    echo "Setting up SQLite environment variables..."
    
    # Set environment variables to avoid SQLite native library issues
    export SQLITE_ENABLE_LOAD_EXTENSION=false
    export SQLITE_ENABLE_LEGACY_LOAD_EXTENSION=false
    
    # Set Java system properties
    export GRADLE_OPTS="$GRADLE_OPTS -Dsqlite.enable.load.extension=false"
    export GRADLE_OPTS="$GRADLE_OPTS -Dsqlite.enable.legacy.load.extension=false"
    
    # Set JVM options to avoid native library loading
    export JAVA_OPTS="$JAVA_OPTS -Dsqlite.enable.load.extension=false"
    export JAVA_OPTS="$JAVA_OPTS -Dsqlite.enable.legacy.load.extension=false"
    
    echo "Environment variables set:"
    echo "SQLITE_ENABLE_LOAD_EXTENSION: $SQLITE_ENABLE_LOAD_EXTENSION"
    echo "GRADLE_OPTS: $GRADLE_OPTS"
    echo "JAVA_OPTS: $JAVA_OPTS"
}

# Function to clean and rebuild with SQLite fixes
clean_and_build() {
    echo "Cleaning previous build artifacts..."
    ./gradlew clean
    
    echo "Building with SQLite fixes..."
    ./gradlew build --no-daemon --parallel --max-workers=2 \
        -Dsqlite.enable.load.extension=false \
        -Dsqlite.enable.legacy.load.extension=false
}

# Function to create a backup of original files
backup_files() {
    echo "Creating backups of original files..."
    cp app/build.gradle app/build.gradle.backup
    cp build.gradle build.gradle.backup
    cp gradle.properties gradle.properties.backup
    echo "Backups created successfully"
}

# Function to restore original files
restore_files() {
    echo "Restoring original files..."
    if [ -f "app/build.gradle.backup" ]; then
        mv app/build.gradle.backup app/build.gradle
    fi
    if [ -f "build.gradle.backup" ]; then
        mv build.gradle.backup build.gradle
    fi
    if [ -f "gradle.properties.backup" ]; then
        mv gradle.properties.backup gradle.properties
    fi
    echo "Original files restored"
}

# Main execution
echo "=== SQLite Issue Fix Script ==="

# Check if we're in Termux
if check_termux; then
    echo "Applying Termux-specific fixes..."
else
    echo "Not in Termux, but applying fixes anyway..."
fi

# Create backups
backup_files

# Set up environment
setup_sqlite_env

# Try to build
echo "Attempting to build with SQLite fixes..."
if clean_and_build; then
    echo "✅ Build successful with SQLite fixes!"
    echo "The SQLite native library issue has been resolved."
    echo ""
    echo "You can now:"
    echo "- Run: ./gradlew installDebug"
    echo "- Run: ./gradlew assembleRelease"
else
    echo "❌ Build still failed. Trying alternative approach..."
    
    # Try with more aggressive settings
    echo "Trying with more aggressive SQLite settings..."
    export GRADLE_OPTS="$GRADLE_OPTS -Dorg.gradle.daemon=false"
    export GRADLE_OPTS="$GRADLE_OPTS -Dorg.gradle.parallel=false"
    
    ./gradlew build --no-daemon --stacktrace \
        -Dsqlite.enable.load.extension=false \
        -Dsqlite.enable.legacy.load.extension=false \
        -Dorg.gradle.daemon=false \
        -Dorg.gradle.parallel=false
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful with aggressive settings!"
    else
        echo "❌ Build still failed. Restoring original files..."
        restore_files
        echo ""
        echo "The issue might be related to:"
        echo "1. Java version compatibility"
        echo "2. Android SDK installation"
        echo "3. Network connectivity"
        echo ""
        echo "Please try:"
        echo "1. Update Java to version 11 or higher"
        echo "2. Check Android SDK installation"
        echo "3. Run: ./gradlew --version"
        exit 1
    fi
fi

echo ""
echo "✅ SQLite issue fix completed successfully!"
echo "The build should now work without SQLite native library errors."