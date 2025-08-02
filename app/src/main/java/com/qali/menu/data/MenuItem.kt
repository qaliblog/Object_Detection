package com.qali.menu.data

// import androidx.room.Entity
// import androidx.room.PrimaryKey

// @Entity(tableName = "menu_items")
data class MenuItem(
    // @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val description: String,
    val price: Double,
    val category: String,
    val modelPath: String?, // Path to 3D model file
    val imagePath: String?, // Path to thumbnail image
    val isAvailable: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
)