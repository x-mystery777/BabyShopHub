package com.babyshophub.service;

import com.babyshophub.dto.CartLineResponse;
import com.babyshophub.dto.CartResponse;
import com.babyshophub.entity.CartItem;
import com.babyshophub.entity.Product;
import com.babyshophub.entity.User;
import com.babyshophub.repository.CartItemRepository;
import com.babyshophub.repository.ProductRepository;
import com.babyshophub.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class CartService {
    private final UserRepository users;
    private final ProductRepository products;
    private final CartItemRepository cart;

    public CartService(UserRepository users, ProductRepository products, CartItemRepository cart) {
        this.users = users;
        this.products = products;
        this.cart = cart;
    }

    @Transactional(readOnly = true)
    public CartResponse getCart(String email) {
        return toResponse(cart.findAllByUserEmailOrderByCartItemId(email));
    }

    @Transactional
    public CartResponse addItem(String email, Long productId, int quantity) {
        if (quantity < 1) throw bad("Quantity must be at least one");
        Product product = products.findById(productId)
                .orElseThrow(() -> missing("Product not found"));
        if (!product.isActive()) throw bad("Product is unavailable");
        CartItem item = cart.findByUserEmailAndProductProductId(email, productId).orElseGet(() -> {
            CartItem newItem = new CartItem();
            newItem.setUser(user(email));
            newItem.setProduct(product);
            return newItem;
        });
        if (item.getQuantity() + quantity > product.getStockQty()) {
            throw bad("Requested quantity exceeds available stock");
        }
        item.setQuantity(item.getQuantity() + quantity);
        cart.save(item);
        return getCart(email);
    }

    @Transactional
    public CartResponse updateItem(String email, Long productId, int quantity) {
        if (quantity < 1) throw bad("Quantity must be at least one");
        CartItem item = cart.findByUserEmailAndProductProductId(email, productId)
                .orElseThrow(() -> missing("Cart item not found"));
        if (!item.getProduct().isActive() || quantity > item.getProduct().getStockQty()) {
            throw bad("Requested quantity exceeds available stock");
        }
        item.setQuantity(quantity);
        cart.save(item);
        return getCart(email);
    }

    @Transactional
    public void removeItem(String email, Long productId) {
        CartItem item = cart.findByUserEmailAndProductProductId(email, productId)
                .orElseThrow(() -> missing("Cart item not found"));
        cart.delete(item);
    }

    private CartResponse toResponse(List<CartItem> items) {
        List<CartLineResponse> lines = items.stream().map(item -> new CartLineResponse(
                item.getProduct().getProductId(), item.getProduct().getName(), item.getQuantity(),
                item.getProduct().getPrice(), item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))
        )).toList();
        BigDecimal total = lines.stream().map(CartLineResponse::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        return new CartResponse(lines, total);
    }

    private User user(String email) {
        return users.findByEmail(email).orElseThrow(() -> missing("User not found"));
    }

    private ResponseStatusException bad(String message) {
        return new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
    }

    private ResponseStatusException missing(String message) {
        return new ResponseStatusException(HttpStatus.NOT_FOUND, message);
    }
}
