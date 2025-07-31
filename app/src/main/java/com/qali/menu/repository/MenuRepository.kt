package com.qali.menu.repository

import android.content.Context
import com.qali.menu.data.MenuDao
import com.qali.menu.data.MenuItem
import com.qali.menu.scanner.Model3DScanner
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class MenuRepository(
    private val menuDao: MenuDao,
    private val context: Context
) {
    private val scanner = Model3DScanner(context)
    
    fun getAllMenuItems(): Flow<List<MenuItem>> = menuDao.getAllMenuItems()
    
    fun getMenuItemsByCategory(category: String): Flow<List<MenuItem>> = 
        menuDao.getMenuItemsByCategory(category)
    
    fun searchMenuItems(query: String): Flow<List<MenuItem>> = 
        menuDao.searchMenuItems(query)
    
    fun getAllCategories(): Flow<List<String>> = menuDao.getAllCategories()
    
    suspend fun addMenuItem(menuItem: MenuItem): Long = menuDao.insertMenuItem(menuItem)
    
    suspend fun updateMenuItem(menuItem: MenuItem) = menuDao.updateMenuItem(menuItem)
    
    suspend fun deleteMenuItem(menuItem: MenuItem) = menuDao.deleteMenuItem(menuItem)
    
    suspend fun scanAndAddMenuItem(
        objectName: String,
        description: String,
        price: Double,
        category: String,
        listener: Model3DScanner.ScanListener
    ): MenuItem {
        // Initialize scanner
        if (!scanner.initializeScanner()) {
            throw Exception("Failed to initialize 3D scanner")
        }
        
        // Start scanning
        val scanResult = scanner.startScanning(objectName, listener)
        
        // Create menu item with 3D model
        val menuItem = MenuItem(
            name = objectName,
            description = description,
            price = price,
            category = category,
            modelPath = scanResult.modelPath,
            imagePath = scanResult.thumbnailPath
        )
        
        // Save to database
        val id = menuDao.insertMenuItem(menuItem)
        return menuItem.copy(id = id)
    }
    
    suspend fun getMenuItemById(id: Long): MenuItem? {
        // This would need to be added to the DAO
        return menuDao.getAllMenuItems().first().find { it.id == id }
    }
    
    fun releaseScanner() {
        scanner.release()
    }
}