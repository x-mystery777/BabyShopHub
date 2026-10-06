package com.babyshophub.service;

import com.babyshophub.dto.CartLineResponse;
import com.babyshophub.dto.OrderResponse;
import com.babyshophub.dto.TrackingResponse;
import com.babyshophub.entity.Address;
import com.babyshophub.entity.CartItem;
import com.babyshophub.entity.OrderTracking;
import com.babyshophub.entity.Payment;
import com.babyshophub.entity.Product;
import com.babyshophub.entity.ShopOrder;
import com.babyshophub.entity.ShopOrderItem;
import com.babyshophub.entity.User;
import com.babyshophub.repository.AddressRepository;
import com.babyshophub.repository.CartItemRepository;
import com.babyshophub.repository.OrderTrackingRepository;
import com.babyshophub.repository.ProductRepository;
import com.babyshophub.repository.ShopOrderRepository;
import com.babyshophub.repository.UserRepository;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class OrderService {
    private final UserRepository users;
    private final ProductRepository products;
    private final CartItemRepository cart;
    private final AddressRepository addresses;
    private final ShopOrderRepository orders;
    private final OrderTrackingRepository tracking;

    public OrderService(UserRepository users, ProductRepository products, CartItemRepository cart,
                        AddressRepository addresses, ShopOrderRepository orders,
                        OrderTrackingRepository tracking) {
        this.users = users;
        this.products = products;
        this.cart = cart;
        this.addresses = addresses;
        this.orders = orders;
        this.tracking = tracking;
    }

    @Transactional
    public OrderResponse checkout(String email, Long addressId) {
        List<CartItem> cartItems = cart.findAllByUserEmailOrderByCartItemId(email);
        if (cartItems.isEmpty()) throw bad("Cart is empty");
        Address address = addresses.findByAddressIdAndUserEmail(addressId, email)
                .orElseThrow(() -> missing("Delivery address not found"));
        ShopOrder order = new ShopOrder();
        order.setUser(user(email));
        order.setShippingAddress(String.join(", ", address.getLine1(), address.getCity(),
                address.getState() == null ? "" : address.getState(), address.getCountry(),
                address.getPostalCode() == null ? "" : address.getPostalCode()));

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem cartItem : cartItems) {
            Product product = products.findByIdForUpdate(cartItem.getProduct().getProductId())
                    .orElseThrow(() -> missing("Product not found"));
            if (!product.isActive() || product.getStockQty() < cartItem.getQuantity()) {
                throw bad("Insufficient stock for " + product.getName());
            }
            BigDecimal subtotal = product.getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity()));
            total = total.add(subtotal);
            ShopOrderItem item = new ShopOrderItem();
            item.setProduct(product);
            item.setProductName(product.getName());
            item.setQuantity(cartItem.getQuantity());
            item.setUnitPrice(product.getPrice());
            item.setSubtotal(subtotal);
            order.addItem(item);
            product.setStockQty(product.getStockQty() - cartItem.getQuantity());
        }

        order.setTotalAmount(total);
        Payment payment = new Payment();
        payment.setMethod("DUMMY");
        payment.setStatus("PAID");
        payment.setReference("DUMMY-" + java.util.UUID.randomUUID());
        payment.setAmount(total);
        order.addPayment(payment);
        OrderTracking firstEvent = new OrderTracking();
        firstEvent.setStatus("CONFIRMED");
        firstEvent.setNote("Order placed; dummy payment recorded.");
        order.addTracking(firstEvent);

        ShopOrder saved = orders.save(order);
        cart.deleteAll(cartItems);
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> myOrders(String email) {
        return orders.findAllByUserEmailOrderByCreatedAtDesc(email).stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse myOrder(String email, Long id) {
        return toResponse(orders.findByOrderIdAndUserEmail(id, email)
                .orElseThrow(() -> missing("Order not found")));
    }

    @Transactional(readOnly = true)
    public List<TrackingResponse> tracking(String email, Long id) {
        orders.findByOrderIdAndUserEmail(id, email).orElseThrow(() -> missing("Order not found"));
        return tracking.findAllByOrderOrderIdOrderByCreatedAtAsc(id).stream()
                .map(event -> new TrackingResponse(event.getTrackingId(), event.getStatus(), event.getNote(), event.getCreatedAt()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> allOrders() {
        return orders.findAll(Sort.by(Sort.Direction.DESC, "createdAt")).stream().map(this::toResponse).toList();
    }

    @Transactional
    public OrderResponse changeOrderStatus(Long id, String status) {
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!List.of("CONFIRMED", "PACKED", "SHIPPED", "DELIVERED", "CANCELLED").contains(normalized)) {
            throw bad("Unsupported order status");
        }
        ShopOrder order = orders.findById(id).orElseThrow(() -> missing("Order not found"));
        if (normalized.equals(order.getOrderStatus())) return toResponse(order);
        if (normalized.equals("CANCELLED")) {
            if (!List.of("CONFIRMED", "PACKED").contains(order.getOrderStatus())) {
                throw bad("Only confirmed or packed orders can be cancelled");
            }
            for (ShopOrderItem item : order.getItems()) {
                Product product = products.findByIdForUpdate(item.getProduct().getProductId())
                        .orElseThrow(() -> missing("Product not found"));
                product.setStockQty(product.getStockQty() + item.getQuantity());
            }
        } else {
            List<String> progression = List.of("CONFIRMED", "PACKED", "SHIPPED", "DELIVERED");
            int current = progression.indexOf(order.getOrderStatus());
            int next = progression.indexOf(normalized);
            if (current < 0 || next != current + 1) throw bad("Order statuses must advance one step at a time");
        }
        order.setOrderStatus(normalized);
        OrderTracking event = new OrderTracking();
        event.setStatus(normalized);
        event.setNote("Order status updated by administrator.");
        order.addTracking(event);
        return toResponse(orders.save(order));
    }

    private OrderResponse toResponse(ShopOrder order) {
        List<CartLineResponse> lines = order.getItems().stream().map(item -> new CartLineResponse(
                item.getProduct().getProductId(), item.getProductName(), item.getQuantity(),
                item.getUnitPrice(), item.getSubtotal())).toList();
        return new OrderResponse(order.getOrderId(), order.getOrderStatus(), order.getPaymentStatus(),
                order.getShippingAddress(), order.getTotalAmount(), order.getCreatedAt(), lines);
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
