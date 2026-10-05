package com.babyshophub.service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.babyshophub.entity.Category;
import com.babyshophub.repository.CategoryRepository;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAllByActiveTrue();
    }
    
    

    public Category createCategory(Category category) {
        if (categoryRepository.existsByName(category.getName())) {
            throw new RuntimeException("Category already exists!");
        }
        return categoryRepository.save(category);
    }

    public Category getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + id));
    }
    
 // Used by admins to create/save a new category
    
    public Category saveCategory(Category category) {
        return categoryRepository.save(category);
    }
}
