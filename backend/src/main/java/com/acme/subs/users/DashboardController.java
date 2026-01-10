package com.acme.subs.users;

import com.acme.subs.subscriptions.SubscriptionRepository;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@RestController
@RequestMapping("/v1/dashboard")
public class DashboardController {

    private final SubscriptionRepository subRepo;

    public DashboardController(SubscriptionRepository subRepo) {
        this.subRepo = subRepo;
    }

    @GetMapping("/summary")
    public Map<String, Object> summary(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();

        var subs = subRepo.findByUserIdAndActiveTrueOrderByNextRenewalAtAsc(userId);

        long monthlyTotalCents = 0;
        for (var s : subs) {
            monthlyTotalCents += estimateMonthlyCents(s.getAmountCents(), s.getBillingCycle(), s.getIntervalCount(), s.getIntervalUnit());
        }

        Instant now = Instant.now();
        Instant sevenDays = now.plus(7, ChronoUnit.DAYS);

        var next7 = subs.stream()
                .filter(s -> !s.getNextRenewalAt().isAfter(sevenDays))
                .limit(10)
                .toList();

        Map<String, Object> out = new HashMap<>();
        out.put("monthlyTotalCents", monthlyTotalCents);
        out.put("currency", "BRL");
        out.put("nextRenewals", next7);
        out.put("activeCount", subs.size());
        return out;
    }

    private long estimateMonthlyCents(int amountCents, String billingCycle, int intervalCount, String intervalUnit) {
        return switch (billingCycle) {
            case "MONTHLY" -> amountCents;
            case "YEARLY" -> Math.round(amountCents / 12.0);
            case "WEEKLY" -> Math.round(amountCents * 4.345); // média semanas/mês
            case "CUSTOM" -> {
                if ("YEAR".equalsIgnoreCase(intervalUnit)) yield Math.round(amountCents / (12.0 * intervalCount));
                // MONTH
                yield Math.round(amountCents / (double) intervalCount);
            }
            default -> amountCents;
        };
    }
}
