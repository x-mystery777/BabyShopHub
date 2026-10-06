package com.babyshophub.dto;
import jakarta.validation.constraints.NotNull;
public class CheckoutRequest { @NotNull private Long addressId; public Long getAddressId(){return addressId;} public void setAddressId(Long addressId){this.addressId=addressId;} }
