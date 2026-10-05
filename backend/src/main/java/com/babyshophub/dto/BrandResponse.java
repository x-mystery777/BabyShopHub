package com.babyshophub.dto;
import com.babyshophub.entity.Brand;
public record BrandResponse(Long brandId, String name, String description) {
    public static BrandResponse from(Brand b) { return new BrandResponse(b.getBrandId(), b.getName(), b.getDescription()); }
}
