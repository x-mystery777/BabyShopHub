package com.babyshophub.controller;
import com.babyshophub.dto.*;
import com.babyshophub.service.CartService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
@RestController
@RequestMapping("/api/cart")
public class CartController {
    private final CartService service;
    public CartController(CartService service){this.service=service;}
    @GetMapping public CartResponse get(Principal p){return service.getCart(p.getName());}
    @PostMapping("/items") public CartResponse add(Principal p,@Valid @RequestBody CartItemRequest q){return service.addItem(p.getName(),q.getProductId(),q.getQuantity());}
    @PatchMapping("/items/{productId}") public CartResponse update(Principal p,@PathVariable Long productId,@Valid @RequestBody QuantityRequest q){return service.updateItem(p.getName(),productId,q.getQuantity());}
    @DeleteMapping("/items/{productId}") public ResponseEntity<Void> remove(Principal p,@PathVariable Long productId){service.removeItem(p.getName(),productId);return ResponseEntity.noContent().build();}
}
