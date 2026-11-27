package se.magnus.api.core.product;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import reactor.core.publisher.Mono;

public interface ProductService {

  Mono<Product> createProduct(Product body);       // @PostMapping 제거 (이벤트로 호출)

  @GetMapping(value = "/product/{productId}", produces = "application/json")
  Mono<Product> getProduct(@PathVariable int productId);

  Mono<Void> deleteProduct(int productId);         // @DeleteMapping 제거 (이벤트로 호출)
}