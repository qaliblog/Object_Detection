#!/bin/bash

echo "Fixing network issues for Menu App build..."

# Function to test network connectivity
test_network() {
    echo "Testing network connectivity..."
    
    # Test Google's Maven repository
    if curl -I --connect-timeout 10 https://dl.google.com/dl/android/maven2/ 2>/dev/null | head -n 1 | grep -q "200"; then
        echo "✅ Google Maven repository is accessible"
        return 0
    else
        echo "❌ Google Maven repository is not accessible"
        return 1
    fi
}

# Function to configure alternative repositories
configure_alternative_repos() {
    echo "Configuring alternative repositories..."
    
    # Create a backup of the original build.gradle
    cp build.gradle build.gradle.backup
    
    # Update repositories with more reliable sources
    cat > build.gradle.new << 'EOF'
/*
 * Copyright 2022 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    // Top-level variables used for versioning
    ext.kotlin_version = '1.9.0'
    ext.java_version = JavaVersion.VERSION_11

    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://repo1.maven.org/maven2/' }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'androidx.navigation:navigation-safe-args-gradle-plugin:2.7.0'
        classpath 'de.undercouch:gradle-download-task:5.4.0'

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://repo1.maven.org/maven2/' }
        maven { url 'https://maven.google.com' }
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

    mv build.gradle.new build.gradle
    echo "✅ Updated build.gradle with alternative repositories"
}

# Function to try different build approaches
try_build_approaches() {
    echo "Trying different build approaches..."
    
    # Approach 1: Normal build
    echo "Attempting normal build..."
    if ./gradlew build --no-daemon; then
        echo "✅ Build successful with normal approach"
        return 0
    fi
    
    # Approach 2: Build with network optimizations
    echo "Attempting build with network optimizations..."
    if ./gradlew build --no-daemon --parallel --max-workers=2; then
        echo "✅ Build successful with network optimizations"
        return 0
    fi
    
    # Approach 3: Build with offline mode (if dependencies are cached)
    echo "Attempting build with offline mode..."
    if ./gradlew build --offline --no-daemon; then
        echo "✅ Build successful with offline mode"
        return 0
    fi
    
    # Approach 4: Clean and rebuild
    echo "Attempting clean rebuild..."
    ./gradlew clean
    if ./gradlew build --no-daemon; then
        echo "✅ Build successful after clean rebuild"
        return 0
    fi
    
    return 1
}

# Main execution
echo "=== Network Issue Fix Script ==="

# Test network connectivity
if ! test_network; then
    echo "Network issues detected. Configuring alternative repositories..."
    configure_alternative_repos
fi

# Try different build approaches
if try_build_approaches; then
    echo "✅ Build completed successfully!"
    echo "You can now install the app:"
    echo "./gradlew installDebug"
else
    echo "❌ All build approaches failed."
    echo ""
    echo "Possible solutions:"
    echo "1. Check your internet connection"
    echo "2. Try using a VPN"
    echo "3. Configure proxy settings if needed"
    echo "4. Try building with Android Studio instead"
    echo ""
    echo "To restore original build.gradle:"
    echo "mv build.gradle.backup build.gradle"
fi