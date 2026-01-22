package com.acme.subs.subscriptions;

import com.acme.subs.subscriptions.dto.SubscriptionCreateRequest;
import com.acme.subs.subscriptions.dto.SubscriptionIconUploadRequest;
import com.acme.subs.subscriptions.dto.SubscriptionIconUploadResponse;
import com.acme.subs.subscriptions.dto.SubscriptionUpdateRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/subscriptions")
public class SubscriptionController {

    private final SubscriptionService service;

    public SubscriptionController(SubscriptionService service) {
        this.service = service;
    }

    @GetMapping
    public List<Subscription> list(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        return service.list(userId);
    }

    @PostMapping
    public Subscription create(Authentication auth, @Valid @RequestBody SubscriptionCreateRequest req) {
        UUID userId = (UUID) auth.getPrincipal();
        return service.create(userId, req);
    }

    @PatchMapping("/{id}")
    public Subscription update(Authentication auth, @PathVariable("id") UUID id, @RequestBody SubscriptionUpdateRequest req) {
        UUID userId = (UUID) auth.getPrincipal();
        // Log para debug
        System.out.println("[DEBUG] Update request - name: " + req.name() + ", amountCents: " + req.amountCents() + 
            ", billingCycle: " + req.billingCycle() + ", category: " + req.category());
        return service.update(userId, id, req);
    }

    @PostMapping("/{id}/icon-upload")
    public SubscriptionIconUploadResponse createIconUpload(
            Authentication auth,
            @PathVariable("id") UUID id,
            @Valid @RequestBody SubscriptionIconUploadRequest req
    ) {
        UUID userId = (UUID) auth.getPrincipal();
        return service.createIconUpload(userId, id, req);
    }

    @DeleteMapping("/{id}")
    public void archive(Authentication auth, @PathVariable("id") UUID id) {
        UUID userId = (UUID) auth.getPrincipal();
        service.archive(userId, id);
    }
}
