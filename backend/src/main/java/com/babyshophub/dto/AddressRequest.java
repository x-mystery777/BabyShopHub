package com.babyshophub.dto;

import jakarta.validation.constraints.NotBlank;

public class AddressRequest {
    private String label;
    @NotBlank private String line1;
    @NotBlank private String city;
    private String state;
    @NotBlank private String country;
    private String postalCode;
    private boolean isDefault;
    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public String getLine1() { return line1; }
    public void setLine1(String line1) { this.line1 = line1; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean aDefault) { isDefault = aDefault; }
}
