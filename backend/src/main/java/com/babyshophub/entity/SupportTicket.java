package com.babyshophub.entity;
import jakarta.persistence.*;
import java.time.LocalDateTime;
@Entity @Table(name="support_tickets")
public class SupportTicket {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long ticketId;
 @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
 @Column(nullable=false) private String subject;
 @Column(nullable=false,columnDefinition="TEXT") private String message;
 @Column(columnDefinition="TEXT") private String adminResponse;
 @Column(nullable=false) private String status="OPEN";
 @Column(nullable=false) private final LocalDateTime createdAt=LocalDateTime.now();
 public Long getTicketId(){return ticketId;} public User getUser(){return user;} public void setUser(User user){this.user=user;}
 public String getSubject(){return subject;} public void setSubject(String subject){this.subject=subject;}
 public String getMessage(){return message;} public void setMessage(String message){this.message=message;}
 public String getAdminResponse(){return adminResponse;} public void setAdminResponse(String adminResponse){this.adminResponse=adminResponse;}
 public String getStatus(){return status;} public void setStatus(String status){this.status=status;}
 public LocalDateTime getCreatedAt(){return createdAt;}
}
