package com.qali.menu.data

import android.content.Context
// import androidx.room.Database
// import androidx.room.Room
// import androidx.room.RoomDatabase

// @Database(entities = [MenuItem::class], version = 1, exportSchema = false)
// abstract class MenuDatabase : RoomDatabase() {
abstract class MenuDatabase {
    abstract fun menuDao(): MenuDao
    
    companion object {
        @Volatile
        private var INSTANCE: MenuDatabase? = null
        
        fun getDatabase(context: Context): MenuDatabase {
            return INSTANCE ?: synchronized(this) {
                // val instance = Room.databaseBuilder(
                //     context.applicationContext,
                //     MenuDatabase::class.java,
                //     "menu_database"
                // ).build()
                // INSTANCE = instance
                // instance
                // throw UnsupportedOperationException("Room database is temporarily disabled")
                val instance = InMemoryMenuDatabase()
                INSTANCE = instance
                instance
            }
        }
    }
}

// Temporary in-memory database implementation
class InMemoryMenuDatabase : MenuDatabase() {
    private val dao = InMemoryMenuDao()
    
    override fun menuDao(): MenuDao = dao
}