package com.acme.subs.subscriptions;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface SubscriptionRepository extends JpaRepository<Subscription, UUID> {

    List<Subscription> findByUserIdAndActiveTrueOrderByNextRenewalAtAsc(UUID userId);

    List<Subscription> findByActiveTrueAndNextRenewalAtBefore(Instant cutoff);

    @Query("""
    select s from Subscription s
    where s.active = true
      and s.nextRenewalAt >= :from
      and s.nextRenewalAt <= :to
  """)
    List<Subscription> findActiveWithRenewalBetween(@Param("from") Instant from, @Param("to") Instant to);
}
