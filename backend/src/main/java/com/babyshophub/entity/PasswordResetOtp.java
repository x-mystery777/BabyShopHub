package com.babyshophub.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "password_reset_otps")
public class PasswordResetOtp {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long otpId;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id", nullable = false)
    private User user;
    @Column(name = "otp_hash", nullable = false, length = 100)
    private String otpHash;
    @Column(nullable = false)
    private LocalDateTime expiresAt;
    @Column(nullable = false)
    private int attempts = 0;
    @Column(nullable = false)
    private boolean used = false;
    @Column(nullable = false)
    private final LocalDateTime createdAt = LocalDateTime.now();

    public Long getOtpId() { return otpId; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getOtpHash() { return otpHash; }
    public void setOtpHash(String otpHash) { this.otpHash = otpHash; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
