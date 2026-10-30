package com.acme.subs.subscriptions;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Component
public class RenewalScheduler {

    private final SubscriptionRepository subRepo;

    public RenewalScheduler(SubscriptionRepository subRepo) {
        this.subRepo = subRepo;
    }

    // A cada hora: avança next_renewal_at das assinaturas cuja renovação já passou.
    // Mantém 1 dia de tolerância para que a renovação ainda apareça como "hoje" no app.
    @Scheduled(cron = "0 15 * * * *")
    @Transactional
    public void advancePastRenewals() {
        Instant now = Instant.now();
        Instant cutoff = now.minus(1, ChronoUnit.DAYS);

        List<Subscription> due = subRepo.findByActiveTrueAndNextRenewalAtBefore(cutoff);
        for (Subscription s : due) {
            Instant next = s.getNextRenewalAt();
            // Loop cobre assinaturas que ficaram vários ciclos sem atualização
            while (next.isBefore(cutoff)) {
                next = BillingCycles.advance(next, s.getBillingCycle(), s.getIntervalCount(), s.getIntervalUnit());
            }
            s.setNextRenewalAt(next);
            s.setUpdatedAt(now);
        }
        subRepo.saveAll(due);
        if (!due.isEmpty()) {
            System.out.println("[RenewalScheduler] Advanced renewal date of " + due.size() + " subscriptions");
        }
    }
}
