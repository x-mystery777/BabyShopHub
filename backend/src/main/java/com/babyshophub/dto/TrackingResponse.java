package com.babyshophub.dto;
import java.time.LocalDateTime;
public record TrackingResponse(Long trackingId, String status, String note, LocalDateTime createdAt) {}
