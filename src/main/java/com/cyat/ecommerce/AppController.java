package com.cyat.ecommerce;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/api")
public class AppController {
    
    @GetMapping("/")
    public String home() {
        return "Welcome to CEEYIT E-Commerce Backend";
    }
    
    @GetMapping("/health")
    public String health() {
        return "Service is healthy";
    }
    
    @GetMapping("/products")
    public String getProducts() {
        return "[{\"id\":1,\"name\":\"Laptop\",\"price\":999.99},{\"id\":2,\"name\":\"Smartphone\",\"price\":499.99}]";
    }
}