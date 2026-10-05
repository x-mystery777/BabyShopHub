package com.babyshophub.repository;

import com.babyshophub.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findAllByUserEmailOrderByAddressId(String email);
    Optional<Address> findByAddressIdAndUserEmail(Long id, String email);
    boolean existsByAddressIdAndUserEmail(Long id, String email);
}
