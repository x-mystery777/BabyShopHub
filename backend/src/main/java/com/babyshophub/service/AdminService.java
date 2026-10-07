package com.babyshophub.service;

import com.babyshophub.dto.AccountStatusRequest;
import com.babyshophub.dto.UserSummaryResponse;
import com.babyshophub.entity.User;
import com.babyshophub.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AdminService {
    private final UserRepository users;

    public AdminService(UserRepository users) {
        this.users = users;
    }

    @Transactional(readOnly = true)
    public List<UserSummaryResponse> listUsers() {
        return users.findAll().stream().map(this::toResponse).toList();
    }

    @Transactional
    public UserSummaryResponse setSuspended(Long userId, AccountStatusRequest request) {
        User user = users.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setSuspended(request.isSuspended());
        return toResponse(users.save(user));
    }

    private UserSummaryResponse toResponse(User user) {
        return new UserSummaryResponse(user.getId(), user.getName(), user.getEmail(), user.getPhoneNumber(),
                user.isEnabled(), user.isSuspended(), user.getRoles().stream().map(Enum::name)
                .collect(java.util.stream.Collectors.toSet()));
    }
}
