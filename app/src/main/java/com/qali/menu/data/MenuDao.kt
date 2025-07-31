package com.qali.menu.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface MenuDao {
    @Query("SELECT * FROM menu_items ORDER BY category, name")
    fun getAllMenuItems(): Flow<List<MenuItem>>
    
    @Query("SELECT * FROM menu_items WHERE category = :category ORDER BY name")
    fun getMenuItemsByCategory(category: String): Flow<List<MenuItem>>
    
    @Query("SELECT * FROM menu_items WHERE name LIKE '%' || :query || '%' OR description LIKE '%' || :query || '%'")
    fun searchMenuItems(query: String): Flow<List<MenuItem>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMenuItem(menuItem: MenuItem): Long
    
    @Update
    suspend fun updateMenuItem(menuItem: MenuItem)
    
    @Delete
    suspend fun deleteMenuItem(menuItem: MenuItem)
    
    @Query("SELECT DISTINCT category FROM menu_items ORDER BY category")
    fun getAllCategories(): Flow<List<String>>
}