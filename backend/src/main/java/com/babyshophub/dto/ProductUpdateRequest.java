package com.babyshophub.dto;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
public class ProductUpdateRequest {
 @Size(min=1) private String name; private String description;
 @DecimalMin("0.00") private BigDecimal price;
 @Min(0) private Integer stockQty;
 private Long categoryId; private Long brandId;
 public String getName(){return name;} public void setName(String v){name=v;}
 public String getDescription(){return description;} public void setDescription(String v){description=v;}
 public BigDecimal getPrice(){return price;} public void setPrice(BigDecimal v){price=v;}
 public Integer getStockQty(){return stockQty;} public void setStockQty(Integer v){stockQty=v;}
 public Long getCategoryId(){return categoryId;} public void setCategoryId(Long v){categoryId=v;}
 public Long getBrandId(){return brandId;} public void setBrandId(Long v){brandId=v;}
}
