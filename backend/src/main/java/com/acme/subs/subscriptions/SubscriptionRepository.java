package com.acme.subs.subscriptions;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface SubscriptionRepository extends JpaRepository<Subscription, UUID> {

    List<Subscription> findByUserIdAndActiveTrueOrderByNextRenewalAtAsc(UUID userId);

    @Query("""
    select s from Subscription s
    where s.active = true
      and s.nextRenewalAt >= :from
      and s.nextRenewalAt <= :to
  """)
    List<Subscription> findActiveWithRenewalBetween(Instant from, Instant to);
}
