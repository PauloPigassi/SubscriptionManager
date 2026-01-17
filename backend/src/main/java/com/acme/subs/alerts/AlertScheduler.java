package com.acme.subs.alerts;

import com.acme.subs.subscriptions.Subscription;
import com.acme.subs.subscriptions.SubscriptionRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Component
public class AlertScheduler {

    private final SubscriptionRepository subRepo;
    private final AlertRuleRepository ruleRepo;
    private final AlertRepository alertRepo;
    private final AlertService alertService;

    @Value("${app.scheduler.horizonDays:30}")
    private int horizonDays;

    public AlertScheduler(SubscriptionRepository subRepo,
                          AlertRuleRepository ruleRepo,
                          AlertRepository alertRepo,
                          AlertService alertService) {
        this.subRepo = subRepo;
        this.ruleRepo = ruleRepo;
        this.alertRepo = alertRepo;
        this.alertService = alertService;
    }

    // Job A: 03:00 - cria alertas para próximas renovações
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void generateUpcomingAlerts() {
        Instant now = Instant.now();
        Instant horizon = now.plus(horizonDays, ChronoUnit.DAYS);

        List<Subscription> subs = subRepo.findActiveWithRenewalBetween(now, horizon);

        for (Subscription sub : subs) {
            var rules = ruleRepo.findByUserIdAndEnabledTrue(sub.getUserId());
            for (var r : rules) {
                Instant scheduledAt = sub.getNextRenewalAt().minus(r.getDaysBefore(), ChronoUnit.DAYS);
                if (scheduledAt.isBefore(now.minus(1, ChronoUnit.DAYS))) continue; // evita criar alertas no passado

                boolean exists = alertRepo.existsBySubscriptionIdAndDaysBeforeAndScheduledAt(
                        sub.getId(), r.getDaysBefore(), scheduledAt
                );

                if (!exists) {
                    alertRepo.save(Alert.pending(sub.getUserId(), sub.getId(), r.getDaysBefore(), scheduledAt));
                }
            }
        }
    }

    // Job B: a cada 5 min - dispara alertas pendentes
    @Scheduled(cron = "0 */5 * * * *")
    public void dispatchPendingAlerts() {
        List<Alert> due = alertRepo.findPendingDue(Instant.now());
        System.out.println("[AlertScheduler] Found " + due.size() + " pending alerts to dispatch");
        for (Alert a : due) {
            alertService.send(a);
        }
    }
}
