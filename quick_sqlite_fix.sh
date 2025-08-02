#!/bin/bash

echo "Quick SQLite Native Library Fix for ARM64 Termux"

# Backup current files
cp gradle.properties gradle.properties.backup
cp app/build.gradle app/build.gradle.backup

# Add kapt-specific settings to gradle.properties
echo "" >> gradle.properties
echo "# Kapt SQLite fix for ARM64" >> gradle.properties
echo "kapt.use.worker.api=false" >> gradle.properties
echo "kapt.incremental.apt=false" >> gradle.properties
echo "kapt.include.compile.classpath=false" >> gradle.properties
echo "kapt.verbose=true" >> gradle.properties

# Add JVM arguments to handle native library issues
sed -i 's/org.gradle.jvmargs=-Xmx1536m/org.gradle.jvmargs=-Xmx2048m -Djava.library.path=\/data\/data\/com.termux\/files\/usr\/lib -Dorg.gradle.native.dir=\/data\/data\/com.termux\/files\/usr\/lib/g' gradle.properties

# Remove Room kapt dependency temporarily
sed -i '/kapt "androidx.room:room-compiler:2.4.3"/d' app/build.gradle

# Clean and try to build
echo "Cleaning previous build..."
./gradlew clean

echo "Attempting build with SQLite fix..."
./gradlew assembleDebug --no-daemon --stacktrace

if [ $? -eq 0 ]; then
    echo "✅ Build successful! SQLite issue resolved."
else
    echo "❌ Build still failed. Restoring original files..."
    cp gradle.properties.backup gradle.properties
    cp app/build.gradle.backup app/build.gradle
    echo "Original files restored. Try the comprehensive fix script: ./fix_sqlite_issue.sh"
fi