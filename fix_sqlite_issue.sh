#!/bin/bash

echo "Fixing SQLite native library issue for ARM64 Termux..."

# Function to check if we're running on ARM64
check_architecture() {
    if [ "$(uname -m)" = "aarch64" ]; then
        echo "Detected ARM64 architecture"
        return 0
    else
        echo "Not ARM64 architecture: $(uname -m)"
        return 1
    fi
}

# Function to install required packages
install_dependencies() {
    echo "Installing required dependencies..."
    
    # Update package list
    pkg update -y
    
    # Install essential packages
    pkg install -y openjdk-17 gradle sqlite
    
    # Install additional libraries that might be needed
    pkg install -y libc++ libandroid-support
    
    echo "Dependencies installed successfully"
}

# Function to configure gradle properties for ARM64
configure_gradle_for_arm64() {
    echo "Configuring Gradle properties for ARM64..."
    
    # Create a backup of current gradle.properties
    cp gradle.properties gradle.properties.backup
    
    # Add ARM64-specific configurations
    cat >> gradle.properties << EOF

# ARM64 Termux specific configurations
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
android.enableR8.fullMode=false
android.enableD8.desugaring=true

# Disable native library loading issues
android.enableJetifier=true
android.useAndroidX=true

# Kapt specific settings for ARM64
kapt.use.worker.api=false
kapt.incremental.apt=false
kapt.include.compile.classpath=false

# Room database settings
android.enableRoomSchemaLocation=true
room.schemaLocation=app/schemas

# Disable problematic native libraries
android.bundle.enableUncompressedNativeLibs=false
EOF
}

# Function to modify Room dependencies to avoid native issues
modify_room_dependencies() {
    echo "Modifying Room dependencies to avoid native library issues..."
    
    # Create a backup of current build.gradle
    cp app/build.gradle app/build.gradle.backup
    
    # Replace Room dependencies with SQLite alternatives
    sed -i 's/implementation "androidx.room:room-runtime:2.4.3"/implementation "androidx.sqlite:sqlite:2.4.1"/g' app/build.gradle
    sed -i 's/implementation "androidx.room:room-ktx:2.4.3"/implementation "androidx.sqlite:sqlite-ktx:2.4.1"/g' app/build.gradle
    sed -i 's/kapt "androidx.room:room-compiler:2.4.3"//g' app/build.gradle
}

# Function to create alternative database implementation
create_sqlite_alternative() {
    echo "Creating SQLite alternative implementation..."
    
    mkdir -p app/src/main/java/com/qali/menu/data
    
    # Create a simple SQLite helper
    cat > app/src/main/java/com/qali/menu/data/DatabaseHelper.kt << 'EOF'
package com.qali.menu.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    
    companion object {
        private const val DATABASE_NAME = "menu_database"
        private const val DATABASE_VERSION = 1
    }
    
    override fun onCreate(db: SQLiteDatabase) {
        // Create tables as needed
        db.execSQL("""
            CREATE TABLE IF NOT EXISTS menu_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                price REAL,
                category TEXT,
                image_path TEXT
            )
        """.trimIndent())
    }
    
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Handle database upgrades
        db.execSQL("DROP TABLE IF EXISTS menu_items")
        onCreate(db)
    }
}
EOF
}

# Function to clean and rebuild
clean_and_rebuild() {
    echo "Cleaning and rebuilding project..."
    
    # Clean previous build artifacts
    ./gradlew clean
    
    # Remove problematic cache
    rm -rf .gradle/caches/
    rm -rf app/build/
    
    # Try to build with specific settings
    echo "Attempting build with ARM64 optimizations..."
    ./gradlew assembleDebug --no-daemon --stacktrace
}

# Function to provide fallback solution
provide_fallback() {
    echo "Providing fallback solution..."
    
    # Create a simplified build.gradle without Room
    cat > app/build.gradle.simple << 'EOF'
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: "androidx.navigation.safeargs"
apply plugin: 'de.undercouch.download'

android {
    namespace "com.qali.menu"
    compileSdkVersion 33
    defaultConfig {
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
        applicationId "com.qali.menu"
        minSdkVersion 24
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }

    buildFeatures {
        dataBinding true
        viewBinding true
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }

    androidResources {
        noCompress 'tflite'
    }
}

project.ext.ASSET_DIR = projectDir.toString() + '/src/main/assets'
apply from:'download_models.gradle'

dependencies {
    implementation 'androidx.core:core-ktx:1.10.1'
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.20"
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.1.0'
    implementation 'androidx.fragment:fragment-ktx:1.6.2'
    
    def nav_version = "2.5.3"
    implementation "androidx.navigation:navigation-fragment-ktx:$nav_version"
    implementation "androidx.navigation:navigation-ui-ktx:$nav_version"
    
    def camerax_version = '1.2.3'
    implementation "androidx.camera:camera-core:$camerax_version"
    implementation "androidx.camera:camera-camera2:$camerax_version"
    implementation "androidx.camera:camera-lifecycle:$camerax_version"
    implementation "androidx.camera:camera-view:$camerax_version"
    
    implementation 'androidx.window:window:1.1.0'
    implementation 'com.google.ar:core:1.40.0'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
    
    testImplementation 'androidx.test.ext:junit:1.1.5'
    testImplementation 'androidx.test:rules:1.5.0'
    testImplementation 'androidx.test:runner:1.5.0'
    testImplementation 'androidx.test.espresso:espresso-core:3.5.1'
    testImplementation 'org.robolectric:robolectric:4.10'
    
    androidTestImplementation "androidx.test.ext:junit:1.1.5"
    androidTestImplementation "androidx.test:core:1.5.0"
    androidTestImplementation "androidx.test:rules:1.5.0"
    androidTestImplementation "androidx.test:runner:1.5.0"
    androidTestImplementation "androidx.test.espresso:espresso-core:3.5.1"
    
    implementation 'com.google.mediapipe:tasks-vision:0.10.2'
}
EOF
}

# Main execution
echo "=== SQLite Native Library Fix Script ==="

# Check architecture
if ! check_architecture; then
    echo "This script is designed for ARM64 architecture. Exiting..."
    exit 1
fi

# Install dependencies
install_dependencies

# Configure gradle properties
configure_gradle_for_arm64

# Try the first approach - modify Room dependencies
echo "Attempting first approach: Modify Room dependencies..."
modify_room_dependencies
create_sqlite_alternative

# Try to build
if clean_and_rebuild; then
    echo "✅ Build successful with modified Room dependencies!"
    exit 0
fi

# If first approach fails, try fallback
echo "First approach failed. Trying fallback solution..."
provide_fallback

# Restore original build.gradle and use simplified version
cp app/build.gradle.backup app/build.gradle
cp app/build.gradle.simple app/build.gradle

# Try building with simplified dependencies
if clean_and_rebuild; then
    echo "✅ Build successful with simplified dependencies!"
    echo "Note: Room database functionality has been replaced with basic SQLite"
else
    echo "❌ All approaches failed. Manual intervention required."
    echo "Please try:"
    echo "1. Install additional libraries: pkg install -y libc++ libandroid-support"
    echo "2. Use a different JDK version: pkg install -y openjdk-11"
    echo "3. Consider building on a different architecture"
fi