package com.babyshophub.controller;
import com.babyshophub.dto.*;
import com.babyshophub.service.SupportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
import java.util.List;
@RestController @RequestMapping("/api/support")
public class SupportController {
 private final SupportService service;
 public SupportController(SupportService service){this.service=service;}
 @PostMapping public SupportResponse create(Principal p,@Valid @RequestBody SupportRequest r){return service.create(p.getName(),r);}
 @GetMapping("/me") public List<SupportResponse> mine(Principal p){return service.mine(p.getName());}
}
