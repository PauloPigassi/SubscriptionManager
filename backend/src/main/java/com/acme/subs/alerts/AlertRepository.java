package com.acme.subs.alerts;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface AlertRepository extends JpaRepository<Alert, UUID> {

    boolean existsBySubscriptionIdAndDaysBeforeAndScheduledAt(UUID subscriptionId, int daysBefore, Instant scheduledAt);

    @Query("""
    select a from Alert a
    where a.status = 'PENDING'
      and a.scheduledAt <= :now
    order by a.scheduledAt asc
  """)
    List<Alert> findPendingDue(Instant now);

}
