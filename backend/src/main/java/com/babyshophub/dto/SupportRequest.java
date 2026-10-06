package com.babyshophub.dto;
import jakarta.validation.constraints.NotBlank;
public class SupportRequest { @NotBlank private String subject; @NotBlank private String message; public String getSubject(){return subject;} public void setSubject(String subject){this.subject=subject;} public String getMessage(){return message;} public void setMessage(String message){this.message=message;} }
