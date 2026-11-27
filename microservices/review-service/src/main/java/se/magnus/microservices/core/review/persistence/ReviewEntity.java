package se.magnus.microservices.core.review.persistence;

import jakarta.persistence.Entity;   // ✅ review는 JPA라서 jakarta.persistence 사용
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.Version;

@Entity
@Table(name = "reviews", indexes = {
  @Index(name = "reviews_unique_idx", unique = true, columnList = "productId,reviewId") })
public class ReviewEntity {

  @Id @GeneratedValue
  private int id;

  @Version
  private int version;

  private int productId;
  private int reviewId;
  private String author;
  private String subject;
  private String content;
  public ReviewEntity() {
  }


  public ReviewEntity(int productId, int reviewId, String author, String subject, String content) {
    this.productId = productId;
    this.reviewId = reviewId;
    this.author = author;
    this.subject = subject;
    this.content = content;
  }
  
  public int getId() { return id; }
  public int getVersion() { return version; }
  public int getProductId() { return productId; }
  public int getReviewId() { return reviewId; }
  public String getAuthor() { return author; }
  public String getSubject() { return subject; }
  public String getContent() { return content; }
  public void setId(int id) { this.id = id; }
  public void setVersion(int version) { this.version = version; }
  public void setProductId(int productId) { this.productId = productId; }
  public void setReviewId(int reviewId) { this.reviewId = reviewId; }
  public void setAuthor(String author) { this.author = author; }
  public void setSubject(String subject) { this.subject = subject; }
  public void setContent(String content) { this.content = content; }
}