package com.babyshophub.service;
import com.babyshophub.dto.*;
import com.babyshophub.entity.*;
import com.babyshophub.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
@Service public class ReviewService {
 private final ProductReviewRepository reviews; private final ProductRepository products; private final UserRepository users;
 public ReviewService(ProductReviewRepository reviews,ProductRepository products,UserRepository users){this.reviews=reviews;this.products=products;this.users=users;}
 @Transactional(readOnly=true) public List<ReviewResponse> list(Long productId){if(!products.existsById(productId))throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Product not found");return reviews.findAllByProductProductIdOrderByCreatedAtDesc(productId).stream().map(this::response).toList();}
 @Transactional public ReviewResponse add(String email,Long productId,ReviewRequest request){Product p=products.findById(productId).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Product not found"));User u=users.findByEmail(email).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"User not found"));ProductReview r=new ProductReview();r.setProduct(p);r.setUser(u);r.setRating(request.getRating());r.setComment(request.getComment());return response(reviews.save(r));}
 private ReviewResponse response(ProductReview r){return new ReviewResponse(r.getReviewId(),r.getUser().getName(),r.getRating(),r.getComment(),r.getCreatedAt());}
}
