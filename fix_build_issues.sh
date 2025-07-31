#!/bin/bash

echo "Fixing build issues for Menu App..."

# Function to check if Android SDK is installed
check_android_sdk() {
    local sdk_paths=(
        "/usr/local/android-sdk"
        "/usr/lib/android-sdk"
        "/opt/android-sdk"
        "$HOME/Android/Sdk"
        "$ANDROID_HOME"
    )
    
    for path in "${sdk_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "Found Android SDK at: $path"
            export ANDROID_HOME="$path"
            return 0
        fi
    done
    return 1
}

# Function to install Android SDK
install_android_sdk() {
    echo "Installing Android SDK..."
    
    # Try to install via package manager
    if command -v apt-get &> /dev/null; then
        echo "Attempting to install via apt..."
        sudo apt-get update
        sudo apt-get install -y android-sdk
        if [ $? -eq 0 ]; then
            export ANDROID_HOME="/usr/lib/android-sdk"
            return 0
        fi
    fi
    
    # Try to install via yum
    if command -v yum &> /dev/null; then
        echo "Attempting to install via yum..."
        sudo yum install -y android-sdk
        if [ $? -eq 0 ]; then
            export ANDROID_HOME="/usr/lib/android-sdk"
            return 0
        fi
    fi
    
    echo "Package manager installation failed. Please install manually:"
    echo "1. Download from: https://developer.android.com/studio#command-tools"
    echo "2. Extract to /usr/local/android-sdk"
    echo "3. Set ANDROID_HOME=/usr/local/android-sdk"
    return 1
}

# Function to configure network settings
configure_network() {
    echo "Configuring network settings..."
    
    # Create gradle.properties with network settings
    cat >> gradle.properties << EOF

# Network settings for better connectivity
systemProp.https.protocols=TLSv1.2,TLSv1.3
systemProp.http.connectionTimeout=60000
systemProp.http.socketTimeout=60000
systemProp.https.connectionTimeout=60000
systemProp.https.socketTimeout=60000
EOF
}

# Function to clean and rebuild
clean_and_build() {
    echo "Cleaning and rebuilding..."
    
    # Clean previous build
    ./gradlew clean
    
    # Try to build with different network settings
    echo "Attempting build with network optimizations..."
    ./gradlew build --no-daemon --parallel --max-workers=2
}

# Main execution
echo "=== Menu App Build Fix Script ==="

# Check if Android SDK is available
if check_android_sdk; then
    echo "Android SDK found at: $ANDROID_HOME"
else
    echo "Android SDK not found. Attempting to install..."
    if ! install_android_sdk; then
        echo "Failed to install Android SDK automatically."
        echo "Please install it manually and run this script again."
        exit 1
    fi
fi

# Configure network settings
configure_network

# Try to build
echo "Attempting to build the app..."
if clean_and_build; then
    echo "✅ Build successful!"
    echo "You can now install the app:"
    echo "./gradlew installDebug"
else
    echo "❌ Build failed. Trying alternative approaches..."
    
    # Try with different network settings
    echo "Trying with different network configuration..."
    export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"
    ./gradlew build --no-daemon --stacktrace
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful with alternative settings!"
    else
        echo "❌ Build still failed. Please check:"
        echo "1. Android SDK installation"
        echo "2. Network connectivity"
        echo "3. Java version (should be 11 or higher)"
        echo ""
        echo "Current environment:"
        echo "ANDROID_HOME: $ANDROID_HOME"
        echo "JAVA_HOME: $JAVA_HOME"
        echo "Java version: $(java -version 2>&1 | head -n 1)"
    fi
fi