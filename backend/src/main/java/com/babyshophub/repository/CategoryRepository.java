package com.babyshophub.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.babyshophub.entity.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    boolean existsByName(String name);
    java.util.List<Category> findAllByActiveTrue();
}
