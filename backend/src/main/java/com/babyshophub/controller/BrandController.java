package com.babyshophub.controller;

import com.babyshophub.dto.BrandResponse;
import com.babyshophub.service.BrandService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/brands")
public class BrandController {
    private final BrandService brandService;
    public BrandController(BrandService brandService) { this.brandService = brandService; }
    @GetMapping
    public List<BrandResponse> getBrands() {
        return brandService.listBrands();
    }
}
