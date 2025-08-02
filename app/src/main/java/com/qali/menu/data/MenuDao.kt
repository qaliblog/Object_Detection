package com.qali.menu.data

// import androidx.room.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

// @Dao
interface MenuDao {
    // @Query("SELECT * FROM menu_items ORDER BY category, name")
    fun getAllMenuItems(): Flow<List<MenuItem>>
    
    // @Query("SELECT * FROM menu_items WHERE category = :category ORDER BY name")
    fun getMenuItemsByCategory(category: String): Flow<List<MenuItem>>
    
    // @Query("SELECT * FROM menu_items WHERE name LIKE '%' || :query || '%' OR description LIKE '%' || :query || '%'")
    fun searchMenuItems(query: String): Flow<List<MenuItem>>
    
    // @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMenuItem(menuItem: MenuItem): Long
    
    // @Update
    suspend fun updateMenuItem(menuItem: MenuItem)
    
    // @Delete
    suspend fun deleteMenuItem(menuItem: MenuItem)
    
    // @Query("SELECT DISTINCT category FROM menu_items ORDER BY category")
    fun getAllCategories(): Flow<List<String>>
}

// Temporary in-memory implementation
class InMemoryMenuDao : MenuDao {
    private val menuItems = MutableStateFlow<List<MenuItem>>(emptyList())
    private var nextId = 1L
    
    override fun getAllMenuItems(): Flow<List<MenuItem>> = menuItems
    
    override fun getMenuItemsByCategory(category: String): Flow<List<MenuItem>> =
        menuItems.map { items -> items.filter { it.category == category } }
    
    override fun searchMenuItems(query: String): Flow<List<MenuItem>> =
        menuItems.map { items ->
            items.filter { 
                it.name.contains(query, ignoreCase = true) || 
                it.description.contains(query, ignoreCase = true) 
            }
        }
    
    override suspend fun insertMenuItem(menuItem: MenuItem): Long {
        val newItem = menuItem.copy(id = nextId++)
        val currentItems = menuItems.value.toMutableList()
        currentItems.add(newItem)
        menuItems.value = currentItems
        return newItem.id
    }
    
    override suspend fun updateMenuItem(menuItem: MenuItem) {
        val currentItems = menuItems.value.toMutableList()
        val index = currentItems.indexOfFirst { it.id == menuItem.id }
        if (index != -1) {
            currentItems[index] = menuItem
            menuItems.value = currentItems
        }
    }
    
    override suspend fun deleteMenuItem(menuItem: MenuItem) {
        val currentItems = menuItems.value.toMutableList()
        currentItems.removeAll { it.id == menuItem.id }
        menuItems.value = currentItems
    }
    
    override fun getAllCategories(): Flow<List<String>> =
        menuItems.map { items -> items.map { it.category }.distinct().sorted() }
}