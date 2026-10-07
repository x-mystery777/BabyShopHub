package com.babyshophub.dto;
import java.math.BigDecimal;
public record CartLineResponse(Long productId, String name, int quantity, BigDecimal unitPrice, BigDecimal subtotal) {}
