package com.acme.subs.alerts;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface AlertRepository extends JpaRepository<Alert, UUID> {

    @Query(value = """
        select exists(
            select 1 from alerts a
            where a.subscription_id = :subscriptionId
              and a.days_before = :daysBefore
              and a.scheduled_at = :scheduledAt
        )
      """, nativeQuery = true)
    boolean existsBySubscriptionIdAndDaysBeforeAndScheduledAt(
            @Param("subscriptionId") UUID subscriptionId,
            @Param("daysBefore") int daysBefore,
            @Param("scheduledAt") Instant scheduledAt);

    @Query("""
    select a from Alert a
    where a.status = 'PENDING'
      and a.scheduledAt <= :now
    order by a.scheduledAt asc
  """)
    List<Alert> findPendingDue(@Param("now") Instant now);

    @Modifying
    @Query("""
    update Alert a set a.status = 'SKIPPED'
    where a.userId = :userId
      and a.status = 'PENDING'
      and a.daysBefore not in :days
  """)
    int skipPendingExcept(@Param("userId") UUID userId, @Param("days") Collection<Integer> days);

    @Modifying
    @Query("""
    update Alert a set a.status = 'SKIPPED'
    where a.userId = :userId
      and a.status = 'PENDING'
  """)
    int skipAllPending(@Param("userId") UUID userId);

}
