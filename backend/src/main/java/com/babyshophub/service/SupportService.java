package com.babyshophub.service;
import com.babyshophub.dto.*;
import com.babyshophub.entity.*;
import com.babyshophub.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
@Service public class SupportService {
 private final SupportTicketRepository tickets; private final UserRepository users;
 public SupportService(SupportTicketRepository tickets,UserRepository users){this.tickets=tickets;this.users=users;}
 @Transactional public SupportResponse create(String email,SupportRequest req){User u=users.findByEmail(email).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"User not found"));SupportTicket t=new SupportTicket();t.setUser(u);t.setSubject(req.getSubject());t.setMessage(req.getMessage());return response(tickets.save(t));}
 @Transactional(readOnly=true) public List<SupportResponse> mine(String email){return tickets.findAllByUserEmailOrderByCreatedAtDesc(email).stream().map(this::response).toList();}
 @Transactional(readOnly=true) public List<SupportResponse> all(){return tickets.findAllByOrderByCreatedAtDesc().stream().map(this::response).toList();}
 @Transactional public SupportResponse status(Long id,SupportStatusRequest request){String s=request.getStatus()==null?"":request.getStatus().trim().toUpperCase();if(!List.of("OPEN","IN_PROGRESS","CLOSED").contains(s))throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Unsupported ticket status");SupportTicket t=tickets.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Ticket not found"));t.setStatus(s);if(request.getAdminResponse()!=null)t.setAdminResponse(request.getAdminResponse());return response(tickets.save(t));}
 private SupportResponse response(SupportTicket t){return new SupportResponse(t.getTicketId(),t.getUser().getEmail(),t.getSubject(),t.getMessage(),t.getAdminResponse(),t.getStatus(),t.getCreatedAt());}
}
