package se.magnus.api.composite.product;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

public interface ProductCompositeService {

  @PostMapping(
    value    = "/product-composite",
    consumes = "application/json")
  void createProduct(@RequestBody ProductAggregate body);              // ← 추가


  @GetMapping(
    value = "/product-composite/{productId}",
    produces = "application/json")
  ProductAggregate getProduct(@PathVariable int productId);


  @DeleteMapping(value = "/product-composite/{productId}")
  void deleteProduct(@PathVariable int productId);                     // ← 추가
}