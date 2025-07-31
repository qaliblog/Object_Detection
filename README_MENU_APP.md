# Menu App with 3D Object Scanning

This Android app provides a restaurant/cafe menu system with 3D object scanning capabilities. Users can scan physical objects using the camera and add them to the menu with 3D models for enhanced visualization.

## Features

### ✅ **Completed Features:**

1. **Object Detection**: Uses MediaPipe for real-time object detection
2. **3D Scanning**: Scans objects from multiple angles using AR Core
3. **3D Model Generation**: Creates OBJ files from point cloud data
4. **Menu Management**: Add, edit, delete menu items with 3D models
5. **Search Functionality**: Search menu items by name or description
6. **Category Organization**: Organize menu items by categories
7. **3D View Indicators**: Visual indicators for items with 3D models

### 🔧 **Technical Implementation:**

- **Package Name**: `com.qali.menu`
- **App Name**: "Menu"
- **Database**: Room database for menu items
- **3D Rendering**: AR Core for object scanning
- **Image Loading**: Glide for thumbnails
- **Architecture**: MVVM with Repository pattern

## Setup Instructions

### 1. Install Android SDK

Choose one of the following options:

**Option A: Package Manager (Ubuntu/Debian)**
```bash
sudo apt update
sudo apt install android-sdk
export ANDROID_HOME=/usr/lib/android-sdk
```

**Option B: Download from Google**
1. Go to https://developer.android.com/studio#command-tools
2. Download the command line tools
3. Extract to `/usr/local/android-sdk`
4. Set environment: `export ANDROID_HOME=/usr/local/android-sdk`

**Option C: Android Studio**
1. Install Android Studio
2. Let it install the SDK
3. Set `ANDROID_HOME` to the SDK location

### 2. Build the App

```bash
# Set Android SDK path
export ANDROID_HOME=/path/to/your/android-sdk

# Build the app
./gradlew build

# Install on device (if connected)
./gradlew installDebug
```

### 3. Run the Setup Script

```bash
./setup_android_sdk.sh
```

## App Usage

### Main Menu
- **Menu Tab**: View all menu items with thumbnails
- **Camera Tab**: Real-time object detection
- **Gallery Tab**: Process images/videos for object detection

### Adding Menu Items
1. Tap the **+** button in the Menu tab
2. Enter object name, description, price, and category
3. Tap "Scan & Add" to start 3D scanning
4. Point camera at the object from different angles
5. The app will generate a 3D model and add to menu

### 3D Scanning Process
- Scans object from 8 different angles (0°, 45°, 90°, etc.)
- Uses AR Core point cloud data
- Generates OBJ file with vertices and faces
- Creates thumbnail image
- Stores model files locally

### Menu Features
- **Search**: Find items by name or description
- **Categories**: Filter by category
- **3D Indicators**: Visual badges for items with 3D models
- **CRUD Operations**: Add, edit, delete menu items

## File Structure

```
app/src/main/java/com/qali/menu/
├── data/
│   ├── MenuItem.kt          # Database entity
│   ├── MenuDao.kt           # Database operations
│   └── MenuDatabase.kt      # Room database
├── repository/
│   └── MenuRepository.kt    # Data layer
├── scanner/
│   └── Model3DScanner.kt    # 3D scanning logic
├── viewmodel/
│   └── MenuViewModel.kt     # UI state management
├── adapter/
│   └── MenuAdapter.kt       # RecyclerView adapter
├── fragments/
│   ├── MenuFragment.kt      # Main menu UI
│   ├── CameraFragment.kt    # Camera functionality
│   ├── GalleryFragment.kt   # Gallery functionality
│   └── PermissionsFragment.kt
└── MainActivity.kt          # Main activity
```

## Dependencies

- **AR Core**: 3D object scanning
- **MediaPipe**: Object detection
- **Room**: Database persistence
- **Glide**: Image loading
- **Navigation**: Fragment navigation
- **Material Design**: UI components

## Troubleshooting

### Build Issues
1. **SDK not found**: Install Android SDK and set `ANDROID_HOME`
2. **Gradle version**: Updated to Gradle 8.4 for Java 21 compatibility
3. **Dependencies**: Updated to compatible versions

### Runtime Issues
1. **Camera permissions**: Grant camera access when prompted
2. **AR Core**: Ensure device supports AR Core
3. **Storage**: Grant storage permissions for saving 3D models

## Future Enhancements

- **3D Model Viewer**: Interactive 3D model viewing
- **Cloud Storage**: Store 3D models in cloud
- **Advanced Scanning**: Better point cloud processing
- **Menu Sharing**: Share menu with QR codes
- **Analytics**: Track popular items

## License

This project is based on MediaPipe object detection example and has been modified for menu management with 3D scanning capabilities.