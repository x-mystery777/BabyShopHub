package com.babyshophub.service;

import com.babyshophub.dto.BrandResponse;
import com.babyshophub.repository.BrandRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BrandService {
    private final BrandRepository brands;

    public BrandService(BrandRepository brands) {
        this.brands = brands;
    }

    @Transactional(readOnly = true)
    public List<BrandResponse> listBrands() {
        return brands.findAll().stream().map(BrandResponse::from).toList();
    }
}
