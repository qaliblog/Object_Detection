package com.qali.menu.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.textfield.TextInputEditText
import com.qali.menu.R
import com.qali.menu.adapter.MenuAdapter
import com.qali.menu.databinding.FragmentMenuBinding
import com.qali.menu.viewmodel.MenuViewModel
import kotlinx.coroutines.launch

class MenuFragment : Fragment() {
    
    private var _binding: FragmentMenuBinding? = null
    private val binding get() = _binding!!
    
    private val menuViewModel: MenuViewModel by activityViewModels()
    private lateinit var menuAdapter: MenuAdapter
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMenuBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupRecyclerView()
        setupObservers()
        setupClickListeners()
    }
    
    private fun setupRecyclerView() {
        menuAdapter = MenuAdapter { menuItem ->
            // Handle menu item click - show 3D view
            show3DView(menuItem)
        }
        
        binding.recyclerViewMenu.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = menuAdapter
        }
    }
    
    private fun setupObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            menuViewModel.menuItems.collect { menuItems ->
                menuAdapter.submitList(menuItems)
                binding.emptyState.visibility = if (menuItems.isEmpty()) View.VISIBLE else View.GONE
            }
        }
        
        viewLifecycleOwner.lifecycleScope.launch {
            menuViewModel.isScanning.collect { isScanning ->
                binding.progressBar.visibility = if (isScanning) View.VISIBLE else View.GONE
                binding.fabAddItem.isEnabled = !isScanning
            }
        }
        
        viewLifecycleOwner.lifecycleScope.launch {
            menuViewModel.scanProgress.collect { progress ->
                binding.progressBar.progress = (progress * 100).toInt()
            }
        }
        
        viewLifecycleOwner.lifecycleScope.launch {
            menuViewModel.scanError.collect { error ->
                error?.let {
                    Toast.makeText(context, "Scan error: $it", Toast.LENGTH_LONG).show()
                    menuViewModel.clearScanError()
                }
            }
        }
    }
    
    private fun setupClickListeners() {
        binding.fabAddItem.setOnClickListener {
            showAddItemDialog()
        }
        
        binding.searchView.setOnQueryTextListener(object : android.widget.SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                query?.let { menuViewModel.searchMenuItems(it) }
                return true
            }
            
            override fun onQueryTextChange(newText: String?): Boolean {
                newText?.let { menuViewModel.searchMenuItems(it) }
                return true
            }
        })
    }
    
    private fun showAddItemDialog() {
        val dialogView = LayoutInflater.from(context).inflate(R.layout.dialog_add_menu_item, null)
        
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Add New Menu Item")
            .setView(dialogView)
            .setPositiveButton("Scan & Add") { _, _ ->
                val nameEdit = dialogView.findViewById<TextInputEditText>(R.id.editTextName)
                val descriptionEdit = dialogView.findViewById<TextInputEditText>(R.id.editTextDescription)
                val priceEdit = dialogView.findViewById<TextInputEditText>(R.id.editTextPrice)
                val categoryEdit = dialogView.findViewById<TextInputEditText>(R.id.editTextCategory)
                
                val name = nameEdit.text.toString()
                val description = descriptionEdit.text.toString()
                val priceText = priceEdit.text.toString()
                val category = categoryEdit.text.toString()
                
                if (name.isNotBlank() && description.isNotBlank() && priceText.isNotBlank() && category.isNotBlank()) {
                    try {
                        val price = priceText.toDouble()
                        menuViewModel.scanAndAddMenuItem(name, description, price, category)
                    } catch (e: NumberFormatException) {
                        Toast.makeText(context, "Invalid price format", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    Toast.makeText(context, "Please fill all fields", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    private fun show3DView(menuItem: com.qali.menu.data.MenuItem) {
        // Navigate to 3D view fragment
        // This would be implemented with navigation component
        Toast.makeText(context, "Opening 3D view for ${menuItem.name}", Toast.LENGTH_SHORT).show()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}