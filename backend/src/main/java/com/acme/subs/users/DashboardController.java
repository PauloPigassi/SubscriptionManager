package com.acme.subs.users;

import com.acme.subs.subscriptions.BillingCycles;
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
        long yearlyTotalCents = 0;
        // categoria normalizada (minúsculas) -> [monthlyCents, count]; null = sem categoria
        Map<String, long[]> byCategory = new HashMap<>();
        for (var s : subs) {
            long monthly = BillingCycles.monthlyCents(s.getAmountCents(), s.getBillingCycle(), s.getIntervalCount(), s.getIntervalUnit());
            monthlyTotalCents += monthly;
            yearlyTotalCents += BillingCycles.yearlyCents(s.getAmountCents(), s.getBillingCycle(), s.getIntervalCount(), s.getIntervalUnit());

            String category = s.getCategory() == null || s.getCategory().isBlank()
                    ? null
                    : s.getCategory().trim().toLowerCase();
            long[] acc = byCategory.computeIfAbsent(category, k -> new long[2]);
            acc[0] += monthly;
            acc[1] += 1;
        }

        List<Map<String, Object>> categoryBreakdown = new ArrayList<>();
        byCategory.entrySet().stream()
                .sorted((a, b) -> Long.compare(b.getValue()[0], a.getValue()[0]))
                .forEach(e -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("category", e.getKey());
                    item.put("monthlyCents", e.getValue()[0]);
                    item.put("count", e.getValue()[1]);
                    categoryBreakdown.add(item);
                });

        Instant now = Instant.now();
        Instant sevenDays = now.plus(7, ChronoUnit.DAYS);

        var next7 = subs.stream()
                .filter(s -> !s.getNextRenewalAt().isAfter(sevenDays))
                .limit(10)
                .toList();

        Map<String, Object> out = new HashMap<>();
        out.put("monthlyTotalCents", monthlyTotalCents);
        out.put("yearlyTotalCents", yearlyTotalCents);
        out.put("currency", "BRL");
        out.put("nextRenewals", next7);
        out.put("activeCount", subs.size());
        out.put("categoryBreakdown", categoryBreakdown);
        return out;
    }
}
