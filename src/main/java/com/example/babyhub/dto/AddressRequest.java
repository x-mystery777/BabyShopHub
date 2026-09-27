package com.example.babyhub.dto;

import lombok.Data;

@Data
public class AddressRequest {
    private String recipientName;
    private String phoneNumber;
    private String streetAddress;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    private boolean isDefault;
}
