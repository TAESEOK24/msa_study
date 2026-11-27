package se.magnus.microservices.core.review;

import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.mysql.MySQLContainer;   // 🔧 2.x 패키지 (교재: org.testcontainers.containers)

public abstract class MySqlTestBase {

  @ServiceConnection
  static final MySQLContainer database =   // 🔧 2.x는 제네릭 없는 클래스
    new MySQLContainer("mysql:9.2.0").withStartupTimeoutSeconds(300);

  static {
    database.start();
  }
}