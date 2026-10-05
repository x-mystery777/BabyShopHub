package com.babyshophub.repository;
import com.babyshophub.entity.SupportTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface SupportTicketRepository extends JpaRepository<SupportTicket, Long> {
 List<SupportTicket> findAllByUserEmailOrderByCreatedAtDesc(String email);
 List<SupportTicket> findAllByOrderByCreatedAtDesc();
}
