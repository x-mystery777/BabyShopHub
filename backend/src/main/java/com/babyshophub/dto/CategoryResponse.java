package com.babyshophub.dto;
import com.babyshophub.entity.Category;
public record CategoryResponse(Long categoryId, String name, String description, boolean active) {
    public static CategoryResponse from(Category c) { return new CategoryResponse(c.getCategoryId(), c.getName(), c.getDescription(), c.isActive()); }
}
