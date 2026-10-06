package com.babyshophub.dto;
import java.math.BigDecimal;
import java.util.List;
public record CartResponse(List<CartLineResponse> items, BigDecimal total) {}
