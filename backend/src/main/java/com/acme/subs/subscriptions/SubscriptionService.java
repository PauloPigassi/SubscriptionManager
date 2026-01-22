package com.acme.subs.subscriptions;

import com.acme.subs.common.NotFoundException;
import com.acme.subs.subscriptions.dto.SubscriptionCreateRequest;
import com.acme.subs.subscriptions.dto.SubscriptionUpdateRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class SubscriptionService {

    private final SubscriptionRepository repo;

    public SubscriptionService(SubscriptionRepository repo) {
        this.repo = repo;
    }

    public List<Subscription> list(UUID userId) {
        return repo.findByUserIdAndActiveTrueOrderByNextRenewalAtAsc(userId);
    }

    @Transactional
    public Subscription create(UUID userId, SubscriptionCreateRequest req) {
        Subscription s = new Subscription();
        s.setUserId(userId);
        s.setName(req.name());
        s.setAmountCents(req.amountCents());
        s.setBillingCycle(req.billingCycle());
        s.setIntervalCount(req.intervalCount() <= 0 ? 1 : req.intervalCount());
        s.setIntervalUnit(req.intervalUnit() == null ? "MONTH" : req.intervalUnit());
        s.setNextRenewalAt(req.nextRenewalAt());
        s.setCategory(req.category());
        s.setCatalogServiceId(req.catalogServiceId());
        s.setNotes(req.notes());
        return repo.save(s);
    }

    @Transactional
    public Subscription update(UUID userId, UUID subId, SubscriptionUpdateRequest req) {
        Subscription s = repo.findById(subId).orElseThrow(() -> new NotFoundException("subscription_not_found"));
        if (!s.getUserId().equals(userId)) throw new NotFoundException("subscription_not_found");
        if (req.name() != null) s.setName(req.name());
        if (req.amountCents() != null) s.setAmountCents(req.amountCents());
        if (req.billingCycle() != null) s.setBillingCycle(req.billingCycle());
        if (req.intervalCount() != null) s.setIntervalCount(req.intervalCount() <= 0 ? 1 : req.intervalCount());
        if (req.intervalUnit() != null) s.setIntervalUnit(req.intervalUnit());
        if (req.nextRenewalAt() != null) s.setNextRenewalAt(req.nextRenewalAt());
        if (req.category() != null) s.setCategory(req.category().isEmpty() ? null : req.category());
        if (req.notes() != null) s.setNotes(req.notes().isEmpty() ? null : req.notes());
        s.setUpdatedAt(Instant.now());
        return repo.save(s);
    }

    @Transactional
    public void archive(UUID userId, UUID subId) {
        Subscription s = repo.findById(subId).orElseThrow(() -> new NotFoundException("subscription_not_found"));
        if (!s.getUserId().equals(userId)) throw new NotFoundException("subscription_not_found");
        s.setActive(false);
        repo.save(s);
    }
}
