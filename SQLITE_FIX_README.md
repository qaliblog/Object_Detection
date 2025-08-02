# SQLite Native Library Fix for ARM64 Termux

## Problem Description

The build is failing with the following error:
```
Failed to load native library:sqlite-3.36.0-774b213f-37a1-47e2-9d0b-100a8352b36f-libsqlitejdbc.so. osinfo: Linux/aarch64
java.lang.UnsatisfiedLinkError: /data/data/com.termux/files/usr/tmp/sqlite-3.36.0-774b213f-37a1-47e2-9d0b-100a8352b36f-libsqlitejdbc.so: dlopen failed: library "libc.so.6" not found
```

This is a common issue when building Android projects with Room database on ARM64 architecture in Termux. The kapt (Kotlin Annotation Processing Tool) tries to load x86_64 SQLite libraries that are incompatible with ARM64.

## Root Cause

1. **Architecture Mismatch**: The Room compiler (kapt) downloads x86_64 SQLite libraries
2. **Missing Native Libraries**: ARM64 Termux environment lacks compatible `libc.so.6`
3. **Kapt Configuration**: Default kapt settings don't handle ARM64 properly

## Solutions

### Quick Fix (Recommended First)

Run the quick fix script:
```bash
./quick_sqlite_fix.sh
```

This script:
- Disables kapt worker API
- Adds ARM64-specific JVM arguments
- Temporarily removes Room kapt dependency
- Attempts to build with minimal changes

### Comprehensive Fix

If the quick fix doesn't work, run the comprehensive fix:
```bash
./fix_sqlite_issue.sh
```

This script:
- Installs required dependencies
- Configures gradle properties for ARM64
- Replaces Room with basic SQLite implementation
- Provides fallback solutions

### Manual Fix

If both scripts fail, try these manual steps:

1. **Install Dependencies**:
   ```bash
   pkg update -y
   pkg install -y openjdk-17 gradle sqlite libc++ libandroid-support
   ```

2. **Modify gradle.properties**:
   Add these lines to `gradle.properties`:
   ```properties
   # Kapt SQLite fix for ARM64
   kapt.use.worker.api=false
   kapt.incremental.apt=false
   kapt.include.compile.classpath=false
   kapt.verbose=true
   
   # JVM arguments for native libraries
   org.gradle.jvmargs=-Xmx2048m -Djava.library.path=/data/data/com.termux/files/usr/lib
   ```

3. **Remove Room Kapt Dependency**:
   In `app/build.gradle`, comment out or remove:
   ```gradle
   // kapt "androidx.room:room-compiler:2.4.3"
   ```

4. **Clean and Build**:
   ```bash
   ./gradlew clean
   ./gradlew assembleDebug --no-daemon --stacktrace
   ```

## Alternative Solutions

### Option 1: Use Different JDK
```bash
pkg install -y openjdk-11
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/openjdk-11
```

### Option 2: Replace Room with Basic SQLite
Replace Room dependencies with basic SQLite:
```gradle
// Remove these lines:
// implementation "androidx.room:room-runtime:2.4.3"
// implementation "androidx.room:room-ktx:2.4.3"
// kapt "androidx.room:room-compiler:2.4.3"

// Add these instead:
implementation "androidx.sqlite:sqlite:2.4.1"
implementation "androidx.sqlite:sqlite-ktx:2.4.1"
```

### Option 3: Build on Different Architecture
Consider building on:
- x86_64 Linux system
- Windows with WSL
- macOS
- Cloud build service

## Verification

After applying fixes, verify the build works:
```bash
./gradlew assembleDebug
```

If successful, you should see:
```
BUILD SUCCESSFUL in X seconds
```

## Troubleshooting

### Still Getting SQLite Errors?
1. Check architecture: `uname -m` (should be `aarch64`)
2. Verify Java version: `java -version`
3. Check Termux packages: `pkg list-installed | grep -E "(openjdk|gradle|sqlite)"`

### Build Still Fails?
1. Try with different JDK version
2. Use simplified build.gradle without Room
3. Consider building on different platform

### Need Help?
- Check Termux documentation: https://wiki.termux.com/
- Android ARM64 build issues: https://developer.android.com/ndk/guides/abis
- Room database alternatives: https://developer.android.com/training/data-storage/room

## Files Created

- `quick_sqlite_fix.sh` - Quick fix script
- `fix_sqlite_issue.sh` - Comprehensive fix script
- `SQLITE_FIX_README.md` - This documentation
- Backup files: `gradle.properties.backup`, `app/build.gradle.backup`

## Notes

- The fix temporarily disables Room database functionality
- Basic SQLite implementation is provided as alternative
- Original files are backed up before modifications
- Scripts are designed specifically for ARM64 Termux environment