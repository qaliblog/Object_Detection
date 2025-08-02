# Termux Build Fix Guide

## Issue Description
When building Android projects in Termux on ARM64 architecture, you may encounter several issues:

### 1. SQLite Native Library Issue
```
Failed to load native library:sqlite-3.36.0-a635d114-4bdb-4d14-adbe-b97e0155bedb-libsqlitejdbc.so. osinfo: Linux/aarch64
java.lang.UnsatisfiedLinkError: /data/data/com.termux/files/usr/tmp/sqlite-3.36.0-a635d114-4bdb-4d14-adbe-b97e0155bedb-libsqlitejdbc.so: dlopen failed: library "libc.so.6" not found
```

This happens because the Kotlin annotation processor (kapt) tries to load a native SQLite library that's incompatible with Termux's ARM64 environment.

### 2. AAPT2 Daemon Issue
```
AAPT2 aapt2-8.1.0-10154469-linux Daemon #0: Unexpected error output: /data/data/com.termux/files/home/.gradle/caches/transforms-3/1e832b95d7e5af4a2d638142dd1a3e38/transformed/aapt2-8.1.0-10154469-linux/aapt2[31]: syntax error: unexpected '('
```

This occurs because the AAPT2 binary is incompatible with the Termux shell environment.

### 3. Gradle Cache Corruption Issue
```
Failed to store cache entry b6bdac5ea70438d8adca66edd095505d for task ':app:compileDebugKotlin': Could not pack tree 'destinationDirectory': java.io.IOException: Request to write '2245' bytes exceeds size in header of '0' bytes for entry 'tree-destinationDirectory/com/qali/menu/fragments/MenuFragment$setupObservers$3$1.class'
```

This occurs when the Gradle build cache becomes corrupted and can't properly store compiled classes.

## Quick Fix (Recommended)

### Option 1: Use the Automated Fix Scripts
```bash
# Run the cache cleanup script first
./clean_gradle_cache.sh

# Then run the SQLite fix script
./fix_sqlite_termux.sh

# Finally run the AAPT2 fix script
./fix_aapt2_issues.sh
```

### Option 2: Manual Fix Steps

1. **Update Termux packages:**
   ```bash
   pkg update && pkg upgrade
   pkg install sqlite libsqlite
   ```

2. **Set environment variables:**
   ```bash
   export LD_LIBRARY_PATH="/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH"
   export JAVA_LIBRARY_PATH="/data/data/com.termux/files/usr/lib"
   ```

3. **Clean and rebuild:**
   ```bash
   ./gradlew clean
   ./gradlew assembleDebug --no-daemon --parallel=false
   ```

## Advanced Solutions

### Solution 1: Disable Room Database (Temporary)
If you don't need the Room database functionality immediately:

1. The Room dependencies are already commented out in `app/build.gradle`
2. An alternative SQLite implementation is provided
3. You can uncomment Room dependencies later when the issue is resolved

### Solution 2: Use Alternative SQLite Implementation
The project now includes `org.sqlite.sqlitex:sqlite-android:3.36.0` which is more compatible with Termux.

### Solution 3: Configure JVM Options
The `gradle.properties` file has been updated with Termux-specific settings:

```properties
org.gradle.jvmargs=-Xmx1536m -Djava.library.path=/data/data/com.termux/files/usr/lib -Dorg.sqlite.lib.path=/data/data/com.termux/files/usr/lib
kapt.use.worker.api=false
kapt.incremental.apt=false
kapt.include.compile.classpath=false
```

## Troubleshooting

### If the build still fails:

1. **Check SQLite installation:**
   ```bash
   sqlite3 --version
   ls -la /data/data/com.termux/files/usr/lib/libsqlite*
   ```

2. **Try building with verbose output:**
   ```bash
   ./gradlew assembleDebug --stacktrace --info
   ```

3. **Use minimal Gradle settings:**
   ```bash
   export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"
   ./gradlew assembleDebug --no-daemon
   ```

4. **Alternative: Use a different build environment**
   - Consider using Android Studio on a desktop
   - Use GitHub Actions for CI/CD
   - Use a cloud-based build service

## Prevention

To avoid this issue in future projects:

1. **Use Termux-compatible dependencies** when possible
2. **Test builds early** in the development process
3. **Consider using alternative libraries** that don't require native libraries
4. **Keep Termux updated** regularly

## Re-enabling Room Database

Once the SQLite issue is resolved, you can re-enable Room database:

1. Uncomment the Room dependencies in `app/build.gradle`
2. Remove the alternative SQLite implementation
3. Update your code to use Room instead of direct SQLite

## Support

If you continue to experience issues:

1. Check the [Termux GitHub repository](https://github.com/termux/termux-app) for updates
2. Look for similar issues in the [Android Gradle Plugin issues](https://github.com/gradle/gradle/issues)
3. Consider using a different development environment for Android development

## Notes

- This fix is specific to Termux on ARM64 architecture
- The Room database is temporarily disabled but can be re-enabled later
- The alternative SQLite implementation provides basic database functionality
- Regular updates to Termux and its packages may resolve this issue in future versions