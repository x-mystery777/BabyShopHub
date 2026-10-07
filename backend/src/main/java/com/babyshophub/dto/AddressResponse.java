package com.babyshophub.dto;
public record AddressResponse(Long addressId, String label, String line1, String city, String state, String country, String postalCode, boolean isDefault) {}
