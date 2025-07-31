package com.qali.menu.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.qali.menu.data.MenuDatabase
import com.qali.menu.data.MenuItem
import com.qali.menu.repository.MenuRepository
import com.qali.menu.scanner.Model3DScanner
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MenuViewModel(application: Application) : AndroidViewModel(application) {
    
    private val repository: MenuRepository
    private val _menuItems = MutableStateFlow<List<MenuItem>>(emptyList())
    private val _categories = MutableStateFlow<List<String>>(emptyList())
    private val _isScanning = MutableStateFlow(false)
    private val _scanProgress = MutableStateFlow(0f)
    private val _scanError = MutableStateFlow<String?>(null)
    
    val menuItems: StateFlow<List<MenuItem>> = _menuItems.asStateFlow()
    val categories: StateFlow<List<String>> = _categories.asStateFlow()
    val isScanning: StateFlow<Boolean> = _isScanning.asStateFlow()
    val scanProgress: StateFlow<Float> = _scanProgress.asStateFlow()
    val scanError: StateFlow<String?> = _scanError.asStateFlow()
    
    init {
        val database = MenuDatabase.getDatabase(application)
        repository = MenuRepository(database.menuDao(), application)
        loadMenuItems()
        loadCategories()
    }
    
    private fun loadMenuItems() {
        viewModelScope.launch {
            repository.getAllMenuItems().collect { items ->
                _menuItems.value = items
            }
        }
    }
    
    private fun loadCategories() {
        viewModelScope.launch {
            repository.getAllCategories().collect { categories ->
                _categories.value = categories
            }
        }
    }
    
    fun searchMenuItems(query: String) {
        viewModelScope.launch {
            repository.searchMenuItems(query).collect { items ->
                _menuItems.value = items
            }
        }
    }
    
    fun getMenuItemsByCategory(category: String) {
        viewModelScope.launch {
            repository.getMenuItemsByCategory(category).collect { items ->
                _menuItems.value = items
            }
        }
    }
    
    fun scanAndAddMenuItem(
        objectName: String,
        description: String,
        price: Double,
        category: String
    ) {
        viewModelScope.launch {
            try {
                _isScanning.value = true
                _scanError.value = null
                _scanProgress.value = 0f
                
                val menuItem = repository.scanAndAddMenuItem(
                    objectName = objectName,
                    description = description,
                    price = price,
                    category = category,
                    listener = object : Model3DScanner.ScanListener {
                        override fun onScanProgress(progress: Float) {
                            _scanProgress.value = progress
                        }
                        
                        override fun onScanComplete(result: Model3DScanner.ScanResult) {
                            _isScanning.value = false
                            _scanProgress.value = 1f
                        }
                        
                        override fun onScanError(error: String) {
                            _isScanning.value = false
                            _scanError.value = error
                        }
                    }
                )
                
                // Reload menu items
                loadMenuItems()
                
            } catch (e: Exception) {
                _isScanning.value = false
                _scanError.value = e.message ?: "Unknown error occurred"
            }
        }
    }
    
    fun addMenuItem(menuItem: MenuItem) {
        viewModelScope.launch {
            repository.addMenuItem(menuItem)
            loadMenuItems()
        }
    }
    
    fun updateMenuItem(menuItem: MenuItem) {
        viewModelScope.launch {
            repository.updateMenuItem(menuItem)
            loadMenuItems()
        }
    }
    
    fun deleteMenuItem(menuItem: MenuItem) {
        viewModelScope.launch {
            repository.deleteMenuItem(menuItem)
            loadMenuItems()
        }
    }
    
    fun clearScanError() {
        _scanError.value = null
    }
    
    override fun onCleared() {
        super.onCleared()
        repository.releaseScanner()
    }
}