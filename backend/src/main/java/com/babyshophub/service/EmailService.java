package com.babyshophub.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    // Modern Constructor Injection
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendVerificationEmail(String toEmail, String verificationCode) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("BabyShopHub - Email Verification Code");
        message.setText("Your verification code is: " + verificationCode + 
                        "\n\nPlease use this code to activate your account. It expires in 15 minutes.");
        mailSender.send(message);
    }

    public void sendPasswordResetEmail(String toEmail, String resetCode) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("BabyShopHub - Password Reset Code");
        message.setText("Your password reset code is: " + resetCode
                + "\n\nEnter this code to reset your password. It expires in 10 minutes."
                + " If you did not request a reset, you can ignore this email.");
        mailSender.send(message);
    }
}
