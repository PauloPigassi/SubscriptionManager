package com.acme.subs.subscriptions;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;

/**
 * Regras de ciclo de cobrança compartilhadas (avanço de renovação e estimativas de gasto).
 * billingCycle: MONTHLY/YEARLY/WEEKLY/CUSTOM; para CUSTOM usa intervalCount + intervalUnit (MONTH/YEAR).
 */
public final class BillingCycles {

    private BillingCycles() {}

    /** Próxima data de cobrança após {@code from}, seguindo o ciclo da assinatura. */
    public static Instant advance(Instant from, String billingCycle, int intervalCount, String intervalUnit) {
        ZonedDateTime d = from.atZone(ZoneOffset.UTC);
        int count = Math.max(1, intervalCount);
        ZonedDateTime next = switch (billingCycle) {
            case "YEARLY" -> d.plusYears(1);
            case "WEEKLY" -> d.plusWeeks(1);
            case "CUSTOM" -> "YEAR".equalsIgnoreCase(intervalUnit) ? d.plusYears(count) : d.plusMonths(count);
            default -> d.plusMonths(1); // MONTHLY
        };
        return next.toInstant();
    }

    public static long monthlyCents(int amountCents, String billingCycle, int intervalCount, String intervalUnit) {
        int count = Math.max(1, intervalCount);
        return switch (billingCycle) {
            case "MONTHLY" -> amountCents;
            case "YEARLY" -> Math.round(amountCents / 12.0);
            case "WEEKLY" -> Math.round(amountCents * 4.345); // média semanas/mês
            case "CUSTOM" -> {
                if ("YEAR".equalsIgnoreCase(intervalUnit)) yield Math.round(amountCents / (12.0 * count));
                // MONTH
                yield Math.round(amountCents / (double) count);
            }
            default -> amountCents;
        };
    }

    public static long yearlyCents(int amountCents, String billingCycle, int intervalCount, String intervalUnit) {
        int count = Math.max(1, intervalCount);
        return switch (billingCycle) {
            case "MONTHLY" -> amountCents * 12L;
            case "YEARLY" -> amountCents;
            case "WEEKLY" -> amountCents * 52L;
            case "CUSTOM" -> {
                if ("YEAR".equalsIgnoreCase(intervalUnit)) yield Math.round(amountCents / (double) count);
                // MONTH
                yield Math.round(amountCents * 12.0 / count);
            }
            default -> amountCents * 12L;
        };
    }
}
