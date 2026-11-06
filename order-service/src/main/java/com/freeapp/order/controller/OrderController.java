package com.freeapp.order.controller;

import com.freeapp.order.model.Order;
import com.freeapp.order.repository.OrderRepository;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;
    private final RestClient productRestClient;

    public OrderController(OrderRepository orderRepository, RestClient productRestClient) {
        this.orderRepository = orderRepository;
        this.productRestClient = productRestClient;
    }

    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    @PostMapping
    public Order placeOrder(@RequestBody Order order) {
        // Inter-service call: Verify product existence before saving order
        try {
            productRestClient.get()
                    .uri("/api/products/{id}", order.getProductId())
                    .retrieve()
                    .toBodilessEntity();
        } catch (Exception e) {
            throw new RuntimeException("Cannot place order. Product validation failed: " + e.getMessage());
        }

        return orderRepository.save(order);
    }
}
