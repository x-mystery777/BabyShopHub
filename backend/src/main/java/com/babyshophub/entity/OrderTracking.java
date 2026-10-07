package com.babyshophub.entity;
import jakarta.persistence.*;
import java.time.LocalDateTime;
@Entity @Table(name="order_tracking")
public class OrderTracking {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long trackingId;
 @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="order_id",nullable=false) private ShopOrder order;
 @Column(nullable=false) private String status;
 private String note;
 @Column(nullable=false) private final LocalDateTime createdAt=LocalDateTime.now();
 public Long getTrackingId(){return trackingId;} public ShopOrder getOrder(){return order;} public void setOrder(ShopOrder order){this.order=order;}
 public String getStatus(){return status;} public void setStatus(String status){this.status=status;}
 public String getNote(){return note;} public void setNote(String note){this.note=note;}
 public LocalDateTime getCreatedAt(){return createdAt;}
}
