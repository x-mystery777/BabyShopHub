package com.babyshophub.controller;
import com.babyshophub.dto.*;
import com.babyshophub.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
import java.util.List;
@RestController @RequestMapping("/api")
public class ReviewController {
 private final ReviewService service;
 public ReviewController(ReviewService service){this.service=service;}
 @GetMapping({"/reviews/products/{productId}", "/products/{productId}/reviews"}) public List<ReviewResponse> list(@PathVariable Long productId){return service.list(productId);}
 @PostMapping({"/reviews/products/{productId}", "/products/{productId}/reviews"}) public ReviewResponse add(Principal p,@PathVariable Long productId,@Valid @RequestBody ReviewRequest request){return service.add(p.getName(),productId,request);}
}
