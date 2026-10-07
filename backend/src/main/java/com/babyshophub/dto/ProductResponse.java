package com.babyshophub.dto;

import com.babyshophub.entity.Product;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record ProductResponse(Long productId, String name, String description, BigDecimal price, Integer stockQty,
                              boolean active, LocalDateTime createdAt, List<String> imageUrls,
                              Long categoryId, String categoryName, Long brandId, String brandName) {
    public static ProductResponse from(Product product) {
        return new ProductResponse(product.getProductId(), product.getName(), product.getDescription(), product.getPrice(),
                product.getStockQty(), product.isActive(), product.getCreatedAt(), product.getImageUrls() == null ? List.of() : List.copyOf(product.getImageUrls()),
                product.getCategory().getCategoryId(), product.getCategory().getName(),
                product.getBrand().getBrandId(), product.getBrand().getName());
    }
}
