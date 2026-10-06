package com.babyshophub.repository;
import com.babyshophub.entity.ShopOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public interface ShopOrderRepository extends JpaRepository<ShopOrder, Long> {
    List<ShopOrder> findAllByUserEmailOrderByCreatedAtDesc(String email);
    Optional<ShopOrder> findByOrderIdAndUserEmail(Long id, String email);
}
