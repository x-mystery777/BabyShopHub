package com.babyshophub.controller;
import com.babyshophub.dto.*;
import com.babyshophub.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
import java.util.List;
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final OrderService service;
    public OrderController(OrderService service){this.service=service;}
    @PostMapping public ResponseEntity<OrderResponse> checkout(Principal p,@Valid @RequestBody CheckoutRequest r){return ResponseEntity.ok(service.checkout(p.getName(),r.getAddressId()));}
    @GetMapping("/me") public List<OrderResponse> mine(Principal p){return service.myOrders(p.getName());}
    @GetMapping("/{id}") public OrderResponse mine(Principal p,@PathVariable Long id){return service.myOrder(p.getName(),id);}
    @GetMapping("/{id}/tracking") public List<TrackingResponse> tracking(Principal p,@PathVariable Long id){return service.tracking(p.getName(),id);}
}
