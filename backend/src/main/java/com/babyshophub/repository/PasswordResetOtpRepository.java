package com.babyshophub.repository;

import com.babyshophub.entity.PasswordResetOtp;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PasswordResetOtpRepository extends JpaRepository<PasswordResetOtp, Long> {
    Optional<PasswordResetOtp> findTopByUserEmailOrderByCreatedAtDesc(String email);
    Optional<PasswordResetOtp> findTopByUserEmailAndUsedFalseOrderByCreatedAtDesc(String email);
    List<PasswordResetOtp> findAllByUserEmailAndUsedFalse(String email);
}
