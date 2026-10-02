package com.example.babyhub.controller;

import com.example.babyhub.dto.AddressRequest;
import com.example.babyhub.model.Address;
import com.example.babyhub.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/addresses")
@RequiredArgsConstructor
public class AddressController {

    private final AddressService addressService;

    @PostMapping
    public ResponseEntity<Address> addAddress(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody AddressRequest request) {
        Address createdAddress = addressService.addAddress(userDetails.getUsername(), request);
        return ResponseEntity.ok(createdAddress);
    }

    @GetMapping
    public ResponseEntity<List<Address>> getUserAddresses(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<Address> addresses = addressService.getUserAddresses(userDetails.getUsername());
        return ResponseEntity.ok(addresses);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteAddress(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        addressService.deleteAddress(id, userDetails.getUsername());
        return ResponseEntity.ok("Address deleted successfully");
    }
}