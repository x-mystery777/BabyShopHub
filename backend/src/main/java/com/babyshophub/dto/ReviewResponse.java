package com.babyshophub.dto;
import java.time.LocalDateTime;
public record ReviewResponse(Long reviewId, String reviewer, Integer rating, String comment, LocalDateTime createdAt) {}
