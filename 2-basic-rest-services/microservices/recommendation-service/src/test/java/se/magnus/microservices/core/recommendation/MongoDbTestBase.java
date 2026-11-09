package se.magnus.microservices.core.recommendation;

import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.mongodb.MongoDBContainer;

public abstract class MongoDbTestBase {

  @ServiceConnection
  private static MongoDBContainer database = new MongoDBContainer("mongo:8.0.5");

  static {
    database.start();
  }

}
