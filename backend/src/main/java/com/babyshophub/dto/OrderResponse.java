package com.babyshophub.dto;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
public record OrderResponse(Long orderId, String orderStatus, String paymentStatus, String shippingAddress, BigDecimal totalAmount, LocalDateTime createdAt, List<CartLineResponse> items) {}
