package com.cyat.ecommerce;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
<<<<<<< HEAD
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
=======

@RestController
public class AppController {

    @GetMapping("/")
    public String home() {
        return "<html><head><style>" +
               "body { font-family: Arial; background: #f4f4f9; color: #333; text-align: center; padding: 50px; }" +
               "img { max-width: 300px; margin-top: 20px; }" +
               "</style></head>" +
               "<body><h1>Welcome to CEEYIT E-Commerce Backend</h1>" +
               "<p>This is a sample API running on Spring Boot.</p>" +
               "<img src='/ceeyit.png' alt='CEEYIT Logo' />" +
               "</body></html>";
    }
}
// This code defines a simple Spring Boot REST controller that serves a welcome message
>>>>>>> 943ee0b81e73be5ba97817c57c11e5f82a79519b
