package com.qali.menu.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.qali.menu.R
import com.qali.menu.data.MenuItem
import com.qali.menu.databinding.ItemMenuBinding
import java.io.File

class MenuAdapter(
    private val onItemClick: (MenuItem) -> Unit
) : ListAdapter<MenuItem, MenuAdapter.MenuViewHolder>(MenuDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MenuViewHolder {
        val binding = ItemMenuBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return MenuViewHolder(binding, onItemClick)
    }
    
    override fun onBindViewHolder(holder: MenuViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    class MenuViewHolder(
        private val binding: ItemMenuBinding,
        private val onItemClick: (MenuItem) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {
        
        fun bind(menuItem: MenuItem) {
            binding.apply {
                textViewName.text = menuItem.name
                textViewDescription.text = menuItem.description
                textViewPrice.text = "$${String.format("%.2f", menuItem.price)}"
                textViewCategory.text = menuItem.category
                
                // Load thumbnail image
                menuItem.imagePath?.let { imagePath ->
                    val imageFile = File(imagePath)
                    if (imageFile.exists()) {
                        Glide.with(root.context)
                            .load(imageFile)
                            .placeholder(R.drawable.placeholder_food)
                            .error(R.drawable.placeholder_food)
                            .into(imageViewThumbnail)
                    } else {
                        imageViewThumbnail.setImageResource(R.drawable.placeholder_food)
                    }
                } ?: run {
                    imageViewThumbnail.setImageResource(R.drawable.placeholder_food)
                }
                
                // Set 3D model indicator
                imageView3dIndicator.visibility = if (menuItem.modelPath != null) {
                    android.view.View.VISIBLE
                } else {
                    android.view.View.GONE
                }
                
                root.setOnClickListener {
                    onItemClick(menuItem)
                }
            }
        }
    }
    
    private class MenuDiffCallback : DiffUtil.ItemCallback<MenuItem>() {
        override fun areItemsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
            return oldItem.id == newItem.id
        }
        
        override fun areContentsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
            return oldItem == newItem
        }
    }
}