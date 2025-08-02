# SQLite Native Library Issue Fix

## Problem Description

When building Android projects in Termux environment, you may encounter the following error:

```
Failed to load native library:sqlite-3.36.0-654923c5-0527-4fca-ab7c-e6b0c98cb8b0-libsqlitejdbc.so
java.lang.UnsatisfiedLinkError: dlopen failed: library "libc.so.6" not found
```

This error occurs because:
1. The Kotlin Annotation Processing Tool (kapt) tries to use SQLite JDBC driver
2. SQLite JDBC requires native libraries that aren't available in Termux
3. The required `libc.so.6` library is not found in the expected location

## Solution

This project includes several fixes to resolve the SQLite native library issue:

### 1. KSP Instead of KAPT (Recommended)

We've replaced kapt with KSP (Kotlin Symbol Processing) for Room database processing:

- **Before**: `kapt "androidx.room:room-compiler:$room_version"`
- **After**: `ksp "androidx.room:room-compiler:$room_version"`

KSP is faster and doesn't have the same native library dependencies as kapt.

### 2. Environment Configuration

Added system properties to `gradle.properties`:
```properties
# Fix for SQLite native library issues in Termux
systemProp.sqlite.enable.load.extension=false
systemProp.sqlite.enable.legacy.load.extension=false
```

### 3. KSP Configuration

Added KSP configuration in `app/build.gradle`:
```gradle
ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
    arg("room.incremental", "true")
    arg("room.expandProjection", "true")
}
```

## How to Apply the Fix

### Option 1: Automatic Fix (Recommended)

Run the provided script:
```bash
./fix_sqlite_issue.sh
```

This script will:
- Create backups of your original files
- Apply all necessary changes
- Attempt to build the project
- Restore original files if the build fails

### Option 2: Manual Fix

1. **Update build.gradle (project level)**:
   Add KSP plugin classpath:
   ```gradle
   classpath 'com.google.devtools.ksp:com.google.devtools.ksp.gradle.plugin:1.9.0-1.0.13'
   ```

2. **Update app/build.gradle**:
   - Add KSP plugin: `apply plugin: 'com.google.devtools.ksp'`
   - Replace kapt with ksp for Room:
     ```gradle
     // Before
     kapt "androidx.room:room-compiler:$room_version"
     
     // After
     ksp "androidx.room:room-compiler:$room_version"
     ```
   - Add KSP configuration:
     ```gradle
     ksp {
         arg("room.schemaLocation", "$projectDir/schemas")
         arg("room.incremental", "true")
         arg("room.expandProjection", "true")
     }
     ```

3. **Update gradle.properties**:
   Add SQLite system properties:
   ```properties
   systemProp.sqlite.enable.load.extension=false
   systemProp.sqlite.enable.legacy.load.extension=false
   ```

## Build Commands

After applying the fix, use these commands:

```bash
# Clean and build
./gradlew clean build

# Build debug version
./gradlew assembleDebug

# Build release version
./gradlew assembleRelease

# Install debug version
./gradlew installDebug
```

## Troubleshooting

### If the build still fails:

1. **Check Java version**:
   ```bash
   java -version
   ```
   Ensure you're using Java 11 or higher.

2. **Check Android SDK**:
   ```bash
   echo $ANDROID_HOME
   ```
   Ensure Android SDK is properly installed and configured.

3. **Try with different settings**:
   ```bash
   ./gradlew build --no-daemon --stacktrace \
       -Dsqlite.enable.load.extension=false \
       -Dorg.gradle.daemon=false
   ```

4. **Check network connectivity**:
   Ensure you have stable internet connection for downloading dependencies.

### Alternative Solutions

If the above fixes don't work, you can try:

1. **Use a different Room version**:
   ```gradle
   def room_version = "2.5.0"  // Try an older version
   ```

2. **Disable Room temporarily**:
   Comment out Room dependencies and rebuild without database functionality.

3. **Use a different database solution**:
   Consider using SQLDelight or other database libraries that don't have native dependencies.

## Files Modified

- `build.gradle` - Added KSP plugin classpath
- `app/build.gradle` - Replaced kapt with ksp for Room
- `gradle.properties` - Added SQLite system properties
- `fix_sqlite_issue.sh` - Automatic fix script

## Benefits of This Fix

1. **Faster builds**: KSP is significantly faster than kapt
2. **No native dependencies**: Avoids SQLite native library issues
3. **Better compatibility**: Works reliably in Termux and other environments
4. **Future-proof**: KSP is the recommended replacement for kapt

## Notes

- This fix is specifically designed for Termux environment
- The changes are backward compatible
- Room database functionality remains fully intact
- Build performance should improve due to KSP usage