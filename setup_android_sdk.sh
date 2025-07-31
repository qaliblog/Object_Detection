#!/bin/bash

echo "Setting up Android SDK for Menu App..."

# Check if Android SDK is already installed
if [ -d "/usr/local/android-sdk" ]; then
    echo "Android SDK found at /usr/local/android-sdk"
    export ANDROID_HOME=/usr/local/android-sdk
else
    echo "Android SDK not found. Please install it first:"
    echo ""
    echo "Option 1: Install via package manager (Ubuntu/Debian)"
    echo "sudo apt update"
    echo "sudo apt install android-sdk"
    echo ""
    echo "Option 2: Download from Google"
    echo "1. Go to https://developer.android.com/studio#command-tools"
    echo "2. Download the command line tools"
    echo "3. Extract to /usr/local/android-sdk"
    echo ""
    echo "Option 3: Use Android Studio"
    echo "1. Install Android Studio"
    echo "2. Let it install the SDK"
    echo "3. Set ANDROID_HOME to the SDK location"
    echo ""
    echo "After installing, run:"
    echo "export ANDROID_HOME=/path/to/android-sdk"
    echo "./gradlew build"
    exit 1
fi

# Set environment variable
export ANDROID_HOME=/usr/local/android-sdk

# Try to build
echo "Attempting to build the app..."
./gradlew build

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can now install the app on your device:"
    echo "./gradlew installDebug"
else
    echo "Build failed. Please check the error messages above."
fi