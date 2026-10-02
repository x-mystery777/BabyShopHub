package com.example.babyhub.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret:BabyHubSuperSecretKeyForTokenGenerationAndValidation123456789}")
    private String secretKey;

    @Value("${jwt.expiration:86400000}") // 24 hours
    private long jwtExpiration;

    public String generateToken(UserDetails userDetails) {
        long expirationTime = System.currentTimeMillis() + jwtExpiration;
        String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        String payload = "{\"sub\":\"" + userDetails.getUsername() + "\",\"exp\":" + expirationTime + "}";

        String encodedHeader = Base64.getUrlEncoder().withoutPadding().encodeToString(header.getBytes(StandardCharsets.UTF_8));
        String encodedPayload = Base64.getUrlEncoder().withoutPadding().encodeToString(payload.getBytes(StandardCharsets.UTF_8));

        String dataToSign = encodedHeader + "." + encodedPayload;
        String signature = hmacSha256(dataToSign, secretKey);

        return dataToSign + "." + signature;
    }

    public String extractUsername(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) return null;
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);

            // Simple string parsing for "sub"
            int subIndex = payloadJson.indexOf("\"sub\":\"");
            if (subIndex == -1) return null;
            int startIndex = subIndex + 7;
            int endIndex = payloadJson.indexOf("\"", startIndex);
            return payloadJson.substring(startIndex, endIndex);
        } catch (Exception e) {
            return null;
        }
    }

    public boolean validateToken(String token, UserDetails userDetails) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) return false;

            String dataToSign = parts[0] + "." + parts[1];
            String expectedSignature = hmacSha256(dataToSign, secretKey);

            if (!expectedSignature.equals(parts[2])) {
                return false; // Invalid signature
            }

            String username = extractUsername(token);
            return username != null && username.equals(userDetails.getUsername()) && !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isTokenExpired(String token) {
        try {
            String[] parts = token.split("\\.");
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);

            int expIndex = payloadJson.indexOf("\"exp\":");
            if (expIndex == -1) return true;
            int startIndex = expIndex + 6;
            int endIndex = payloadJson.indexOf("}", startIndex);
            if (endIndex == -1) endIndex = payloadJson.indexOf(",", startIndex);

            long expirationTime = Long.parseLong(payloadJson.substring(startIndex, endIndex).trim());
            return System.currentTimeMillis() > expirationTime;
        } catch (Exception e) {
            return true;
        }
    }

    private String hmacSha256(String data, String secret) {
        try {
            Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
            SecretKeySpec secret_key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256_HMAC.init(secret_key);
            byte[] hash = sha256_HMAC.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to calculate HMAC-SHA256", e);
        }
    }
}