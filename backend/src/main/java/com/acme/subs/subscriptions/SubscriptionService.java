package com.acme.subs.subscriptions;

import com.acme.subs.common.NotFoundException;
import com.acme.subs.subscriptions.dto.SubscriptionCreateRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
