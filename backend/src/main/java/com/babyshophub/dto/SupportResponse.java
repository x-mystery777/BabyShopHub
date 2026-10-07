package com.babyshophub.dto;
import java.time.LocalDateTime;
public record SupportResponse(Long ticketId, String requesterEmail, String subject, String message, String adminResponse, String status, LocalDateTime createdAt) {}
