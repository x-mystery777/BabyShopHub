package com.babyshophub.dto;
import java.util.Set;
public record UserSummaryResponse(Long id, String name, String email, String phoneNumber, boolean enabled, boolean suspended, Set<String> roles) {}
