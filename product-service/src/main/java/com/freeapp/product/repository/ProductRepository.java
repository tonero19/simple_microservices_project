package com.freeapp.product.repository;

import com.freeapp.product.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    // JpaRepository automatically generates standard CRUD methods (findAll, save, findById)
}

