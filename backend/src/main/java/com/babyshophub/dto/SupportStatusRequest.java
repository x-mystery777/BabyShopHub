package com.babyshophub.dto;
import jakarta.validation.constraints.NotBlank;
public class SupportStatusRequest {
    @NotBlank private String status;
    private String adminResponse;
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }
}
