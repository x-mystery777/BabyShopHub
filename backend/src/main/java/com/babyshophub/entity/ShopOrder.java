package com.babyshophub.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class ShopOrder {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long orderId;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id", nullable = false) private User user;
    @Column(name = "shipping_address_snapshot", nullable = false, length = 1000) private String shippingAddress;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalAmount;
    @Column(nullable = false) private final String paymentStatus = "PAID";
    @Column(nullable = false) private String orderStatus = "CONFIRMED";
    @Column(nullable = false) private final LocalDateTime createdAt = LocalDateTime.now();
    @Column(nullable = false) private LocalDateTime updatedAt = LocalDateTime.now();
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true) private final List<ShopOrderItem> items = new ArrayList<>();
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true) private final List<OrderTracking> tracking = new ArrayList<>();
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true) private final List<Payment> payments = new ArrayList<>();
    public Long getOrderId() { return orderId; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getPaymentStatus() { return paymentStatus; }
    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public List<ShopOrderItem> getItems() { return items; }
    public void addItem(ShopOrderItem item) { items.add(item); item.setOrder(this); }
    public List<OrderTracking> getTracking() { return tracking; }
    public void addTracking(OrderTracking event) { tracking.add(event); event.setOrder(this); }
    public void addPayment(Payment payment) { payments.add(payment); payment.setOrder(this); }
    @PrePersist
    @PreUpdate
    public void updateTimestamp() { this.updatedAt = LocalDateTime.now(); }
}
